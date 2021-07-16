//
//  DisplayView.swift
//  KimOne
//
//  Created by Jonathan Foucher on 16/07/2021.
//  Copyright © 2021 Jonathan Foucher. All rights reserved.
//

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
