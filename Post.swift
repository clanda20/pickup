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
    private var _postDescription: String!
    private var _imageUrl: String?
    private var _likes: Int!
    private var _username: String!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    private var _dislikes: Int!
    
    
    var postDescription: String{
        return _postDescription
    }
    
    var imageUrl: String?{
        return _imageUrl
    }
    
    var likes: Int{
        return _likes
    }
    
    var username: String{
        return _username
    }
    
    var postKey: String{
        return _postKey
    }
    
    var postRef: FIRDatabaseReference{
        return _postRef
    }
    
    var dislikes: Int {
        return _dislikes
    }
    
    
    init(description: String, imageUrl: String?, username: String) {
        self._postDescription = description
        self._imageUrl = imageUrl
        self._username = username
    }
    
    init(postKey: String, dictionary: Dictionary<String, AnyObject>){
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
        
        self._postRef = DataService.ds.REF_POSTS.child(self._postKey)
    }
    
    func adjustLikes(addLike: Bool) {
        
        if addLike {
            _likes = _likes + 1
            
        } else {
            _likes = _likes - 1
        }
        
        _postRef.child("likes").setValue(_likes)
        
        
        
    }
    
    func adjustDislikes(addDislikes: Bool) {
        
        if addDislikes {
            _dislikes = _dislikes + 1
        }else {
            _dislikes = _dislikes - 1
        }
        
        _postRef.child("dislikes").setValue(_dislikes)
        
        
    }
}
















