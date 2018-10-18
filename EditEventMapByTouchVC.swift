//
//  EditEventMapByTouchVC.swift
//  pickup
//
//  Created by christian landa on 10/28/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase
import AddressBookUI

class EditEventMapByTouchVC: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    
    var addressButton: String!
    var fullAddressStringByTouch: String!
    var fullAddressString_no_breakLineByTouch: String!
    var placemark: String!
    // var annotation: MKPointAnnotation!
    
    var fullAddressStringByTouchTempData: String!  // hold the previus data if not changed or done is pressed.
    var fullAddressString_no_breakLineByTouchTempData: String!
    
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    //    var titleTextField: String!
    //
    //    var descriptionTextView: String!
    //
    //    var dateRaw: String!
    
    
      var eventKey: String!  // from segue
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters    // kCLLocationAccuracyNearestTenMeters
        _locationManager.activityType = .automotiveNavigation
        
        // Movement threshold for new events
        _locationManager.distanceFilter = 10.0
        return _locationManager
    }()
    
    
    var friendsArray: [String] = []
    
    var geoFire: GeoFire!
    var geoFireEvent: GeoFire!
    var geoFireRef: FIRDatabaseReference!
    var geoFireEventRef: FIRDatabaseReference!
    
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseFanout()
        
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
        
        //save changes on firebase Database
        if  self.longitude != nil {
            performSegue(withIdentifier: "segue_ToEditAddVC", sender: nil)
            
            //From Here Nov 1
            let key = self.eventKey
            
            
            
            
            
            let time  = String(Int(NSDate().timeIntervalSince1970))
            
           
            
            let event: Dictionary<String, AnyObject> = [
               
                
                "fullAddress": self.fullAddressString_no_breakLineByTouch as AnyObject,
                "fullAddressWithBreaks": self.fullAddressStringByTouch as AnyObject,
               "placemark"  : self.placemark as AnyObject,
               "time": time as AnyObject,
                ]
//            let descriptionTimeLine: String!
//            descriptionTimeLine = "\(self.fullAddressString_no_breakLine) \n\(self.strDate)\n\(self.descriptionTextView.text!)"
//            //let time  = String(Int(NSDate().timeIntervalSince1970))
            
            
            
            
            
            
            
//            let eventToTimeline: Dictionary<String, AnyObject> = [
//                
//                "description": descriptionTimeLine,
//                "time": time,
//                "uid":  KEY_UID!,
//                "likes": 0,
//                "dislikes": 0,
//                "fullName": self.profileName,
//                "avatar": self.profileImg,
//                "mediaType":"EVENT",
//                "eventKey":self.eventKey,
//                "eventTitle": self.titleTextField.text!,
//                "eventTitleChanges": "CHANGES",
//                
//                ]
            
            
            
            ref.child("events").child(key!).updateChildValues(["fullAddress": self.fullAddressString_no_breakLineByTouch])
            ref.child("events").child(key!).updateChildValues(["fullAddressWithBreaks": self.fullAddressStringByTouch])
            ref.child("events").child(key!).updateChildValues(["placemark"  : self.placemark])
            ref.child("events").child(key!).updateChildValues(["time": time])
            
            ref.child("user-events").child(KEY_UID!).child(key!).updateChildValues(["fullAddress": self.fullAddressString_no_breakLineByTouch])
            ref.child("user-events").child(KEY_UID!).child(key!).updateChildValues(["fullAddressWithBreaks": self.fullAddressStringByTouch])
            ref.child("user-events").child(KEY_UID!).child(key!).updateChildValues(["placemark"  : self.placemark])
            ref.child("user-events").child(KEY_UID!).child(key!).updateChildValues(["time": time])

            
//            let childUpadates = ["/events/\(key)": event,
//                                 "/user-events/\(KEY_UID!)/\(key)/":event]
//            ref.updateChildValues(childUpadates)
            
           
            
            
            for friendID in friendsArray {
                
                
                ref.child("events-timeline").child(friendID).child(key!).updateChildValues(["fullAddress": self.fullAddressString_no_breakLineByTouch])
                ref.child("events-timeline").child(friendID).child(key!).updateChildValues(["fullAddressWithBreaks": self.fullAddressStringByTouch])
                ref.child("events-timeline").child(friendID).child(key!).updateChildValues(["placemark"  : self.placemark])
                ref.child("events-timeline").child(friendID).child(key!).updateChildValues(["time": time])

                
//                let childUpadates2 =  ["/events-timeline/\(friendID)/\(key)/": event]
//                ref.updateChildValues(childUpadates2)
                
               // let updateTimeline = ["/timeline/\(friendID)/\(key)": eventToTimeline]
                
               // ref.updateChildValues(updateTimeline)
                
                //  ref.child("event-followers").child(key).child(friendID).setValue(true)
                
                
                
                
            }
            // Event's creator always on the Timeline, events-timeline, event-followers
            
            
            ref.child("events-timeline").child(KEY_UID!).child(key!).updateChildValues(["fullAddress": self.fullAddressString_no_breakLineByTouch])
            ref.child("events-timeline").child(KEY_UID!).child(key!).updateChildValues(["fullAddressWithBreaks": self.fullAddressStringByTouch])
            ref.child("events-timeline").child(KEY_UID!).child(key!).updateChildValues(["placemark"  : self.placemark])
            ref.child("events-timeline").child(KEY_UID!).child(key!).updateChildValues(["time": time])


            
//            let childUpadates2 =  ["/events-timeline/\(KEY_UID!)/\(key)/": event]
//            ref.updateChildValues(childUpadates2)
//            
            
          //  let updateTimelineEvent = ["/timeline/\(KEY_UID!)/\(key)": eventToTimeline]
          //  ref.updateChildValues(updateTimelineEvent)
            
            
            /* ref.child("event-followers").child(key).child(KEY_UID!).setValue(true)
             
             
             
             ref.child("host-events-id").child(KEY_UID!).child(key).setValue(true)
             
             //host is always going.
             ref.child("users-event-coming").child(key).child("host").setValue(KEY_UID!)
             
             ref.child("users").child(KEY_UID!).child("events").child(key).setValue(true)   */
            
            // GEO EVENT
            
            geoFireEventRef = FIRDatabase.database().reference().child("geo-user-events").child(KEY_UID!)
            geoFire = GeoFire(firebaseRef: geoFireEventRef)
            geoFire.setLocation(CLLocation(latitude: self.latitude, longitude: self.longitude), forKey: key)
            
            
            geoFireRef = FIRDatabase.database().reference().child("geo-events")
            geoFireEvent = GeoFire(firebaseRef: geoFireRef)
            geoFireEvent.setLocation(CLLocation(latitude: self.latitude, longitude: self.longitude), forKey: key)
            
        // tuesday Nov 1
            
            
            
            
            
            
        } else {
            typeInSomethingAlert()
        }
    }
    
    
    @IBAction func doneBtnFn(sender: AnyObject) {
        
        performSegue(withIdentifier: "segue_ToEditAddVC_No_DATA", sender: nil)
        
        
    }
    
     override func prepare(for forsegue: UIStoryboardSegue, sender: Any?) {
        
        if forsegue.identifier == "segue_ToEditAddVC"
        {
            
            let destinationVC = forsegue.destination as? EditEventVC
            
            destinationVC!.fullAddressStringByTouch =  self.fullAddressStringByTouch
            
            destinationVC!.fullAddressString_no_breakLineByTouch =  self.fullAddressString_no_breakLineByTouch
            
            destinationVC!.self.placemark = self.placemark
            
            destinationVC!.self.latitude = self.latitude
            
            destinationVC!.self.longitude = self.longitude
            
            destinationVC!.eventKey = self.eventKey
        }
            
        if forsegue.identifier == "segue_ToEditAddVC_No_DATA"  //might not be necessary
        {
                let destinationVC = forsegue.destination as? EditEventVC
//
//                destinationVC!.fullAddressStringByTouch =  self.fullAddressStringByTouchTempData
//                
//                destinationVC!.fullAddressString_no_breakLineByTouch =  self.fullAddressString_no_breakLineByTouchTempData
//            
                destinationVC!.eventKey = self.eventKey
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
        
        
        
        
        _ = UIAlertAction(title: "Cancel", style: .cancel, handler: {
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
    
    
    func FirebaseFanout(){
        
       
        DataService.ds.REF_FOLLOWER_USERID.observe(.value, with:  { snapshot in
            
            
            print("new snapshot array: \(snapshot.key)")
            
            
            self.friendsArray = []
            
            for child in snapshot.children {
                let friendID = (child as AnyObject).key as String
                print("friendID  Array IIIIiiiiiiiiiiiiiiiii: \(friendID)")
                
                self.friendsArray.append(friendID)
                
                _ = Post(followersList: self.friendsArray)
                
                
                for friendID in self.friendsArray {
                    print(" Array friendID tonight \(friendID)")
                }
                
            }
            
            
            
        }, withCancel: { (error) ->  Void in
                
                
        })
    }
    
    
    
}

extension EditEventMapByTouchVC : CLLocationManagerDelegate {
   // func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
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
