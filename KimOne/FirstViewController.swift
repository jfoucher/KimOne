//
//  FirstViewController.swift
//  KimOne
//
//  Created by Jonathan Foucher on 30/05/2019.
//

import UIKit
import AVFoundation

var digits: [DigitItem] = [DigitItem(id:0), DigitItem(id:1), DigitItem(id:2), DigitItem(id:3), DigitItem(id:4), DigitItem(id:5)]

class FirstViewController: UIViewController {
    private let queue = DispatchQueue(label: "UI")
    private var _running: Bool = true
    var running: Bool {
        get {
            var a: Bool!
            queue.sync {
                a = self._running
            }
            
            return a
        }
        set {
            queue.sync {
                _running = newValue
            }
        }
    }
    
    private var _speedLimit: Bool = false
    var speedLimit: Bool {
        get {
            var a: Bool!
            queue.sync {
                a = self._speedLimit
            }
            
            return a
        }
        set {
            queue.sync {
                _speedLimit = newValue
            }
        }
    }
    
    let kbSound = URL(fileURLWithPath: Bundle.main.path(forResource: "key", ofType: "m4a")!)
    var audioPlayer = AVAudioPlayer()
    
    var processorInterface: ProcessorInterface = ProcessorInterface()
    
    
    
    @IBSegueAction func showHelp(_ coder: NSCoder) -> HelpViewController? {
        dispatchQueue.async(flags: .barrier) {
            self.running = false;
        }
        return HelpViewController(coder: coder)
    }
    @IBSegueAction func serialOn(_ coder: NSCoder) -> SerialViewController? {
        print("Serial on segue")
        riot0.serial = true
        
        return SerialViewController(coder: coder)
    }
    @IBAction func showLoadBtnClicked(_ sender: Any) {
        dispatchQueue.async(flags: .barrier) {
            print("set running to false")
            self.running = false;
        }
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

            processorInterface.reset()
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
            self.processorInterface.resetSpeed()
        }
    }
    
    @IBAction func GoClicked(_ sender: Any) {
        riot0.charPending = 0x13;
        
        audioPlayer.play()
    }
    @IBAction func stClicked(_ sender: Any) {
        print("NMI")
        audioPlayer.play()
        riot0.charPending = 0x15
        processorInterface.nmi()
    }
    @IBAction func rstClicked(_ sender: Any) {
        print("RESET")
        
        if (start.uptimeNanoseconds > 1000) {
            processorInterface.reset()
            riot0.charPending = 0x15
            
            start = DispatchTime.now()
        }
        audioPlayer.play()
    }
    @IBAction func sstChanged(_ sender: UISwitch) {
        processorInterface.singleStep = sender.isOn
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
        print("first view controller view did load")
        // Prepare UI
        goButton.titleLabel!.adjustsFontSizeToFitWidth = true
        
        sst.isOn = processorInterface.singleStep;
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: kbSound)
        }catch{}
        sst.backgroundColor = UIColor.darkGray
        sst.layer.cornerRadius = sst.frame.height / 2.0
        sst.clipsToBounds = true
        
        
        let displayView: DisplayView = self.view.viewWithTag(1) as! DisplayView

        self.view.backgroundColor = UIColor.black
        for d in digits {
            displayView.addSubview(d.view)
        }
        
        self.view.addSubview(displayView)

        
        
        //Restore digits from RAM
        restoreDigits()

        
        var prevS: UInt64 = 0
        
        var prevTime: UInt64 = 0;
        
        
        
        //Start a new thread to run the 6502 emulation
        start = DispatchTime.now()
        dispatchQueue.async {
            self.processorInterface.reset();
            
            // Start main loop
            while true {
                if !self.running {
                    usleep(1000000);
                    print("stopped")
                    continue;
                }
                
                let t = DispatchTime.now().uptimeNanoseconds
                
                // Slow down if speed limit
                let div = t > start.uptimeNanoseconds ? t.subtractingReportingOverflow(start.uptimeNanoseconds).partialValue : 1
                let freq = self.processorInterface.ticks * 100000 / div
                
                if (self.speedLimit && freq > 100) {
                    usleep(1);
                    continue;
                }

                let totalEl = t > prevTime ? t - prevTime : 0

                // update speed counter every 0.1s
                if (totalEl > 100000000) {
                    prevTicks = self.processorInterface.ticks
                    prevTime = t
                    // Only update if it changed by at least 0.1 MHz
                    if (freq/10 != prevS && freq/10+1 != prevS) {
                        prevS = freq/10
                        DispatchQueue.main.async {
                            if let title = self.speedButton.attributedTitle(for: .normal) {
                                let attributedText: NSAttributedString = title
                                
                                let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
                                mutableAttributedText.mutableString.setString(String(format: "%.2f MHz", Float(freq)/100.0))
                                self.speedButton.setAttributedTitle(mutableAttributedText, for: .normal)
                            }
                        }
                    }
                }
                
                self.processorInterface.runOneStep()
            }
        }
    }
    
    func restoreDigits() {
        let c1 = memory[0x00FB]
        digits[0].view.showDigit(digit: ((c1 & 0xF0) >> 4))
        digits[1].view.showDigit(digit: (c1 & 0x0F))
        
        let c2 = memory[0x00FA]
        digits[2].view.showDigit(digit: ((c2 & 0xF0) >> 4))
        digits[3].view.showDigit(digit: (c2 & 0x0F))
    
        let c3 = memory[0x00F9]
        digits[4].view.showDigit(digit: ((c3 & 0xF0) >> 4))
        digits[5].view.showDigit(digit: (c3 & 0x0F))
    }

    
    // Hide status bar
    override var prefersStatusBarHidden: Bool{
        return true
    }
}

