//
//  FirstViewController.swift
//  KimOne
//
//  Created by Jonathan Foucher on 30/05/2019.
//

import UIKit
import AVFoundation

var digits: [DigitItem] = [DigitItem(id:0), DigitItem(id:1), DigitItem(id:2), DigitItem(id:3), DigitItem(id:4), DigitItem(id:5)]


var singleStep: Bool = false

class FirstViewController: UIViewController {
    var running: Bool = true
    let kbSound = URL(fileURLWithPath: Bundle.main.path(forResource: "key", ofType: "m4a")!)
    var audioPlayer = AVAudioPlayer()
    
    var speedLimit: Bool = false
    
    @IBSegueAction func showHelp(_ coder: NSCoder) -> HelpViewController? {
        dispatchQueue.async(flags: .barrier) {
            self.running = false;
        }
        return HelpViewController(coder: coder)
    }
    @IBSegueAction func serialOn(_ coder: NSCoder) -> SerialViewController? {
        print("Serial on segue")
        dispatchQueue.sync(flags: .barrier) {
            riot0.serial = true
        }
        return SerialViewController(coder: coder)
    }
    @IBAction func showHelpBtnClicked(_ sender: Any) {
        dispatchQueue.async(flags: .barrier) {
            print("set running to false")
            self.running = false;
        }
    }
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        // Stop getting serial chars
        print("unwind")
        dispatchQueue.sync(flags: .barrier) {
            self.running = true;
        
//            riot0.turnSerialOff()
            riot0.charPending = 0x15
            riot0.serial = false

            reset6502()
        }
        start = DispatchTime.now()
    }
    
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
            dispatchQueue.sync(flags: .barrier) {
                clockticks6502 = 0
                prevTicks = 0
            }
        }
    }
    
    @IBAction func GoClicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0x13;
        }
        audioPlayer.play()
    }
    @IBAction func stClicked(_ sender: Any) {
        print("NMI")
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0x15
            nmi6502()
        }
        audioPlayer.play()
    }
    @IBAction func rstClicked(_ sender: Any) {
        print("RESET")
        
        if (start.uptimeNanoseconds > 1000) {
            dispatchQueue.sync(flags: .barrier) {
                reset6502()
                riot0.charPending = 0x15
            }
            start = DispatchTime.now()
        }
        audioPlayer.play()
    }
    @IBAction func sstChanged(_ sender: UISwitch) {
        singleStep = sender.isOn
    }
    @IBAction func ADClicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0x10
        }
        audioPlayer.play()
    }
    @IBAction func DAClicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0x11
        }
        audioPlayer.play()
    }
    @IBAction func pcClicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0x14
        }
        audioPlayer.play()
    }
    
    @IBAction func plusClicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0x12
        }
        audioPlayer.play()
    }
    
    @IBAction func CClicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0xC
        }
        audioPlayer.play()
    }
    @IBAction func DClicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0xD
        }
        audioPlayer.play()
    }
    @IBAction func EClicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0xE
        }
        audioPlayer.play()
    }
    @IBAction func FClicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0xF
        }
        audioPlayer.play()
    }
    @IBAction func Eightclicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0x8
        }
        audioPlayer.play()
    }
    @IBAction func NineClicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0x9
        }
        audioPlayer.play()
    }
    @IBAction func AClicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0xA
        }
        audioPlayer.play()
    }
    @IBAction func Bclicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0xB
        }
        audioPlayer.play()
    }
    @IBAction func FourClicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0x4
        }
        audioPlayer.play()
    }
    @IBAction func FiveClicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0x5
        }
        audioPlayer.play()
    }
    @IBAction func SixClicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0x6
        }
        audioPlayer.play()
    }
    @IBAction func SevenClicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0x7
        }
        audioPlayer.play()
    }
    @IBAction func ZeroClicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0x0
        }
        audioPlayer.play()
    }
    @IBAction func OneClicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0x1
        }
        audioPlayer.play()
    }
    @IBAction func TwoClicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0x2
        }
        audioPlayer.play()
    }
    @IBAction func ThreeClicked(_ sender: Any) {
        dispatchQueue.sync(flags: .barrier) {
            riot0.charPending = 0x3
        }
        audioPlayer.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("first view controller view did load")
        // Prepare UI
        goButton.titleLabel!.adjustsFontSizeToFitWidth = true
        
        sst.isOn = singleStep;
        
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

        
        
        //Restore digits from RAM
        restoreDigits()

        
        var prevS: UInt64 = 0
        
        var prevTime: UInt64 = 0;
        
        
        
        //Start a new thread to run the 6502 emulation
        start = DispatchTime.now()
        dispatchQueue.async {
            reset6502();
            // Flag for NMI when single stepping or when ST is pressed
            var nmiFlag: Bool = false;
            // Start main loop
            while true {
                if !self.running {
                    print ("not running")
                    usleep(1000000);
                    continue;
                }
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
                if (singleStep && ((pc < 0x1C00) || (pc >= 0x2000))) {
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
                } else if ((pc == 0x1E65)) {
                    pc = 0x1e85;
                    a = 0
                    if (serialCharsWaiting > 0) {
                        let v = serialBuffer[serialCharsWaiting-1]
                        serialCharsWaiting -= 1
                        a = v
                    }
                    
                    y = 0xff;
                }
                
                //print(String(format:"%04X", pc))
            }
        }
    }
    
    func restoreDigits() {
        dispatchQueue.sync {
            let c1 = memory[0x00FB]
            DispatchQueue.main.async {
                digits[0].view.showDigit(digit: ((c1 & 0xF0) >> 4))
                digits[1].view.showDigit(digit: (c1 & 0x0F))
            }
        }
        dispatchQueue.sync {
            let c2 = memory[0x00FA]
            DispatchQueue.main.async {
                digits[2].view.showDigit(digit: ((c2 & 0xF0) >> 4))
                digits[3].view.showDigit(digit: (c2 & 0x0F))
            }
        }
        dispatchQueue.sync {
            let c3 = memory[0x00F9]
            DispatchQueue.main.async {
                digits[4].view.showDigit(digit: ((c3 & 0xF0) >> 4))
                digits[5].view.showDigit(digit: (c3 & 0x0F))
            }
        }
    }
    

    
    // Hide status bar
    override var prefersStatusBarHidden: Bool{
        return true
    }
}

