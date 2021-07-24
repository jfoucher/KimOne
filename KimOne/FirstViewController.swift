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
    
    let UISerialQueue = DispatchQueue(label: "com.kimone.queue.serial.ui")
    
    @IBSegueAction func showHelp(_ coder: NSCoder) -> HelpViewController? {
        serialQueue.sync {
            self.running = false;
        }
        return HelpViewController(coder: coder)
    }
    @IBSegueAction func serialOn(_ coder: NSCoder) -> SerialViewController? {
        print("Serial on segue")
        serialQueue.async {
            riot0.serial = true
        }
        return SerialViewController(coder: coder)
    }
    @IBAction func showHelpBtnClicked(_ sender: Any) {
        serialQueue.async {
            print("set running to false")
            self.running = false;
        }
    }
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        // Stop getting serial chars
        print("unwind")
        serialQueue.async {
            self.running = true;
        
//            riot0.turnSerialOff()
            riot0.charPending = 0x15
            riot0.serial = false

            reset6502()
        }
        start = DispatchTime.now().uptimeNanoseconds
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

    
    @IBAction func GoClicked(_ sender: Any) {
        serialQueue.async {
            riot0.charPending = 0x13;
        }
        audioPlayer.play()
    }
    @IBAction func stClicked(_ sender: Any) {
        print("NMI")
        serialQueue.async {
            riot0.charPending = 0x15
            nmi6502()
        }
        audioPlayer.play()
    }
    @IBAction func rstClicked(_ sender: Any) {
        print("RESET")
        
        if (start > 1000) {
            serialQueue.async {
                reset6502()
                riot0.charPending = 0x15
            }
            start = DispatchTime.now().uptimeNanoseconds
        }
        audioPlayer.play()
    }
    @IBAction func sstChanged(_ sender: UISwitch) {
        let r = sender.isOn
        serialQueue.async {
            singleStep = r
        }
    }
    @IBAction func ADClicked(_ sender: Any) {
        serialQueue.async {
            riot0.charPending = 0x10
        }
        audioPlayer.play()
    }
    @IBAction func DAClicked(_ sender: Any) {
        serialQueue.async {
            riot0.charPending = 0x11
        }
        audioPlayer.play()
    }
    @IBAction func pcClicked(_ sender: Any) {
        serialQueue.async {
            riot0.charPending = 0x14
        }
        audioPlayer.play()
    }
    
    @IBAction func plusClicked(_ sender: Any) {
        serialQueue.async {
            riot0.charPending = 0x12
        }
        audioPlayer.play()
    }
    
    @IBAction func CClicked(_ sender: Any) {
        serialQueue.async {
            riot0.charPending = 0xC
        }
        audioPlayer.play()
    }
    @IBAction func DClicked(_ sender: Any) {
        serialQueue.async {
            riot0.charPending = 0xD
        }
        audioPlayer.play()
    }
    @IBAction func EClicked(_ sender: Any) {
        serialQueue.async {
            riot0.charPending = 0xE
        }
        audioPlayer.play()
    }
    @IBAction func FClicked(_ sender: Any) {
        serialQueue.async {
            riot0.charPending = 0xF
        }
        audioPlayer.play()
    }
    @IBAction func Eightclicked(_ sender: Any) {
        serialQueue.async {
            riot0.charPending = 0x8
        }
        audioPlayer.play()
    }
    @IBAction func NineClicked(_ sender: Any) {
        serialQueue.async {
            riot0.charPending = 0x9
        }
        audioPlayer.play()
    }
    @IBAction func AClicked(_ sender: Any) {
        serialQueue.async {
            riot0.charPending = 0xA
        }
        audioPlayer.play()
    }
    @IBAction func Bclicked(_ sender: Any) {
        serialQueue.async {
            riot0.charPending = 0xB
        }
        audioPlayer.play()
    }
    @IBAction func FourClicked(_ sender: Any) {
        serialQueue.async {
            riot0.charPending = 0x4
        }
        audioPlayer.play()
    }
    @IBAction func FiveClicked(_ sender: Any) {
        serialQueue.async {
            riot0.charPending = 0x5
        }
        audioPlayer.play()
    }
    @IBAction func SixClicked(_ sender: Any) {
        serialQueue.async {
            riot0.charPending = 0x6
        }
        audioPlayer.play()
    }
    @IBAction func SevenClicked(_ sender: Any) {
        serialQueue.async {
            riot0.charPending = 0x7
        }
        audioPlayer.play()
    }
    @IBAction func ZeroClicked(_ sender: Any) {
        serialQueue.async {
            riot0.charPending = 0x0
        }
        audioPlayer.play()
    }
    @IBAction func OneClicked(_ sender: Any) {
        serialQueue.async {
            riot0.charPending = 0x1
        }
        audioPlayer.play()
    }
    @IBAction func TwoClicked(_ sender: Any) {
        serialQueue.async {
            riot0.charPending = 0x2
        }
        audioPlayer.play()
    }
    @IBAction func ThreeClicked(_ sender: Any) {
        serialQueue.async {
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

        //Start a new thread to run the 6502 emulation
        start = DispatchTime.now().uptimeNanoseconds
        reset6502();
        dispatchQueue.async {
            // Start main loop
            while true {
                serialQueue.sync {
                    if !self.running {
                        usleep(1000000)
                        return
                    }
                    // Flag for NMI when single stepping or when ST is pressed
                    var nmiFlag: Bool = false;

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
                    
                    //print(String(format: "pc: %04X", pc))
                    
                    if (pc == 0x1F18) {
                        if a == 0 {
                            usleep(1000)
                        }
                    } else if (pc == 0x1f90 || pc == 0x1f79) {
                        // If we get to the place where a character has been read,
                        // clear out the pending keyboard character.
                        riot0.charPending = 0x15;
                    } else if (pc == 0x1E65) {
                        if let v = serialBuffer.dequeue() {
                            pc = 0x1e81;

                            memory[0xFE] = v
                            a = v
                            y = 0xff;
//                            print("got char from serial", v)
                        } else {
                            //print("waiting for serial character")
                            usleep(1000)
                        }
                    }
                }
                
                //print(String(format:"%04X", pc))
            }
        }
    }
    
    func restoreDigits() {
        serialQueue.async {
            let c1 = memory[0x00FB]
            DispatchQueue.main.async {
                digits[0].view.showDigit(digit: ((c1 & 0xF0) >> 4))
                digits[1].view.showDigit(digit: (c1 & 0x0F))
            }
        }
        serialQueue.async {
            let c2 = memory[0x00FA]
            DispatchQueue.main.async {
                digits[2].view.showDigit(digit: ((c2 & 0xF0) >> 4))
                digits[3].view.showDigit(digit: (c2 & 0x0F))
            }
        }
        serialQueue.async {
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

