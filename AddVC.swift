//
//  AddVC.swift
//  pickup
//
//  Created by christian landa on 8/19/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase



protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}


class AddVC: UIViewController, UISearchBarDelegate {
    
    @IBOutlet  var saveBtnItem: UIBarButtonItem!
    @IBOutlet  var doneBtnItem: UIBarButtonItem!
    @IBOutlet  var doneLeftBtnItem: UIBarButtonItem!

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var searchBtnText: UIButton!
    @IBOutlet weak var mapViewLarge: MKMapView!
    

    
    var addressButton: String!
    var fullAddressString: String!
    var fullAddressString_no_breakLine: String!
    var placemark: String!
    
    let locationManager = CLLocationManager()
    
    var resultSearchController: UISearchController? = nil
    
    var searchBar: UISearchBar? = nil
    
    var selectedPin:MKPlacemark? = nil
    
    
    var followersRef: FIRDatabaseReference!
    var friendsArray: [String] = []
    
    var geoFire: GeoFire!
    var geoFireEvent: GeoFire!
    var geoFireRef: FIRDatabaseReference!
    var geoFireEventRef: FIRDatabaseReference!
    
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    
    var strDate: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init the zoom level
       /* let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.378437, longitude: -122.116825)
        let span = MKCoordinateSpanMake(2.0, 2.0)
        let region = MKCoordinateRegionMake(coordinate, span)
        self.mapViewLarge.setRegion(region, animated: true)  */
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    
        FirebaseFanout()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true , animated: animated);
        FirebaseFanout()
    }
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.leftBarButtonItem = nil
        FirebaseFanout()

    }
    @IBAction func chooseDateBtn(sender: AnyObject) {
        
    
        self.titleTextField.hidden = true
        self.dateBtn.hidden = true
        self.descriptionTextView.hidden = true
        self.searchBtnText.hidden = true
      
        self.datePicker.hidden = false
      
        self.navigationItem.rightBarButtonItem = self.doneBtnItem
 
    }

    @IBAction func doneDateHidden(sender: AnyObject) {
        
       
        self.titleTextField.hidden = false
        self.dateBtn.hidden = false
        self.descriptionTextView.hidden = false
        self.datePicker.hidden = true
    
        self.navigationItem.rightBarButtonItem = self.saveBtnItem
        
        
    }
    
    @IBAction func doneItemBtn(sender: AnyObject) {
        
        
        self.titleTextField.hidden = false
        self.dateBtn.hidden = false
        self.descriptionTextView.hidden = false
        self.searchBtnText.hidden = false
        self.datePicker.hidden = true
        
        self.navigationItem.rightBarButtonItem = self.saveBtnItem
        
    }
    @IBAction func datePickerBtn(sender: AnyObject) {
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy hh:mm a"
        self.strDate = dateFormatter.stringFromDate(datePicker.date)
        self.dateBtn.setTitle(strDate, forState: .Normal)
    }
    
    
    @IBAction func searchBtn(sender: AnyObject) {

        self.titleTextField.hidden = true
        self.dateBtn.hidden = true
        self.descriptionTextView.hidden = true
        self.mapView.hidden = true
        self.datePicker.hidden = true
        self.datePicker.hidden = true
        self.searchBtnText.hidden = true
        
        
        
        self.mapViewLarge.hidden = false
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        
        self.navigationItem.leftBarButtonItem = self.doneLeftBtnItem


        //added August 22
        
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        

        self.searchBar = resultSearchController!.searchBar
        self.searchBar!.sizeToFit()
        self.searchBar!.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        
        
        locationSearchTable.mapViewLarge = mapViewLarge
        locationSearchTable.mapView = mapView
        
        locationSearchTable.handleMapSearchDelegate = self
        
        
        
        
    }
    
    @IBAction func doneLeftBtnItemAction(sender: AnyObject) {
        
       
        self.titleTextField.hidden = false
        self.dateBtn.hidden = false
        self.descriptionTextView.hidden = false
        self.mapView.hidden = false
        self.searchBtnText.hidden = false
    
        
        self.mapViewLarge.hidden = true
        self.datePicker.hidden = true
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = self.saveBtnItem
        
        self.searchBtnText.setTitle(self.addressButton, forState: .Normal)
        
        //added Augost 22
        resultSearchController?.hidesNavigationBarDuringPresentation = true
        self.searchBar?.hidden = true
        resultSearchController?.searchResultsUpdater = nil
        
        //Setting the Search Button text 
        
        if self.fullAddressString == nil {
             self.searchBtnText.setTitle("Find a Location", forState: .Normal)
            self.searchBtnText.titleLabel!.font = UIFont(name: "Marker Felt", size: 16)

            
        } else{
           // self.addressButton = self.fullAddressString
            self.searchBtnText.setTitle("\(self.fullAddressString)", forState: .Normal)
            self.searchBtnText.titleLabel!.font = UIFont(name: "Marker Felt", size: 14)
            self.searchBtnText.titleLabel?.textAlignment = NSTextAlignment.Center

        }
    
  
       }
    
    
    
    @IBAction func saveBtn(sender: AnyObject) {
        
        let event: Dictionary<String, AnyObject> = [
            "title": self.titleTextField.text!,
            "description": self.descriptionTextView.text!,
            "fullAddress": self.fullAddressString_no_breakLine,
            "fullAddressWithBreaks": self.fullAddressString,
            "members": 0,
            "date": self.strDate,
            "host-uid":  KEY_UID!,
            "geo": 0,
            "eventComments": 0,
            "no-eventComments": 0,
            "no-of-members" : 2,
            "placemark"  : self.placemark,
           
        ]
        
        
        
        
        
        let key = ref.child("user-events").childByAutoId().key
        
        let childUpadates = ["/events/\(key)": event,
                             "/user-events/\(KEY_UID!)/\(key)/":event]
        ref.updateChildValues(childUpadates)
        
        for friendID in friendsArray {
            
            let childUpadates2 =  ["/events-timeline/\(friendID)/\(key)/": event]
            ref.updateChildValues(childUpadates2)
            print(" Array inside \(friendID)")
            
            
        }
        
            ref.child("host-events-id").child(KEY_UID!).child(key).setValue(true)
        
            //host is always going.
            ref.child("users-event-coming").child(key).child("host").setValue(KEY_UID!)
        
            ref.child("users").child(KEY_UID!).child("events").child(key).setValue(true)
        
        // GEO EVENT
            
            geoFireEventRef = FIRDatabase.database().reference().child("geo-user-events").child(KEY_UID!)
            geoFire = GeoFire(firebaseRef: geoFireEventRef)
            geoFire.setLocation(CLLocation(latitude: self.latitude, longitude: self.longitude), forKey: key)
        
        
            geoFireRef = FIRDatabase.database().reference().child("geo-events")
            geoFireEvent = GeoFire(firebaseRef: geoFireRef)
            geoFireEvent.setLocation(CLLocation(latitude: self.latitude, longitude: self.longitude), forKey: key)

        
           // geoFireEventRef =

        
        performSegueWithIdentifier("segueToEventVC", sender: nil) 
    
        
    }
    
   
    
    func FirebaseFanout(){
        
        followersRef = DataService.ds.REF_FOLLOWER_USERID
        followersRef.observeEventType(.Value, withBlock:  { snapshot in
            
            
            print("new snapshot array: \(snapshot.key)")
            
            
            self.friendsArray = []
            
            for child in snapshot.children {
                let friendID = child.key as String
                print("friendID  Array IIIIiiiiiiiiiiiiiiiii: \(friendID)")
                
                self.friendsArray.append(friendID)
                
                _ = Post(followersList: self.friendsArray)
                
                
                for friendID in self.friendsArray {
                    print(" Array friendID tonight \(friendID)")
                }
                
            }
            
            
            
            }, withCancelBlock: { (error) ->  Void in
                
                
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



extension AddVC: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapViewLarge.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        
        print("Annotation.coordinate: \(annotation.coordinate)")
         print("Annotation.coordinate Longitude: \(annotation.coordinate.latitude)")
         print("Annotation.coordinate: Longitude \(annotation.coordinate.longitude)")
         self.latitude = annotation.coordinate.latitude
         self.longitude = annotation.coordinate.longitude
        
        
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            
            
            annotation.subtitle = "\(city) \(state)"
           
            // Full Address to be Displayed
             print("Placemark@@@@@@@@: \(placemark)")
            
            self.placemark = "\(placemark)"
        
            self.fullAddressString =  "\(placemark.name!)\n \(placemark.subThoroughfare!) \(placemark.thoroughfare!) \n \(city), \(state)"
            print("New Address: \(self.fullAddressString)")
            
            // String Without  \n
            
            self.fullAddressString_no_breakLine =  "\(placemark.name!) \(placemark.subThoroughfare!) \(placemark.thoroughfare!)  \(city), \(state)"
            print("New Address: \(self.fullAddressString_no_breakLine)")
            
            
        }
        mapViewLarge.addAnnotation(annotation)
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        
        mapViewLarge.setRegion(region, animated: true)
        mapView.setRegion(region, animated: true)
    }
    
    // Dismiss keyBoard
    
    func hideKeyboard()
    {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
    
    
   
    
}


// EXTENSION:
extension AddVC : CLLocationManagerDelegate {
 func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
  
 if status == .AuthorizedWhenInUse {
 locationManager.requestLocation()
 }
 }
 
 func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
 if let location = locations.first {
 let span = MKCoordinateSpanMake(0.05, 0.05)
 let region = MKCoordinateRegion(center: location.coordinate, span: span)
 mapViewLarge.setRegion(region, animated: true)
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
