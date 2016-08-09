//
//  CommentCell.swift
//  pickup
//
//  Created by christian landa on 6/22/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Firebase

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
   // @IBOutlet weak var Username2: UILabel!
    
    @IBOutlet weak var Username2: UIButton!
   // @IBOutlet weak var commentText: UITextView!
    
    @IBOutlet weak var commentText: UILabel!
    
    
    var comment: Comment!
  //  var post: Post!
    
    var value: Int!
    
    var postRefKey: FIRDatabaseReference!
    
    var postKey:String?
    
    var  DeleteRef: FIRDatabaseReference!
    var  DeleteRef2: FIRDatabaseReference!
    var  DeleteRef3: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
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
        self.comment = comment
        
        self.commentText.text = comment.commentDescription
        
       // print(" Printing Full Name  \(comment.fullName)")
        
         self.Username2.setTitle("\(comment.fullName)", forState: .Normal)
         self.Username2.titleLabel!.font = UIFont(name: "Marker Felt", size: 12)
         
        
        postRefKey = DataService.ds.REF_POSTCOMMENTS.child("postKey")  //added 6-29-16
        
      //  print("PostKey PostCell XX: \(post.postKey)")
        
        
        
        downloadAvatar(comment.avatar!, completion:  { (data) in
            self.profileImg.image = UIImage(data: data)
            self.profileImg.layer.cornerRadius = 20.0
            self.profileImg.clipsToBounds = true
        })
        
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
        
        print("Delete BTn Pressed")
        print("Delete Photo from Storage: \(comment.imageUrl2!)")
        
        let   commentID = comment.commentKey
        
        DeleteRef = DataService.ds.REF_POSTS  //("posts")
        DeleteRef.child(commentID).removeValue()
        
        DeleteRef2 = DataService.ds.REF_USER_POSTS_BY_USER  //("user-posts")
        DeleteRef2.child(commentID).removeValue()
        
        DeleteRef3 = DataService.ds.REF_TIMELINE_POST  //("timeline")
        
        // let   postID = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        
        
     /*   for friendID in self.friendsArray {
            
            DeleteRef3.child(friendID).child(postID).removeValue()
            
            // print("Delete BTn Pressed")
            //  print("Delete Photo from Storage: \(post.imageUrl)")
            
            
            //delete photo posted.
            
            // Create a reference to the file to delete
            let photoPostRef = storage.referenceForURL(post.imageUrl!)  // url
            
            //  let desertRef = storageRef.child(post.imageUrl!)
            // Delete the file
            photoPostRef.deleteWithCompletion { (error) -> Void in
                if (error != nil) {
                    // Uh-oh, an error occurred!
                    print("error deleting photo")
                } else {
                    // File deleted successfully
                    print("File deleted successfully")
                }
            }
            
            
        }  */
        
        
        
    }
    // Delete only those post on my timeline or Wall
    
    @IBAction func delete_Btn_Not_in_my_timeline(sender: AnyObject) {
        
        let   commentID = comment.commentKey
        
        DeleteRef3 = DataService.ds.REF_TIMELINE_POST_USERID
        DeleteRef3.child(commentID).removeValue()
        
    }
    
}
