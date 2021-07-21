//
//  ProcessorInterface.swift
//  KimOne
//
//  Created by Jonathan Foucher on 16/07/2021.
//  Copyright © 2021 Jonathan Foucher. All rights reserved.
//

import Foundation

var memory: Ram = Ram(size: 64*1024)

var serialBuffer: Ram = Ram(size: 256)
var serialCharsWaiting: UInt16 = 0;

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
        val = riot0.ram[addr - riot0.ramBaseAddress]
        //print(String(format: "Read riot 0 RAM ad: %04X v: %02X", address, val))
    } else if (addr >= riot1.ramBaseAddress && addr < riot1.ramBaseAddress + 64) {
        val = riot1.ram[addr - riot1.ramBaseAddress]
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
        val = memory[address]
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
        riot0.ram[addr - riot0.ramBaseAddress] = value
    } else if (addr >= riot1.ramBaseAddress && addr < riot1.ramBaseAddress + 64) {
        //print(String(format: "Write riot 1 RAM ad: %04X v: %02X", address, value))
        riot1.ram[addr - riot1.ramBaseAddress] = value
    } else if ((addr >= riot0.romBaseAddress && addr < riot0.romBaseAddress + 1024) || (addr >= riot1.romBaseAddress && addr < riot1.romBaseAddress + 1024) || (addr >= 0xFF00)) {
        // ROM, do nothing
    } else {
        //print(String(format: "Write mem ad: %04X v: %02X", address, value))
        memory[address] = value
    }
}

class ProcessorInterface {
    private let queue = DispatchQueue(label: "Processor")
    
    private var _singleStep: Bool = false
    
    var singleStep: Bool {
        get {
            var a: Bool!
            queue.sync {
                a = self._singleStep
            }
            
            return a
        }
        set {
            queue.sync {
                _singleStep = newValue
            }
        }
    }
    
    var ticks: UInt64 {
        get {
            var a: UInt64!
            queue.sync {
                a = clockticks6502
            }
            
            return a
        }
        set {
            queue.sync {
                clockticks6502 = newValue
            }
        }
    }
    
    func reset() {
        queue.sync {
            reset6502()
        }
    }
    
    func nmi() {
        queue.sync {
            nmi6502()
        }
    }
    
    func step() {
        //queue.sync {
            step6502()
        //}
    }
    
    func resetSpeed() {
        queue.sync {
            clockticks6502 = 0
            prevTicks = 0
        }
    }
    
    func handlePC() {
        queue.sync {
            if ((pc == 0x1f79) || (pc == 0x1f90)) {
                // If we get to the place where a character has been read,
                // clear out the pending keyboard character.
                
                riot0.charPending = 0x15;
            } else if ((pc == 0x1E65)) {
                pc = 0x1e85;
                a = 0
                if (serialCharsWaiting > 0) {
                    let v = serialBuffer[serialCharsWaiting-1]
                    serialCharsWaiting -= 1
                    a = v
                    print("read from serial", v)
                }
                
                y = 0xff;
            }
        }
    }
    
    func runOneStep() {
        // Flag for NMI when single stepping or when ST is pressed
        var nmiFlag: Bool = false;
        
        // If the single step switch is on and we are in RAM
        // Turn the nmi flag on
        if (self.singleStep && ((pc < 0x1C00) || (pc >= 0x2000))) {
            print("single step", self.singleStep)
            nmiFlag = true;
        }
        
        //Run the current instruction
        self.step()
        
        if (nmiFlag) {
            // If we have an nmi, go to the nmi handler now
            nmiFlag = false;
            self.nmi();
        }
        
        handlePC()
    }
}


