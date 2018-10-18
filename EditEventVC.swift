//
//  EditEventVC.swift
//  pickup
//
//  Created by christian landa on 9/21/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase


protocol HandleMapSearchEditEvent {
    func dropPinZoomIn(placemark:MKPlacemark)
}


class EditEventVC: UIViewController, UISearchBarDelegate, UITextFieldDelegate, UITextViewDelegate{
    
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
    @IBOutlet weak var searchBtnByTouch: UIButton!
    
    
    
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
    
    var activeUserInfo: NSDictionary?
    var eventDict: NSDictionary?
    
    var profileName: String!
    var profileImg: String!
    var eventKey: String!  // from segue
    //var hostUid: String! // from segue
    
    var dateRaw: String!
    
    
    var fullAddressStringByTouch: String!   // data received from EventMapByTouchVC
    var fullAddressString_no_breakLineByTouch: String! // data received from EventMapByTouchVC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // for keyboard dismiss
        self.titleTextField.delegate = self
        self.descriptionTextView.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditEventVC.dismissKeyboard))
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
        QueryEvent()
        
        if titleTextField.text == "" {
        
            let loadedStringTitleTextField = UserDefaults().string(forKey: "titleTextField") ?? ""
            
            titleTextField.text = loadedStringTitleTextField
        }

        if descriptionTextView.text == "" {
        
            let loadedStringDescriptionTextView = UserDefaults().string(forKey: "descriptionTextView") ?? ""
            
            descriptionTextView.text = loadedStringDescriptionTextView
        }
        
        
//        if self.fullAddressStringByTouch == nil {
//            self.searchBtnByTouch.setTitle("Find a Location by Touch", forState: .Normal)
//            self.searchBtnByTouch.titleLabel!.font = UIFont(name: "Marker Felt", size: 18)
//            
//            
//            
//        } else{
//            // self.addressButton = self.fullAddressString
//            self.searchBtnByTouch.setTitle("\(self.fullAddressStringByTouch)", forState: .Normal)
//            self.searchBtnByTouch.titleLabel!.font = UIFont(name: "Marker Felt", size: 15)
//            self.searchBtnByTouch.titleLabel!.textColor = UIColor.redColor()
//            self.searchBtnByTouch.titleLabel?.textAlignment = NSTextAlignment.Center
//            
//            
//            self.searchBtnText.setTitle("Find a Location", forState: .Normal)
//            self.searchBtnText.titleLabel!.font = UIFont(name: "Marker Felt", size: 18)
//            
//            let tempFullAdressText = self.fullAddressStringByTouch
//            
//            self.fullAddressString = tempFullAdressText
//            
//            self.fullAddressString_no_breakLine = self.fullAddressString_no_breakLineByTouch
//            
//        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true , animated: animated);
        FirebaseFanout()
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.leftBarButtonItem = nil
        
        self.navigationItem.rightBarButtonItem = self.saveBtnItem
        
        FirebaseFanout()
        QueryCurrentUser()
        
        
    }
    @IBAction func chooseDateBtn(sender: AnyObject) {
        
        
        self.titleTextField.isHidden = true
        self.dateBtn.isHidden = true
        self.descriptionTextView.isHidden = true
        self.searchBtnText.isHidden = true
        self.searchBtnByTouch.isHidden = true   // nov 28
        self.datePicker.isHidden = false
    
        self.navigationItem.leftBarButtonItems  = nil
        self.navigationItem.rightBarButtonItem = self.doneBtnItem
        
       // self.saveBtnItem = nil
        
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
        self.searchBtnByTouch.isHidden = true 
        
        self.navigationItem.rightBarButtonItem = self.saveBtnItem
        
    }
    @IBAction func datePickerBtn(sender: AnyObject) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "E, d MMM yyyy hh:mm a"
        self.strDate = dateFormatter.string(from: datePicker.date)
       // self.dateBtn.setTitle(strDate, for: .normal)
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
        
        locationSearchTable.handleMapSearchEditEventDelegate = self
        
        
        
        
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
            self.searchBtnText.setTitle("\(self.fullAddressString!)", for: .normal)
            self.searchBtnText.titleLabel!.font = UIFont(name: "Marker Felt", size: 14)
            self.searchBtnText.titleLabel?.textAlignment = NSTextAlignment.center
            
            //Reset SearchButtonByTouch
            self.searchBtnByTouch.setTitle("Find a Location by Touch", for: .normal)
            self.searchBtnByTouch.titleLabel!.font = UIFont(name: "Marker Felt", size: 18)
            
//            self.searchBtnText.setTitle("Find a Location by Address", forState: .Normal)
//            self.searchBtnText.titleLabel!.font = UIFont(name: "Marker Felt", size: 18)
            
        }
        
        //Setting the Search Button text
        
//        if self.fullAddressString == nil {
//            self.searchBtnText.setTitle("Find a Location", forState: .Normal)
//            self.searchBtnText.titleLabel!.font = UIFont(name: "Marker Felt", size: 16)
//            
//            
//        } else{
//            // self.addressButton = self.fullAddressString
//            self.searchBtnText.setTitle("\(self.fullAddressString)", forState: .Normal)
//            self.searchBtnText.titleLabel!.font = UIFont(name: "Marker Felt", size: 14)
//            self.searchBtnText.titleLabel?.textAlignment = NSTextAlignment.Center
//            
//        }
        
        
    }
    
    
    
    @IBAction func saveBtn(sender: AnyObject) {
        
       // let key = ref.child("user-events").childByAutoId().key
        
      //  self.eventKey = key
        
        let key = self.eventKey
        
      
        
       
        
        let time  = String(Int(NSDate().timeIntervalSince1970))
        
        let titleChange = ("CHANGES: \(self.titleTextField.text!)")
        
        let event: Dictionary<String, AnyObject> = [
            "title":  self.titleTextField.text! as AnyObject,
            "description":self.descriptionTextView.text! as AnyObject,
            "fullAddress": self.fullAddressString_no_breakLine as AnyObject,
            "fullAddressWithBreaks": self.fullAddressString as AnyObject,
            "members": 0 as AnyObject,
            "date": self.strDate as AnyObject,
            "dateRaw": self.dateRaw as AnyObject,
            "host-uid":  KEY_UID! as AnyObject,
            "geo": 0 as AnyObject,
            "eventComments": 0 as AnyObject,
            "no-eventComments": 0 as AnyObject,
            "no-of-members" : 2 as AnyObject,
            "placemark"  : self.placemark as AnyObject,
            "time": time as AnyObject,
            "eventKey":self.eventKey as AnyObject,
            
            ]
        
        let descriptionTimeLine: String!
        descriptionTimeLine = "\(self.fullAddressString_no_breakLine!) \n\(self.strDate!)\n\(self.descriptionTextView.text!)!"
        //let time  = String(Int(NSDate().timeIntervalSince1970))
        
       
        
        
        
        
        
        let eventToTimeline: Dictionary<String, AnyObject> = [
        
            "description": descriptionTimeLine!  as AnyObject,
            "time": time as AnyObject,
            "uid":  KEY_UID! as AnyObject,
            "likes": 0 as AnyObject,
            "dislikes": 0 as AnyObject,
            "fullName": self.profileName as AnyObject,
            "avatar": self.profileImg as AnyObject,
            "mediaType":"EVENT" as AnyObject,
            "eventKey":self.eventKey as AnyObject,
            "eventTitle": self.titleTextField.text! as AnyObject,
            "eventTitleChanges": "CHANGES" as AnyObject,
            
        ]
        
        
        
        
        
        let childUpadates = ["/events/\(key!)": event,
                             "/user-events/\(KEY_UID!)/\(key!)/":event]
        ref.updateChildValues(childUpadates)
        
      //  ref.child("timeline")
        
        //  ref.child("user-events-id").child(KEY_UID!).child(key).setValue(true)
        
        
        for friendID in friendsArray {
            
            let childUpadates2 =  ["/events-timeline/\(friendID)/\(key!)/": event]
            ref.updateChildValues(childUpadates2)
            
            let updateTimeline = ["/timeline/\(friendID)/\(key!)": eventToTimeline]
            
            ref.updateChildValues(updateTimeline)
            
          //  ref.child("event-followers").child(key).child(friendID).setValue(true)
            
           
            
            
        }
        // Event's creator always on the Timeline, events-timeline, event-followers
        
      let childUpadates2 =  ["/events-timeline/\(KEY_UID!)/\(key!)/": event]
        ref.updateChildValues(childUpadates2)
        
        
        let updateTimelineEvent = ["/timeline/\(KEY_UID!)/\(key!)": eventToTimeline]
        ref.updateChildValues(updateTimelineEvent)
        
        
       /* ref.child("event-followers").child(key).child(KEY_UID!).setValue(true)
        
        
        
        ref.child("host-events-id").child(KEY_UID!).child(key).setValue(true)
        
        //host is always going.
        ref.child("users-event-coming").child(key).child("host").setValue(KEY_UID!)
        
        ref.child("users").child(KEY_UID!).child("events").child(key).setValue(true)   */
        
        // GEO EVENT
        
        geoFireEventRef = FIRDatabase.database().reference().child("geo-user-events").child(KEY_UID!)
        geoFire = GeoFire(firebaseRef: geoFireEventRef)
        geoFire.setLocation(CLLocation(latitude: self.latitude, longitude: self.longitude), forKey: key!)
        
        
        geoFireRef = FIRDatabase.database().reference().child("geo-events")
        geoFireEvent = GeoFire(firebaseRef: geoFireRef)
        geoFireEvent.setLocation(CLLocation(latitude: self.latitude, longitude: self.longitude), forKey: key!)
        
        
       
        
        
        performSegue(withIdentifier: "segueReturntoEvent", sender: nil)  //ojo
        
        
    }
    
    
    
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
            
            let item = snapshot as FIRDataSnapshot
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
    
    
    
    
    func QueryEvent(){
    
        DataService.ds.REF_BASE.child("events").child(self.eventKey).observe(.value, with: { (snapshot)  in
            
            let item = snapshot as FIRDataSnapshot
            print("SNAP-Itemxxxxxxxxxxx: \(item)")
            
            // if let dict = item.value as? NSDictionary{
            
            if let dict = item.value as? [String : AnyObject]{
                
                
                self.eventDict = dict as NSDictionary?
                
                
                self.titleTextField.text = " \((self.eventDict!["title"]! as AnyObject).uppercased!)"
                //  self.dateBtn = " \(self.eventDict!["date"]!)"
                UserDefaults().set(self.titleTextField.text!, forKey: "titleTextField")
                
                
                self.dateBtn.setTitle("\(self.eventDict!["date"]!)", for: .normal)
                
                self.descriptionTextView.text = " \(self.eventDict!["description"]!)"
                
                UserDefaults().set(self.descriptionTextView.text!, forKey: "descriptionTextView")
                
                // self.searchBtnText.text = " \(self.eventDict!["fullAddressWithBreaks"]!)"
                self.searchBtnText.setTitle("\(self.eventDict!["fullAddressWithBreaks"]!)", for: .normal)
                self.strDate = "\(self.eventDict!["date"]!)"
                self.fullAddressString_no_breakLine = " \(self.eventDict!["fullAddress"]!)"
                self.fullAddressString = " \(self.eventDict!["fullAddressWithBreaks"]!)"
                self.dateRaw =  "\(self.eventDict!["dateRaw"]!)"
                self.placemark = "\(self.eventDict!["placemark"]!)"
                
                
                
                
                //                    if self.fullAddressStringByTouch == nil {
                //                        self.searchBtnByTouch.setTitle("Find a Location by Touch", forState: .Normal)
                //                        self.searchBtnByTouch.titleLabel!.font = UIFont(name: "Marker Felt", size: 18)
                //                        
                //                        
                //                        
                //                    } else{
                //                        // self.addressButton = self.fullAddressString
                //                        self.searchBtnByTouch.setTitle("\(self.fullAddressStringByTouch)", forState: .Normal)
                //                        self.searchBtnByTouch.titleLabel!.font = UIFont(name: "Marker Felt", size: 15)
                //                        self.searchBtnByTouch.titleLabel!.textColor = UIColor.redColor()
                //                        self.searchBtnByTouch.titleLabel?.textAlignment = NSTextAlignment.Center
                //                        
                //                        
                //                        self.searchBtnText.setTitle("Find a Location", forState: .Normal)
                //                        self.searchBtnText.titleLabel!.font = UIFont(name: "Marker Felt", size: 18)
                //                        
                //                        let tempFullAdressText = self.fullAddressStringByTouch
                //                        
                //                        self.fullAddressString = tempFullAdressText
                //                        
                //                        self.fullAddressString_no_breakLine = self.fullAddressString_no_breakLineByTouch
                //                        
                //                    }
                
            }
            
            
            
            //   completation(imageStr: image!)
            
        }, withCancel: {(error) -> Void in
    
        })
    
    
    
    }
    
    @IBAction func SearchMap_By_Touch(sender: AnyObject) {
   
        performSegue(withIdentifier: "segue_To_MapTouch", sender: nil)
        

    
    }
    
     override func prepare(for forsegue: UIStoryboardSegue, sender: Any?) {
        
       
        
        if forsegue.identifier == "segueReturntoEvent"
        {
            let destinationVC = forsegue.destination as! EventDetailVC
            
            destinationVC.eventKey   = self.eventKey
            
            
        }
        
        if forsegue.identifier == "segue_To_MapTouch"
        {
            let destinationVC = forsegue.destination as! EditEventMapByTouchVC
            
            destinationVC.eventKey   = self.eventKey
             destinationVC.fullAddressStringByTouchTempData   = self.fullAddressStringByTouch
            destinationVC.fullAddressString_no_breakLineByTouchTempData = self.fullAddressString_no_breakLineByTouch
            
            
        }

        
    }
    
    
}



extension EditEventVC: HandleMapSearchEditEvent {
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
        if let city = placemark.locality, let state = placemark.administrativeArea {
            
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
            print("New Address: \(self.fullAddressString)")
            
            // String Without  \n
            
         self.fullAddressString_no_breakLine =  "\(locationName!) \(locationNumber!) \(locationStreet!)  \(city), \(state)"
          print("New Address: \(self.fullAddressString_no_breakLine)")
            
            mapViewLarge.addAnnotation(annotation)
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion.init(center: placemark.coordinate, span: span)
        
        mapViewLarge.setRegion(region, animated: true)
        mapView.setRegion(region, animated: true)
        } else {
        
       typeInSomethingAlert()
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
    
}


// EXTENSION:
extension EditEventVC : CLLocationManagerDelegate {
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
