//
//  ViewController.swift
//  SwimSense
//
//  Created by Kanu Jason Kanu on 4/27/17.
//  Copyright © 2017 Kanu Jason Kanu. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet weak var turnover_label: UILabel!
    @IBOutlet weak var gyro_label: UILabel!
    @IBOutlet weak var accel_label: UILabel!
    
    var session: WCSession!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if(WCSession.isSupported()){
            self.session = WCSession.default()
            self.session.delegate = self
            self.session.activate()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
    
            if let receivedInfo:NSDictionary = message["info"] as? NSDictionary {
                if let turnover = receivedInfo["turnover"], let gyro = receivedInfo["gyro"],
                    let accel = receivedInfo["accel"] {
                   self.turnover_label.text = "\(turnover)"
                   self.gyro_label.text = "\(gyro)"
                    self.accel_label.text = "\(accel)"
                }
                
                
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}

