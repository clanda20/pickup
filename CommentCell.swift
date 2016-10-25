//
//  CommentCell.swift
//  pickup
//
//  Created by christian landa on 6/22/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Firebase

protocol ContactIDCommentCellDelegate {
    func ContactIDCommentSegueFromCell(contactID dataobject: AnyObject)
    
}

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
   // @IBOutlet weak var Username2: UILabel!
    
    @IBOutlet weak var Username2: UIButton!
   // @IBOutlet weak var commentText: UITextView!
    
    @IBOutlet weak var commentText: UILabel!
    
 
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var deleteBtn_friends_comment: UIButton!
    
    
    
    var comment: Comment!
     var post: Post!
    
    var value: Int!
    
    var postRefKey: FIRDatabaseReference!
    
    var userCommentsRef: FIRDatabaseReference!
    
    var postKey:String?
    
    var commentKeyID:String?
    
    var  DeleteRef: FIRDatabaseReference!
    var  DeleteRef2: FIRDatabaseReference!
    var  DeleteRef3: FIRDatabaseReference!
    
    var myCommentsArray: [String] = []
    var myPostArray: [String] = []
    var notifications_Array: [String] = []
    
    
    var following_Array: [String] = []
    
    var notificationstimelineID_Array: [String] = []
    
    
     var delegate2 : ContactIDCommentCellDelegate?
    
     var contactId: String!
    
   var notifications = [Notification]()

    var notification: Notification!
    
    var notificationID: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        FirebaseFanout()
       
      
      
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCommentCell(comment: Comment,img: UIImage?){
        
     
        
        let   commentID = comment.commentKey
          self.commentKeyID = comment.uid
            
            
          
        
        let notificationKey = notification?.notificationKey
        
       self.notificationID = notificationKey
                
           
       
        self.comment = comment
        
        
        self.commentText.text = comment.commentDescription
       // self.commentKeyID = comment.commentKey
        
       // print(" Printing Full Name  \(comment.fullName)")
        
         self.Username2.setTitle("\(comment.fullName)", forState: .Normal)
         self.Username2.titleLabel!.font = UIFont(name: "Marker Felt", size: 12)
         
        
        postRefKey = DataService.ds.REF_POSTCOMMENTS.child("postKey")  //added 6-29-16 //maybe mistake not affect anything
        
      //  print("PostKey PostCell XX: \(post.postKey)")
        
        
        if let  seconds = Double(((comment.date))) {
            let timeStampDate = NSDate(timeIntervalSince1970: seconds)
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "E, MMM d, H:mm a"
            self.dateLbl.text = dateFormatter.stringFromDate(timeStampDate)
        }
        
        
        
        downloadAvatar(comment.avatar!, completion:  { (data) in
            self.profileImg.image = UIImage(data: data)
            self.profileImg.layer.cornerRadius = 20.0
            self.profileImg.clipsToBounds = true
        })
        
        
        
       
        
        // Delete your own post only so hidden Delete button if the post is not yours
        
       // let uid = NSUserDefaults.standardUserDefaults().valueForKey("uid") as? String
        if KEY_UID != comment.uid {
            
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
       
        let   commentID = comment.commentKey
        
        DeleteRef = DataService.ds.Ref_USER_COMMENTS  //("user-comments")
        DeleteRef.child(KEY_UID!).child(commentID).removeValue()
        
        
           DeleteRef3 = DataService.ds.REF_POSTCOMMENTS_ID   //("post-comments" / postID")
        
        
            
            DeleteRef3.child(commentID).removeValue()
            
       // }
        
       let DeleteRef4 = DataService.ds.REF_POSTCOMMENTS_USER_ID  //URL_BASE.child("post-comments-userID").child(postID)
        DeleteRef4.child(commentID).removeValue()
        
        
        //delete notifications
        
         let postkeyUID = NSUserDefaults.standardUserDefaults().valueForKey("postKeyUID") as! String  // owner of the post
     
        
        if KEY_UID != postkeyUID {
         
                
                
                DataService.ds.REF_BASE.child("notifications").child(postkeyUID).child("N\(commentID)").removeValue()
                DataService.ds.REF_BASE.child("notifications-postUID").child(postkeyUID).child("N\(commentID)").removeValue()
                
            } else {
             // do nothing
        }
       
    }
    

    
    
    
  
    
    // should delete post-comments //post-comments-userID// user-comments

    
    @IBAction func delete_Btn_Not_in_my_timeline(sender: AnyObject) {   //  Delete only those post on my timeline or Wall
       
        
        print("delete_Btn_Not_in_my_timeline Pressed---------------------------")
       // should delete post-comments //post-comments-userID//
      //  ok, when pressed button1 , but button 2 only erase post-comments
        
        let   commentID = comment.commentKey
    

        DeleteRef = DataService.ds.REF_POSTCOMMENTS  //("post-comments") ok/// -------------1
        
          for postID in self.myPostArray {   // if post belong to current user  delete the comment on Post-comment
        
        DeleteRef.child(postID).child(commentID).removeValue()
        
          }
        
        
        let DeleteRef4 = DataService.ds.REF_COMMENTS_USERID  //URL_BASE.child("post-comments-userID").child(postID) ook-----------2
        
          for postID in self.myPostArray {   // if post belong to current user  delete the comment on Post-comment
        
       DeleteRef4.child(postID).child(commentID).removeValue()
            
        }
        
        //delete notifications
        
        let postkeyUID = NSUserDefaults.standardUserDefaults().valueForKey("postKeyUID") as! String  // owner of the post
        let postID  = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String  // might not be necesary 
        
          if KEY_UID == postkeyUID {
        
            DataService.ds.REF_BASE.child("notifications").child(postkeyUID).child("N\(commentID)").removeValue()
            DataService.ds.REF_BASE.child("notifications-postUID").child(postkeyUID).child("N\(commentID)").removeValue()
             DataService.ds.REF_BASE.child("post-commentsOnly").child(postID).child(commentID).removeValue()
            
          }  else {
            // do nothing
        }
            
     
        
       
        
        
            }
    
 
    func FirebaseFanout(){   // grabing the postID form the user-posts-id and userID
        
       
        userCommentsRef = DataService.ds.REF_USER_USER_POSTS_ID.child(KEY_UID!)   //("user-posts-id")
        userCommentsRef.observeEventType(.Value, withBlock:  { snapshot in
            
            
            
            
            
           self.myPostArray = []
            //  self.usersLists = []
            
            for child in snapshot.children {
                let postID = child.key as String
                print("postID  Array IIIIiiiiiipostIDDiii: \(postID)")
                
                self.myPostArray.append(postID)
                
                //   _ = Post(followersList: self.friendsArray)
                
                // self.usersLists.append(usersList)
                
                for postID in self.myPostArray {
                    print(" Array postID tonight  postID \(postID)")
                }
                
            }
        })
    }
    
    
 
    
    
    
    
    
    @IBAction func profileNameBtn(sender: AnyObject) {
        
        
        print("SNaps Agosto 2 POstKeyxxxxxxxxxxxxxxxx  :\(self.commentKeyID)")
        
        let contactID_Post_Profile = self.commentKeyID
        
        print("Segue Agosto 1xxxxx: contactID_Post_Profile \(contactID_Post_Profile)")
        
        if(self.delegate2 != nil){ //Just to be safe.
            self.delegate2!.ContactIDCommentSegueFromCell(contactID: contactID_Post_Profile!)
            print("Segue Agosto 1xxxxx: \(contactID_Post_Profile)")
            
        }
    }
    
}
