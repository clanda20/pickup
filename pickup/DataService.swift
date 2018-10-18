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
    private var _REF_USERS = URL_BASE.child("users")
    private var _REF_POSTCOMMENTS = URL_BASE.child("post-comments")
   // private var _REF_POSTCOMMENTS_ID = URL_BASE.child("post-comments")
    private var _REF_USER_POST = URL_BASE.child("user-posts")
    private var _REF_TIMELINE_POST = URL_BASE.child("timeline")
    private var _REF_FOLLOWING = URL_BASE.child("following")
    private var _REF_FOLLOWER = URL_BASE.child("followers")
    private var _Ref_USER_COMMENTS = URL_BASE.child("user-comments")
    private var _REF_USER_USER_POSTS_ID = URL_BASE.child("user-posts-id")
    private var _REF_COMMENTS_USERID = URL_BASE.child("post-comments-userID")
    private var _REF_EVENTS = URL_BASE.child("events")
    
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
    
    
    
    var REF_USER_POST: FIRDatabaseReference{
        return _REF_USER_POST
    }
    
    var REF_TIMELINE_POST: FIRDatabaseReference{
          return _REF_TIMELINE_POST
    }
    
    var REF_FOLLOWING: FIRDatabaseReference{
        return _REF_FOLLOWING
    }
  
    var REF_FOLLOWER: FIRDatabaseReference{
        return _REF_FOLLOWER
    }
    
    var Ref_USER_COMMENTS: FIRDatabaseReference{
        return _Ref_USER_COMMENTS
    }
    
    var REF_USER_USER_POSTS_ID: FIRDatabaseReference{
        return _REF_USER_USER_POSTS_ID
    }
    
    
    var REF_COMMENTS_USERID: FIRDatabaseReference{
        return _REF_COMMENTS_USERID
    }
    
    var REF_EVENTS:FIRDatabaseReference{
        return _REF_EVENTS
    }

    
    
    var REF_POSTCOMMENTS_ID: FIRDatabaseReference{
        
        let postID = UserDefaults.standard.value(forKey: "postKey") as! String
        
        let REF_POSTCOMMENTS_ID = URL_BASE.child("post-comments").child(postID)
        
        return REF_POSTCOMMENTS_ID
    }
    
    var REF_POSTCOMMENTS_USER_ID: FIRDatabaseReference{
        
        let postID = UserDefaults.standard.value(forKey: "postKey") as! String
        
        let REF_POSTCOMMENTS_USER_ID = URL_BASE.child("post-comments-userID").child(postID)
        
        return REF_POSTCOMMENTS_USER_ID
    }
    
    var REF_FOLLOWING_USERID: FIRDatabaseReference{
        let uid = UserDefaults.standard.value(forKey: "uid") as? String
        // let postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        
        let REF_FOLLOWING_USERID = URL_BASE.child("following").child(uid!)
        
        
        return REF_FOLLOWING_USERID
    }
    
    var REF_FOLLOWER_USERID: FIRDatabaseReference{
        let uid = UserDefaults.standard.value(forKey: "uid") as? String
        // let postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        
        let REF_FOLLOWER_USERID = URL_BASE.child("followers").child(uid!)
        
        
        return REF_FOLLOWER_USERID
    }
    
    
    
    
    var REF_TIMELINE_POST_USERID: FIRDatabaseReference{
        let uid = UserDefaults.standard.value(forKey: "uid") as? String
        // let postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        
        let REF_TIMELINE_POST_USERID = URL_BASE.child("timeline").child(uid!)
        
        
        return REF_TIMELINE_POST_USERID
    }
    
    var REF_TIMELINE_POST_ARRAY_USERID: FIRDatabaseReference{
        let uid = UserDefaults.standard.value(forKey: "uid") as? String
        // let postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        
        let REF_TIMELINE_POST_ARRAY_USERID = URL_BASE.child("timeline").child(uid!)
        
        
        return REF_TIMELINE_POST_ARRAY_USERID
    }
    
    
    var REF_USER_POSTS_USERID: FIRDatabaseReference{
        let uid = UserDefaults.standard.value(forKey: "uid") as? String
       // let postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        
        let USER_POSTS_USERID = URL_BASE.child("user-posts").child(uid!)
        
        
        return USER_POSTS_USERID
    }
    
 /*   var REF_POSTS_USERID: FIRDatabaseReference{
        let postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        // let postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        
        let REF_POSTS_USERID = URL_BASE.child("posts").child(postID)
        
        
        return REF_POSTS_USERID
    }  */
    
    
    var REF_USER_POSTS: FIRDatabaseReference{
        let uid = UserDefaults.standard.value(forKey: "uid") as? String
       let postID = UserDefaults.standard.value(forKey: "postKey") as! String

        let USER_POSTS_ID = URL_BASE.child("user-posts").child(uid!).child(postID)
        
        
        return USER_POSTS_ID
    }
    
    var REF_USER_POSTS_BY_USER: FIRDatabaseReference{
        let userID = UserDefaults.standard.value(forKey: "userID") as? String
       // let postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        
        let USER_POSTS_BY_USER = URL_BASE.child("user-posts").child((userID)!) //.child(postID)
        
        
        return USER_POSTS_BY_USER
    }
    
    
    var REF_USER_POSTS_BY_USER2: FIRDatabaseReference{
        let postUserID = UserDefaults.standard.value(forKey: "postUserID") as? String   //july 24 postUserID
        // let postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        
        let USER_POSTS_BY_USER2 = URL_BASE.child("user-posts").child(postUserID!) //.child(postID)
        
        
        return USER_POSTS_BY_USER2
    }
    
    //post-userID
    
    
    var REF_USER_CURRENT: FIRDatabaseReference{
        let uid = UserDefaults.standard.value(forKey: "uid") as? String
        let user = URL_BASE.child("users").child(uid!)
        return user
        
    }
   var REF_POST_KEY: FIRDatabaseReference{
         let postID = UserDefaults.standard.value(forKey: "postKey") as! String
         let postKey = URL_BASE.child("post-comments").child(postID)
     return postKey
    }
 
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(user)  //  user is user: Dictionary<String, String>
    }
    
  //  func createfirebasePostID( PostID: String) {
    //    REF_POSTCOMMENTS.child(PostID).setValue(PostID)
   // }
    
    
    
    
}


