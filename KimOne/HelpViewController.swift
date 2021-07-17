//
//  HelpViewController.swift
//  KimOne
//
//  Created by Jonathan Foucher on 17/07/2021.
//  Copyright © 2021 Jonathan Foucher. All rights reserved.
//

import Foundation

import UIKit
import WebKit

class HelpViewController: UIViewController, UITextViewDelegate {
    
    
    @IBOutlet weak var webview: UIWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = Bundle.main.url(forResource: "help", withExtension: "html") {
            webview.loadRequest(URLRequest(url: url))
        }
    }
    // Hide status bar
    override var prefersStatusBarHidden: Bool{
        return true
    }
}
