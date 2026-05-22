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

@MainActor class EventMapByTouchVC: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    
    var addressButton: String?
    var fullAddressStringByTouch: String?
    var fullAddressString_no_breakLineByTouch: String?
    var placemark: String?
   // var annotation: MKPointAnnotation!
    
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
        
        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(_:)))
        uilgr.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(uilgr)

        saveBtn.isEnabled = false

        // Without an explicit region, MapKit can start zoomed out to the whole world.
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
//        print("titleTextField    : \(titleTextField)")
//        print("descriptionTextView    : \(descriptionTextView)")
//        print("dateRaw    : \(dateRaw)")
//        

    }
    @IBAction func saveBtnFn(sender: AnyObject) {
        guard fullAddressStringByTouch != nil,
              fullAddressString_no_breakLineByTouch != nil,
              placemark != nil,
              latitude != nil,
              longitude != nil else {
            typeInSomethingAlert()
            return
        }

        performSegue(withIdentifier: "segue_ToAddVC", sender: nil)
        
    }

    
    @IBAction func doneBtnFn(sender: AnyObject) {
       
    performSegue(withIdentifier: "segue_ToAddVC_No_DATA", sender: nil)
        
      
    }

    override func prepare(for forsegue: UIStoryboardSegue, sender: Any?) {
        if forsegue.identifier == "segue_ToAddVC"
        {
            
            guard let destinationVC = forsegue.destination as? AddVC else { return }

            destinationVC.fullAddressStringByTouch = self.fullAddressStringByTouch
            destinationVC.fullAddressString_no_breakLineByTouch = self.fullAddressString_no_breakLineByTouch
            destinationVC.placemark = self.placemark
            destinationVC.latitude = self.latitude
            destinationVC.longitude = self.longitude
            
            
            //            destinationVC!.titleTextFieldSegue =  self.titleTextField
            //
            //            destinationVC!.descriptionTextViewSegue =  self.descriptionTextView
            //
            //            destinationVC!.dateRaw = self.dateRaw
            
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

@MainActor extension EventMapByTouchVC : @preconcurrency CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // ~50 miles radius-ish view (roughly). Good starting point for picking by touch.
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
