//
//  ViewController.swift
//  VehicleTrackingApp
//
//  Created by UmarFarooq on 29/09/2021.
//

import UIKit
import FirebaseDatabase
import Toast_Swift
import CoreLocation

class ViewController: UIViewController {

    var ref: DatabaseReference?
    var dbHandle: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ref = Database.database().reference()
        
        //------------Add Node Operation
        
        /*
        ref?.child("Drivers/\("driver1")/driverId").setValue(22)
        ref?.child("Drivers/\("driver1")/driverLat").setValue(24.2323232323)
        ref?.child("Drivers/\("driver1")/driverLong").setValue(65.2323232323)
        ref?.child("Drivers/\("driver1")/rideId").setValue(34)
        */
        
        
        
        
        
        
        
        
        
        //ref?.child("Drivers/\("driver707")/driverId").setValue(12)
        //ref?.child("Drivers/driverId").setValue(12)
        //ref?.child("Drivers/Abc").setValue(14)
        //ref?.child("Driver/driverid").setValue(13, withCompletionBlock: { error, dbref in
        
            
        
        //------------Update Node Operation
        /*
        guard let key = ref?.child("Drivers").child("driver1").key else { return }
        let driver = [
                    "driver1": "1",
                    "driverLat": "24.457893475",
                    "driverLong": "64.23847824",
                    "rideId": "55"
                    ]
        
        let childUpdates = ["/Drivers/\(key)": driver]
        ref?.updateChildValues(childUpdates)
        */
        
        //------------Delete Node Operation
        /*
        guard (ref?.child("Drivers").child("driver2").key) != nil else { return }
        let deleteRef = ref?.child("Drivers").child("driver2").ref
        deleteRef?.removeValue(completionBlock: { error, ref in
            print(error.debugDescription)
        })*/
        
        //-------------Change Event Node
        /*
        if ref != nil {
            let firebase = "Drivers/driver1"
            
            dbHandle = ref?.child(firebase).observe(DataEventType.value, with: { (snapshot) in
                //self.ref.child(firebase).removeValue()
                let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                var lat: String = ""
                var long: String = ""
                
                print("Observer received..........")
                
                if let latValue = postDict["driverLat"] as? String {
                    lat = latValue
                }
                
                if let longValue = postDict["driverLong"] as? String {
                    long = longValue
                }
                
                if lat == "" || long == "" {
                    return
                }
                
                if let duration = postDict["duration"] as? String {
                    //showDialogWithOneButton(animated: true, viewControl: self, titleMsg: "" , msgTitle: "Your driver is \(duration) Away")
                }
                //self.showDriverMarker(lat: Double(lat)!, long: Double(long)!)
                
            })
        }*/
        
        
        BackgroundLocationManager.instance.delegate = self
        BackgroundLocationManager.instance.start()
    }
    
    func showToast(animated: Bool = true, viewControl: UIViewController, titleMsg: String, msgTitle: String) {
        //viewControl.view.makeToast(msgTitle, duration: 3.0, position: .center)
        
        viewControl.view.makeToast(msgTitle, duration: 2.0, point: CGPoint(x: viewControl.view.frame.width/2, y: viewControl.view.frame.size.height - 100), title: "", image: nil) { didTap in //UIImage(named: "warning-icon")
        }
    }
      


}

extension ViewController: sendCoordinatesDelegate{
    func sendLocation(coordinates: CLLocationCoordinate2D) {
        showToast(viewControl: self, titleMsg: "", msgTitle: "Latitude= \(coordinates.latitude), Longitude= \(coordinates.longitude)")
    }
}

