//
//  MapUserAnnotation.swift
//  pickup
//
//  Created by christian landa on 8/15/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import Foundation

class MapUserAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var key: String
   // var userFullName : String
  //  var title: String?
    


  init(coordinate: CLLocationCoordinate2D, key: String){
    
    self.coordinate = coordinate
    self.key = key
  //  self.userFullName = userFullName
 //   self.title = self.userFullName
  
    
}  
    
    
 /*   init( key: String){
       self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        self.key = key
    }  */

}