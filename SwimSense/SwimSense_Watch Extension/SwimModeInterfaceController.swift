//
//  SwimModeInterfaceController.swift
//  SwimSense
//
//  Created by Kanu Jason Kanu on 5/6/17.
//  Copyright © 2017 Kanu Jason Kanu. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion
import WatchConnectivity

class SwimInfo {
    var gyro: (Double, Double, Double)
    var accel: (Double, Double, Double)
    var turnover: Int
    
    init(turnover: Int, accel: (Double, Double, Double), gyro: (Double, Double, Double)) {
        self.turnover = turnover
        self.accel = accel
        self.gyro = gyro
    }
}

class SwimModeInterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet var turnover_label: WKInterfaceLabel!
    @IBOutlet var accel_label: WKInterfaceLabel!
    @IBOutlet var gyro_label: WKInterfaceLabel!
    
    var accel_values:[Double] = []
    var min_accel:Double = 0
    var max_accel:Double = 0
    
    var x_acc:Double = 0
    var y_acc:Double = 0
    var z_acc:Double = 0
    
    var x_gyr:Double = 0
    var y_gyr:Double = 0
    var z_gyr:Double = 0
    
    var t_rate:Int = 0
    
    var count:Int = 0
    
    var vib_timer:Timer? = nil
    var count_timer:Timer? = nil
    
    
    let motionManager = CMMotionManager()
    
    var session:WCSession!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        
        t_rate = Int(context as! String)!
        
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.gyroUpdateInterval = 0.1
        // Configure interface objects here.
    }
 
    func vibrate() {
        WKInterfaceDevice.current().play(.failure)
    }
    
    func update_count(){
        count += 1
    }
    
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        
        count_timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update_count), userInfo: nil, repeats: true)
        
        if(WCSession.isSupported()){
            self.session = WCSession.default()
            self.session.delegate = self
            self.session.activate()
        }
        
        turnover_label.setText(String(t_rate))
        
        if motionManager.isAccelerometerAvailable {
            
            let handler:CMAccelerometerHandler = {(data: CMAccelerometerData?, error: Error?) -> Void in
                self.x_acc = (data!.acceleration.x).rounded()
                self.y_acc = (data!.acceleration.y).rounded()
                self.z_acc = (data!.acceleration.z).rounded()
                self.accel_label.setText("\(self.x_acc, self.y_acc, self.z_acc)")
                
                let total_accel = (pow(self.x_acc,2) + pow(self.y_acc,2) + pow(self.z_acc,2)).squareRoot()
                print(total_accel)
                
                if (self.count < 15){
                    self.accel_values.append(total_accel)
                }
                if (self.count == 15){
                    self.min_accel = self.accel_values.min()!
                    self.max_accel = self.accel_values.max()!
                }
                
                if (self.count > 15 && (self.count % 15 == 0)){
                    if (((total_accel - 0.5) ... (total_accel + 0.5)  ~= self.accel_values.last!) &&
                        ((total_accel - 0.5) ... (total_accel + 0.5)  ~= self.max_accel))
                        {
                        self.vib_timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.vibrate), userInfo: nil, repeats: true)
                    }
                    if (((total_accel - 0.5) ... (total_accel + 0.5)  ~= self.accel_values.last!) &&
                        ((total_accel - 0.5) ... (total_accel + 0.5)  ~= self.min_accel))
                    {
                        self.vib_timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.vibrate), userInfo: nil, repeats: true)
                    }
                }
            }
            
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: handler)
        }
        
        
    }
    
    
    override func didAppear() {
        let info = ["turnover": "\(t_rate)",
                    "accel":"\(x_acc,y_acc,z_acc)",
                    "gyro":"\(x_gyr,y_gyr,z_gyr)"]
        
        if let session = session, session.isReachable {
            session.sendMessage(["info":info], replyHandler: { replyData in print(replyData)}, errorHandler: { error in print(error)
            })
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
}

