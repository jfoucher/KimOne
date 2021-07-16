//
//  FirstViewController.swift
//  KimOne
//
//  Created by Jonathan Foucher on 30/05/2019.
//

import UIKit
import AVFoundation

var digits: [DigitItem] = [DigitItem(id:0), DigitItem(id:1), DigitItem(id:2), DigitItem(id:3), DigitItem(id:4), DigitItem(id:5)]

let dispatchQueue = DispatchQueue.global(qos: .background)

let riot0 = Riot(n:0)
let riot1 = Riot(n:1)


class FirstViewController: UIViewController {
    var running: Bool = true
    let kbSound = URL(fileURLWithPath: Bundle.main.path(forResource: "key", ofType: "m4a")!)
    var audioPlayer = AVAudioPlayer()
    var singleStep: Bool = false
    var speedLimit: Bool = false
    
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
    @IBOutlet weak var speedButton: UIButton!
    
    @IBAction func speedClicked(_ sender: UIButton) {
        self.speedLimit = !self.speedLimit
        
        if (start.uptimeNanoseconds > 1000) {
            start = DispatchTime.now()
            clockticks6502 = 0
            prevTicks = 0
        }
        if (self.speedLimit) {
            let attributedText: NSAttributedString = self.speedButton.attributedTitle(for: .normal)!
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            mutableAttributedText.mutableString.setString("1.00 MHz")
            self.speedButton.setAttributedTitle(mutableAttributedText, for: .normal)
            
        }
    }
    
    @IBAction func GoClicked(_ sender: Any) {
        riot0.charPending = 0x13;
        audioPlayer.play()
    }
    @IBAction func stClicked(_ sender: Any) {
        print("NMI")
        riot0.charPending = 0x15
        nmi6502()
        audioPlayer.play()
    }
    @IBAction func rstClicked(_ sender: Any) {
        print("RESET")
        riot0.charPending = 0x15
        if (start.uptimeNanoseconds > 1000) {
            reset6502()
            start = DispatchTime.now()
        }
        audioPlayer.play()
    }
    @IBAction func sstChanged(_ sender: UISwitch) {
        self.singleStep = sender.isOn
    }
    @IBAction func ADClicked(_ sender: Any) {
        riot0.charPending = 0x10
        audioPlayer.play()
    }
    @IBAction func DAClicked(_ sender: Any) {
        riot0.charPending = 0x11
        audioPlayer.play()
    }
    @IBAction func pcClicked(_ sender: Any) {
        riot0.charPending = 0x14
        audioPlayer.play()
    }
    
    @IBAction func plusClicked(_ sender: Any) {
        riot0.charPending = 0x12
        audioPlayer.play()
    }
    
    @IBAction func CClicked(_ sender: Any) {
        riot0.charPending = 0xC
        audioPlayer.play()
    }
    @IBAction func DClicked(_ sender: Any) {
        riot0.charPending = 0xD
        audioPlayer.play()
    }
    @IBAction func EClicked(_ sender: Any) {
        riot0.charPending = 0xE
        audioPlayer.play()
    }
    @IBAction func FClicked(_ sender: Any) {
        riot0.charPending = 0xF
        audioPlayer.play()
    }
    @IBAction func Eightclicked(_ sender: Any) {
        riot0.charPending = 0x8
        audioPlayer.play()
    }
    @IBAction func NineClicked(_ sender: Any) {
        riot0.charPending = 0x9
        audioPlayer.play()
    }
    @IBAction func AClicked(_ sender: Any) {
        riot0.charPending = 0xA
        audioPlayer.play()
    }
    @IBAction func Bclicked(_ sender: Any) {
        riot0.charPending = 0xB
        audioPlayer.play()
    }
    @IBAction func FourClicked(_ sender: Any) {
        riot0.charPending = 0x4
        audioPlayer.play()
    }
    @IBAction func FiveClicked(_ sender: Any) {
        riot0.charPending = 0x5
        audioPlayer.play()
    }
    @IBAction func SixClicked(_ sender: Any) {
        riot0.charPending = 0x6
        audioPlayer.play()
    }
    @IBAction func SevenClicked(_ sender: Any) {
        riot0.charPending = 0x7
        audioPlayer.play()
    }
    @IBAction func ZeroClicked(_ sender: Any) {
        riot0.charPending = 0x0
        audioPlayer.play()
    }
    @IBAction func OneClicked(_ sender: Any) {
        riot0.charPending = 0x1
        audioPlayer.play()
    }
    @IBAction func TwoClicked(_ sender: Any) {
        riot0.charPending = 0x2
        audioPlayer.play()
    }
    @IBAction func ThreeClicked(_ sender: Any) {
        riot0.charPending = 0x3
        audioPlayer.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepare UI
        goButton.titleLabel!.adjustsFontSizeToFitWidth = true
        sst.isOn = false;
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: kbSound)
        }catch{}
        sst.backgroundColor = UIColor.darkGray
        sst.layer.cornerRadius = sst.frame.height / 2.0
        sst.clipsToBounds = true
        
        
        let testView: DisplayView = self.view.viewWithTag(1) as! DisplayView

        self.view.backgroundColor = UIColor.black
        for d in digits {
            testView.addSubview(d.view)
        }
        
        self.view.addSubview(testView)
        
        // Load data into 6530 ROM
        riot0.loadRom()
        riot1.loadRom()
        
        // LOAD data into RAM
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
        
        var prevS: UInt64 = 0
        
        var prevTime: UInt64 = 0;
        
        //Start a new thread to run the 6502 emulation
        dispatchQueue.async {
            reset6502();
            start = DispatchTime.now()
            
            // Flag for NMI when single stepping or when ST is pressed
            var nmiFlag: Bool = false;
            // Start main loop
            while self.running {
                let t = DispatchTime.now().uptimeNanoseconds
                
                // Slow down if speed limit
                let div = t > start.uptimeNanoseconds ? t.subtractingReportingOverflow(start.uptimeNanoseconds).partialValue : 1
                let freq = clockticks6502*100000 / div
                
                if (self.speedLimit && freq > 100) {
                    usleep(1);
                    continue;
                }

                let totalEl = t > prevTime ? t - prevTime : 0

                // update speed counter every 0.1s
                if (totalEl > 100000000) {
                    prevTicks = clockticks6502
                    prevTime = t
                    // Only update if it changed by at least 0.1 MHz
                    if (freq/10 != prevS && freq/10+1 != prevS) {
                        prevS = freq/10
                        DispatchQueue.main.async {
                            let attributedText: NSAttributedString = self.speedButton.attributedTitle(for: .normal)!
                            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
                            mutableAttributedText.mutableString.setString(String(format: "%.2f MHz", Float(freq)/100.0))
                            self.speedButton.setAttributedTitle(mutableAttributedText, for: .normal)
                        }
                    }
                }
                // If the single step switch is on and we are in RAM
                // Turn the nmi flag on
                if (self.singleStep && ((pc < 0x1C00) || (pc >= 0x2000))) {
                    nmiFlag = true;
                }
                
                //Run the current instruction
                step6502()
                
                if (nmiFlag) {
                    // If we have an nmi, go to the nmi handler now
                    nmiFlag = false;
                    nmi6502();
                }
                
                if ((pc == 0x1f79) || (pc == 0x1f90)) {
                    // If we get to the place where a character has been read,
                    // clear out the pending keyboard character.
                    
                    riot0.charPending = 0x15;
                }
            }
        }
    }
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    // Load microchess at 0XC000
    func loadMicroChess() {
        var i = 0;
        let val = [UInt8].fromTuple(mchess)

        while i < 1393 {
            memory[0xC000 + i] = val?[i] ?? 0
            i += 1
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
