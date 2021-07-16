//
//  FirstViewController.swift
//  Cesium
//
//  Created by Jonathan Foucher on 30/05/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import UIKit


fileprivate var buffer = ""

var memory:[UInt8] = [UInt8](repeating: 0x00, count: Int(64*1024))

var digits: [DigitItem] = [DigitItem(id:0), DigitItem(id:1), DigitItem(id:2), DigitItem(id:3), DigitItem(id:4), DigitItem(id:5)]

let dispatchQueue = DispatchQueue.global(qos: .background)

struct DigitItem {
    let view: DigitView = DigitView()
    let id: Int
}

let riot0 = Riot(n:0)
let riot1 = Riot(n:1)

var prev1: UInt8 = 0xFF
var prev2: UInt8 = 0xFF
var prev3: UInt8 = 0xFF

@_cdecl("ReadCallback")
func read6502Swift(address: UInt16) -> UInt8 {
    var val: UInt8
    let  addr = address;
    if (addr == 0x1F1F) {
        pc = 0x1F45;    // skip subroutine part that deals with LEDs
        let c1 = memory[0x00FB]
        if (c1 != prev1) {
            prev1 = c1;
            DispatchQueue.main.async {
                digits[0].view.showDigit(digit: ((c1 & 0xF0) >> 4))
                digits[1].view.showDigit(digit: (c1 & 0x0F))
            }
        }
        let c2 = memory[0x00FA]
        if (c2 != prev2) {
            prev2 = c2;
            DispatchQueue.main.async {
                digits[2].view.showDigit(digit: ((c2 & 0xF0) >> 4))
                digits[3].view.showDigit(digit: (c2 & 0x0F))
            }
        }
        let c3 = memory[0x00F9]
        if (c3 != prev3) {
            prev3 = c3;
            DispatchQueue.main.async {
                digits[4].view.showDigit(digit: ((c3 & 0xF0) >> 4))
                digits[5].view.showDigit(digit: (c3 & 0x0F))
            }
        }
        
        return (0xEA);
    } else if (address == 0xCFF4)  {
         //simulated keyboard input
        let tempval = riot0.charPending;
        riot0.charPending = 0x15
                // translate KIM-1 button codes into ASCII code expected by this version of Microchess
        switch (tempval) {
        case 0x14:  return 0x50    // PC translated to P
        case 0xF:  return 13    // F translated to Return
        case 0x12: return 0x57   // + translated to W meaning Blitz mode toggle
        default:
            return tempval
        }
        
    } else if (address == 0xCFF3) {
        return (riot0.charPending == 0) ? 0 : 1;
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
    } else if (addr >= riot0.romBaseAddress && addr <= riot0.romBaseAddress + 1023) {
        
        val = riot0.rom[Int(addr - riot0.romBaseAddress)]
        //print(String(format: "Read riot 0 ROM ad: %04X v: %02X", address, val))
    } else if (addr >= riot1.romBaseAddress && addr <= riot1.romBaseAddress + 1023) {
        
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
    } else {
        //print(String(format: "Write mem ad: %04X v: %02X", address, value))
        memory[Int(address)] = value
    }
    
    
}

class FirstViewController: UIViewController {
    
    var running: Bool = true;

    var singleStep: Bool = false
    
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var stbutton: UIButton!
    @IBOutlet weak var rsbutton: UIButton!
    @IBOutlet weak var sst: UISwitch!

    @IBOutlet var adBtn: UIButton!
    @IBOutlet weak var DAButton: UIButton!
    @IBOutlet weak var PCButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var Cbutton: UIButton!
    @IBOutlet weak var Dbutton: UIButton!
    @IBOutlet weak var EButton: UIButton!
    @IBOutlet weak var Fbutton: UIButton!
    
    @IBOutlet weak var speedLabel: UILabel!
    
    
    @IBAction func GoClicked(_ sender: Any) {
        riot0.charPending = 0x13;
    }
    @IBAction func stClicked(_ sender: Any) {
        print("NMI")
        riot0.charPending = 0x15
        nmi6502()
    }
    @IBAction func rstClicked(_ sender: Any) {
        print("RESET")
        riot0.charPending = 0x15
        reset6502()
    }
    @IBAction func sstChanged(_ sender: UISwitch) {
        self.singleStep = sender.isOn
    }
    @IBAction func ADClicked(_ sender: Any) {
        riot0.charPending = 0x10
    }
    @IBAction func DAClicked(_ sender: Any) {
        riot0.charPending = 0x11
    }
    @IBAction func pcClicked(_ sender: Any) {
        riot0.charPending = 0x14
    }
    
    @IBAction func plusClicked(_ sender: Any) {
        riot0.charPending = 0x12
    }
    
    @IBAction func CClicked(_ sender: Any) {
        riot0.charPending = 0xC
    }
    @IBAction func DClicked(_ sender: Any) {
        riot0.charPending = 0xD
    }
    @IBAction func EClicked(_ sender: Any) {
        riot0.charPending = 0xE
    }
    @IBAction func FClicked(_ sender: Any) {
        riot0.charPending = 0xF
    }
    @IBAction func Eightclicked(_ sender: Any) {
        riot0.charPending = 0x8
    }
    @IBAction func NineClicked(_ sender: Any) {
        riot0.charPending = 0x9
    }
    @IBAction func AClicked(_ sender: Any) {
        riot0.charPending = 0xA
    }
    @IBAction func Bclicked(_ sender: Any) {
        riot0.charPending = 0xB
    }
    @IBAction func FourClicked(_ sender: Any) {
        riot0.charPending = 0x4
    }
    @IBAction func FiveClicked(_ sender: Any) {
        riot0.charPending = 0x5
    }
    @IBAction func SixClicked(_ sender: Any) {
        riot0.charPending = 0x6
    }
    @IBAction func SevenClicked(_ sender: Any) {
        riot0.charPending = 0x7
    }
    @IBAction func ZeroClicked(_ sender: Any) {
        riot0.charPending = 0x0
    }
    @IBAction func OneClicked(_ sender: Any) {
        riot0.charPending = 0x1
    }
    @IBAction func TwoClicked(_ sender: Any) {
        riot0.charPending = 0x2
    }
    @IBAction func ThreeClicked(_ sender: Any) {
        riot0.charPending = 0x3
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let testView: UIView = self.view.viewWithTag(1)!
        
        let screenWidth = testView.bounds.width
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goButton.titleLabel!.adjustsFontSizeToFitWidth = true
        sst.isOn = false;
        
        sst.backgroundColor = UIColor.darkGray
        sst.layer.cornerRadius = sst.frame.height / 2.0
        sst.clipsToBounds = true
        
        speedLabel.text = ""
        
        let testView: UIView = self.view.viewWithTag(1)!

        self.view.backgroundColor = UIColor.black
        
        riot0.loadRom()
        riot1.loadRom()
        
        loadMicroChess()
        

        memory[0x400] = 0x42
        memory[0x401] = 0xFF
        memory[0x402] = 0xCA
        memory[0x403] = 0xD0
        memory[0x404] = 0xFD
        
        // Set up default IRQ vector
        write6502(0x17FE, 0x22)
        write6502(0x17FF, 0x1C)
        //Setup default NMI vector
        write6502(0x17FA, 0x00)
        write6502(0x17FB, 0x1C)
        
        
        for d in digits {
            testView.addSubview(d.view)
        }
        
        self.view.addSubview(testView)
        
        let start = DispatchTime.now()
        var prevS: UInt64 = 0
        
        dispatchQueue.async {
            reset6502();
            
            var nmiFlag: Bool = false;
            while self.running {
                let t = DispatchTime.now().uptimeNanoseconds

                let totalEl = t - start.uptimeNanoseconds

                if (totalEl > 1000000) {
                    let s = clockticks6502 / (totalEl/100000)
                    if (s/10 != prevS) {
                        print(s)
                        prevS = s/10
                        DispatchQueue.main.async {
                            self.speedLabel.text = String(format: "%.2f MHz", Float(s)/100.0)
                        }
                    }
                    if (s > 100) {
                        // We are running at more than 1 MHz, slow down
                        usleep(1)
                        continue
                    }
                }
                
                
                if (self.singleStep && ((pc < 0x1C00) || (pc >= 0x2000))) {
                    nmiFlag = true;
                }
                
                
                
                step6502()
                
                
                
                if (nmiFlag) {
                    nmiFlag = false;
                    nmi6502();
                }
                
                //print(String(format: "%04X", pc))
                
                if ((pc == 0x1f79) || (pc == 0x1f90)) {
                    // If we get to the place where a character has been read,
                    // clear out the pending keyboard character.
                    
                    riot0.charPending = 0x15;
                }
                
                    
                //usleep(1)
            }
        }
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
   }
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    func loadMicroChess() {
        var i = 0;
        let val = [UInt8].fromTuple(mchess)

        while i < 1393 {
            memory[0xC000 + i] = val?[i] ?? 0
            i += 1
        }
    }
    
//    func loadTest() {
//        var i = 0;
//        let val = [UInt8].fromTuple(test)
//
//        while i < 65536 {
//            memory[i] = val?[i] ?? 0
//            i += 1
//        }
//    }
    
    func mapCodeToChar(code: UInt8) -> UInt8 {
        switch code {
        case 57:
            return 0xC
        case 94:
            return 0xD
        case 121:
            return 0xE
            
        case 113:
            return 0xF
        case 127:
            return 0x8
        case 111:
            return 0x9
        case 119:
            return 0xA
        case 124:
            return 0xB
        case 102:
            return 0x4
        case 109:
            return 0x5
        case 125:
            return 0x6
        case 7:
            return 0x7
        case 6:
            return 0x1
        case 91:
            return 0x2
        case 79:
            return 0x3
        case 63:
            return 0
        default:
            print(String(format: "Unkown code %d", code))
            return 0xFF
        }
    }
}

extension Array {
    
    /**
     Attempt to convert a tuple into an Array.
     
     - Parameter tuple: The tuple to try and convert. All members must be of the same type.
     - Returns: An array of the tuple's values, or `nil` if any tuple members do not match the `Element` type of this array.
     */
    static func fromTuple<Tuple> (_ tuple: Tuple) -> [Element]? {
        let val = Array<Element>.fromTupleOptional(tuple)
        return val.allSatisfy({ $0 != nil }) ? val.map { $0! } : nil
    }
    
    /**
     Convert a tuple into an array.
     
     - Parameter tuple: The tuple to try and convert.
     - Returns: An array of the tuple's values, with `nil` for any values that could not be cast to the `Element` type of this array.
     */
    static func fromTupleOptional<Tuple> (_ tuple: Tuple) -> [Element?] {
        return Mirror(reflecting: tuple)
            .children
            .filter { child in
                (child.label ?? "x").allSatisfy { char in ".1234567890".contains(char) }
            }.map { $0.value as? Element }
    }
}
