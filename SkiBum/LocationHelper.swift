//
//  LocationHelper.swift
//  SkiBum
//
//  Created by Nick Raff on 7/24/15.
//  Copyright (c) 2015 Nick Raff. All rights reserved.
//
//import UIKit
import Foundation
import CoreLocation


class LocationHelper: NSObject {
    
    let locationManager = CLLocationManager()
    var speed: CLLocationSpeed?
    var altitude: CLLocationDistance?
    var timeStamp: NSDate?
    var startingLocation: CLLocation!
    
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
    
    var newSpeed:CLLocationSpeed = 0
    var maxSpeed:CLLocationSpeed?
    var newAltitude: CLLocationDistance = 0
    var peakAltitude: CLLocationDistance?
    var startLocation: CLLocation?
    var nextLocation: CLLocation?
    var totalDistance: CLLocationDistance = 0
    
    var finalTopSpeed: Double = 0.0
    var highAltitude: Double = 0.0
    var finalDistance: Double = 0.0
    var finalAveSpeed: Double = 0.0
    
    func startedLocation(){
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            //locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            println("Location services are not enabled");
        }
    }

}

//MARK: All statistics functions
extension LocationHelper {
    func getTopSpeed() -> Double {
        if locationManager.location != nil {
            if locationManager.location.speed >= 0 {
                newSpeed = locationManager.location.speed
                if maxSpeed != nil {
                    //find the maxSpeed
                    if newSpeed > maxSpeed {
                        maxSpeed = newSpeed
                        if Session.measureSwitch == false {
                            finalTopSpeed = (round(maxSpeed! * imperialConvMPH * 100)/100)
                        }
                        else{
                            finalTopSpeed = (round(maxSpeed! * metricConversionKPH * 100)/100)
                        }
                    }
                }
                else {
                    //just display the most recently recorded speed
                    maxSpeed = newSpeed
                    if Session.measureSwitch == false {
                        finalTopSpeed = (round(newSpeed * imperialConvMPH * 100)/100)
                    }
                    else {
                        finalTopSpeed = (round(newSpeed * metricConversionKPH * 100)/100)
                    }
                }
            }
            else {
                newSpeed = 0.0
                if maxSpeed == nil {
                    maxSpeed = 0.0
                    finalTopSpeed = 0.0
                }
            }
        }
        else{
            if finalTopSpeed == 0.0 {
            finalTopSpeed = 0.0
            }
        }
        return finalTopSpeed
    }

    func getPeakAltitude() -> Double{
        if locationManager.location != nil {
            if locationManager.location.altitude >= 0 {
                newAltitude = locationManager.location.altitude
                if peakAltitude != nil {
                    if newAltitude > peakAltitude {
                        peakAltitude = newAltitude
                        if Session.measureSwitch == false {
                           highAltitude = round(peakAltitude! * imperialConvFt * 100)/100
                        }
                        else {
                            highAltitude = round(peakAltitude! * 100)/100
                        }
                    }
                }
                else {
                    peakAltitude = newAltitude
                    if Session.measureSwitch == false {
                        highAltitude = round(newAltitude * imperialConvFt * 100)/100
                    }
                    else {
                        highAltitude = round(newAltitude * 100)/100
                    }
                }
            }
        }
        else {
            if highAltitude == 0.0 {
            highAltitude = 0.0
            }
        }
        
       return highAltitude
    }

    func getTotalDistance() -> Double {
        if locationManager.location != nil {
            if startLocation == nil {
                startLocation = locationManager.location
                if Session.measureSwitch == false {
                    finalDistance = round(totalDistance * imperialConvMi * 1000)/1000
                }
                else {
                    finalDistance = round(totalDistance * metricConversionKM * 1000)/1000
                }
            }
            else {
                nextLocation = locationManager.location
                totalDistance += nextLocation!.distanceFromLocation(startLocation)
                startLocation = nextLocation
                if Session.measureSwitch == false {
                    finalDistance = round(totalDistance * imperialConvMi * 1000)/1000
                }
                else {
                    finalDistance = round(totalDistance * metricConversionKM * 1000)/1000
                }
            }
        }
        else {
            if finalDistance == 0.0 {
                finalDistance = 0.0
            }
        }
        
        return finalDistance
    }
    
    func getAverageSpeed() -> Double{
        if locationManager.location != nil {
            if locationManager.location.speed >= 0 {
                averageSpeedArray.append(locationManager.location.speed)
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
                finalAveSpeed = round(averageSpeed * imperialConvMPH * 100)/100
            }
            else {
                finalAveSpeed = round(averageSpeed * metricConversionKPH * 100)/100
            }
        }
        
        return finalAveSpeed
    }
    
    func getAltitudeSkied(){
        //formula to find total ft skiied rather than sitting on the lift
        //use if statements to determine if user is going downhill
        //if user is going downhill then calculate how many feet downhill
        //keep updating the total like total distance
    }
    

    func tripDuration() -> String {
        seconds++
        if seconds > 59 {
            seconds = 0
            minutes++
        }
        if minutes > 59 {
            minutes = 0
            hours++
        }
        return adventureTime()
    }
    
    func adventureTime() -> String {
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
        
        return ventureTime
    }
    

}

extension LocationHelper: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        //removeLoadingView()
        if ((error) != nil) {
            print(error)
            println("Nope you broke it")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as! CLLocation
        var coord = locationObj.coordinate
        
         speed = locationObj.speed
         timeStamp = locationObj.timestamp
         altitude = locationObj.altitude
//        println(coord.latitude)
//        println(coord.longitude)
//        println(speed)
//        println(altitude)
//        println(timeStamp)
    }
}