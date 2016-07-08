//
//  DataService.swift
//  pickup
//
//  Created by christian landa on 5/23/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = FIRDatabase.database().reference()


class DataService {
    
    
  //  let   postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
    
    static let ds = DataService()
    
    
    private var _REF_BASE = URL_BASE
    private var _REF_POSTS = URL_BASE.child("posts")
    private var _REF_USERS = URL_BASE.child("user")
    private var _REF_POSTCOMMENTS = URL_BASE.child("post-comments")
    private var _REF_POSTCOMMENTS_ID = URL_BASE.child("post-comments")
    
  //  let postID  = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
    
    
    
    
   // commentsRef = ref.child("post-comments").child(postID)
    
    var  REF_BASE: FIRDatabaseReference{
        return _REF_BASE
    }
    
    var REF_POSTS: FIRDatabaseReference{
        return _REF_POSTS
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_POSTCOMMENTS: FIRDatabaseReference{
        return _REF_POSTCOMMENTS
    }
    
    var REF_POSTCOMMENTS_ID: FIRDatabaseReference{
        return _REF_POSTCOMMENTS_ID
    }
    
    var REF_USER_CURRENT: FIRDatabaseReference{
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as? String
        let user = URL_BASE.child("users").child(uid!)
        return user
        
    }
   var REF_POST_KEY: FIRDatabaseReference{
         let postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
         let postKey = URL_BASE.child("post-comments").child(postID)
     return postKey
    }
 
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        REF_USERS.child(uid).setValue(user)  //  user is user: Dictionary<String, String>
    }
    
    func createfirebasePostID( PostID: String) {
        REF_POSTCOMMENTS.child(PostID).setValue(PostID)
    }
    
  //  func RER_USER_
    // commentsRef = ref.child("post-comments").child(postKey)
    
  /*  var REF_COMMENT_USER:  FIRDatabaseReference {
    
        
        return
        
    }  */

    
}


