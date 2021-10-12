//
//  LocationUpdate.swift
//  SafeTruck-Passenger
//
//  Created by UmarFarooq on 15/09/2021.
//  Copyright © 2021 UmarFarooq. All rights reserved.
//


/*
<key>NSLocationAlwaysUsageDescription</key>
<string>Vehicle Tracking App uses locations services to fetch nearby restaurants.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Vehicle App uses locations services to fetch nearby restaurants.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Vehicle App uses locations services to fetch nearby restaurants.</string>
*/

/*
<key>DATABASE_URL</key>
<string>https://vehicletrackingapp-7729a-default-rtdb.firebaseio.com/</string>
 */


import UIKit
import Foundation
import CoreLocation
import FirebaseDatabase
import Toast_Swift

protocol sendCoordinatesDelegate {
    func sendLocation(coordinates: CLLocationCoordinate2D)
}

class BackgroundLocationManager :NSObject, CLLocationManagerDelegate {

    var delegate: sendCoordinatesDelegate?
    
    static let instance = BackgroundLocationManager()
    static let BACKGROUND_TIMER = 3.0 //150.0 // restart location manager every 150 seconds
    static let UPDATE_SERVER_INTERVAL = 4 //60 * 60 // 1 hour - once every 1 hour send location to server

    let locationManager = CLLocationManager()
    var timer: Timer?
    var currentBgTaskId: UIBackgroundTaskIdentifier?
    var lastLocationDate: NSDate = NSDate()
    
    var ref: DatabaseReference? //db refrence

    private override init(){
        super.init()
        ref = Database.database().reference()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .otherNavigation;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        if #available(iOS 9, *){
            locationManager.allowsBackgroundLocationUpdates = true
        }

        
        //Backgroud task to let user keep track latest coordinates
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
    }

    @objc func applicationEnterBackground(){
        print("applicationEnterBackground")
        start()
    }

    func start(){
        
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            if #available(iOS 9, *){
                locationManager.requestLocation()
            } else {
                locationManager.startUpdatingLocation()
            }
        }else {
                locationManager.requestAlwaysAuthorization()
        }
    }
    
    func stop(){
        timer?.invalidate()
        timer = nil
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        locationManager.stopUpdatingLocation()
    }
    
    
    @objc func restart (){
        timer?.invalidate()
        timer = nil
        start()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.restricted:
            print("Restricted Access to location")
        case CLAuthorizationStatus.denied:
            print("User denied access to location")
        case CLAuthorizationStatus.notDetermined:
            print("Status not determined")
        default:
            //log("startUpdatintLocation")
            if #available(iOS 9, *) {
                locationManager.requestLocation()
            } else {
                locationManager.startUpdatingLocation()
            }
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if(timer==nil){
            // The locations array is sorted in chronologically ascending order, so the
            // last element is the most recent
            guard locations.last != nil else {return}
            
            guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
            print("locations = \(locValue.latitude) \(locValue.longitude)")

            beginNewBackgroundTask()
            locationManager.stopUpdatingLocation()
            let now = NSDate()
            if(isItTime(now: now)){
                //TODO: Every n minutes do whatever you want with the new location. Like for example sendLocationToServer(location, now:now)
                print("Send location to Server...........")
                //self.view.makeToast(msgTitle, duration: 3.0, position: .center)
                
                //Update Node Operation on Firebase
                guard let key = ref?.child("Drivers").child("driver2").key else { return }
                let driver = [
                            "driver1": "1",
                            "driverLat": "\(locValue.latitude)",
                            "driverLong": "\(locValue.longitude)",
                            "rideId": "55"
                            ]
                
                self.delegate?.sendLocation(coordinates: locValue)
                
                let childUpdates = ["/Drivers/\(key)": driver]
                ref?.updateChildValues(childUpdates)
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")

        beginNewBackgroundTask()
        locationManager.stopUpdatingLocation()
    }


    func isItTime(now:NSDate) -> Bool {
        let timePast = now.timeIntervalSince(lastLocationDate as Date)
        let intervalExceeded = Int(timePast) > BackgroundLocationManager.UPDATE_SERVER_INTERVAL
        return intervalExceeded;
    }

    func beginNewBackgroundTask(){
        var previousTaskId = currentBgTaskId;
        currentBgTaskId = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            print("task expired: ")
        })
        
        if let taskId = previousTaskId{
            UIApplication.shared.endBackgroundTask(taskId)
            previousTaskId = UIBackgroundTaskIdentifier.invalid
        }

        timer = Timer.scheduledTimer(timeInterval: BackgroundLocationManager.BACKGROUND_TIMER, target: self, selector: #selector(self.restart),userInfo: nil, repeats: false)
        
    }
}
