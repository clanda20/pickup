//
//  EventMapByTouchVC.swift
//  pickup
//
//  Created by christian landa on 10/25/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseMessaging
import FirebaseStorage
import FirebaseDatabase
import AddressBookUI

class EventMapByTouchVC: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    
    var addressButton: String!
    var fullAddressStringByTouch: String!
    var fullAddressString_no_breakLineByTouch: String!
   var placemark: String!
   // var annotation: MKPointAnnotation!
    
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
//    var titleTextField: String!
//    
//    var descriptionTextView: String!
//    
//    var dateRaw: String!

    
    
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters    // kCLLocationAccuracyNearestTenMeters
        _locationManager.activityType = .automotiveNavigation
        
        // Movement threshold for new events
        _locationManager.distanceFilter = 10.0
        return _locationManager
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.none
        mapView.showsTraffic = true
        mapView.showsScale = true
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        
        mapView.showsUserLocation = true
        
        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(MKMapView.addAnnotation(_:)))
        uilgr.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(uilgr)
        
//        print("titleTextField    : \(titleTextField)")
//        print("descriptionTextView    : \(descriptionTextView)")
//        print("dateRaw    : \(dateRaw)")
//        

    }
    @IBAction func saveBtnFn(sender: AnyObject) {
        
        performSegue(withIdentifier: "segue_ToAddVC", sender: nil)
        
    }

    
    @IBAction func doneBtnFn(sender: AnyObject) {
       
    performSegue(withIdentifier: "segue_ToAddVC_No_DATA", sender: nil)
        
      
    }

    override func prepare(for forsegue: UIStoryboardSegue, sender: Any?) {
        if forsegue.identifier == "segue_ToAddVC"
        {
            
            let destinationVC = forsegue.destination as? AddVC
            
            destinationVC!.fullAddressStringByTouch =  self.fullAddressStringByTouch
            
            destinationVC!.fullAddressString_no_breakLineByTouch =  self.fullAddressString_no_breakLineByTouch
            
            destinationVC!.self.placemark = self.placemark
            
            destinationVC!.self.latitude = self.latitude
            
            destinationVC!.self.longitude = self.longitude
            
            
            //            destinationVC!.titleTextFieldSegue =  self.titleTextField
            //
            //            destinationVC!.descriptionTextViewSegue =  self.descriptionTextView
            //
            //            destinationVC!.dateRaw = self.dateRaw
            
        }
        
       
        
    }
    
    func addAnnotation(_ gestureRecognizer:UIGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
               
                
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                
//                var addressString = ABCreateStringWithAddressDictionary(placemark.addressDictionary, true)
//                addressString = addressString.stringByReplacingOccurrencesOfString("\n", withString: ", ")
//                cell.textLabel?.text = addressString
//
                
                if error == nil, let pm = placemarks, !pm.isEmpty {
                
                print("PLACEMARK: \( placemarks!)")
                    
                self.latitude   = newCoordinates.latitude
                self.longitude  = newCoordinates.longitude
                    
                 print("PLACEMARK Latitude: \( newCoordinates.latitude)")
                 print("PLACEMARK Longitude: \( newCoordinates.longitude)")
                    
              //  var LocationActual: CLLocation = CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
                    
                    var LocationActual: CLLocation = CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
                
                if placemarks!.count > 0 {
                    let pm = placemarks![0]
                    
//                    if let addressDict = placemarks.addressDictionary, coordinate = LocationActual {
//                        let mkPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
//                    }
                    
//                    let firstPlacemark:CLPlacemark = placemarks![1]
//                    let  mapPlacemark = MKPlacemark(placemark: firstPlacemark)
                    
                  //   print("PLACEMARK mapPlacemark: \(mkPlacemark)")
                    
                    // not all places have thoroughfare & subThoroughfare so validate those values
//                    annotation.title =  pm.subThoroughfare! + ", " + pm.thoroughfare!
//                    annotation.subtitle = pm.subLocality
                    self.mapView.addAnnotation(annotation )
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
                        
                       
                        
                        // self.fullAddressString =  "\(placemark.name!)\n \(placemark.subThoroughfare!) \(placemark.thoroughfare!) \n \(city), \(state)"
                        // print("New Address: \(self.fullAddressString)")
                        
                        
                        self.fullAddressStringByTouch =  "\(locationName!)\n \(locationNumber!) \(locationStreet!) \n \(city), \(state)"
                        print("New Address: \(self.fullAddressStringByTouch)")
                        
                        // String Without  \n
                        
                        self.fullAddressString_no_breakLineByTouch =  "\(locationName!) \(locationNumber!) \(locationStreet!)  \(city), \(state)"
                        print("New Address 2: \(self.fullAddressString_no_breakLineByTouch)")
                        
                        
                         self.placemark = "\(self.fullAddressString_no_breakLineByTouch), \( newCoordinates.latitude), \( newCoordinates.longitude)"
                        
                        self.mapView.addAnnotation(annotation)
                        
                        let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
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
                    
                } // end of the  if error == nil, let p = placemarks where !p.isEmpty
            })
        }
    }
    
    func typeInSomethingAlert(){
        let optionMenu = UIAlertController(title: nil, message: "Can't Be Saved! Try another one! ", preferredStyle: .actionSheet)
        
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        
        self.present(optionMenu, animated: true, completion: nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

   

}

extension EventMapByTouchVC : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            
            
            let location:CLLocationCoordinate2D = (manager.location?.coordinate)!
            
            // self.latitude = location.latitude
            // self.longitude = location.longitude
            
            
            print("location:: \(location)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: (error)")
    }
    
}
