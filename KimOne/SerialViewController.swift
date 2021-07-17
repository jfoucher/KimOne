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

class SerialViewController: UIViewController, UITextViewDelegate, TextReceiverDelegate {

    var text = ""
    var previousText = ""
    
    @IBOutlet weak var serialText: UITextView!
    
    override func viewDidLoad() {
        serialText.textContainerInset.left = 10
        serialText.textContainerInset.right = 10
        serialText.textContainerInset.top = 10
        serialText.textContainerInset.bottom = 10
        serialText.clipsToBounds = true;
        serialText.layer.cornerRadius = 10.0;
        
        serialText.isEditable = true
        
        
        // Hidden textview to make keyboard appear
        let textView = UITextView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
        
        textView.delegate = self
        textView.becomeFirstResponder()
        self.view.addSubview(textView)
//        riot0.charPending = 0x15
//        if (start.uptimeNanoseconds > 1000) {
//            reset6502()
//            start = DispatchTime.now()
//        }
        riot0.serial = true
        
        riot0.delegate = self
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
         //the textView parameter is the textView where text was changed
        if (textView.text.count < previousText.count) {
            // Delete key was pressed, trigger it on Kim
            print("delete")
            dispatchQueue.sync {
                serialBuffer[serialCharsWaiting] = 0x7F
                serialCharsWaiting = (serialCharsWaiting + 1) & 0xFF
                print(serialCharsWaiting)
            }
        }
        if (textView.text.count > previousText.count) {
            if let character = textView.text.last {
                if let f = character.unicodeScalars.first {
                    
                    var v = UInt8(f.value & 0xFF)
                    // convert lowercase to uppercase
                    if (v >= 0x61 && v <= 0x74) {
                        v -= 0x20
                    }
                    // Convert + to LF to enable stepping forwards
                    if (v == 43) {
                        v = 13
                    }
                    
                    // Add text to serial monitor, unless its return
                    if (v != 13 && v != 10) {
                        self.serialText.text.append(Character(UnicodeScalar(v)))
                        let range = NSMakeRange(self.serialText.text.count - 2, 1)
                        self.serialText.scrollRangeToVisible(range)
                    }
                
                    
                    dispatchQueue.sync {
                        serialBuffer[serialCharsWaiting] = v
                        serialCharsWaiting = (serialCharsWaiting + 1) & 0xFF
                    }
                }
                
            }
            
        }
        
        previousText = textView.text
    }
    
    func addText(char: UInt8) {
        self.serialText.text.append(Character(UnicodeScalar(char)))
        let range = NSMakeRange(self.serialText.text.count - 2, 1)
        self.serialText.scrollRangeToVisible(range)
    }
    
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool{
        return true
    }
}
