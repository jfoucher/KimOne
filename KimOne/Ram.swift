//
//  Ram.swift
//  KimOne
//
//  Created by Jonathan Foucher on 21/07/2021.
//  Copyright © 2021 Jonathan Foucher. All rights reserved.
//

import Foundation

class Ram: Codable {
    private var data: [UInt8]
    
    private let size: UInt
    private let max: UInt16
    
    private let queue = DispatchQueue(label: "Ram")
    
    enum CodingKeys: CodingKey {
        case data
        case size
        case max
    }
    
    subscript(address: UInt16) -> UInt8 {
        get {
            var result: UInt8!
            queue.sync {
                result = data[Int(address & self.max)]
            }
            
            return result
        }
        set {
            queue.async {
                self.data[Int(address & self.max)] = newValue
            }
        }
    }
    
    init(size: UInt) {
        self.size = size
        self.max = UInt16(size - 1)
        self.data = [UInt8](repeating: 0x00, count: Int(self.size))
    }
}
