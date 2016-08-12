//
//  Constants.swift
//  pickup
//
//  Created by christian landa on 5/23/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

let SHADOW_COLOR: CGFloat = 157.0 / 255.0


let KEY_UID =  NSUserDefaults.standardUserDefaults().valueForKey("uid") as? String
let postKey = "postKey"

// var POST_KEY_ID = "postKey"

let ref = FIRDatabase.database().reference()
var postRef  =  (ref.child("posts"))
var userRef = ref.child("users")
//var commentRef = ref.child("post-comments")
var user_postsRef = ref.child("user-posts")
//STORAGE

let storage = FIRStorage.storage()
let storageRef = storage.referenceForURL("gs://pickup-9b67a.appspot.com")


//Segues

let SEGUE_LOGGED_IN = "loggedIn"

//Status Codes
let STATUS_ACCOUNT_NONEXIST = 17011


