//
//  AppDelegate.swift
//  Cesium
//
//  Created by Jonathan Foucher on 30/05/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import UIKit
var start:DispatchTime = DispatchTime.now();

let dispatchQueue = DispatchQueue.global(qos: .background)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        restoreData()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        saveData()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        saveData()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        dispatchQueue.sync {
            clockticks6502 = 0
            prevTicks = 0
            restoreData()
        }
        start = DispatchTime.now()
        
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        dispatchQueue.sync {
            clockticks6502 = 0
            prevTicks = 0
            restoreData()
        }
        start = DispatchTime.now()
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveData()
    }


    func saveData() {
        let mem = Data(memory).base64EncodedString()
        UserDefaults.standard.set(mem, forKey: "memory")
        
        UserDefaults.standard.set(pc, forKey: "pc")
        UserDefaults.standard.set(a, forKey: "a")
        UserDefaults.standard.set(x, forKey: "x")
        UserDefaults.standard.set(y, forKey: "y")
        UserDefaults.standard.set(sp, forKey: "sp")
        UserDefaults.standard.set(status, forKey: "status")
        UserDefaults.standard.set(singleStep, forKey: "singleStep")
        
        if let encoded = try? JSONEncoder().encode(riot0) {
            UserDefaults.standard.set(encoded, forKey: "riot0")
        }
        if let encoded = try? JSONEncoder().encode(riot1) {
            UserDefaults.standard.set(encoded, forKey: "riot1")
        }
    }
    
    func restoreData() {
        // LOAD data into RAM
        //loadMicroChess()

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
        
//        
//        
//
//        
//        if let riot0Data = UserDefaults.standard.data(forKey: "riot0") {
//            do {
//                riot0 = try JSONDecoder().decode(Riot.self, from: riot0Data)
//            } catch {
//                riot0 = Riot(n: 0)
//            }
//            
//        }
//        
//        riot0.serial = false
//        
//        if let riot1Data = UserDefaults.standard.data(forKey: "riot1") {
//            do {
//                riot1 = try JSONDecoder().decode(Riot.self, from: riot1Data)
//            } catch {
//                riot1 = Riot(n: 1)
//            }
//            
//        }
//
//        pc = UInt16(UserDefaults.standard.integer(forKey: "pc"))
//        a = UInt8(UserDefaults.standard.integer(forKey: "a"))
//        x = UInt8(UserDefaults.standard.integer(forKey: "x"))
//        y = UInt8(UserDefaults.standard.integer(forKey: "y"))
//        sp = UInt8(UserDefaults.standard.integer(forKey: "sp"))
//        singleStep = UserDefaults.standard.bool(forKey: "singleStep")
//        status = UInt8(UserDefaults.standard.integer(forKey: "status"))
//        if (status == 0) {
//            status = UInt8(FLAG_CONSTANT)
//        }
//
//        //Load user data
//        if let stringData = UserDefaults.standard.string(forKey: "memory")  {
//            if let nsdata1 = Data(base64Encoded: stringData, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) {
//
//                memory = nsdata1.withUnsafeBytes {
//                   Array(UnsafeBufferPointer<UInt8>(start: $0, count: nsdata1.count/MemoryLayout<UInt8>.size))
//                }
//            }
//        }
//        
        loadBasic()
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
    
    func loadBasic() {
        let path = Bundle.main.path(forResource: "TinyBasic", ofType: "bin")!
        let size = MemoryLayout<UInt8>.stride
        let data = NSData(contentsOfFile: path)!
        let length = data.count * size
        var bytes1 = [UInt8](repeating: 0, count: data.count / size)
        data.getBytes(&bytes1, length: length)
        
        for (i, b) in bytes1.enumerated() {
            memory[i+0x100] = b
        }
    }
}

extension String {
    
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
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
