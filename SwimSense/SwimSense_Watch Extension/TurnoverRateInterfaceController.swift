//
//  TurnoverRateInterfaceController.swift
//  SwimSense
//
//  Created by Kanu Jason Kanu on 5/6/17.
//  Copyright © 2017 Kanu Jason Kanu. All rights reserved.
//

import WatchKit
import Foundation


class TurnoverRateInterfaceController: WKInterfaceController {
    
    var r_index:Int = 0
    
    @IBOutlet var rate_list: WKInterfacePicker!
    
    @IBAction func ratepicker(_ value: Int) {
        r_index = value
    }
    
    var itemList: [(String, String)] = [
        ("R1", "50"),
        ("R2", "55"),
        ("R3", "60"),
        ("R4", "65"),
        ("R5", "70") ]

    @IBAction func go_bttn() {
        let (_, t_rate) = itemList[r_index]
        pushController(withName: "SwimModeInterfaceController", context: t_rate)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let pickerItems: [WKPickerItem] = itemList.map {
            let pickerItem = WKPickerItem()
            pickerItem.caption = $0.0
            pickerItem.title = $0.1
            return pickerItem
        }
        
        rate_list.setItems(pickerItems)
        
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
