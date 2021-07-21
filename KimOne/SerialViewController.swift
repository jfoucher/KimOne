//
//  SerialViewController.swift
//  KimOne
//
//  Created by Jonathan Foucher on 17/07/2021.
//  Copyright © 2021 Jonathan Foucher. All rights reserved.
//

import Foundation
import UIKit

protocol TextReceiverDelegate:class {
    func addText(char: UInt8)
}

class SerialViewController: UIViewController, UITextViewDelegate, TextReceiverDelegate, UIDocumentPickerDelegate {

    var text = ""
    var previousText = "aaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    let processorInterface: ProcessorInterface
    
    let textView = UITextView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
    
    @IBOutlet weak var serialText: UITextView!
    
    @IBAction func paperFile(_ sender: Any) {
        let documentPickerController = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true)
        textView.becomeFirstResponder()
    }

    init(with processorInterface: ProcessorInterface) {
        self.processorInterface = processorInterface
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        self.processorInterface = ProcessorInterface()
        super.init(coder: aDecoder)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let file = urls[0];
        // Send file to serial port of Kim-1
        //reading
        self.textView.becomeFirstResponder()
        do {
            
            let text = try String(contentsOf: file, encoding: .ascii)
            
            for char in text {
                if let f = char.unicodeScalars.first {
                    let v = UInt8(f.value & 0xFF)
                    dispatchQueue.sync(flags: .barrier) {
                        usleep(1000)
                        if (v == 0x0D || v == 0x0A) {
                            // Wait a while for lines
                            usleep(20000)
                        }
                        if (serialCharsWaiting > 128) {
                            // If many chars in buffer, wait a while
                            usleep(10000)
                        }
                        print("sending",serialCharsWaiting, char, v)
                        serialBuffer[serialCharsWaiting] = v
                        serialCharsWaiting = (serialCharsWaiting + 1) & 0xFF
                    }
                }
            }
        }
        catch {/* error handling here */}
        
    }
    
    override func viewDidLoad() {
        print("serial view controller view did load")
        serialText.textContainerInset.left = 10
        serialText.textContainerInset.right = 10
        serialText.textContainerInset.top = 10
        serialText.textContainerInset.bottom = 10
        serialText.clipsToBounds = true;
        serialText.layer.cornerRadius = 10.0;
        
        serialText.isEditable = true
        
        
        // Hidden textview to make keyboard appear
        
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.keyboardType = .alphabet
        textView.keyboardAppearance = .dark
        // Init with some text to be able to type delete
        textView.text = "aaaaaaaaaaaaaaaaaaaaaaaaaaaa"

        textView.delegate = self
        textView.becomeFirstResponder()
        self.view.addSubview(textView)

        dispatchQueue.sync(flags: .barrier) {
            riot0.delegate = self
            riot0.serial = true
        }
        
        
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
         //the textView parameter is the textView where text was changed
        
        if (textView.text.count < previousText.count) {
            // Delete key was pressed, trigger it on Kim

            dispatchQueue.sync(flags: .barrier) {
                serialBuffer[serialCharsWaiting] = 0x7F
                serialCharsWaiting = (serialCharsWaiting + 1) & 0xFF
                print(serialCharsWaiting)
            }
        }
        if (textView.text.count > previousText.count) {
            if let character = textView.text.last {
                if let f = character.unicodeScalars.first {
                    var v = UInt8(f.value & 0xFF)
                    if (f.value == 8220 || f.value == 8221) {
                        // Replace smart quotes
                        v = 34
                    } else if (v >= 0x61 && v <= 0x7A) {
                        // convert lowercase to uppercase
                        v -= 0x20
                    } else if (v == 0x5E) {
                        // Convert ^ to CR to enable stepping backwards
                        v = 10
                    }else if (v == 10) {
                        v = 13
                    }
                    
                    // Add text to serial monitor, unless its return
                    // print("sending to kim", v)
                    if (v != 13 && v != 10) {
                        if let c = String(bytes: [v], encoding: .ascii) {
                            self.serialText.text.append(c)
                        } else {
                            print("could not convert", v, "to ascii")
                        }
                    }
                
                    
                    dispatchQueue.sync(flags: .barrier) {
                        serialBuffer[serialCharsWaiting] = v
                        serialCharsWaiting = (serialCharsWaiting + 1) & 0xFF
                    }
                }
                
            }
            
        }
        
        previousText = textView.text
    }
    
    func addText(char: UInt8) {
        if let v = String(bytes: [char], encoding: .ascii) {
            self.serialText.text.append(v)
        } else {
            print("could not convert", char, "to ascii")
        }
        
        if (char == 10 || char == 13) {
            //try and make it really scroll to the bottom
            let range = NSMakeRange(self.serialText.text.count*2, 1)
            self.serialText.scrollRangeToVisible(range)
        }
    }
    
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool{
        return true
    }
}
