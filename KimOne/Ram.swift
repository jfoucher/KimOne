//
//  Ram.swift
//  KimOne
//
//  Created by Jonathan Foucher on 21/07/2021.
//  Copyright © 2021 Jonathan Foucher. All rights reserved.
//

import Foundation

class Ram {
    private var data = [UInt8]()
    
    private let queue = DispatchQueue(label: "Ram")
    
    subscript(address: UInt16) -> UInt8 {
        get {
            var result: UInt8!
            queue.sync {
                result = data[Int(address)]
            }
            
            return result
        }
        set {
            queue.async {
                self.data[Int(address)] = newValue
            }
        }
    }
}
