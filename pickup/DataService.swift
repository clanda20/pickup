//
//  DataService.swift
//  pickup
//
//  Created by christian landa on 5/23/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseMessaging
import FirebaseStorage

let URL_BASE = Database.database().reference()


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
    
    var  REF_BASE: DatabaseReference{
        return _REF_BASE
    }
    
    var REF_POSTS: DatabaseReference{
        return _REF_POSTS
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_POSTCOMMENTS: DatabaseReference{
        return _REF_POSTCOMMENTS
    }
    
    
    
    var REF_USER_POST: DatabaseReference{
        return _REF_USER_POST
    }
    
    var REF_TIMELINE_POST: DatabaseReference{
          return _REF_TIMELINE_POST
    }
    
    var REF_FOLLOWING: DatabaseReference{
        return _REF_FOLLOWING
    }
  
    var REF_FOLLOWER: DatabaseReference{
        return _REF_FOLLOWER
    }
    
    var Ref_USER_COMMENTS: DatabaseReference{
        return _Ref_USER_COMMENTS
    }
    
    var REF_USER_USER_POSTS_ID: DatabaseReference{
        return _REF_USER_USER_POSTS_ID
    }
    
    
    var REF_COMMENTS_USERID: DatabaseReference{
        return _REF_COMMENTS_USERID
    }
    
    var REF_EVENTS:DatabaseReference{
        return _REF_EVENTS
    }

    
    
    var REF_POSTCOMMENTS_ID: DatabaseReference{
        
        let postID = UserDefaults.standard.value(forKey: "postKey") as! String
        
        let REF_POSTCOMMENTS_ID = URL_BASE.child("post-comments").child(postID)
        
        return REF_POSTCOMMENTS_ID
    }
    
    var REF_POSTCOMMENTS_USER_ID: DatabaseReference{
        
        let postID = UserDefaults.standard.value(forKey: "postKey") as! String
        
        let REF_POSTCOMMENTS_USER_ID = URL_BASE.child("post-comments-userID").child(postID)
        
        return REF_POSTCOMMENTS_USER_ID
    }
    
    var REF_FOLLOWING_USERID: DatabaseReference{
        let uid = UserDefaults.standard.value(forKey: "uid") as? String
        // let postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        
        let REF_FOLLOWING_USERID = URL_BASE.child("following").child(uid!)
        
        
        return REF_FOLLOWING_USERID
    }
    
    var REF_FOLLOWER_USERID: DatabaseReference{
        let uid = UserDefaults.standard.value(forKey: "uid") as? String
        // let postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        
        let REF_FOLLOWER_USERID = URL_BASE.child("followers").child(uid!)
        
        
        return REF_FOLLOWER_USERID
    }
    
    
    
    
    var REF_TIMELINE_POST_USERID: DatabaseReference{
        let uid = UserDefaults.standard.value(forKey: "uid") as? String
        // let postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        
        let REF_TIMELINE_POST_USERID = URL_BASE.child("timeline").child(uid!)
        
        
        return REF_TIMELINE_POST_USERID
    }
    
    var REF_TIMELINE_POST_ARRAY_USERID: DatabaseReference{
        let uid = UserDefaults.standard.value(forKey: "uid") as? String
        // let postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        
        let REF_TIMELINE_POST_ARRAY_USERID = URL_BASE.child("timeline").child(uid!)
        
        
        return REF_TIMELINE_POST_ARRAY_USERID
    }
    
    
    var REF_USER_POSTS_USERID: DatabaseReference{
        let uid = UserDefaults.standard.value(forKey: "uid") as? String
       // let postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        
        let USER_POSTS_USERID = URL_BASE.child("user-posts").child(uid!)
        
        
        return USER_POSTS_USERID
    }
    
 /*   var REF_POSTS_USERID: DatabaseReference{
        let postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        // let postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        
        let REF_POSTS_USERID = URL_BASE.child("posts").child(postID)
        
        
        return REF_POSTS_USERID
    }  */
    
    
    var REF_USER_POSTS: DatabaseReference{
        let uid = UserDefaults.standard.value(forKey: "uid") as? String
       let postID = UserDefaults.standard.value(forKey: "postKey") as! String

        let USER_POSTS_ID = URL_BASE.child("user-posts").child(uid!).child(postID)
        
        
        return USER_POSTS_ID
    }
    
    var REF_USER_POSTS_BY_USER: DatabaseReference{
        let userID = UserDefaults.standard.value(forKey: "userID") as? String
       // let postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        
        let USER_POSTS_BY_USER = URL_BASE.child("user-posts").child((userID)!) //.child(postID)
        
        
        return USER_POSTS_BY_USER
    }
    
    
    var REF_USER_POSTS_BY_USER2: DatabaseReference{
        let postUserID = UserDefaults.standard.value(forKey: "postUserID") as? String   //july 24 postUserID
        // let postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        
        let USER_POSTS_BY_USER2 = URL_BASE.child("user-posts").child(postUserID!) //.child(postID)
        
        
        return USER_POSTS_BY_USER2
    }
    
    //post-userID
    
    
    var REF_USER_CURRENT: DatabaseReference{
        let uid = UserDefaults.standard.value(forKey: "uid") as? String
        let user = URL_BASE.child("users").child(uid!)
        return user
        
    }
   var REF_POST_KEY: DatabaseReference{
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


