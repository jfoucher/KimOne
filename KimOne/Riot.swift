//
//  Riot.swift
//  KimOne
//
//  Created by Jonathan Foucher on 15/07/2021.
//

import Foundation

struct TIMER {
    var timer_mult:UInt16
    var tick_accum: UInt16
    var start_value: UInt8
    var timer_count: UInt8
    var timeout: UInt8

    var starttime: UInt64;
}


class Riot: Codable {
    var rom:[UInt8] = [UInt8](repeating: 0, count: Int(1024))
    var ram: [UInt8] = [UInt8](repeating: 0, count: Int(64))
    var padd: UInt8 = 0
    var sad: UInt8 = 0
    var pbdd: UInt8 = 0
    var sbd: UInt8 = 0
    var charPending: UInt8 = 0x15
    var serial = false
    var sendingSerial = false
    var sendingSerialCount = 0
    var sendingSerialByte: UInt8 = 0
    var sendingSerialReady = false
    
    var delegate: TextReceiverDelegate!
    
    var timer: TIMER = TIMER(timer_mult: 0, tick_accum: 0, start_value: 0, timer_count: 0, timeout: 0, starttime: DispatchTime.now().uptimeNanoseconds)

    let num: UInt
    let baseAddress: UInt16
    let ramBaseAddress: UInt16
    let romBaseAddress: UInt16
    
    enum CodingKeys: CodingKey {
        case rom
        case ram
        case padd
        case sad
        case pbdd
        case sbd
        case charPending
        case num
        case baseAddress
        case ramBaseAddress
        case romBaseAddress
        case serial
        case sendingSerial
        case sendingSerialCount
        case sendingSerialByte
        case sendingSerialReady
    }
    
    let keyBits: [UInt8] = [ 0xbf, 0xdf, 0xef, 0xf7, 0xfb, 0xfd, 0xfe ];
    
    required init(n: UInt) {
        self.num = n
        // Riot 0 is 0x1740 and Riot 1 is 0x1700
        self.baseAddress = (n == 0) ? 0x1740 : 0x1700
        // Riot 0 is 0x17C0 and Riot 1 is 0x1780
        self.ramBaseAddress = (n == 0) ? 0x17C0 : 0x1780
        // Riot 0 is 0x1c00 and Riot 1 is 0x1800
        self.romBaseAddress = (n == 0) ? 0x1c00 : 0x1800
    }
    
    
    func read(address: UInt16) -> UInt8 {
        let addr = address - self.baseAddress;
        var sv: UInt8
        
        switch addr {
        case 0:
            if (self.num == 1) {
                return self.sad
            }
            //print("get sad from riot 0")
            sv = (self.sbd >> 1) & 0xf
            
            let ch = Int(self.charPending)
            
            if (sv == 0) {
                if (ch <= 6) {
                    return keyBits[ch]
                } else {
                    return 0xff
                }
            } else if (sv == 1) {
                if ((ch >= 7) && (ch <= 13)) {
                    return keyBits[ch-7]
                } else {
                    return 0xff
                }
            } else if (sv == 2) {
                if ((ch >= 14) && (ch <= 20)) {
                    return keyBits[ch-14]
                } else {
                    return 0xff
                }
            } else if (sv == 3) {
                if (self.serial) {
                    if (self.sendingSerial) {
                        return 0
                    }
                    return 0x80;
                }
                return 0xff
            } else {
                return 0x80
            }
        case 1:
            return self.padd
        case 2:
            if (self.sendingSerial) {
                self.sendingSerialReady = true
            }
            return self.sbd
        case 3:
            return self.pbdd
        case 6 | 0xE:
            if (self.timer.timeout > 0) {
                resetTimer(scale: self.timer.timer_mult, value:self.timer.start_value);
                return 0;
            } else {
                return self.timer.timer_count;
            }
        case 7:
            if (self.timer.timeout > 0) {
                return 0x80;
            } else {
                return 0;
            }
        default:
            return 0
        }
    }
    
    func write(address: UInt16, value:UInt8) {
        let addr = address - self.baseAddress;
        switch addr {
        case 0:
            self.sad = value
            break
        case 1:
            self.padd = value
            break
        case 2:
            self.sbd = value
            
            if (!self.sendingSerial && ((value & 1) == 0)) {
                self.sendingSerial = true
                self.sendingSerialCount = 0
                self.sendingSerialByte = 0
                self.sendingSerialReady = false

            } else if (self.sendingSerial && self.sendingSerialReady) {
                if (self.sendingSerialCount == 8) {
                    DispatchQueue.main.sync {
                        self.delegate?.addText(char: self.sendingSerialByte)
                    }
     
                    self.sendingSerial = false
                }
                
                self.sendingSerialByte = ((self.sendingSerialByte >> 1) & 0x7f) | ((value & 1) << 7)
                self.sendingSerialCount += 1
                self.sendingSerialReady = false;
            }
            
            
            break
        case 3:
            self.pbdd = value
            break
        case 4:
            resetTimer(scale: 1, value: value)
            break
        case 5:
            resetTimer(scale: 8, value: value)
            break
        case 6:
            resetTimer(scale: 64, value: value)
            break
        case 7:
            resetTimer(scale: 1024, value: value)
            break
        default:
            return
        }
    }
    
    func resetTimer(scale: UInt16, value: UInt8) {
        self.timer.timer_mult = scale;
        self.timer.tick_accum = 0;
        self.timer.start_value = value;
        self.timer.timer_count = value;
        self.timer.timeout = 0;
        self.timer.starttime = DispatchTime.now().uptimeNanoseconds
    }
    
    func updateTimer() {
        if ((self.timer.timer_mult == 0) || self.timer.timeout > 0) {
            return;
        }
        let t = DispatchTime.now()
        let diff = t.uptimeNanoseconds - self.timer.starttime
        if (diff / 1000 >= UInt64(self.timer.start_value) * UInt64(self.timer.timer_mult)) {
            self.timer.timeout = 1;
            self.timer.timer_count = 0;
        } else {
            self.timer.timer_count = UInt8(UInt16(self.timer.start_value) - UInt16((diff / 1000)));
        }
    }
    
    func loadRom() {
        print("loading rom contents", String(format: "rom%d", self.num))
        let filename = String(format: "rom%d", self.num)
        let bundle = Bundle.main
        let path = bundle.path(forResource: filename, ofType: "bin")!

        let data = NSData(contentsOfFile: path)!
        let dataRange = NSRange(location: 0, length: 1024)
        data.getBytes(&self.rom, range: dataRange)
    }
}
