//
//  EventMapByTouchVC.swift
//  pickup
//
//  Created by christian landa on 10/25/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase

class EventMapByTouchVC: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    
    var addressButton: String!
    var fullAddressStringByTouch: String!
    var fullAddressString_no_breakLineByTouch: String!
    var placemark: String!
    
    
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters    // kCLLocationAccuracyNearestTenMeters
        _locationManager.activityType = .Fitness
        
        // Movement threshold for new events
        _locationManager.distanceFilter = 10.0
        return _locationManager
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        var uilgr = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")
        uilgr.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(uilgr)
        

    }
    @IBAction func saveBtnFn(sender: AnyObject) {
        
        performSegueWithIdentifier("segue_ToAddVC", sender: nil)
        
    }

        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segue_ToAddVC"
        {

            let destinationVC = segue.destinationViewController as? AddVC

            destinationVC!.fullAddressStringByTouch =  self.fullAddressStringByTouch

            destinationVC!.fullAddressString_no_breakLineByTouch =  self.fullAddressString_no_breakLineByTouch
            
            destinationVC!.self.placemark = self.placemark

        }
    }
    
    @IBAction func doneBtnFn(sender: AnyObject) {
       
    performSegueWithIdentifier("segue_ToAddVC_No_DATA", sender: nil)
        
//        let backItem = UIBarButtonItem()
//    
//        backItem.title = ""
//        navigationItem.backBarButtonItem = backItem
        
       
//        let mapViewControllerObj = self.storyboard?.instantiateViewControllerWithIdentifier("AddVC") as? AddVC
//        self.navigationController?.pushViewController(mapViewControllerObj!, animated: true)
//       
    }

    
    func addAnnotation(gestureRecognizer:UIGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                
                if placemarks!.count > 0 {
                    let pm = placemarks![0]
                    
                    // not all places have thoroughfare & subThoroughfare so validate those values
//                    annotation.title =  pm.subThoroughfare! + ", " + pm.thoroughfare!
//                    annotation.subtitle = pm.subLocality
                    self.mapView.addAnnotation(annotation)
                    print("Print PM: \(pm)")
                    // self.displayLocationInfo(pm)
                    
                    if let city = pm.locality,
                        let state = pm.administrativeArea {
                        
                        var locationName = pm.name
                        if locationName == "nil" || locationName == nil{
                            locationName = ""
                        } else {
                            locationName = pm.name
                        }
                        
                        
                        var locationNumber = pm.subThoroughfare
                        
                        if locationNumber == nil || locationNumber == "nil" {
                            locationNumber = ""
                        } else {
                            locationNumber = (pm.subThoroughfare)
                        }
                        
                        
                        var locationStreet = pm.thoroughfare
                        // var locationStreet2:String?
                        
                        if locationStreet! == "nil" || locationStreet == nil {
                            locationStreet = ""
                        } else {
                            locationStreet = pm.thoroughfare
                        }
                        
                        
                        annotation.title =  locationNumber! + ", " + locationStreet!
                        annotation.subtitle = pm.subLocality
                        
                        annotation.subtitle = "\(city) \(state)"
                        
                        // Full Address to be Displayed
                        print("Placemark@@@@@@@@: \(pm)")
                        
                        self.placemark = "\(pm)"
                        
                        // self.fullAddressString =  "\(placemark.name!)\n \(placemark.subThoroughfare!) \(placemark.thoroughfare!) \n \(city), \(state)"
                        // print("New Address: \(self.fullAddressString)")
                        
                        
                        self.fullAddressStringByTouch =  "\(locationName!)\n \(locationNumber!) \(locationStreet!) \n \(city), \(state)"
                        print("New Address: \(self.fullAddressStringByTouch)")
                        
                        // String Without  \n
                        
                        self.fullAddressString_no_breakLineByTouch =  "\(locationName!) \(locationNumber!) \(locationStreet!)  \(city), \(state)"
                        print("New Address 2: \(self.fullAddressString_no_breakLineByTouch)")
                        
                        self.mapView.addAnnotation(annotation)
                        
                        let span = MKCoordinateSpanMake(0.05, 0.05)
                      //  let region = MKCoordinateRegionMake(placemark., span)
                        
                     //   mapView.setRegion(region, animated: true)
                    } else {
                        
                        self.typeInSomethingAlert()
                    }
                    
                    
                }
                else {
                    annotation.title = "Unknown Place"
                    self.mapView.addAnnotation(annotation)
                    print("Problem with the data received from geocoder")
                }
                //  places.append(["name":annotation.title,"latitude":"\(newCoordinates.latitude)","longitude":"\(newCoordinates.longitude)"])
                
                
                //self.mapView!.addAnnotation(annotation)
            })
        }
    }
    
    func typeInSomethingAlert(){
        let optionMenu = UIAlertController(title: nil, message: "Can't Be Saved! Try another one! ", preferredStyle: .ActionSheet)
        
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

   

}

extension EventMapByTouchVC : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            
            
            var location:CLLocationCoordinate2D = (manager.location?.coordinate)!
            
            // self.latitude = location.latitude
            // self.longitude = location.longitude
            
            
            print("location:: \(location)")
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: (error)")
    }
    
}
