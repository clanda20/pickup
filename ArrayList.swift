//
//  ArrayList.swift
//  pickup
//
//  Created by christian landa on 7/27/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseMessaging
import FirebaseStorage


  struct ArrayList{
    
    let key: String!
    let ref: DatabaseReference?
    var completed: Bool!
    
    // Initialize from arbitrary data
    init(name: String,  completed: Bool, key: String = "") {
        self.key = key
        self.completed = completed

        self.ref = nil
    
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
      // completed = snapshot.value!["completed"] as! Bool
        ref = snapshot.ref
    }
    
    
    
}