//
//  Contact.swift
//  pickup
//
//  Created by christian landa on 7/11/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import Foundation
import Firebase

class Contact{
    private var _fullName: String!
    private var _username: String!
    private var _avatar: String?
    private var _likes: Int!
    private var _dislikes: Int!
    private var _email: String!
    private var _postNumber: Int!
    private var _following: Int!
    private var _followers: Int!
    private var _followings: NSDictionary?
    private var _contactKey: String!
    private var _contactRef: FIRDatabaseReference!
    private var _contactAdd: NSDictionary!
    
    
    var fullName: String{
        return _fullName
    }
    
    
    
    var username: String{
        return _username
    }
    
    var avatar: String?{
        return _avatar
    }
    
    var likes: Int{
        return _likes
    }
    
    var dislikes: Int? {
        return _dislikes
    }
    
    var email: String{
        return _email
    }
    
    var postNumber: Int{
        return _postNumber
    }
    
    var following: Int {
        return _following
    }
    
    var followers: Int {
        return _followers
    }
    
    var contactKey: String{
        return _contactKey
    }
    
    var contactRef: FIRDatabaseReference{
        return _contactRef
    }
    
    var contactAdd: NSDictionary {
        return _contactAdd
    }
    
    var followings: NSDictionary? {
        return _followings
    }
    
    init(data: NSDictionary){
        
        self._contactAdd = data
        
    }
    
    
    init(fullName: String, username: String, avatar: String?, likes: Int, dislikes: Int, email: String, postNumber: Int,followings: NSDictionary, following: Int, followers:Int) {
        self._fullName = fullName
         self._username = username
        self._avatar = avatar
        self._likes = likes
        self._dislikes = dislikes
        self._email = email
        self._postNumber = postNumber
        self._following = following
        self._followings = followings
        self._followers = followers
        
    }
    
    
    init(contactKey: String, dictionary: Dictionary<String, AnyObject>){
        
        self._contactKey = contactKey
        
        if let fullName = dictionary["fullName"] as? String {
            self._fullName = fullName
        }
        
        
        if let username = dictionary["username"] as? String {
            self._username = username
        }
        
        if let avatar = dictionary["avatar"] as? String {
            self._avatar = avatar
        }
        
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        }
        
        if let dislikes = dictionary["dislikes"] as? Int {
            self._dislikes = dislikes
        }
        
        if let email = dictionary["email"] as? String {
            self._email = email
        }
        
        if let postNumber = dictionary["postNumber"] as? Int {
            self._postNumber = postNumber
        }
        
        
        if let following = dictionary["following"] as? Int {
            self._following = following
        }
        
        if let followers = dictionary["followers"] as? Int {
            self._followers = followers
        }
        
        if let followings = dictionary["followings"] as? NSDictionary {
            self._followings = followings
        }
        
        
          self._contactRef = DataService.ds.REF_USERS.child(self._contactKey)
        
        // self._commentPostRef = DataService.ds.REF_POSTCOMMENTS.child(self._postKey)
    }
    
    
    init(contactKey_Nesting: String, dictionary_Nesting: AnyObject){
        
        self._contactKey = contactKey_Nesting
        
        if let fullName = dictionary_Nesting["fullName"] as? String {
            self._fullName = fullName
        }
        
       
        
        if let username = dictionary_Nesting["username"] as? String {
            self._username = username
        }
        
        if let avatar = dictionary_Nesting["avatar"] as? String {
            self._avatar = avatar
        }
        
       
        
        if let email = dictionary_Nesting["email"] as? String {
            self._email = email
        }
        
        if let postNumber = dictionary_Nesting["postNumber"] as? Int {
            self._postNumber = postNumber
        }
        
        
        if let following = dictionary_Nesting["following"] as? Int {
            self._following = following
        }
        
        if let followers = dictionary_Nesting["followers"] as? Int {
            self._followers = followers
        }
        
       
        
        
        self._contactRef = DataService.ds.REF_USERS.child(self._contactKey)
        
        // self._commentPostRef = DataService.ds.REF_POSTCOMMENTS.child(self._postKey)  
    }

}


