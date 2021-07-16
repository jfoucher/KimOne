//
//  File.swift
//  Cesium
//
//  Created by Jonathan Foucher on 14/07/2021.
//  Copyright © 2021 Jonathan Foucher. All rights reserved.
//

import Foundation
import UIKit


class DigitView: UIView {
    var value: UInt8 = 0
    
    var layers: [CAShapeLayer]
    
    override init(frame: CGRect){
        self.layers = [CAShapeLayer(), CAShapeLayer(), CAShapeLayer(), CAShapeLayer(), CAShapeLayer(), CAShapeLayer(), CAShapeLayer()]
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        self.layers = [CAShapeLayer(), CAShapeLayer(), CAShapeLayer(), CAShapeLayer(), CAShapeLayer(), CAShapeLayer(), CAShapeLayer()]
        super.init(coder: aDecoder)
        setup()
    }
    
    func showDigit(digit: UInt8) {
        let segments = getActiveSegments(digit: digit)
        
        for (i, l) in self.layers.enumerated() {
            if (segments[i]) {
                l.fillColor = UIColor.red.cgColor
            } else {
                l.fillColor = UIColor(red: 0.25, green: 0.15, blue: 0.15, alpha: 1).cgColor
            }
        }
    }
    
    func setup() {
        // Create a CAShapeLayer
        let grey = UIColor(red: 0.25, green: 0.15, blue: 0.15, alpha: 1).cgColor
        self.layers[0].path = createSidePath(w:18, h:40, flipH: true).cgPath
        self.layers[0].fillColor = grey
        self.layers[0].position = CGPoint(x: 20, y: 10)
        //shapeLayer.transform = CATransform3DMakeRotation(CGFloat(Double.pi), 0.0, 0.0, 1.0)
        
        self.layer.addSublayer(self.layers[0])
        
        
        
        self.layers[1].path = createTopPath(w:29, h:10).cgPath
        self.layers[1].fillColor = grey
        self.layers[1].position = CGPoint(x: 38, y: 10)
        
        self.layer.addSublayer(self.layers[1])
        
        
        self.layers[2].path = createSidePath(w:18, h:40, flipH: false).cgPath
        self.layers[2].fillColor = grey
        self.layers[2].position = CGPoint(x: 60, y: 10)
        //shapeLayer.transform = CATransform3DMakeRotation(CGFloat(Double.pi), 0.0, 0.0, 1.0)
        
        self.layer.addSublayer(self.layers[2])
        
        self.layers[3] = CAShapeLayer()
        
        self.layers[3].path = createMiddlePath(w:38, h:10).cgPath
        self.layers[3].fillColor = grey
        self.layers[3].position = CGPoint(x: 25.5, y: 46)
        //shapeLayer.transform = CATransform3DMakeRotation(CGFloat(Double.pi), 0.0, 0.0, 1.0)
        
        self.layer.addSublayer(self.layers[3])
        
        
        self.layers[4] = CAShapeLayer()
        
        self.layers[4].path = createSidePath(w:18, h:40, flipH: false).cgPath
        self.layers[4].fillColor = grey
        self.layers[4].position = CGPoint(x: 29, y: 92)
        self.layers[4].transform = CATransform3DMakeRotation(CGFloat(Double.pi), 0.0, 0.0, 1.0)
        
        self.layer.addSublayer(self.layers[4])
        
        self.layers[5] = CAShapeLayer()
        
        self.layers[5].path = createTopPath(w:29, h:10).cgPath
        self.layers[5].fillColor = grey
        self.layers[5].position = CGPoint(x: 22, y: 82)
        
        self.layer.addSublayer(self.layers[5])
        
        self.layers[6] = CAShapeLayer()
        
        self.layers[6].path = createSidePath(w:18, h:40, flipH: true).cgPath
        self.layers[6].fillColor = grey
        self.layers[6].position = CGPoint(x: 69, y: 92)
        self.layers[6].transform = CATransform3DMakeRotation(CGFloat(Double.pi), 0.0, 0.0, 1.0)
        
        self.layer.addSublayer(self.layers[6])
    }
    
    func createMiddlePath(w: CGFloat, h: CGFloat) -> UIBezierPath {
        // create a new path
        let path = UIBezierPath()
        
        // move to start
        path.move(to: CGPoint(x: 6, y: 0))
        path.addLine(to: CGPoint(x: w-5, y: 0))

        path.addLine(to: CGPoint(x: w, y: h/2-0.5))
        path.addLine(to: CGPoint(x: w-6, y: h))

        path.addLine(to: CGPoint(x: 5, y: h))

        path.addLine(to: CGPoint(x: 0, y: h/2+0.5))
        path.close()
        
        return path
    }
    
    func createTopPath(w: CGFloat, h: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 2.4, y: 0))
        path.addLine(to: CGPoint(x: w, y: 0))

        path.addLine(to: CGPoint(x: w-2.4, y: h))

        path.addLine(to: CGPoint(x: 0, y: h))

        path.addLine(to: CGPoint(x: 2.4, y: 0))
        
        return path
    }
    
    
    func createSidePath(w: CGFloat, h: CGFloat, flipH: Bool = false) -> UIBezierPath {
        // create a new path
        let path = UIBezierPath()
        
        let startTop: CGFloat = flipH ? w+1 : w/2
        let movX: CGFloat = flipH ? -4 : 3
        let centerY: CGFloat = w/2-3
        let centerX: CGFloat = flipH ? startTop-5 : startTop + movX
        let radius: CGFloat = w/2-3
        let movY: CGFloat = flipH ? -5 : 4
        let bottomX = flipH ? 0 : w/2
        let bottom2X = flipH ? w/2+2 : 0
        let bottom2Y = flipH ? h-w/2-movY-1 : h-w/2+movY
        
        let startA: Double = (-Double.pi/2)
        let endA: Double = flipH ? (-Double.pi) : 0

        // move to start
        path.move(to: CGPoint(x: startTop, y: 0))
        path.addLine(to: CGPoint(x: centerX, y: 0))
        path.addArc(withCenter: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: CGFloat(startA), endAngle: CGFloat(endA), clockwise: !flipH)

        
        path.addLine(to: CGPoint(x: bottomX, y: h))

        path.addLine(to: CGPoint(x: bottomX-movY, y: h))
        path.addLine(to: CGPoint(x: bottom2X, y: bottom2Y))
            
        path.close() // draws the final line to close the path
        
        return path
    }
    
    
    func getActiveSegments(digit: UInt8, point: Bool = false) -> [Bool] {
        var activeSegments: [Bool] = [
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false
        ];
        if (digit == 0) {
            activeSegments = [
                true,
                true,
                true,
                false,
                true,
                true,
                true,
                false
            ]
        } else if (digit == 1) {
            activeSegments =  [
                false,
                false,
                true,
                false,
                false,
                false,
                true,
                false
            ]
        } else if (digit == 2) {
            activeSegments =  [
                false,
                true,
                true,
                true,
                true,
                true,
                false,
                false
            ]
        } else if (digit == 3) {
            activeSegments =  [
                false,
                true,
                true,
                true,
                false,
                true,
                true,
                false
            ]
        } else if (digit == 4) {
            activeSegments =  [
                true,
                false,
                true,
                true,
                false,
                false,
                true,
                false
            ]
        } else if (digit == 5) {
            activeSegments =  [
                true,
                true,
                false,
                true,
                false,
                true,
                true,
                false
            ]
        }
        else if (digit == 6) {
            activeSegments =  [
               true,
               true,
               false,
               true,
               true,
               true,
               true,
               false
           ]
        } else if (digit == 7) {
            activeSegments =  [
                false,
                true,
                true,
                false,
                false,
                false,
                true,
                false
            ]
        } else if (digit == 8) {
            activeSegments =  [
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                false
            ]
        } else if (digit == 9) {
            activeSegments =  [
                true,
                true,
                true,
                true,
                false,
                true,
                true,
                false
            ]
        } else if (digit == 10) {
           activeSegments =  [
               true,
               true,
               true,
               true,
               true,
               false,
               true,
               false
           ]
        } else if (digit == 11) {
            activeSegments =  [
                true,
                false,
                false,
                true,
                true,
                true,
                true,
                false
            ]
        } else if (digit == 12) {
            activeSegments =  [
                true,
                true,
                false,
                false,
                true,
                true,
                false,
                false
            ]
        } else if (digit == 13) {
            activeSegments =  [
                false,
                false,
                true,
                true,
                true,
                true,
                true,
                false
            ]
        } else if (digit == 14) {
            activeSegments =  [
                true,
                true,
                false,
                true,
                true,
                true,
                false,
                false
            ]
        } else if (digit == 15) {
            activeSegments =  [
                true,
                true,
                false,
                true,
                true,
                false,
                false,
                false
            ]
        }
        
        if (point) {
            activeSegments[7] = true;
        }
        
        return activeSegments
    }
}
