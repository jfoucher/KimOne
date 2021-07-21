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
    
    let textView = UITextView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
    
    @IBOutlet weak var serialText: UITextView!
    
    @IBAction func paperFile(_ sender: Any) {
        self.textView.resignFirstResponder()
        let documentPickerController = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let file = urls[0];
        // Send file to serial port of Kim-1
        //reading
        
        do {
            
            let text = try String(contentsOf: file, encoding: .ascii)
            
            dispatchQueue.async {
                var line = ""
                for char in text {
                    
                    if let f = char.unicodeScalars.first {
                        let v = UInt8(f.value & 0xFF)
                        
                        
                        if let c = String(bytes: [v], encoding: .ascii) {
                            line = line + c
                        } else {
                            print("could not convert", v, "to ascii")
                        }
                        
                        if (v == 0x0D || v == 0x0A) {
                            print(line)
                            DispatchQueue.main.sync {
                                self.serialText.text.append(line)
                                self.textView.text.append(line)
                                let range = NSMakeRange(self.serialText.text.count*2, 1)
                                self.serialText.scrollRangeToVisible(range)
                            }
                            
                            line = ""
                        }
                        
                        usleep(200)
                        
                        var w: Int!
                        
                        serialQueue.sync {
                            print("sending",serialCharsWaiting, char, v)
                            serialBuffer[serialCharsWaiting] = v
                            serialCharsWaiting = (serialCharsWaiting + 1)
                            
                            w = serialCharsWaiting
                        }
                        
                        if w > 5 {
                            usleep(1000*UInt32(w*w))
                        }
                    }
                }
            }
            
        }
        catch {/* error handling here */}
        
        self.textView.becomeFirstResponder()
        
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

        riot0.delegate = self
        
        serialQueue.async {
            
            riot0.serial = true
        }
        
        
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
         //the textView parameter is the textView where text was changed
        
        if (textView.text.count < previousText.count) {
            // Delete key was pressed, trigger it on Kim

            serialQueue.async {
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
                
                    
                    serialQueue.async {
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
            self.textView.text.append(v)
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
