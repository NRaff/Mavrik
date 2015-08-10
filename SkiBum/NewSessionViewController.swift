//
//  NewSessionViewController.swift
//  SkiBum
//
//  Created by Nick Raff on 7/27/15.
//  Copyright (c) 2015 Nick Raff. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import CoreLocation
import Mixpanel

class NewSessionViewController: UIViewController {

    let mixpanel: Mixpanel = Mixpanel.sharedInstance()
    
    var locationInfo = LocationHelper()
    var isAddSession = true
    var currentSession: Session?
    var newSpeed:CLLocationSpeed = 0
    var maxSpeed:CLLocationSpeed?
    var newAltitude: CLLocationDistance = 0
    var peakAltitude: CLLocationDistance?
    var startLocation: CLLocation?
    var nextLocation: CLLocation?
    var totalDistance: CLLocationDistance = 0
    
    var statsTimer: NSTimer?
    var sessionDuration: NSTimer?
    var aveVelocity: NSTimer?
    
    var seconds: Int = 0
    var minutes: Int = 0
    var hours: Int = 0
    var ventureTime: String = ""
    var metricConversionKPH = 3.6
    var metricConversionKM = 0.001
    var imperialConvMPH = 2.23694
    var imperialConvMi = 0.000621371
    var imperialConvFt = 3.28084
    
    var averageSpeedArray = [CLLocationSpeed]()
    var sumSpeeds: CLLocationSpeed = 0
    var averageSpeed: Double = 0
    
    var backImageID: Int = 0
    
    let settings = SettingsViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTrek_tf.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        locationInfo.startLocation()
        //if user is adding a session then display the add fields
        
        if isAddSession == true {
            backImageID = Int(arc4random_uniform(8) + 1)
            backImage.image = UIImage(named: "detailsbg\(backImageID)")
            back_btn.hidden = true
            sessionTime.hidden = true
            titleLabel.hidden = true
            end_btn.hidden = true
            nameTrek_tf.attributedPlaceholder = NSAttributedString(string:"NAME YOUR TREK",
                attributes:[NSForegroundColorAttributeName: UIColor.lightTextColor()])
            
            //Mixpanel.sharedInstanceWithToken("28c4af140f3b0963fca2c97bbbca2d84")
//            let mixpanel: Mixpanel = Mixpanel.sharedInstance()
            mixpanel.track("Add Session Started", properties: ["Event": "Opened Scene"])
            
        }
            
        //otherwise hide the editable fields and display the recorded topspeed and peak altitude
        else{
            unhideNeeded()
            hideUnneeded()
            end_btn.hidden = true
            titleLabel.text = currentSession!.sessionTitle
            sessionTime.text  = currentSession!.sessionTime
            backImage.image = UIImage(named: "detailsbg\(currentSession!.imageID)")
//            mixpanel.track("Viewing Old Session")
            
            if currentSession!.sessionMeasuredIn == false {
            topSpeed_lb.text = toString(currentSession!.topSpeed) + " mph"
            peakAltitude_lb.text = toString(currentSession!.peakAltitude) + " ft"
            totalDistance_lb.text = toString(currentSession!.totalDistance) + " mi"
            currentSpeed_lb.text = "\(currentSession!.averageSpeed) mph"
            }
                
            else {
                topSpeed_lb.text = toString(currentSession!.topSpeed) + " kph"
                peakAltitude_lb.text = toString(currentSession!.peakAltitude) + " m"
                totalDistance_lb.text = toString(currentSession!.totalDistance) + " km"
                currentSpeed_lb.text = "\(currentSession!.averageSpeed) kph"
            }
            mixpanel.track("Old Session", properties: ["Viewing?": "Opened Old Session"])
        }

       //update the different stats every second
       self.statsTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateCurrentStats", userInfo: nil, repeats: true)

}

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    @IBOutlet weak var end_btn: UIButton!
    @IBOutlet weak var totalDistance_lb: UILabel!
    @IBOutlet weak var currentSpeed_lb: UILabel!
    @IBOutlet weak var topSpeed_lb: UILabel!
    @IBOutlet weak var currentAltitude_lb: UILabel!
    @IBOutlet weak var peakAltitude_lb: UILabel!
    @IBOutlet weak var sessionTime: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTrek_tf: UITextField!
    @IBOutlet weak var cancel_btn: UIButton!
    @IBOutlet weak var startNew_btn: UIButton!
    @IBOutlet weak var back_btn: UIButton!
    
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var editView: UIView!
    
    
    func unhideNeeded(){
       back_btn.hidden = false
       titleLabel.hidden = false
       sessionTime.hidden = false
       end_btn.hidden = false
    }
    
    func hideUnneeded(){
        nameTrek_tf.hidden = true
        cancel_btn.hidden = true
        startNew_btn.hidden = true
        editView.hidden = true
    }
    
    
    @IBAction func backCancelButton(sender: AnyObject) {
        if isAddSession == true {
        var cancelAlert = UIAlertController(title: "Cancel Session?", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        cancelAlert.addAction(UIAlertAction(title: "Save & Exit", style: .Default, handler: { (action: UIAlertAction!) in
            self.saveStuff()
            self.mixpanel.track("Back/Cancel Alert", properties: ["Options": "Save Session (Alert)"])
            self.performSegueWithIdentifier("segueToAlert", sender: nil)
        }))
        
        cancelAlert.addAction(UIAlertAction(title: "Keep Shredding!", style: .Default, handler: { (action: UIAlertAction!) in
            self.mixpanel.track("Back/Cancel Alert", properties: ["Options": "Continue Session (Alert)"])
            }))
        
        presentViewController(cancelAlert, animated: true, completion: nil)
        }
        else {
            self.performSegueWithIdentifier("segueToAlert", sender: nil)
            mixpanel.track("Old Session", properties: ["Viewing?": "No - Left Session"])
        }
    }
    
    @IBAction func startNewSessionBtn(sender: AnyObject) {
        
        if nameTrek_tf.text != "" {
        mixpanel.track("Add Session Started", properties: ["Recording": "Check Button - OK"])
        hideUnneeded()
        aveVelocity = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "getAverageSpeed", userInfo: nil, repeats: true)
        sessionDuration = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "tripDuration", userInfo: nil, repeats: true)
        titleLabel.text = nameTrek_tf.text
        nameTrek_tf.resignFirstResponder()
        unhideNeeded()
        
        }
            
        else {
            //if the user didn't give the session a name, then give this error message
            let alert = UIAlertView()
            alert.title = "Oops!"
            alert.message = "Make sure you've named your trip!"
            alert.addButtonWithTitle("OK")
            alert.show()
            mixpanel.track("Add Session Started", properties: ["Recording": "Check Button - Needs Name"])
        }

    }
    
    @IBAction func endButton(sender: AnyObject) {
        saveStuff()
        self.performSegueWithIdentifier("segueToAlert", sender: nil)
        mixpanel.track("Back/Cancel Alert", properties: ["Options": "Saved with End"])
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        locationInfo.locationManager.stopUpdatingLocation()
        startLocation = nil
        nextLocation = nil
        statsTimer?.invalidate()
        sessionDuration?.invalidate()
        aveVelocity?.invalidate()
    }

}

extension NewSessionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if nameTrek_tf.text != "" {
            
            hideUnneeded()
            aveVelocity = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "getAverageSpeed", userInfo: nil, repeats: true)
            sessionDuration = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "tripDuration", userInfo: nil, repeats: true)
            titleLabel.text = nameTrek_tf.text
            nameTrek_tf.resignFirstResponder()
            unhideNeeded()
            mixpanel.track("Add Session Started", properties: ["Recording": "Keyboard 'GO' - OK"])
        }
            
        else {
            //if the user didn't give the session a name, then give this error message
            let alert = UIAlertView()
            alert.title = "Oops!"
            alert.message = "Make sure you've named your trip!"
            alert.addButtonWithTitle("OK")
            alert.show()
            mixpanel.track("Add Session Started", properties: ["Recording": "Keyboard 'GO' - Needs Name"])
        }
        return true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        nameTrek_tf.resignFirstResponder()
        
    }
}

//MARK: - All Helper Functions

extension NewSessionViewController {
    func saveStuff(){
        if isAddSession == true && cancel_btn.hidden == true {
            currentSession = Session()
            
            currentSession?.imageID = backImageID
            currentSession?.sessionTitle = nameTrek_tf.text
            currentSession?.Date = NSDate()
            
            if Session.measureSwitch == false {
                currentSession?.sessionMeasuredIn = false
                currentSession?.topSpeed = Double(round(maxSpeed! * imperialConvMPH * 100)/100)
                currentSession?.peakAltitude = Double(round(peakAltitude! * imperialConvFt * 100)/100)
                currentSession?.totalDistance = Double(round(totalDistance * imperialConvMi * 100)/100)
                currentSession?.averageSpeed = round(averageSpeed * imperialConvMPH * 100)/100
            }
            else {
                currentSession?.sessionMeasuredIn = true
                currentSession?.topSpeed = Double(round(maxSpeed! * metricConversionKPH * 100)/100)
                currentSession?.peakAltitude = Double(round(peakAltitude! * 100)/100)
                currentSession?.totalDistance = Double(round(totalDistance * metricConversionKM * 100)/100)
                currentSession?.averageSpeed = round(averageSpeed * metricConversionKPH * 100)/100
            }
            
            currentSession?.sessionTime = "TIME ADVENTURING: " + ventureTime
            println(toString(totalDistance))
            let realm = Realm()
            realm.write() {
                realm.add(self.currentSession!)
            }
        }
    }
    
    func updateCurrentStats(){
        if isAddSession == true {
            if Session.measureSwitch == false {
                println(locationInfo.locationManager.location)
                if locationInfo.locationManager.location != nil {
                    if locationInfo.locationManager.location.altitude > 0 {
                        currentAltitude_lb.text = toString(round(locationInfo.locationManager.location.altitude * imperialConvFt * 1000)/1000) + " ft"
                    }
                    else{
                        currentAltitude_lb.text = "0.0 ft"
                    }
                }
                else {
                  currentAltitude_lb.text = "- . - ft"
                }
            }
            else {
                if locationInfo.locationManager.location != nil {
                    if locationInfo.locationManager.location.altitude > 0 {
                        currentAltitude_lb.text = toString(round(locationInfo.locationManager.location.altitude * 100)/100) + " m"
                    }
                    else{
                        currentAltitude_lb.text = "0.0 m"
                    }
                }
                else {
                   currentAltitude_lb.text = "- - - -"
                }
            }
        
            getTopSpeed()
            getPeakAltitude()
            getTotalDistance()
        }
        else {
            if currentSession!.sessionMeasuredIn == false {
                currentAltitude_lb.text = toString(round(locationInfo.locationManager.location.altitude * imperialConvFt * 1000)/1000) + " ft"
            }
            else {
               currentAltitude_lb.text = toString(round(locationInfo.locationManager.location.altitude * 100)/100) + " m"
            }
        }
    }
    
    func getTopSpeed(){
        if locationInfo.locationManager.location != nil {
            if locationInfo.locationManager.location.speed >= 0 {
                newSpeed = locationInfo.locationManager.location.speed
                if maxSpeed != nil {
                    //find the maxSpeed
                    if newSpeed > maxSpeed {
                        maxSpeed = newSpeed
                        if Session.measureSwitch == false {
                            topSpeed_lb.text = toString(round(maxSpeed! * imperialConvMPH * 100)/100) + " mph"
                        }
                        else{
                            topSpeed_lb.text = toString(round(maxSpeed! * metricConversionKPH * 100)/100) + " kph"
                        }
                    }
                }
                else {
                    //just display the most recently recorded speed
                    maxSpeed = newSpeed
                    if Session.measureSwitch == false {
                        topSpeed_lb.text = toString(round(newSpeed * imperialConvMPH * 100)/100) + " mph"
                    }
                    else {
                        topSpeed_lb.text = toString(round(newSpeed * metricConversionKPH * 100)/100) + " kph"
                    }
                }
            }
            else {
                newSpeed = 0.0
                    if maxSpeed == nil {
                        maxSpeed = 0.0
                    }
                topSpeed_lb.text = "- - - -"
            }
        }
    }
    
    func getPeakAltitude(){
        if locationInfo.locationManager.location != nil {
            if locationInfo.locationManager.location.altitude > 0 {
                newAltitude = locationInfo.locationManager.location.altitude
                if peakAltitude != nil {
                    if newAltitude > peakAltitude {
                        peakAltitude = newAltitude
                        if Session.measureSwitch == false {
                            peakAltitude_lb.text = toString(round(peakAltitude! * imperialConvFt * 100)/100) + " ft"
                        }
                        else {
                            peakAltitude_lb.text = toString(round(peakAltitude! * 100)/100) + " m"
                        }
                    }
                }
                else {
                    peakAltitude = newAltitude
                    if Session.measureSwitch == false {
                        peakAltitude_lb.text = toString(round(newAltitude * imperialConvFt * 100)/100) + " ft"
                    }
                    else {
                        peakAltitude_lb.text = toString(round(newAltitude * 100)/100) + " m"
                    }
                }
            }
        }
        else {
            peakAltitude_lb.text = "- - - -"
        }
    }
    
    func getTotalDistance(){
        if locationInfo.locationManager.location != nil {
            if startLocation == nil {
                startLocation = locationInfo.locationManager.location
                if Session.measureSwitch == false {
                    totalDistance_lb.text = toString(round(totalDistance * imperialConvMi * 1000)/1000) + " mi"
                }
                else {
                    totalDistance_lb.text = toString(round(totalDistance * metricConversionKM * 1000)/1000) + " km"
                }
            }
            else {
                nextLocation = locationInfo.locationManager.location
                totalDistance += nextLocation!.distanceFromLocation(startLocation)
                startLocation = nextLocation
                if Session.measureSwitch == false {
                    totalDistance_lb.text = toString(round(totalDistance * imperialConvMi * 1000)/1000) + " mi"
                }
                else {
                    totalDistance_lb.text = toString(round(totalDistance * metricConversionKM * 1000)/1000) + " km"
                }
            }
        }
        else {
                totalDistance_lb.text = "- - - -"
        }
    }
    
    func getAverageSpeed(){
        if locationInfo.locationManager.location != nil {
            if locationInfo.locationManager.location.speed > 0 {
                averageSpeedArray.append(locationInfo.locationManager.location.speed)
            }
            else {
                averageSpeedArray.append(0.0)
            }
            
            if averageSpeedArray.count < 2 {
                averageSpeed = Double(averageSpeedArray[0])
                sumSpeeds = averageSpeedArray[0]
            }
            else {
                sumSpeeds += averageSpeedArray.last!
                averageSpeed = Double(sumSpeeds)/Double(averageSpeedArray.count)
            }
            if Session.measureSwitch == false {
                currentSpeed_lb.text = "\(round(averageSpeed * imperialConvMPH * 100)/100) mph"
            }
            else {
                currentSpeed_lb.text = "\(round(averageSpeed * metricConversionKPH * 100)/100) kph"
            }
        }
    }
    
    func tripDuration(){
        seconds++
        if seconds > 59 {
            seconds = 0
            minutes++
        }
        if minutes > 59 {
            minutes = 0
            hours++
        }
        adventureTime()
    }
    
    func adventureTime() {
        if hours < 10 && minutes < 10 && seconds < 10 {
            ventureTime = "0\(hours).0\(minutes).0\(seconds)"
        }
        else {
            if hours < 10 && minutes < 10 && seconds > 9 {
                ventureTime = "0\(hours).0\(minutes).\(seconds)"
            }
            else {
                if hours < 10 && minutes > 9 && seconds < 10 {
                    ventureTime = "0\(hours).\(minutes).0\(seconds)"
                }
                else {
                    if hours < 10 && minutes > 9 && seconds > 9 {
                        ventureTime = "0\(hours).\(minutes).\(seconds)"
                    }
                    else {
                        if hours > 9 && minutes < 10 && seconds < 10 {
                            ventureTime = "\(hours).0\(minutes).0\(seconds)"
                        }
                        else {
                            if hours > 9 && minutes < 10 && seconds > 9 {
                                ventureTime = "\(hours).0\(minutes).\(seconds)"
                            }
                            else {
                                if hours > 9 && minutes > 9 && seconds < 10 {
                                    ventureTime = "\(hours).\(minutes).0\(seconds)"
                                }
                                else {
                                    if hours > 9 && minutes > 9 && seconds > 9 {
                                        ventureTime = "\(hours).\(minutes).\(seconds)"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        sessionTime.text = "ACTIVE SESSION: " + ventureTime
    }

}