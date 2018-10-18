//
//  Pin.swift
//  pickup
//
//  Created by christian landa on 8/30/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit

class Pin: NSObject, MKAnnotation{
    
    var coordinate: CLLocationCoordinate2D
    var identifier: String!
    var title: String!
    
    init(identifier: String, title: String) {
        self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        self.identifier = identifier
        self.title = title
        
    }
    
}
