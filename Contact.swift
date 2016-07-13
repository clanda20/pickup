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
    private var _firstName: String!
    private var _lastName: String!
    private var _username: String!
    private var _avatar: String?
    private var _likes: Int!
    private var _dislikes: Int!
    private var _email: String!
    private var _postNumber: Int!
    private var _following: Int!
    private var _followers: Int!
    private var _contactKey: String!
    private var _contactRef: FIRDatabaseReference!
    private var _contactAdd: NSDictionary!
    
    
    var firstName: String{
        return _firstName
    }
    
    var lastName: String{
        
        return _lastName
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
    
    var dislikes: Int {
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
    
    
    init(data: NSDictionary){
        
        self._contactAdd = data
        
    }
    
    
    init(firstName: String,lastName: String, username: String, avatar: String?, likes: Int, email: String, postNumber: Int, following: Int, followers:Int) {
        self._firstName = firstName
        self._lastName = lastName
        self._username = username
        self._avatar = avatar
        self._likes = likes
        self._dislikes = dislikes
        self._email = email
        self._postNumber = postNumber
        self._following = following
        self._followers = followers
        
    }
    
    
    init(contactKey: String, dictionary: Dictionary<String, AnyObject>){
        
        self._contactKey = contactKey
        
        if let firstName = dictionary["firstName"] as? String {
            self._firstName = firstName
        }
        
        if let lastName = dictionary["lastName"] as? String {
            self._lastName = lastName
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
        
        if let postNumber = dictionary["email"] as? Int {
            self._postNumber = postNumber
        }
        
        
        if let following = dictionary["following"] as? Int {
            self._following = following
        }
        
        if let followers = dictionary["followers"] as? Int {
            self._followers = followers
        }
        
        
          self._contactRef = DataService.ds.REF_USERS.child(self._contactKey)
        
        // self._commentPostRef = DataService.ds.REF_POSTCOMMENTS.child(self._postKey)
    }
}


