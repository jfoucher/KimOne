//
//  HelpViewController.swift
//  KimOne
//
//  Created by Jonathan Foucher on 17/07/2021.
//  Copyright © 2021 Jonathan Foucher. All rights reserved.
//

import Foundation

import UIKit


class HelpViewController: UIViewController, UITextViewDelegate {
    
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Help view controller view did load")
        
        if let rtfPath = Bundle.main.url(forResource: "manual", withExtension: "rtf") {
            do {
                let attributedStringWithRtf: NSAttributedString = try NSAttributedString(url: rtfPath, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                self.textView.attributedText = attributedStringWithRtf
            } catch let error {
                print("Got an error \(error)")
            }
        }
        
        
        
    }
    // Hide status bar
    override var prefersStatusBarHidden: Bool{
        return true
    }
}


