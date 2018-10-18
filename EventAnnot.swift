//
//  EventAnnot.swift
//  pickup
//
//  Created by christian landa on 8/29/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import Foundation
import MapKit

class EventAnnot: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}