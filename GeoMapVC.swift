//
//  GeoMapVC.swift
//  pickup
//
//  Created by christian landa on 8/25/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MapKit
import FirebaseDatabase

 enum MapType: Int {
    case Standard = 0
   // case Satellite
  //  case Hybrid
    case SatelliteFlyover
    case HybridFlyover
}

class GeoMapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sliderOutlet: UISlider!
    @IBOutlet weak var radiusLbl: UILabel!
    
    var eventKey: String!  // from segue coming from EventVC
    
    // let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false
    
    var geoFire: GeoFire!
    var geoFireRef: FIRDatabaseReference!
    
    var geoFireUserLocation: GeoFire!
    var geoFireUserLocationRef: FIRDatabaseReference!
    
    var regionQuery: GFRegionQuery?   // Shows all key that have been geocoded on a specific region
    var annotations: Dictionary<String, MapUserAnnotation> = Dictionary(minimumCapacity: 1)
    var foundQuery: GFCircleQuery?
    
    var lastExchangeKeyFound: String?
    var lastExchangeLocationFound: CLLocation?
    
    var circle:MKCircle!
    var run: Run!
    var contacts = [Contact]()
    
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    
    var latitudeEvent: CLLocationDegrees = 0
    var longitudeEvent: CLLocationDegrees = 0
    
    
    var seconds = 0.0
    var distance = 0.0
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters    // kCLLocationAccuracyNearestTenMeters
        _locationManager.activityType = .AutomotiveNavigation
      //  _locationManager.requestAlwaysAuthorization()
        
        // Movement threshold for new events
        _locationManager.distanceFilter = 10.0
        return _locationManager
    }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = NSTimer()
    
    
    //var activeUserInfo: NSDictionary?
    var fullName: String!
    let regionRadius: CLLocationDistance = 3000
    var locationCoordinate: CLLocationCoordinate2D!
    
    var allKeys = [String:CLLocation]()
    
    var keyUsers: String!
    
    var usersLocations: CLLocation!
    
    var annotationsUser: Dictionary<String, Pin> = Dictionary(minimumCapacity: 8)
    
    var eventLocationMap: EventAnnot!
    var annotationEvent: Pin!
    
    var eventInfo: NSDictionary?

    var coming_Array: [String] = []
  //  var contacts = [Contact]()
    
    
    var radiusEvent: String!
    var radiousEventDouble: Double! = 1609
    
    var polyline: MKPolyline = MKPolyline()
    var circleRenderer: MKCircleRenderer!
    
    var objectAnnotation:MKPointAnnotation!
  //  var placemark:  MKPlacemark!!
    
    // var mapPlacemark: MKPlacemark!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.hidden = true
        
        QueryGeoEvent()
        QueryUsers()
       // QueryMyEvent_Details()
        
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.None
        mapView.showsTraffic = true
        mapView.showsScale = true
        mapView.zoomEnabled = true
        mapView.scrollEnabled = true
    
       
        mapView.showsUserLocation = true
        
        startLocationUpdates()
        
        
        let initialLocation = CLLocation(latitude: self.latitudeEvent, longitude: self.longitudeEvent)
        
        centerMapOnLocation(initialLocation)
        
        
    
    }
    
    override func viewWillAppear(animated: Bool) {
         locationManager.requestAlwaysAuthorization()
        mapView.showsUserLocation = true
        QueryGeoEvent()
        FirebaseFanout()
       
    }
    
    override func viewDidAppear(animated: Bool) {
        QueryUsers()
        
    }
 
    
    func startLocationUpdates() {
        // Here, the location manager will be lazily instantiated
        locationManager.startUpdatingLocation()
    }
    
    
    func QueryGeoEvent(){
        
        geoFireRef = FIRDatabase.database().reference().child("geo-events")
        geoFire = GeoFire(firebaseRef: geoFireRef)
        
        QueryLocation{ (location) ->() in
            
            self.latitudeEvent = location.coordinate.latitude
            self.longitudeEvent = location.coordinate.longitude
            
        }
    }
    
    func QueryLocation(completion:(location: CLLocation) -> ()) {
        
        geoFire.getLocationForKey(self.eventKey, withCallback: {(location, error) in
            
            if (error != nil) {
                print("An error occurred getting the location for \(self.eventKey): \(error.localizedDescription)")
            } else if (location != nil) {
                print("Location for \(self.eventKey) is [\(location.coordinate.latitude), \(location.coordinate.longitude)]")
            } else {
                print("GeoFire does not contain a location for \(self.eventKey)")
            }
            
            self.addRadiusCircle(location.coordinate)  // very important   created the blue circle
            self.locationCoordinate = location.coordinate
            self.geoFireUserLocationRef = FIRDatabase.database().reference().child("geo-user-location")
            self.geoFireUserLocation  = GeoFire(firebaseRef: self.geoFireUserLocationRef)
            
            let center = CLLocation(latitude:  location.coordinate.latitude, longitude:  location.coordinate.longitude)
            
            self.latitudeEvent = location.coordinate.latitude
            self.longitudeEvent = location.coordinate.longitude
            
          
            let initialLocation = CLLocation(latitude: self.latitudeEvent, longitude: self.longitudeEvent)
            
            self.centerMapOnLocation(initialLocation)
            
             self.eventLocationMap = EventAnnot(title: "Today's Event",
                                                locationName: "CheckLocation",
                                                coordinate: CLLocationCoordinate2D(latitude: self.latitudeEvent, longitude: self.longitudeEvent))
            
            self.mapView.addAnnotation(self.eventLocationMap)
            
            var radiousEventDoubleToKM = (self.radiousEventDouble / 1000)
            
            var circleQuery =  self.geoFireUserLocation.queryAtLocation(center, withRadius: radiousEventDoubleToKM)  // radius of the events location
            
            // Query location by region
            let span = MKCoordinateSpanMake(0.005, 0.005)
            let region = MKCoordinateRegionMake(center.coordinate, span)
            _ = self.geoFire.queryWithRegion(region)
            
        
            
            /*   circleQuery.observeEventType(.KeyEntered, withBlock:{ (key, location) in ///---------circleQuery
             
             
             
             self.querryUserID(key){ (fullName, array) -> () in
             
             print("From ARRAy Agosto: \(fullName)")
             
             self.fullName = fullName
             
             // self.showSightingsOnMap( location)
             }
             
             //   print("fullName on foundQuery: \(self.activeUserInfo!["fullName"]!)")
             
             self.lastExchangeKeyFound = key
             self.lastExchangeLocationFound = location
             
             
             
             
             //  let foundAFriend = UIAlertView(title: "One is Coming", message: "this guy \(self.fullName) is coming", delegate: self, cancelButtonTitle: "Press Here", otherButtonTitles: "Hello")
             // foundAFriend.show()
             self.startLocationUpdates()
             
             })  */
            circleQuery!.observeEventType(.KeyMoved, withBlock: { (key, location) in
                
                self.keyUsers = key
                self.usersLocations = location
                
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
                
                var lat = location.coordinate.latitude
                var log = location.coordinate.longitude
                
             
                self.showSightingsOnMap(key, location: location)
                
                
            })
            
            circleQuery!.observeEventType(.KeyEntered, withBlock: { (key, location) in
                
                
                
                self.keyUsers = key
                self.usersLocations = location
                
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
                
                print("location from GeoFire KeyEntered = \(self.latitude) \(self.longitude)")
                self.showSightingsOnMap(key, location: location)
                
                
            })
            
        /*   circleQuery!.observeEventType(.KeyExited, withBlock: { (key, location) in
                
               // self.keyUsers = key
               // self.usersLocations = location
                
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
                
                print("location from GeoFire KeyExit = \(self.latitude) \(self.longitude)")
                
               //self.mapView.removeAnnotation(self.annotations[key]!)
              //  self.annotationsUser[key] = nil
                
                //  if let key = key, let location = location {
                
                self.showSightingsOnMap(key, location: location)
                
              let myTimer : NSTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("myPerformeCode:"), userInfo: nil, repeats: false)
               self.showSightingsOnMap(key, location: location)
            })   */
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(location: location )
            })
           // }
        })
        
        
    } //end Function
    
    
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    
    
    
    
    // MARK: showSightingsOnMap----------
    func showSightingsOnMap(key:String, location: CLLocation){
        
      self.querryUserID(key){ (fullName, array) -> () in
            
            print("From ARRAy Agosto: \(fullName)")
            
            self.fullName = fullName
        
       }
        
        //  annotationSetup(key, location: location)
       var lat = location.coordinate.latitude
        var log = location.coordinate.longitude
        
        var pinLocation = CLLocationCoordinate2DMake(lat, log)
       self.objectAnnotation = MKPointAnnotation()  //MKPinAnnotationView

        self.objectAnnotation.coordinate = pinLocation
        self.objectAnnotation.title = "\(fullName)"
       //self.objectAnnotation. = MKPinAnnotationView.greenPinColor()
        
       // self.objectAnnotation.subtitle = "Subtitle"
        self.mapView.addAnnotation(self.objectAnnotation) 
        
   
        
       
        
          let myTimer : NSTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("myPerformeCode:"), userInfo: nil, repeats: false)
        /*  var coordinate: CLLocationCoordinate2D = location.coordinate
         let anno = MapUserAnnotation(coordinate: coordinate, key: key)
         
         self.mapView.addAnnotation(anno)  */
       
    
    }
    
    func myPerformeCode(timer : NSTimer) {
        
         self.mapView.annotations.forEach {
            if !($0 is MKUserLocation) {
                self.mapView.removeAnnotation($0)
                 self.mapView.addAnnotation(self.eventLocationMap)
                // self.mapView.addAnnotation(self.annotationEvent)
                self.mapView.addAnnotation(self.objectAnnotation )
            }
        }
      //  self.mapView.addAnnotation(self.annotationEvent)
    }
  
    
    //  MARK: - LOCATION MANAGER
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //from here to here fomr Persy
        
        var location:CLLocationCoordinate2D = (manager.location?.coordinate)!
        
        self.latitude = location.latitude
        self.longitude = location.longitude
        
        for location in locations {
            let howRecent = location.timestamp.timeIntervalSinceNow
            
            if abs(howRecent) < 10 && location.horizontalAccuracy < 20 {
                //update distance
                if self.locations.count > 0 {
                    distance += location.distanceFromLocation(self.locations.last!)
                    
                    var coords = [CLLocationCoordinate2D]()
                  //  coords.append(self.locations.last!.coordinate)
                    coords.append(location.coordinate)
                    
                   var geoFireUserLocationSetLocationRef = FIRDatabase.database().reference().child("geo-user-location")
                   var  geoFireUserLocationSetLocation  = GeoFire(firebaseRef: geoFireUserLocationSetLocationRef)

                    for comingIDx in self.coming_Array {
                        
                        if comingIDx == KEY_UID {
                                        /*-----------*/ //=================================================================GEOFIRE
                    geoFireUserLocationSetLocation!.setLocation(location, forKey: KEY_UID)
                    
                        } else {
                          //  geoFireUserLocationSetLocation.removeKey(KEY_UID)
                        }
                        
                    }
                }
                
                //save location
                  self.locations.append(location)
                
            
            }
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //  MARK: - Query USer
    
    
 /*   func querryUser(){
        
        DataService.ds.REF_USERS.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            
            print(snapshot.value)
            
            
            
            self.contacts = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]  {
                
                for snap in snapshots {
                    print("SNAP MAP-----Map: \(snap)")
                    
                    
                    
                    if let contactDict = snap.value as? [String : AnyObject]  {
                        
                        
                        let key = snap.key
                        let contact = Contact(contactKey: key, dictionary: contactDict)
                        
                        
                        
                        
                        //  self.contacts.insert(contact, atIndex: 0)  //self.posts.append(post)
                        self.contacts.append(contact)
                        
                        print("SNAP Contacts for MAP : \(self.contacts)")
                        print("ContactKEY-Outside For Map----------------------: \(contact.contactKey)")                    }
                }
            }
            
            
        })
        
    }  */
    
    var image: String?
    // guardado Sat agosto 28
    
    func querryUserID(key: String, completion:(fullName: String, array:NSArray) -> ()){
        
        var activeUserInfo = [NSDictionary]()
        var fullName: String!
        
        DataService.ds.REF_USERS.child(key).observeEventType(.Value, withBlock: { (snapshot) in
            
            let item = snapshot as FIRDataSnapshot
            print("SNAP-Itemxxxxxxagodstttttooooxxxxx: \(item)")
            
            // if let dict = item.value as? NSDictionary{
            
            if let activeUserInfo = item.value as? [String : AnyObject]{
                let avatar = activeUserInfo["avatar"] as! String
                //  image = avatar
                
                //  activeUserInfo = dict
                
                
                //contact's information
                
                fullName =   (activeUserInfo["fullName"]!.uppercaseString!)
                
                print("FullName Agosto 17: \(fullName)")
                //  self.postsLabel.text = " \(self.activeUserInfo!["postNumber"]!) \n posts"
                //  self.followersLabel.text = " \(self.activeUserInfo!["followers"]!) \n followers"
                //  self.followingLabel.text = " \(self.activeUserInfo!["following"]!) \n following"
                
                //  let  activeUserInfoID = self.activeUserInfo!["id"] as! String
                
                //    print("activeUserInfoID----xxxx-------:\(activeUserInfoID)")
                
                
                
                self.downloadAvatar(avatar, completion: { (data) in
                    
                    //   self.avatarImageView.image = UIImage(data: data)
                    
                    // self.avatarImageView.layer.cornerRadius = 50.0
                    // self.avatarImageView.clipsToBounds = true
                })
                
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                 completion(fullName: fullName, array: activeUserInfo)
            })
            }, withCancelBlock: {(error) -> Void in
                
                print(error.description)
                
        })
        
    }
    
    
    func downloadAvatar(image:String, completion:(data:NSData)-> ()) {
        
        let urlString = NSURL(string: image)
        let request = NSURLSession.sharedSession().dataTaskWithURL(urlString!){ (data, response, error) -> Void in
            
            if error == nil {
                
                if let dataValid = data {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(data: dataValid)
                    })
                    
                }
            }
            
            
        }
        
        request.resume()
    }
    
    
  
    
  /*  func QueryMyEvent_Details(){
        print("EVentKEy: \(self.eventKey)")
        
        ref.child("events").child(self.eventKey!).observeEventType(.Value , withBlock: { (snapshot) in  //observeSingleEventOfType
            
            
            let item = snapshot as FIRDataSnapshot
            print("SNAP-Itemxxxxxxxxxxx: \(item)")
            
            // if let dict = item.value as? NSDictionary{
            
            if let dict = item.value as? [String : AnyObject]{
                
                self.eventInfo = dict
                
                
             //   self.titleLbl.text = " \(self.eventInfo!["title"]!.uppercaseString!)"
             //   self.descriptionText.text = " \(self.eventInfo!["description"]!)"
              // self.placemark =  (self.eventInfo!["placemark"]!) as! MKPlacemark
                
                
                // self.mapBtn = self.fullAddressString
              //  self.mapBtn.setTitle("\(self.eventInfo!["fullAddressWithBreaks"]!)", forState: .Normal)
                // self.mapBtn.titleLabel!.font = UIFont(name: "Marker Felt", size: 14)
               // self.mapBtn.titleLabel?.textAlignment = NSTextAlignment.Center
                
                
            }
            
            
            //   completation(imageStr: image!)
            
            }, withCancelBlock: {(error) -> Void in
                
        })
        
    }   */
    
    
    
    //
    func QueryUsers(){
        
        self.contacts = []
        
        if self.coming_Array != [] {
            
            for comingIDx in self.coming_Array {
                
                print(" Array Coming 2>>>>>>> \(comingIDx)")
                
                InsideQueryUsers(comingIDx)
                print("comingIDx if nil: \(comingIDx)")
            }
        } else {
            let comingIDXX:String = "xx"   //xx is any ramdon string to pass the for-in than doesn't accept Nil arrays
            
            InsideQueryUsers(comingIDXX)
            
        }
        
    }
    func  InsideQueryUsers(comingIDx: String){
        
        
        DataService.ds.REF_USERS.child(comingIDx).observeEventType(.Value, withBlock: { (snapshot) in
            
            print("List Snapshot EVent Detail: \(snapshot)")
            
            if let contactDict = snapshot.value as? [String: AnyObject]
                
            {
                print("dictionaryXXXXXX Event Coming \(contactDict) xxxxxxxxxxxx")
                
                
                let key = snapshot.key
                let contact = Contact(contactKey: key, dictionary: contactDict)
                
                self.contacts.append(contact)
                
            }
        })
    }
   
    //  getting all those users coming to the event.  //----comingArray
    func FirebaseFanout(){
        
        
        ref.child("users-event-coming").child(self.eventKey).child("coming").observeEventType(.Value, withBlock:  { snapshot in
           
            self.coming_Array = []
            
            
            for child in snapshot.children {
                let comingID = child.key as String
                print("ComingID  Array IIIIiiiiiDelete Postiiiiiiiii: \(comingID)")
                
                self.coming_Array.append(comingID)
                
                _ = Post(followersList: self.coming_Array)
                
                for comingIDx in self.coming_Array {
                    print(" Array Coming 1>>>>>>> \(comingIDx)")
                }
                
            }
            
            
            }, withCancelBlock: { (error) ->  Void in
                
                
        })
    }
    
    func addRadiusCircle(location: CLLocationCoordinate2D){
        
        self.mapView.delegate = self
        var circle = MKCircle(centerCoordinate: location, radius: self.radiousEventDouble)    // radious 2090
        self.mapView.addOverlay(circle)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let overlay = overlay as? MKCircle //{
        self.circleRenderer = MKCircleRenderer(circle: overlay!)

        circleRenderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
        return circleRenderer
    }
    
    @IBAction func mapTypeChanged(sender: AnyObject) {
       
        let mapType = MapType(rawValue: mapTypeSegmentedControl.selectedSegmentIndex)
        switch (mapType!) {
        case .Standard:
            mapView.mapType = MKMapType.Standard
        case .SatelliteFlyover:
            mapView.mapType = MKMapType.SatelliteFlyover
        case .HybridFlyover:
            mapView.mapType = MKMapType.HybridFlyover
        }
    }
    
    

    @IBAction func sliderSlid(sender: AnyObject) {
       // self.mapView.removeOverlay(self.circle)
        
       // geoFireUserLocation.removeKey(KEY_UID)
        radiusLbl.text = ""
        sliderOutlet.continuous = false
        radiusLbl.text = "\(NSString(format: "%.2f", sliderOutlet.value / 1609)) mi."  // in miles
        
        self.radiusEvent = String(sliderOutlet.value)     //  in km                     //self.radiusLbl.text
         self.radiousEventDouble = Double(self.radiusEvent!)!
        self.mapView.removeOverlays(self.mapView.overlays)  // remove all overlays including the circle

        QueryGeoEvent()
        circleRenderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
        
        }
    
    // To Active Apple's Navigation GPS
    
    func getDirections(){
        
        let geocoder:CLGeocoder = CLGeocoder()
         var theLocation: CLLocation = CLLocation(latitude: self.latitudeEvent, longitude: self.longitudeEvent)
         geocoder.reverseGeocodeLocation(theLocation,
             completionHandler: { ( placemarks, error) -> Void in
        
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                
                if placemarks!.count > 0 {
                    let pm = placemarks![0]
                    print(pm.locality)
                    
                    let firstPlacemark:CLPlacemark = placemarks![0]
                    let  mapPlacemark = MKPlacemark(placemark: firstPlacemark)
                    let selectedPinCoor  = mapPlacemark
                    // if let selectedPinCoor = selectedPinCoor {
                    let mapItem = MKMapItem(placemark: selectedPinCoor)   //CLLocationCoordinate2D
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMapsWithLaunchOptions(launchOptions)
                
                }
                else {
                    print("Problem with the data received from geocoder")
                }
                
              
            })
        
       
        
       
       // }
    }
        
        
    }




extension GeoMapVC {
    
    // 1
   func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? EventAnnot {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
                view.pinTintColor = MKPinAnnotationView.purplePinColor()
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                //adding
                 let smallSquare = CGSize(width: 30, height: 30)
                let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
                button.setBackgroundImage(UIImage(named: "car"), forState: .Normal)
                button.addTarget(self, action: "getDirections", forControlEvents: .TouchUpInside)
                view.leftCalloutAccessoryView = button
                
                //end adding
                view.rightCalloutAccessoryView = UIButton(type: UIButtonType.Custom) as UIView
                view.pinTintColor = MKPinAnnotationView.purplePinColor()
                return view
            }
            return view
        }
        return nil
    }
}


