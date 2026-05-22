//
//  AddVC.swift
//  pickup
//
//  Created by christian landa on 8/19/16.
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



@MainActor protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}


@MainActor class AddVC: UIViewController, UISearchBarDelegate, UITextFieldDelegate, UITextViewDelegate{
    
    @IBOutlet  var saveBtnItem: UIBarButtonItem!
    @IBOutlet  var doneBtnItem: UIBarButtonItem!
    @IBOutlet  var doneLeftBtnItem: UIBarButtonItem!
    @IBOutlet  var PreviousButton: UIBarButtonItem!

    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var searchBtnText: UIButton!
    @IBOutlet weak var mapViewLarge: MKMapView!
    @IBOutlet weak var searchBtnByTouch: UIButton!
    
    
    
    var addressButton: String!
    var fullAddressString: String!
    var fullAddressString_no_breakLine: String!
    var placemark: String!   // data received from EventMapByTouchVC when search by touch
    //ByTouch
    
    var fullAddressStringByTouch: String!   // data received from EventMapByTouchVC
    var fullAddressString_no_breakLineByTouch: String! // data received from EventMapByTouchVC
    
    
    let locationManager = CLLocationManager()
    
    var resultSearchController: UISearchController? = nil
    
    var searchBar: UISearchBar? = nil
    
    var selectedPin:MKPlacemark? = nil
    
    
    var followersRef: DatabaseReference!
    var friendsArray: [String] = []
    
    var geoFire: GeoFire!
    var geoFireEvent: GeoFire!
    var geoFireRef: DatabaseReference!
    var geoFireEventRef: DatabaseReference!
    
    var latitude: CLLocationDegrees! //= 0
    var longitude: CLLocationDegrees! //= 0
    
    var strDate: String!
    
    var activeUserInfo: NSDictionary?
    var profileName: String!
    var profileImg: String!
    var eventKey: String!
    
    var dateRaw: String!
    
//    var titleTextFieldSegue: String!
//    
//    var descriptionTextViewSegue: String!
    
 //  var annotation: MKPointAnnotation!   // data received from EventMapByTouchVC
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        findLocationFirstAlert()
       
        
        // for keyboard dismiss
        self.titleTextField.delegate = self
        self.descriptionTextView.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddVC.dismissKeyboard))
        view.addGestureRecognizer(tap)


        
        
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
        // added Nov 28
        if titleTextField.text == "" {
            
            let loadedStringTitleTextField = UserDefaults().string(forKey: "titleTextFieldNoEdit") ?? ""
            
            titleTextField.text = loadedStringTitleTextField
        }
        
        if descriptionTextView.text == "" {
            
            let loadedStringDescriptionTextView = UserDefaults().string(forKey: "descriptionTextViewNoEdit") ?? ""
            
            descriptionTextView.text = loadedStringDescriptionTextView
        }
        //end added Nov 28
        
        //ByTouch
        
        if self.fullAddressStringByTouch == nil {
            self.searchBtnByTouch.setTitle("Find a Location by Touch", for: .normal)
            self.searchBtnByTouch.titleLabel!.font = UIFont(name: "Marker Felt", size: 18)
            
            
            
        } else{
            // self.addressButton = self.fullAddressString
            let addr = self.fullAddressStringByTouch ?? ""
            self.searchBtnByTouch.setTitle(addr.isEmpty ? "Find a Location by Touch" : addr, for: .normal)
            self.searchBtnByTouch.titleLabel!.font = UIFont(name: "Marker Felt", size: 15)
            self.searchBtnByTouch.titleLabel!.textColor = UIColor.red
            self.searchBtnByTouch.titleLabel?.textAlignment = NSTextAlignment.center
            
            let tempFullAdressText = addr.isEmpty ? nil : addr
            
            self.fullAddressString = tempFullAdressText
            
            self.fullAddressString_no_breakLine = self.fullAddressString_no_breakLineByTouch
            
        }
        
    }
    

    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true , animated: animated)
        self.navigationController?.isToolbarHidden = true
        
        
        FirebaseFanout()

    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       self.navigationController?.setNavigationBarHidden(false, animated: animated)
       // self.navigationController?.setNavigationBarHidden(true, animated: animated)

        self.navigationItem.rightBarButtonItems = nil
      self.navigationItem.leftBarButtonItem = nil
      self.navigationItem.leftBarButtonItem = self.PreviousButton
         self.navigationItem.setHidesBackButton(true, animated: false)
        
 
        
        FirebaseFanout()
        QueryCurrentUser()

    }
    @IBAction func chooseDateBtn(sender: AnyObject) {
        
    
        self.titleTextField.isHidden = true
        self.dateBtn.isHidden = true
        self.descriptionTextView.isHidden = true
        self.searchBtnText.isHidden = true
        self.searchBtnByTouch.isHidden = true
      
        self.datePicker.isHidden = false
      
         self.navigationItem.leftBarButtonItems  = nil
        self.navigationItem.rightBarButtonItem = self.doneBtnItem
 
    }

//    @IBAction func doneDateHidden(sender: AnyObject) {
//        
//       
//        self.titleTextField.isHidden = false
//        self.dateBtn.isHidden = false
//        self.descriptionTextView.isHidden = false
//        self.datePicker.isHidden = true
//    
//        self.navigationItem.rightBarButtonItem = self.saveBtnItem
//        
//        
//    }
    
    @IBAction func doneItemBtn(sender: AnyObject) {
        
        
        self.titleTextField.isHidden = false
        self.dateBtn.isHidden = false
        self.descriptionTextView.isHidden = false
        self.searchBtnText.isHidden = false
        self.datePicker.isHidden = true
        self.searchBtnByTouch.isHidden = false
        
        
        self.navigationItem.rightBarButtonItem = self.saveBtnItem
        
    }
    @IBAction func datePickerBtn(sender: AnyObject) {
        
        let dateFormatter = DateFormatter()
       
        dateFormatter.dateFormat = "E, d MMM yyyy hh:mm a"
        self.strDate = dateFormatter.string(from: datePicker.date)
        self.dateBtn.setTitle(strDate, for: .normal)
        
        self.dateRaw = String(describing: datePicker.date)
    }
    
    
    @IBAction func searchBtn(sender: AnyObject) {

        self.titleTextField.isHidden = true
        self.dateBtn.isHidden = true
        self.descriptionTextView.isHidden = true
        self.mapView.isHidden = true
        self.datePicker.isHidden = true
        self.searchBtnText.isHidden = true
        self.searchBtnByTouch.isHidden = true
        
        
        
        self.mapViewLarge.isHidden = false
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        
        self.navigationItem.leftBarButtonItem = self.doneLeftBtnItem


        //added August 22
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
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
        
       
        self.titleTextField.isHidden = false
        self.dateBtn.isHidden = false
        self.descriptionTextView.isHidden = false
        self.mapView.isHidden = false
        self.searchBtnText.isHidden = false
        self.searchBtnByTouch.isHidden = false
    
        
        self.mapViewLarge.isHidden = true
        self.datePicker.isHidden = true
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = self.saveBtnItem
        
        self.searchBtnText.setTitle(self.addressButton, for: .normal)
        
        //added Augost 22
        resultSearchController?.hidesNavigationBarDuringPresentation = true
        self.searchBar?.isHidden = true
        resultSearchController?.searchResultsUpdater = nil
        
        //Setting the Search Button text 
        
        if self.fullAddressString == nil {
             self.searchBtnText.setTitle("Find a Location by Address", for: .normal)
            self.searchBtnText.titleLabel!.font = UIFont(name: "Marker Felt", size: 18)
            
//            self.searchBtnByTouch.setTitle("Find a Location by Touch", forState: .Normal)
//            self.searchBtnByTouch.titleLabel!.font = UIFont(name: "Marker Felt", size: 18)

            
        } else{
           // self.addressButton = self.fullAddressString
            self.searchBtnText.setTitle("\(self.fullAddressString)", for: .normal)
            self.searchBtnText.titleLabel!.font = UIFont(name: "Marker Felt", size: 14)
            self.searchBtnText.titleLabel?.textAlignment = NSTextAlignment.center
            
            //Reset SearchButtonByTouch
            self.searchBtnByTouch.setTitle("Find a Location by Touch", for: .normal)
            self.searchBtnByTouch.titleLabel!.font = UIFont(name: "Marker Felt", size: 18)

        }
        
       
    
  
       }
    
    
    @IBAction func PreviousBtn(sender: AnyObject) {
        
        
       // performSegueWithIdentifier("segue_To_Event_Detail", sender: nil)
    
    
    }
    
    @IBAction func saveBtn(sender: AnyObject) {
        
        
if self.titleTextField.text != "" && self.descriptionTextView.text  != "" && self.fullAddressString_no_breakLine != nil && self.strDate != nil && self.fullAddressString != nil {
       
        
        guard let key = ref.child("user-events").childByAutoId().key else {
            return
        }
        
        self.eventKey = key
        
        let time  = String(Int(NSDate().timeIntervalSince1970))
        
        let event: Dictionary<String, AnyObject> = [
            "title": self.titleTextField.text! as AnyObject,
            "description": self.descriptionTextView.text! as AnyObject,
            "fullAddress": self.fullAddressString_no_breakLine as AnyObject,
            "fullAddressWithBreaks": self.fullAddressString as AnyObject,
            "members": 0 as AnyObject,
            "date": self.strDate as AnyObject,
            "dateRaw": self.dateRaw as AnyObject,
            "host-uid":  KEY_UID! as AnyObject,
            "host-Name":  self.profileName as AnyObject,
            "geo": 0 as AnyObject,
            "eventComments": 0 as AnyObject,
            "no-eventComments": 0 as AnyObject,
            "no-of-members" : 2 as AnyObject,
            "placemark"  : self.placemark as AnyObject,
            "time": time as AnyObject,
            "eventKey":self.eventKey as AnyObject,
            
           
        ]
        let descriptionTimeLine: String!
           descriptionTimeLine = "\(self.fullAddressString_no_breakLine!) \n\(self.strDate!)\n\(self.descriptionTextView.text!)"
         //let time  = String(Int(NSDate().timeIntervalSince1970))
        
        let eventToTimeline: Dictionary<String, AnyObject> = [
            
           
            "description": descriptionTimeLine! as AnyObject,
            "time": time as AnyObject,
            "uid":  KEY_UID! as AnyObject,
            "likes": 0 as AnyObject,
            "dislikes": 0 as AnyObject,
            "fullName": self.profileName as AnyObject,
            "avatar": self.profileImg as AnyObject,
           "mediaType":"EVENT" as AnyObject,
           "eventKey":self.eventKey as AnyObject,
           "eventTitle": self.titleTextField.text! as AnyObject
            
            ]
        
        
        
      //   NSUserDefaults.standardUserDefaults().setValue(KEY_UID!, forKey: "eventKeyUID")   ///   user who created this Event
        
        let childUpadates = ["/events/\(key)": event,
                             "/user-events/\(KEY_UID!)/\(key)/":event]
        ref.updateChildValues(childUpadates)
        
        ref.child("timeline")
        
      //  ref.child("user-events-id").child(KEY_UID!).child(key).setValue(true)
        
        
        for friendID in friendsArray {
            
            let childUpadates2 =  ["/events-timeline/\(friendID)/\(key)/": event]
            ref.updateChildValues(childUpadates2)
            
            let updateTimeline = ["/timeline/\(friendID)/\(key)": eventToTimeline]
            
            ref.updateChildValues(updateTimeline)
            
            ref.child("event-followers").child(key).child(friendID).setValue(true) 
            
            print(" Array inside \(friendID)")
            
            
        }
         // Event's creator always on the Timeline, events-timeline, event-followers
        
        let childUpadates2 =  ["/events-timeline/\(KEY_UID!)/\(key)/": event]
        ref.updateChildValues(childUpadates2)
        
        
        let updateTimelineEvent = ["/timeline/\(KEY_UID!)/\(key)": eventToTimeline]
        ref.updateChildValues(updateTimelineEvent)
        
        
        ref.child("event-followers").child(key).child(KEY_UID!).setValue(true)
        
        
        
            ref.child("host-events-id").child(KEY_UID!).child(key).setValue(true)
        
            //host is always going.
            ref.child("users-event-coming").child(key).child("host").setValue(KEY_UID!)
        
            ref.child("users").child(KEY_UID!).child("events").child(key).setValue(true)
        
        // GEO EVENT
            
            geoFireEventRef = Database.database().reference().child("geo-user-events").child(KEY_UID!)
            geoFire = GeoFire(firebaseRef: geoFireEventRef)
            geoFire.setLocation(CLLocation(latitude: self.latitude, longitude: self.longitude), forKey: key)
        
        
            geoFireRef = Database.database().reference().child("geo-events")
            geoFireEvent = GeoFire(firebaseRef: geoFireRef)
            geoFireEvent.setLocation(CLLocation(latitude: self.latitude, longitude: self.longitude), forKey: key)

        
           // geoFireEventRef =

        
        performSegue(withIdentifier: "segueToEventVC", sender: nil)
            
    } else {
            typeInSomethingAlert()
        }
    
    }
    
 
    @IBAction func searchBtnByTouchFC(sender: AnyObject) {
        
      performSegue(withIdentifier: "segue_To_Find_Location_Touch", sender: nil)
        
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "segue_To_Find_Location_Touch"
//        {
//        
//            
//            
//            let destinationVC = segue.destinationViewController as? EventMapByTouchVC
//            
//            destinationVC!.titleTextField =  self.titleTextField.text!
//            
//            print("self.titleTextField.text!  \(self.titleTextField.text!)")
//            
//            destinationVC!.descriptionTextView =  self.descriptionTextView.text!
//            
//            print("self.descriptionTextView.text!  \(self.descriptionTextView.text!)")
//            
//            destinationVC!.dateRaw = self.dateRaw
//            print("self.dateRaw  \(self.dateRaw)")
//            
//            
//        }
//    }
//    
    func FirebaseFanout(){
        
        followersRef = DataService.ds.REF_FOLLOWER_USERID
        followersRef.observe(.value, with:  { snapshot in
            
            
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Dismiss keyBoard
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        titleTextField.resignFirstResponder()
       
        
        return true
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            descriptionTextView.resignFirstResponder()
        return false
        }
        return true
        
    }
   
    
    func hideKeyboard()
    {
        self.view.endEditing(true)
    }
    
    
    
    func QueryCurrentUser(){
        
        DataService.ds.REF_USER_CURRENT.observe(.value, with: { (snapshot)  in
            
            let item = snapshot as DataSnapshot
            print("SNAP-Itemxxxxxxxxxxx: \(item)")
            
            // if let dict = item.value as? NSDictionary{
            
            if let dict = item.value as? [String : AnyObject]{
                let avatar = dict["avatar"] as! String
                // self.image = avatar
                
                self.activeUserInfo = dict as NSDictionary?
                
                // self.title = "Welcome \(self.activeUserInfo!["firstName]!)"
                self.profileName = "\((self.activeUserInfo!["fullName"]! as AnyObject).uppercased!)"
                self.profileImg = "\(self.activeUserInfo!["avatar"]!)"
                // self.followersLabel.text = " \(self.activeUserInfo!["followers"]!) \n followers"
                // self.followingLabel.text = " \(self.activeUserInfo!["following"]!) \n following"
            }
            
        }, withCancel: {(error) -> Void in
        })
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
    


    
}



extension AddVC: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapViewLarge.removeAnnotations(mapView.annotations)
        mapView.removeAnnotations(mapView.annotations)
        
      //  if self.annotation == nil {
        
        let annotation = MKPointAnnotation()
        
      //  }
         annotation.coordinate = placemark.coordinate
        
        print("Annotation.coordinate: \(annotation.coordinate)")
         print("Annotation.coordinate Longitude: \(annotation.coordinate.latitude)")
         print("Annotation.coordinate: Longitude \(annotation.coordinate.longitude)")
         self.latitude = annotation.coordinate.latitude
         self.longitude = annotation.coordinate.longitude
        
        
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            
            var locationName = placemark.name
            if locationName == "nil" || locationName == nil{
                locationName = ""
            } else {
                locationName = placemark.name
            }
            
            
            var locationNumber = placemark.subThoroughfare
            
            if locationNumber == nil || locationNumber == "nil" {
                locationNumber = ""
            } else {
                locationNumber = (placemark.subThoroughfare)
            }
            
            
            var locationStreet = placemark.thoroughfare
            // var locationStreet2:String?
            
            if locationStreet == "nil" || locationStreet == nil {
                locationStreet = ""
            } else {
                locationStreet = placemark.thoroughfare
            }
            
            
            annotation.subtitle = "\(city) \(state)"
            
            // Full Address to be Displayed
            print("Placemark@@@@@@@@: \(placemark)")
            
            self.placemark = "\(placemark)"
            
            // self.fullAddressString =  "\(placemark.name!)\n \(placemark.subThoroughfare!) \(placemark.thoroughfare!) \n \(city), \(state)"
            // print("New Address: \(self.fullAddressString)")
            
            
            self.fullAddressString =  "\(locationName!)\n \(locationNumber!) \(locationStreet!) \n \(city), \(state)"
            print("New Address: \(self.fullAddressString!)")
            
            // String Without  \n
            
            self.fullAddressString_no_breakLine =  "\(locationName!) \(locationNumber!) \(locationStreet!)  \(city), \(state)"
            print("New Address: \(self.fullAddressString_no_breakLine!)")
            
            mapViewLarge.addAnnotation(annotation)
            mapView.addAnnotation(annotation)  //
            
            let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion.init(center: placemark.coordinate, span: span)
            
            mapViewLarge.setRegion(region, animated: true)
            mapView.setRegion(region, animated: true)
        }  else {
            
            typeInSomethingAlert()
        }
        
    }
    
    
        func findLocationFirstAlert(){
        let optionMenu = UIAlertController(title: nil, message: "Find your location first. You might lost your text entries! ", preferredStyle: .actionSheet)
        
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        
        self.present(optionMenu, animated: true, completion: nil)
    }
        
}
    
  




// EXTENSION:
@MainActor extension AddVC : @preconcurrency CLLocationManagerDelegate {
 func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
  
 if status == .authorizedWhenInUse {
 locationManager.requestLocation()
 }
 }
 
 func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
 if let location = locations.first {
 let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
 let region = MKCoordinateRegion(center: location.coordinate, span: span)
 mapViewLarge.setRegion(region, animated: true)
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
