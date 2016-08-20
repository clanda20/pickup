//
//  Run.swift
//  pickup
//
//  Created by christian landa on 8/15/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import Foundation
import CoreData

class Run: NSManagedObject {
    
    @NSManaged var duration: NSNumber
    @NSManaged var distance: NSNumber
    @NSManaged var timestamp: NSDate
    @NSManaged var locations: NSOrderedSet
    
}
