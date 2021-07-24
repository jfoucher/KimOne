//
//  SerialViewController.swift
//  KimOne
//
//  Created by Jonathan Foucher on 17/07/2021.
//  Copyright © 2021 Jonathan Foucher. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol TextReceiverDelegate:class {
    func addText(char: UInt8)
}

class SerialViewController: UIViewController, UITextViewDelegate, TextReceiverDelegate, UIDocumentPickerDelegate {
    var audioPlayer = AVAudioPlayer()

    var cancelSend = false
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
        dispatchQueue.sync{
            self.cancelSend = false
        }
        
        do {
            let text = try String(contentsOf: file, encoding: .ascii)
            
            dispatchQueue.async {
                var line = ""
                for char in text {
                    if self.cancelSend == true {
                       return
                    }
                    if let f = char.unicodeScalars.first {
                        let v = UInt8(f.value & 0xFF)
                        
                        
                        if let c = String(bytes: [v], encoding: .ascii) {
                            line = line + c
                        } else {
                            print("could not convert", v, "to ascii")
                        }
                        
                        if (v == 0x0D || v == 0x0A) {
                            DispatchQueue.main.sync {
                                self.serialText.text.append(line)
                                let range = NSMakeRange(self.serialText.text.count, 1)
                                self.serialText.scrollRangeToVisible(range)
                            }
                            
                            line = ""
                        }
                        
                        //usleep(100)
                        
                        serialQueue.sync {
                            //print("sending", char, v)
                            serialBuffer.enqueue(v)
                        }
                    }
                }
                
                DispatchQueue.main.sync {
                    self.serialText.text.append("\n\n")
                    let range = NSMakeRange(self.serialText.text.count, 1)
                    self.serialText.scrollRangeToVisible(range)
                }
                
            }
            
        }
        catch {/* error handling here */}
        
        self.textView.becomeFirstResponder()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        dispatchQueue.async {
            self.cancelSend = true
        }
    }
    
    override func viewDidLoad() {
        let bellSound = URL(fileURLWithPath: Bundle.main.path(forResource: "bell", ofType: "m4a")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: bellSound)
        }catch{}
        
        dispatchQueue.async {
            self.cancelSend = false
        }
        serialText.textContainerInset.left = 10
        serialText.textContainerInset.right = 10
        serialText.textContainerInset.top = 10
        serialText.textContainerInset.bottom = 10
        serialText.clipsToBounds = true;
        serialText.layer.cornerRadius = 10.0;
        
        serialText.isEditable = true
        
        serialText.contentSize = CGSize(width: 800, height: serialText.frame.size.height)
        
        
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
                serialBuffer.enqueue(0x7F)
            }
            
//            if (serialText.text.count > 0) {
//                serialText.text.removeLast()
//            }
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
//                        print("sending", character, v)
                        serialBuffer.enqueue(v)
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
        if (char == 7) {
            dispatchQueue.async {
                self.audioPlayer.play()
            }
        }else if (char == 10 || char == 13) {
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
