//
//  LoadViewController.swift
//  KimOne
//
//  Created by Jonathan Foucher on 20/07/2021.
//  Copyright © 2021 Jonathan Foucher. All rights reserved.
//

import Foundation
import UIKit

class LoadViewController: UIViewController, UIDocumentPickerDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var startAddress: UITextField!
    
    @IBAction func choosefileClicked(_ sender: Any) {
        print("text", textView.text)
        print("address", startAddress.text)
        
        let bytes = textView.text.components(separatedBy: " ")
        
        if let ad = self.startAddress.text {
            if let start = UInt16(ad, radix: 16) {
                for i in 0...bytes.count-1 {
                    if let b = UInt8(bytes[i], radix: 16) {
                        memory[Int(start) + i] = b
                    } else {
                        print(String(format: "byte %d is not a hex integer", i))
                    }
                }
            } else {
                print("Address is not a hex integer")
            }
        } else {
            print("Address is not defined")
        }
        
        
    }
    
    override func viewDidLoad() {
        self.textView.layer.borderWidth = 1.0
        self.textView.layer.borderColor = UIColor.darkGray.cgColor
        self.textView.layer.cornerRadius = 8
        self.textView.textContainerInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    }
    
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool{
        return true
    }
}
