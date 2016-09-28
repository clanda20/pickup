//
//  EventCommentCell.swift
//  pickup
//
//  Created by christian landa on 9/5/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Firebase

protocol ContactIDEventCommentCellDelegate {
    func ContactIDEventCommentSegueFromCell(contactID dataobject: AnyObject)
    
}

class EventCommentCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    // @IBOutlet weak var Username2: UILabel!
    
    @IBOutlet weak var Username2: UIButton!
    // @IBOutlet weak var commentText: UITextView!
    
    @IBOutlet weak var commentText: UILabel!
    
    
    
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var deleteBtn_friends_comment: UIButton!
    
    
    
    var eventcomment: EventComment!
    var eventcomments = [EventComment]()
    //  var post: Post!
    
    var value: Int!
    
    var eventRefKey: FIRDatabaseReference!
    
    var userCommentsRef: FIRDatabaseReference!
    
    var postKey:String?
    
    var eventkey:String?
    var eventKey: String! // from segue EventDetailVC
    
     var eventcommentKeyID:String?
    
    var  DeleteRef: FIRDatabaseReference!
    var  DeleteRef2: FIRDatabaseReference!
    var  DeleteRef3: FIRDatabaseReference!
    
    var myCommentsArray: [String] = []
    var myPostArray: [String] = []
    
    
    
    var delegate2 : ContactIDEventCommentCellDelegate?
    
    var contactId: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        FirebaseFanout()
        //  FirebaseFanout2()
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureEventCommentCell(eventcomment: EventComment,img: UIImage?, eventKey: String!){
        
        // self.contactId =  post.uid
        
        let   eventcommentID = eventcomment.commentKey
        self.eventcommentKeyID = eventcomment.uid
        
        self.eventkey = eventKey
        
        self.eventcomment = eventcomment
        
        
        self.commentText.text = eventcomment.commentDescription
        // self.commentKeyID = comment.commentKey
        
        // print(" Printing Full Name  \(comment.fullName)")
        
        self.Username2.setTitle("\(eventcomment.fullName)", forState: .Normal)
        self.Username2.titleLabel!.font = UIFont(name: "Marker Felt", size: 12)
        
        
      //  postRefKey = DataService.ds.REF_POSTCOMMENTS.child("postKey")  //added 6-29-16 //maybe mistake not affect anything
        
        //  print("PostKey PostCell XX: \(post.postKey)")
        
        
        if let  seconds = Double(((eventcomment.date))) {
            let timeStampDate = NSDate(timeIntervalSince1970: seconds)
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "E, MMM d, H:mm a"
            self.dateLbl.text = dateFormatter.stringFromDate(timeStampDate)
        }
        
        
        
        downloadAvatar(eventcomment.avatar!, completion:  { (data) in
            self.profileImg.image = UIImage(data: data)
            self.profileImg.layer.cornerRadius = 20.0
            self.profileImg.clipsToBounds = true
        })
        
        
        
        //  self.contactId =  post.uid
        
        // Delete your own post only so hidden Delete button if the post is not yours
        
        // let uid = NSUserDefaults.standardUserDefaults().valueForKey("uid") as? String
        if KEY_UID != eventcomment.uid {
            
            self.deleteBtn.hidden = true
            self.deleteBtn_friends_comment.hidden = false
            
        } else {
            
            self.deleteBtn.hidden = false
            self.deleteBtn_friends_comment.hidden = true
            
        }
        
        
        
    }
    
    func downloadAvatar(image:String, completion:(data:NSData)-> ()) {
        
        let urlString = NSURL(string: image)
        let request = NSURLSession.sharedSession().dataTaskWithURL(urlString!){ (data, response, error) -> Void in
            
            if error == nil {
                
                if let dataValid = data {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(data: dataValid)
                    })
                    
                }
            }
            
            
        }
        
        request.resume()
    }
    
    
    
    //Delete complete post in all its locations.   Only the User Post.
    @IBAction func deleteCommentByUID(sender: AnyObject) {
        
        print("Delete BTn Pressed----------------------------------------")
        
        
        let   EventcommentID = eventcomment.commentKey
        
        
        DeleteRef = DataService.ds.REF_BASE.child("event-comments") //("event-comments")
        DeleteRef.child(KEY_UID!).child(EventcommentID).removeValue()
        
        //  DeleteRef2 = DataService.ds.REF_USER_USER_POSTS_ID  //("user-posts-id")
        // DeleteRef2.child(KEY_UID!).child(commentID).removeValue()
        
        // 9-5 DeleteRef3 = DataService.ds.REF_POSTCOMMENTS_ID   //("post-comments" / postID")
        DeleteRef3 = DataService.ds.REF_BASE.child("event-comments").child(eventkey!)
        
        // let   postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        
        
        
        // for commentID in self.myCommentsArray {
        
        DeleteRef3.child(EventcommentID).removeValue()
        
        // }
        
        let DeleteRef4 = DataService.ds.REF_BASE.child("event-comments-userID").child(eventkey!)  //URL_BASE.child("post-comments-userID").child(postID)
        
        DeleteRef4.child(EventcommentID).removeValue()
        
    }
    // Delete only those post on my timeline or Wall
    
    // should delete post-comments //post-comments-userID// user-comments
    
    
    @IBAction func delete_Btn_Not_in_my_timeline(sender: AnyObject) {
        
        
        
        print("delete_Btn_Not_in_my_timeline Pressed---------------------------")
        // should delete post-comments //post-comments-userID//
        //  ok, when pressed button1 , but button 2 only erase post-comments
        
        let   eventcommentID = eventcomment.commentKey
        
        
        //9-5     DeleteRef = DataService.ds.REF_POSTCOMMENTS  //("post-comments") ok/// -------------1
        DeleteRef = DataService.ds.REF_BASE.child("user-commets")
        
        for postID in self.myPostArray {   // if post belong to current user  delete the comment on Post-comment
            
            DeleteRef.child(eventkey!).child(eventcommentID).removeValue()
        }
        
        
        let DeleteRef4 = DataService.ds.REF_BASE.child("event-comments-userID").child(eventkey!) //URL_BASE.child("post-comments-userID").child(postID) ook-----------2
        
        
        for postID in self.myPostArray {   // if post belong to current user  delete the comment on Post-comment
            
            DeleteRef4.child(eventkey!).child(eventcommentID).removeValue()
            
        }
        
        
        
    }
    
    
    func FirebaseFanout(){   // grabing the postID form the user-posts-id and userID
        
        
        userCommentsRef = DataService.ds.REF_BASE.child("user-posts-id").child(KEY_UID!)   //("user-posts-id")
        
        userCommentsRef.observeEventType(.Value, withBlock:  { snapshot in
            
            
            print("new snapshot array: \(snapshot.key)")
            
            
            self.myPostArray = []
            //  self.usersLists = []
            
            for child in snapshot.children {
                let eventID = child.key as String
                print("postID  Array IIIIiiiiiipostIDDiii: \(eventID)")
                
                self.myPostArray.append(eventID)
                
                //   _ = Post(followersList: self.friendsArray)
                
                // self.usersLists.append(usersList)
                
                for eventID in self.myPostArray {
                    print(" Array postID tonight  postID \(eventID)")
                }
                
            }
        })
    }
    @IBAction func profileNameBtn(sender: AnyObject) {
        
        
        print("SNaps Agosto 2 POstKeyxxxxxxxxxxxxxxxx  :\(self.eventcommentKeyID)")
        
        let contactID_Post_Profile = self.eventcommentKeyID
        
        print("Segue Agosto 1xxxxx: contactID_Post_Profile \(contactID_Post_Profile)")
        
        if(self.delegate2 != nil){ //Just to be safe.
            self.delegate2!.ContactIDEventCommentSegueFromCell(contactID: contactID_Post_Profile!)
            print("Segue Agosto 1xxxxx: \(contactID_Post_Profile)")
            
        }
    }
    
}
