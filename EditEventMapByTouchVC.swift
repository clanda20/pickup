//
//  EditEventMapByTouchVC.swift
//  pickup
//
//  Created by christian landa on 10/28/16.
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

@MainActor class EditEventMapByTouchVC: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    
    var addressButton: String?
    var fullAddressStringByTouch: String?
    var fullAddressString_no_breakLineByTouch: String?
    var placemark: String?
    // var annotation: MKPointAnnotation!
    
    var fullAddressStringByTouchTempData: String?  // hold the previus data if not changed or done is pressed.
    var fullAddressString_no_breakLineByTouchTempData: String?
    
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?

    private func normalize(_ value: String?) -> String {
        guard let value, value != "nil" else { return "" }
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func formattedAddress(from placemark: CLPlacemark) -> (multiline: String, singleLine: String) {
        let name = normalize(placemark.name)
        let number = normalize(placemark.subThoroughfare)
        let street = normalize(placemark.thoroughfare)
        let city = normalize(placemark.locality)
        let state = normalize(placemark.administrativeArea)
        let postal = normalize(placemark.postalCode)
        let country = normalize(placemark.country)

        var line1Parts = [name]
        let streetLine = [number, street].filter { !$0.isEmpty }.joined(separator: " ")
        if !streetLine.isEmpty { line1Parts.append(streetLine) }
        let line1 = line1Parts.filter { !$0.isEmpty }.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)

        let line2 = [city, state, postal].filter { !$0.isEmpty }.joined(separator: ", ").trimmingCharacters(in: .whitespacesAndNewlines)
        let single = [name, streetLine, line2, country].filter { !$0.isEmpty }.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        let multi = [line1, line2].filter { !$0.isEmpty }.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)

        return (multi.isEmpty ? "Unknown Place" : multi, single.isEmpty ? "Unknown Place" : single)
    }
    
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
    var geoFireRef: DatabaseReference!
    var geoFireEventRef: DatabaseReference!
    
 
    
    
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
        
        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(_:)))
        uilgr.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(uilgr)

        // Enable once reverse-geocoding finishes and we have a complete pick.
        saveBtn.isEnabled = false

        // Ensure we start zoomed near the user's area instead of "the whole world".
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        //        print("titleTextField    : \(titleTextField)")
        //        print("descriptionTextView    : \(descriptionTextView)")
        //        print("dateRaw    : \(dateRaw)")
        //
        
    }
    @IBAction func saveBtnFn(sender: AnyObject) {
        
        //save changes on firebase Database
        guard let fullBreaks = self.fullAddressStringByTouch,
              let fullSingle = self.fullAddressString_no_breakLineByTouch,
              let placemark = self.placemark,
              let latitude = self.latitude,
              let longitude = self.longitude else {
            typeInSomethingAlert()
            return
        }

        performSegue(withIdentifier: "segue_ToEditAddVC", sender: nil)
            
            //From Here Nov 1
            let key = self.eventKey
            
            
            
            
            
            let time  = String(Int(NSDate().timeIntervalSince1970))
            
           
            
            let event: Dictionary<String, AnyObject> = [
               
                
                "fullAddress": fullSingle as AnyObject,
                "fullAddressWithBreaks": fullBreaks as AnyObject,
               "placemark"  : placemark as AnyObject,
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
            
            
            
            ref.child("events").child(key!).updateChildValues(["fullAddress": fullSingle])
            ref.child("events").child(key!).updateChildValues(["fullAddressWithBreaks": fullBreaks])
            ref.child("events").child(key!).updateChildValues(["placemark"  : placemark])
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
            
            geoFireEventRef = Database.database().reference().child("geo-user-events").child(KEY_UID!)
            geoFire = GeoFire(firebaseRef: geoFireEventRef)
            geoFire.setLocation(CLLocation(latitude: latitude, longitude: longitude), forKey: key)
            
            
            geoFireRef = Database.database().reference().child("geo-events")
            geoFireEvent = GeoFire(firebaseRef: geoFireRef)
            geoFireEvent.setLocation(CLLocation(latitude: latitude, longitude: longitude), forKey: key)
            
        // tuesday Nov 1
            
            
            
            
            
            
    }
    
    
    @IBAction func doneBtnFn(sender: AnyObject) {
        
        performSegue(withIdentifier: "segue_ToEditAddVC_No_DATA", sender: nil)
        
        
    }
    
     override func prepare(for forsegue: UIStoryboardSegue, sender: Any?) {
        
        if forsegue.identifier == "segue_ToEditAddVC"
        {
            guard let destinationVC = forsegue.destination as? EditEventVC else { return }

            destinationVC.fullAddressStringByTouch = self.fullAddressStringByTouch
            destinationVC.fullAddressString_no_breakLineByTouch = self.fullAddressString_no_breakLineByTouch
            destinationVC.placemark = self.placemark
            if let lat = self.latitude, let lon = self.longitude {
                destinationVC.latitude = lat
                destinationVC.longitude = lon
            }
            destinationVC.eventKey = self.eventKey
        }
            
        if forsegue.identifier == "segue_ToEditAddVC_No_DATA"  //might not be necessary
        {
                let destinationVC = forsegue.destination as? EditEventVC
//
//                destinationVC!.fullAddressStringByTouch =  self.fullAddressStringByTouchTempData
//                
//                destinationVC!.fullAddressString_no_breakLineByTouch =  self.fullAddressString_no_breakLineByTouchTempData
//            
                destinationVC?.eventKey = self.eventKey
            }
        
       
    }
    
    
    @objc func addAnnotation(_ gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }

        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let geocodeLocation = CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)

        CLGeocoder().reverseGeocodeLocation(geocodeLocation) { placemarks, error in
            if let error = error {
                print("Reverse geocoder failed with error \(error.localizedDescription)")
                return
            }

            Task { @MainActor in
                self.latitude = newCoordinates.latitude
                self.longitude = newCoordinates.longitude

                let annotation = MKPointAnnotation()
                annotation.coordinate = newCoordinates

                guard let pm = placemarks?.first else {
                    annotation.title = "Unknown Place"
                    self.mapView.addAnnotation(annotation)
                    self.saveBtn.isEnabled = false
                    print("Problem with the data received from geocoder")
                    return
                }

                let addr = self.formattedAddress(from: pm)
                annotation.title = addr.singleLine
                self.fullAddressStringByTouch = addr.multiline
                self.fullAddressString_no_breakLineByTouch = addr.singleLine
                self.placemark = "\(addr.singleLine), \(newCoordinates.latitude), \(newCoordinates.longitude)"

                self.mapView.addAnnotation(annotation)
                self.saveBtn.isEnabled = true
            }
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

@MainActor extension EditEventMapByTouchVC : @preconcurrency CLLocationManagerDelegate {
   // func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
     
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // ~50 miles radius-ish view (roughly).
            let span = MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8)
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
