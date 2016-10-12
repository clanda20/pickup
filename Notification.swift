//
//  Notification.swift
//  pickup
//
//  Created by christian landa on 10/3/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import Foundation
import Firebase

class Notification {
    private var _commentID: String?
    private var _avatar: String?
    private var _fullName: String!
    private var _postKey: String!
    private var _notificationKey: String!
    private var _uid: String?
    private var _date: String!
    private var _type: String!
    private var _notificationRef: FIRDatabaseReference!
    
    
    
    var commentID: String?{
        return _commentID
    }
    
    
    var avatar: String?{
        return _avatar
    }
    
    
    var fullName: String{
        return _fullName
    }
    
    var postKey: String{
        return _postKey
    }
    var notificationKey: String{
        return _notificationKey
    }
    
    
    var uid: String? {
        return _uid
    }
    
    
    var type: String{
        return _type
    }
    
    var date: String{
        return _date
    }
    var notificationRef: FIRDatabaseReference{
        return _notificationRef
    }
    
    
    init(commentID: String?, fullName: String, avatar: String?, date: String, type: String, postKey: String, notificationKey: String ) {
        self._commentID = commentID
        self._fullName = fullName
        self._avatar = avatar
        self._date = date
        self._type = type
        self._postKey = postKey
        self._notificationKey = notificationKey
        
    }
    
    
    
    init(notificationKey: String, dictionary: Dictionary<String, AnyObject>){  // need UID
         self._notificationKey = notificationKey
        
        
        
        if let commentID = dictionary["commentID"] as? String {
            self._commentID = commentID
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
        
        if let notificationKey = dictionary["notificationKey"] as? String {
            self._notificationKey = notificationKey
        }
        
        if let date = dictionary["date"] as? String {
            self._date = date
        }
        if let type = dictionary["type"] as? String {
            self._type = type
        }
        if let postKey = dictionary["postKey"] as? String {
            self._postKey = postKey
        }
        
        
       self._notificationRef = DataService.ds.REF_BASE.child("notifications").child(self._notificationKey)
    }
}

