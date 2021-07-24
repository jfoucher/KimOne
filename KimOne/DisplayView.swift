//
//  DisplayView.swift
//  KimOne
//
//  Created by Jonathan Foucher on 16/07/2021.

//The MIT License (MIT)
//
//Copyright © 2021 Jonathan FOUCHER
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import UIKit

class DisplayView: UIView {
    override func didAddSubview(_ subview: UIView) {
        // This is to scale the display on large screen
        let screenWidth = self.bounds.width
        
        let totalWidth = CGFloat(70.0*5.0+95.0);
        
        let ratio = screenWidth / totalWidth
        
        for (i, d) in digits.enumerated() {
            var s = 70.0;
            if (i == 4) {
                s=74.0
            }
            if (i == 5) {
                s=73.0
            }
            
            d.view.transform = CGAffineTransform(scaleX: ratio, y: ratio)
            
            d.view.frame = CGRect(x: (CGFloat(s)*CGFloat(i)*ratio), y: 0, width: 85*ratio, height: 110*ratio)
        }
    }
}
