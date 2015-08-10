//
//  Session.swift
//  SkiBum
//
//  Created by Nick Raff on 7/27/15.
//  Copyright (c) 2015 Nick Raff. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Session : Object {
    
    dynamic var sessionTitle: String = ""
    dynamic var Date = NSDate()
    dynamic var imageID = 0
    dynamic var backImageID = 0
    
    dynamic var currentSpeed: Int = 0
    dynamic var currentAltitude: Int = 0
    dynamic var topSpeed: Double = 0
    dynamic var peakAltitude: Double = 0
    dynamic var totalDistance: Double = 0
    dynamic var sessionTime: String = ""
    dynamic var averageSpeed: Double = 0
    dynamic var sessionMeasuredIn: Bool = false
    
    static var measureSwitch : Bool = false
    
 
//    func randomizeImage() -> UIImage {
//        let imageCount = 12
//        let randomNumber = Int(arc4random_uniform(12))
//        
//        if let pic = UIImage(named: "cell_bg\(randomNumber)") {
//            return pic
//        }
//        else {
//            return UIImage(named: "cell_bg1")!
//        }
//        
//    }
//    
    
}



