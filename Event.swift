//
//  Comment.swift
//  pickup
//
//  Created by christian landa on 6/23/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import Foundation
import Firebase

class Event {
    private var _date: String!
    private var _description: String!
    private var _fullAddress: String!
    private var _fullAddressWithBreaks: String!
    private var _title: String!
    private var _geo: FIRDatabaseReference!
    private var _eventKey: String!
    private var _hostUid: String!
    private var _eventRef: FIRDatabaseReference!
    private var _placemark:  MKPlacemark!
    
    var date: String {
        return _date
    }
    

    var description: String {
        return _description
    }
    
    
    var fullAddress: String {
        return _fullAddress
    }
    
    var fullAddressWithBreaks: String{
        return _fullAddressWithBreaks
    }
    
    var title: String {
        return _title
    }
    
    
    var hostUid: String {
        return _hostUid
    }
    
    var geo: FIRDatabaseReference{
        return _geo
    }
    
    var eventKey: String {
        return _eventKey
    }
    
    var eventRef: FIRDatabaseReference{
        return _eventRef
    }
    
    var placemark:  MKPlacemark! {
        return _placemark
    }
    
    init(date: String, description: String, fullAddress: String, fullAddressWithBreaks: String, title: String, placemark:  MKPlacemark!) {
        
        self._date = date
        self._description = description
        self._fullAddress = fullAddress
        self._fullAddressWithBreaks = fullAddressWithBreaks
        self._title = title
        self._placemark = placemark
        
    }
    
    init(eventKey: String, dictionary: Dictionary<String, AnyObject>) {
        
        self._eventKey = eventKey
        
        if let date = dictionary["date"] as? String {
            self._date = date
        }
        
        if let description = dictionary["description"] as? String {
            self._description = description
        }
        
        if let fullAddress = dictionary["fullAddress"] as? String {
            self._fullAddress = fullAddress
        }
        
       if let fullAddressWithBreaks = dictionary["fullAddressWithBreaks"] as? String {
            
            self._fullAddressWithBreaks = fullAddressWithBreaks
        }  

        if let title = dictionary["title"] as? String {
            self._title = title
        }
        if let hostUid = dictionary["host-uid"] as? String {
            self._hostUid = hostUid
        }
        
        
        if let placemark = dictionary["placemark"] as?  MKPlacemark? {
            self._placemark = placemark
        }
        
        
          self._eventRef = DataService.ds.REF_EVENTS.child(self._eventKey)
        
    }
}
