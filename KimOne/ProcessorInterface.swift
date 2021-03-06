//
//  ProcessorInterface.swift
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

var memory:[UInt8] = [UInt8](repeating: 0x00, count: Int(64*1024))

struct Queue<T> {
  private var elements: [T] = []

  mutating func enqueue(_ value: T) {
    elements.append(value)
  }

  mutating func dequeue() -> T? {
    guard !elements.isEmpty else {
      return nil
    }
    return elements.removeFirst()
  }

  var head: T? {
    return elements.first
  }

  var tail: T? {
    return elements.last
  }
}

var serialBuffer: Queue<UInt8> = Queue<UInt8>()

var prev1: UInt8 = 0xFF
var prev2: UInt8 = 0xFF
var prev3: UInt8 = 0xFF

@_cdecl("ReadCallback")
func read6502Swift(address: UInt16) -> UInt8 {
    var val: UInt8
    let  addr = address;
    if (addr == 0x1F1F) {
        // SCAND routine, show characters
        pc = 0x1F45;    // skip subroutine part that deals with LEDs
        let c1 = memory[0x00FB]
        if (c1 != prev1 && riot0.serial == false) {
            prev1 = c1;
            DispatchQueue.main.async {
                digits[0].view.showDigit(digit: ((c1 & 0xF0) >> 4))
                digits[1].view.showDigit(digit: (c1 & 0x0F))
            }
        }
        let c2 = memory[0x00FA]
        if (c2 != prev2 && riot0.serial == false) {
            prev2 = c2;
            DispatchQueue.main.async {
                digits[2].view.showDigit(digit: ((c2 & 0xF0) >> 4))
                digits[3].view.showDigit(digit: (c2 & 0x0F))
            }
        }
        let c3 = memory[0x00F9]
        if (c3 != prev3 && riot0.serial == false) {
            prev3 = c3;
            DispatchQueue.main.async {
                digits[4].view.showDigit(digit: ((c3 & 0xF0) >> 4))
                digits[5].view.showDigit(digit: (c3 & 0x0F))
            }
        }
        
        return (0xEA);
    } else if (addr >= riot0.baseAddress && addr < riot0.baseAddress + 8) {
        val = riot0.read(address: addr)
        //print(String(format: "Read riot 0 registers ad: %04X v: %02X", address, val))
    } else if (addr >= riot1.baseAddress && addr < riot1.baseAddress + 8) {
        val = riot1.read(address: addr)
        //print(String(format: "Read riot 1 registers ad: %04X v: %02X", address, val))
    } else if (addr >= riot0.ramBaseAddress && addr < riot0.ramBaseAddress + 64) {
        val = riot0.ram[Int(addr - riot0.ramBaseAddress)]
        //print(String(format: "Read riot 0 RAM ad: %04X v: %02X", address, val))
    } else if (addr >= riot1.ramBaseAddress && addr < riot1.ramBaseAddress + 64) {
        val = riot1.ram[Int(addr - riot1.ramBaseAddress)]
        //print(String(format: "Read riot 1 RAM ad: %04X v: %02X", address, val))
    } else if (addr >= riot0.romBaseAddress && addr < riot0.romBaseAddress + 1024) {
        val = riot0.rom[Int(addr - riot0.romBaseAddress)]
        //print(String(format: "Read riot 0 ROM ad: %04X v: %02X", address, val))
    } else if (addr >= riot1.romBaseAddress && addr < riot1.romBaseAddress + 1024) {
        val = riot1.rom[Int(addr - riot1.romBaseAddress)]
        //print(String(format: "Read riot 1 ROM ad: %04X v: %02X", address, val))
    } else if (addr >= 0xFF00) {
        val = riot0.rom[Int(addr - 0xFC00)]
        //print(String(format: "Read riot 0 ROM ad: %04X v: %02X", address, val))
    } else {
        val = memory[Int(address)]
        //print(String(format: "Read MEMORY ad: %04X v: %02X", address, val))
    }
    
//    print(String(format: "read ad: %04X v: %02X", addr, val))
    
    return val
}

@_cdecl("WriteCallback")
func write6502Swift(address: UInt16, value: UInt8) {
    let  addr = address;
    if (addr >= riot0.baseAddress && addr < riot0.baseAddress + 8) {
        //print(String(format: "Write riot 0 registers ad: %04X v: %02X", address, value))
        riot0.write(address: addr, value: value)
    } else if (addr >= riot1.baseAddress && addr < riot1.baseAddress + 8) {
        //print(String(format: "Write riot 1 registers ad: %04X v: %02X", address, value))
        riot1.write(address: addr, value: value)
    } else if (addr >= riot0.ramBaseAddress && addr < riot0.ramBaseAddress + 64) {
        //print(String(format: "Write riot 0 RAM ad: %04X v: %02X", address, value))
        riot0.ram[Int(addr - riot0.ramBaseAddress)] = value
    } else if (addr >= riot1.ramBaseAddress && addr < riot1.ramBaseAddress + 64) {
        //print(String(format: "Write riot 1 RAM ad: %04X v: %02X", address, value))
        riot1.ram[Int(addr - riot1.ramBaseAddress)] = value
    } else if ((addr >= riot0.romBaseAddress && addr < riot0.romBaseAddress + 1024) || (addr >= riot1.romBaseAddress && addr < riot1.romBaseAddress + 1024) || (addr >= 0xFF00)) {
        // ROM, do nothing
    } else {
        //print(String(format: "Write mem ad: %04X v: %02X", address, value))
        memory[Int(address)] = value
    }
}
