//
//  Post.swift
//  pickup
//
//  Created by christian landa on 5/24/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _postDescription: String?
    private var _imageUrl: String?
    private var _avatar: String?
    private var _likes: Int!
    private var _fullName: String!
    private var _username: String!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    private var _commentPostRef: FIRDatabaseReference!
    private var _user_posts_Ref: FIRDatabaseReference!
    private var __post_REf_By_USER: FIRDatabaseReference!
    private var _dislikes: Int!
    private var _uid: String?
    private var _followersList: [String]?
    private var _friendsArraylist: [String]!
    private var _time: String!
    
    var postDescription: String?{
        return _postDescription
    }
    
    var imageUrl: String?{
        return _imageUrl
    }
    
    var avatar: String?{
        return _avatar
    }
    
    var likes: Int{
        return _likes
    }
    
    var username: String{
        return _username
    }
    
    var fullName: String{
        return _fullName
    }
    
    var postKey: String{
        return _postKey
    }
    
    var postRef: FIRDatabaseReference{
        return _postRef
    }
    
    var dislikes: Int{
        return _dislikes
    }
    
    var uid: String? {
        return _uid
    }
    
    var followersList: [String]? {
        return _followersList
    }
    
   var friendsArraylist: [String]{
        return _friendsArraylist
    }
    
    var time: String{
        return _time
    }
    
    init(description: String?, imageUrl: String?, fullName: String, avatar: String?, time: String) {
        self._postDescription = description
        self._imageUrl = imageUrl
        self._fullName = fullName
        self._avatar = avatar
        self._time = time
    }
    
    
    
    init(postKey: String, dictionary: Dictionary<String, AnyObject>){  // need UID
        self._postKey = postKey
        
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        }
        
        if let dislikes = dictionary["dislikes"] as? Int {
            self._dislikes = dislikes
        }
        
        if let imgUrl = dictionary["imageUrl"] as? String {
            self._imageUrl = imgUrl
        }
        
        if let desc = dictionary["description"] as? String {
            self._postDescription = desc 
        }
        
        if let uid = dictionary["uid"] as? String {
            self._uid = uid
        }
        
        if let fullName = dictionary["fullName"] as? String {
            self._fullName = fullName
        }
        
        if let avatar = dictionary["avatar"] as? String {
            self._avatar = avatar
        }
        
        if let time = dictionary["time"] as? String {
            self._time = time
        }
        
    //  self._postRef = DataService.ds.REF_POSTS.child(self._postKey)
       // self._postRef = DataService.ds.REF_USER_POSTS_USERID.child(self._postKey)
        
        self._commentPostRef = DataService.ds.REF_POSTCOMMENTS.child(self._postKey)
    
    self._user_posts_Ref = DataService.ds.REF_USER_POSTS_USERID.child(self._postKey)
   // self._user_posts_Ref = DataService.ds.REF_USER_POSTS_BY_USER2.child(self._postKey)
    
    self.__post_REf_By_USER  =  DataService.ds.REF_USER_POSTS_BY_USER.child(self._postKey)
    
    }    //post on user-posts/userID/postID
    
    
    init(followersList:[String]) {  // need UID
        
            self._followersList = followersList
          //  self._friendsArraylist = friendsArraylist
          // _friendsArraylist.append(followersList)
    
        
    
    }
    
    func comment_postRef() {
        
        _commentPostRef.childByAutoId()
    }
    
    
    
    func adjustLikes(addLike: Bool, followersList: Array<String>) {
        self._followersList = followersList
        
        if addLike {
            _likes = _likes! + 1
            
        } else {
            _likes = _likes! - 1
        }
        
      //  _postRef.child("likes").setValue(_likes)
      // _user_posts_Ref.child("likes").setValue(_likes)  ////post on user-posts/userID/postID
        
        DataService.ds.REF_USER_POSTS_BY_USER2.child(self._postKey).child("likes").setValue(_likes)
       // DataService.ds.REF_TIMELINE_POST_USERID.child(self._postKey).child("likes").setValue(_likes)
      //  DataService.ds.REF_POSTS_USERID.child("likes").setValue(_likes)
        
        URL_BASE.child("posts").child(self._postKey).child("likes").setValue(_likes)
        
      
        
        for friendID in self.followersList! {
            
            DataService.ds.REF_TIMELINE_POST.child(friendID).child(self._postKey).child("likes").setValue(_likes)
            print(" Array inside \(friendID)")
            
        }
        
    }
    
    
    func adjustDislikes(addDislikes: Bool, followersList: Array<String>) {
        self._followersList = followersList
        
        if addDislikes {
            _dislikes = _dislikes! + 1
        }else {
            _dislikes = _dislikes! - 1
        }
        
        //  _postRef.child("dislikes").setValue(_dislikes)
       // _user_posts_Ref.child("dislikes").setValue(_dislikes)
        DataService.ds.REF_USER_POSTS_BY_USER2.child(self._postKey).child("dislikes").setValue(_dislikes)
         URL_BASE.child("posts").child(self._postKey).child("dislikes").setValue(_dislikes)
      //  DataService.ds.REF_TIMELINE_POST_USERID.child(self._postKey).child("dislikes").setValue(_dislikes)
        
        
        for friendID in self.followersList! {
            
            DataService.ds.REF_TIMELINE_POST.child(friendID).child(self._postKey).child("dislikes").setValue(_dislikes)
            print(" Array inside \(friendID)")
            
        }

    }
    
    
    func adjustLikesByUser(addLike: Bool) {
        
        if addLike {
            _likes = _likes! + 1
            
        } else {
            _likes = _likes! - 1
        }
        
        //  _postRef.child("likes").setValue(_likes)
        __post_REf_By_USER.child("likes").setValue(_likes)  ////post on user-posts/userID/postID
        
        
        
        
    }
    
    func adjustDislikesByUser(addDislikes: Bool) {
        
        if addDislikes {
            _dislikes = _dislikes! + 1
        }else {
            _dislikes = _dislikes! - 1
        }
        
      //  _postRef.child("dislikes").setValue(_dislikes)
         __post_REf_By_USER.child("dislikes").setValue(_dislikes)
    }
    
    
    
    
    
}
















