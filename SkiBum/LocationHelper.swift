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
    
    func startLocation(){
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