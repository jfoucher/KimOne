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
   func addText()
}

class SerialViewController: UIViewController, UITextViewDelegate {

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
        serialText.delegate = self
        
        riot0.serial = true
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
         //the textView parameter is the textView where text was changed
        if (textView.text.count < previousText.count) {
            // Delete key was pressed, trigger it on Kim
            
        }
        if (textView.text.last! == "\n") {
            var lines = textView.text.components(separatedBy: "\n")
            lines.removeLast()
            let lastLine = lines.last ?? ""
            print(lastLine);
        }
        
        previousText = textView.text
    }
    
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool{
        return true
    }
}
