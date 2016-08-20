//
//  Location.swift
//  pickup
//
//  Created by christian landa on 8/15/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import Foundation
import CoreData

class Location: NSManagedObject {
    
    @NSManaged var timestamp: NSDate
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var run: NSManagedObject
    
}

