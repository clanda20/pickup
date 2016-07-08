//
//  Comment.swift
//  pickup
//
//  Created by christian landa on 6/23/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import Foundation
import Firebase

/* class Comment: NSObject {
    var uid: String
    var text: String
    
    
    init(uid: String, text: String){
        self.uid = uid
        self.text = text
    }
    
    convenience override init(){
        self.init(uid: "", text: "")
    }
}
*/
  class Comment {
    private var _commentDescription: String?
    private var _imageUrl2: String?
    private var _username2: String!
    private var _commentKey: String!
    private var _commentRef: FIRDatabaseReference!
    
    var commentDescription: String? {
        return _commentDescription
    }
    
    var imageUrl2: String? {
        return _imageUrl2
    }
    
    var username2: String? {
        return _username2
    }
    
    var commentKey: String {
        return _commentKey
    }
    

    
    var commentRef: FIRDatabaseReference{
        return _commentRef
    }
    
    init(description: String, imageUrl2: String?, username2: String) {
        
        self._commentDescription = description
        self._imageUrl2 = imageUrl2
        self._username2 = username2
        
    }
    
    init(commentKey: String, dictionary: Dictionary<String, AnyObject>) {
        
        self._commentKey = commentKey
        
        if let imgUrl2 = dictionary["imageUrl2"] as? String {
            self._imageUrl2 = imgUrl2
        }
        
        if let desc = dictionary["text"] as? String {
            self._commentDescription = desc
        }
        
        self._commentRef = DataService.ds.REF_POSTCOMMENTS.child(self._commentKey)
        
    }
}
