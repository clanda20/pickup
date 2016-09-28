//
//  EventComment.swift
//  pickup
//
//  Created by christian landa on 9/5/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import Foundation
import Firebase


class EventComment {
    private var _commentDescription: String?
    private var _imageUrl2: String?
    private var _avatar: String?
    private var _fullName: String!
    private var _username2: String!
    private var _commentKey: String!
    private var _commentRef: FIRDatabaseReference!
    private var _uid: String!
    private var _date: String!

    
    var commentDescription: String? {
        return _commentDescription
    }
    
    var imageUrl2: String? {
        return _imageUrl2
    }
    
    var avatar: String? {
        return _avatar
    }
    
    var username2: String? {
        return _username2
    }
    
    
    var fullName: String {
        return _fullName
    }
    
    var commentKey: String {
        return _commentKey
    }
    
    var uid: String {
        return _uid
    }
    
    var commentRef: FIRDatabaseReference{
        return _commentRef
    }
    
    var date: String{
        return _date
    }
    
    
    init(description: String, imageUrl2: String?, fullName: String,avatar: String?, date: String) {
        
        self._commentDescription = description
        self._imageUrl2 = imageUrl2
        self._fullName = fullName
        self._avatar = avatar
        self._date = date

    
    }
    
    init(commentKey: String, dictionary: Dictionary<String, AnyObject>) {
        
        self._commentKey = commentKey
        
        if let imgUrl2 = dictionary["imageUrl2"] as? String {
            self._imageUrl2 = imgUrl2
        }
        
        if let desc = dictionary["text"] as? String {
            self._commentDescription = desc
        }
        
        if let desc = dictionary["fullName"] as? String {
            self._fullName = desc
        }
        
        if let avatar = dictionary["avatar"] as? String {
            self._avatar = avatar
        }
        if let uid = dictionary["uid"] as? String {
            self._uid = uid
        }
        if let date = dictionary["date"] as? String {
            self._date = date
        }
        
self._commentRef = DataService.ds.REF_BASE.child("event-comments").child(self._commentKey)
    }
}

