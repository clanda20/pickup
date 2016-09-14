//
//  MapVC.swift
//  pickup
//
//  Created by christian landa on 8/12/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MapKit
import FirebaseDatabase
import HealthKit

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate{
    var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var searchBtn: UIButton!
    
   // let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false
    
    var geoFire: GeoFire!
    var geoFireRef: FIRDatabaseReference!
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
    
    
    var seconds = 0.0
    var distance = 0.0
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters    // kCLLocationAccuracyNearestTenMeters
        _locationManager.activityType = .Fitness
        
        // Movement threshold for new events
        _locationManager.distanceFilter = 10.0
        return _locationManager
    }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = NSTimer()
    
    
    //var activeUserInfo: NSDictionary?
    var fullName: String!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.FollowWithHeading
        
        geoFireRef = FIRDatabase.database().reference().child("geo")
        geoFire = GeoFire(firebaseRef: geoFireRef)
        
       // locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
       // querryUser()
        startLocationUpdates()
        //loadMap()
        
    
        
        
    
    }
    
    override func viewWillAppear(animated: Bool) {
           // locationManager.requestAlwaysAuthorization()
            mapView.showsUserLocation = false   // true or fall doesn't make a difference

    }
    
    override func viewDidAppear(animated: Bool) {
        locationAuthStatus()
        
      
        self.mapView.userLocation.addObserver(self, forKeyPath: "location", options: NSKeyValueObservingOptions(), context: nil)
        
        

        
    }
    
    
    func startLocationUpdates() {
        // Here, the location manager will be lazily instantiated
        
        
        locationManager.startUpdatingLocation()
        
       
        
       // startLocationUpdates()
    }
  // From YouTube
   
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if(self.mapView.showsUserLocation && self.mapView.userLocation.location != nil) {
            
            let span = MKCoordinateSpanMake(0.07, 0.07)  //(0.0125, 0.0125)
            let region = MKCoordinateRegion(center: (self.mapView.userLocation.location?.coordinate)!, span: span)
            self.mapView.setRegion(region, animated: true)
            
            if regionQuery == nil {
                regionQuery = geoFire?.queryWithRegion(region)
                
                regionQuery!.observeEventType(GFEventType.KeyEntered, withBlock: { (key, location) in
                 
                })
                
                
                
                regionQuery!.observeEventType(GFEventType.KeyMoved, withBlock: { (key, location) in
                 
                    self.latitude = location.coordinate.latitude
                    self.longitude = location.coordinate.longitude
                   
                    print("location from GeoFire KeyMove = \(self.latitude) \(self.longitude)")
                    
                  //  if let key = key, let location = location {
                   
                      self.showSightingsOnMap( location)
                   // }
 
                })
                
                regionQuery!.observeEventType(GFEventType.KeyExited, withBlock: { (key, location) in
                    
               
                    
                })
            }
            
            if foundQuery == nil {   //\(authData?.uid)
                foundQuery = geoFire?.queryAtLocation(self.mapView.userLocation.location, withRadius: 3.5) //0.05
              //  foundQuery?.displayLayer(CALayer)
                
                foundQuery!.observeEventType(GFEventType.KeyEntered, withBlock:{ (key, location) in
                    
                    self.querryUserID(key){ (fullName, array) -> () in
                        
                        print("From ARRAy Agosto: \(fullName)")
                        
                        self.fullName = fullName
                        
                       // self.showSightingsOnMap( location)
                    }
                    
             //   print("fullName on foundQuery: \(self.activeUserInfo!["fullName"]!)")
                    
                self.lastExchangeKeyFound = key
                self.lastExchangeLocationFound = location
                    
                    
                    
                    
                //let foundAFriend = UIAlertController(title: "One is Coming", message: "this guy is coming", preferredStyle: .Alert)
              let foundAFriend = UIAlertView(title: "One is Coming", message: "this guy \(self.fullName) is coming", delegate: self, cancelButtonTitle: "Press Here", otherButtonTitles: "Hello")
                    foundAFriend.show()
                    self.startLocationUpdates()
                    
            })
                
                
                foundQuery!.observeEventType(GFEventType.KeyExited, withBlock:{ (key, location) in
                    self.lastExchangeKeyFound = key
                    self.lastExchangeLocationFound = location
                    
                    self.querryUserID(key){ (fullName, array) -> () in
                        
                        print("From ARRAy Agosto: \(fullName)")
                        
                        self.fullName = fullName
                    }

                    //let foundAFriend = UIAlertController(title: "One is leaving", message: "this guy is leaving", preferredStyle: .Alert)
                    let foundAFriend = UIAlertView(title: "One is leaving", message: "this guy \(self.fullName) is leaving", delegate: self, cancelButtonTitle: "Press Here", otherButtonTitles: "Hello")
                    foundAFriend.show()
                })
          
            } else {
                foundQuery?.center = self.mapView.userLocation.location
            }
    }
    }
    // MARK: showSightingsOnMap----------
    func showSightingsOnMap(/*key:String,*/ location: CLLocation){
        
      //  annotationSetup(key, location: location)
        var lat = location.coordinate.latitude
        var log = location.coordinate.longitude
        
        var pinLocation = CLLocationCoordinate2DMake(lat, log)
        var objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = "\(self.fullName)"
        objectAnnotation.subtitle = "Subtitle"
         self.mapView.addAnnotation(objectAnnotation)

        let myTimer : NSTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("myPerformeCode:"), userInfo: nil, repeats: false)
          /*  var coordinate: CLLocationCoordinate2D = location.coordinate
            let anno = MapUserAnnotation(coordinate: coordinate, key: key)
    
            self.mapView.addAnnotation(anno)  */
      
        
    }
    
   
    func myPerformeCode(timer : NSTimer) {
        
        self.mapView.annotations.forEach {
            if !($0 is MKUserLocation) {
                self.mapView.removeAnnotation($0)
            }
        }
    }
    func locationAuthStatus(){
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
            
        } else {
           // locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        }
        
    }
    
   
    
 //  MARK: - LOCATION MANAGER
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //from here to here fomr Persy 
        
        var location:CLLocationCoordinate2D = (manager.location?.coordinate)!
        
        self.latitude = location.latitude
        self.longitude = location.longitude
        
     
        
       // self.mapView.addOverlay(MKCircle(centerCoordinate: location, radius: 3500))
       addRadiusCircle(location)
       // self.mapView.removeOverlays(mapView.overlays)
        
        
        
        //  print("location = \(location.latitude) \(location.longitude)")
        
       
        //to here
        
        
        for location in locations {
            let howRecent = location.timestamp.timeIntervalSinceNow
            
            if abs(howRecent) < 10 && location.horizontalAccuracy < 20 {
                //update distance
                if self.locations.count > 0 {
                    distance += location.distanceFromLocation(self.locations.last!)
                    
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locations.last!.coordinate)
                    coords.append(location.coordinate)
                    
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
                    mapView.setRegion(region, animated: true)
                
                    geoFire!.setLocation(location, forKey: KEY_UID)
                  
                }
                
                //save location
                self.locations.append(location)
                
                
                dispatch_after(
                    dispatch_time(
                        DISPATCH_TIME_NOW,
                        Int64(3.0 * Double(NSEC_PER_SEC))
                    ),
                    dispatch_get_main_queue(),
                    {
                    self.mapView.removeOverlays(self.mapView.overlays)
                    }
                )
               // self.mapView.removeOverlays(mapView.overlays)
            }
        }
    }

    func addRadiusCircle(location: CLLocationCoordinate2D){
        
      //
        self.mapView.delegate = self
        var circle = MKCircle(centerCoordinate: location, radius: 3500)
        self.mapView.addOverlay(circle)
        
    }
    
  // very good but not for this project
     
   /*  func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if !overlay.isKindOfClass(MKPolyline) {
            
            return nil
        }
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.blackColor()
        renderer.lineWidth = 6
     
        return renderer
    
    }
     
     

    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        
        let locations = run.locations.array as! [Location]
        for location in locations {
            coords.append(CLLocationCoordinate2D(latitude: location.latitude.doubleValue,
                longitude: location.longitude.doubleValue))
        }
        
        return MKPolyline(coordinates: &coords, count: run.locations.count)
    }   */
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    
    @IBAction func searchBtnAction(sender: AnyObject) {  // I don't think it is necessary for my project 
        
       // let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
      //  let rand = arc4random_uniform(151)
      //  createSighting(loc, withUser: rand)
        // adding location to firebase database
        let key = KEY_UID
        let location = mapView.userLocation.location
        
        geoFire!.setLocation(mapView.userLocation.location, forKey: key)
        
        startLocationUpdates()
     }
    
 
 
    func querryUser(){
        
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
    
    }
    
     var image: String?
    
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


    
    
    
     // Doesn't work
     
  /*   func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
     let overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
     overlayRenderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
     overlayRenderer.lineWidth = 1.0
     overlayRenderer.strokeColor = UIColor.blackColor()
     return overlayRenderer
     }  */
 
    
    
    /* func createSighting(location: CLLocation, withUser userId: String){
     
     geoFire.setLocation(location, forKey: "\(userId)")
     
     
     }   */
    
    
    
    /*  func showSightingsOnMap(location: CLLocation){
     let circleQuery = geoFire!.queryAtLocation(location, withRadius: 3)
     
     _ = circleQuery?.observeEventType(.KeyEntered, withBlock: { (key, location) in
     
     if let key = key, let location = location {
     //   let anno = MapUserAnnotation( .latitude, key: key )
     // self.mapView.addAnnotation(anno)
     }
     
     })
     
     
     }   */
    
    
    /*  func loadMap() {
     if run.locations.count > 0 {
     mapView.hidden = false
     
     // Set the map bounds
     mapView.region = mapRegion()
     
     // Make the line(s!) on the map
     mapView.addOverlay(polyline())
     } else {
     // No locations were found!
     mapView.hidden = true
     
     UIAlertView(title: "Error",
     message: "Sorry, this run has no locations saved",
     delegate:nil,
     cancelButtonTitle: "OK").show()
     }
     }  */
    
    /*  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
     
     if status == .AuthorizedWhenInUse {
     mapView.showsUserLocation = true
     }
     }  */
    
  
    
    
   func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion  = MKCoordinateRegionMakeWithDistance(location.coordinate, 5000, 5000)
        
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
       
        if let loc = userLocation.location{
            
            if !mapHasCenteredOnce {
                centerMapOnLocation(loc)
                mapHasCenteredOnce = true
                          }
            
        }
    }

    // This one for custom annotations  which is called whenever self.mapView.addAnnotation(anno) is called

    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
      let annoIdentifier = "Pokemon"
        
        var annotationView: MKAnnotationView?
        

        
      if annotation.isKindOfClass(MKUserLocation.self) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "\(self.fullName)")
            annotationView?.image = UIImage(named: "car")
        }   else if let deqAnno = mapView.dequeueReusableAnnotationViewWithIdentifier(annoIdentifier) {
            annotationView = deqAnno
            annotationView?.annotation = annotation
         }    /* else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
            let buttonType = UIButtonType.DetailDisclosure
            av.rightCalloutAccessoryView = UIButton(type: buttonType)
            annotationView = av
        }
           */
         // this part is probably not working
        if let annotationView = annotationView, let anno = annotation as? MapUserAnnotation{
            annotationView.canShowCallout = true
            annotationView.image = UIImage(contentsOfFile: "car.png")
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn.setImage(UIImage(named: "car"), forState: .Normal)
            annotationView.rightCalloutAccessoryView = btn
            
        }
        
        return annotationView
    }
    
  /*  func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        showSightingsOnMap(loc)
    }  */
    
  /*  func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        
    }  */
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
          let overlay = overlay as? MKCircle //{
            let circleRenderer = MKCircleRenderer(circle: overlay!)
            circleRenderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.05)
            return circleRenderer
       // }
    
    }
    
 /*   func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
       let overlay = overlay as? MKCircle
        
        if overlay != nil {
            setNeedsDisplay()
        }
    }  */
    
    }


