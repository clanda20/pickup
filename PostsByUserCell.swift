//
//  PostsByUserCell.swift
//  pickup
//
//  Created by christian landa on 7/15/16.
//  Copyright © 2016 christian landa. All rights reserved.
//


    import UIKit
    import Alamofire
    import Firebase
    
   protocol PostsByUserCellDelegate {
        func callSegueFromCell(myData dataobject: AnyObject)
    }
 
    
    class PostsByUserCell: UITableViewCell {
        
        @IBOutlet weak var profileImg: UIImageView!
       @IBOutlet weak var showcaseImg: UIImageView!
        @IBOutlet weak var descriptionText: UITextView!
        @IBOutlet weak var likeLbl: UILabel!
        @IBOutlet weak var likeImage: UIImageView!
        
        @IBOutlet weak var profileName: UIButton!
        
        @IBOutlet weak var dislikeLbl: UILabel!
        @IBOutlet weak var dislikeImage: UIImageView!
        // @IBOutlet weak var commentBtn: UIButton!
        @IBOutlet weak var commentBtn: UIButton!
        
 
        var delegate : PostsByUserCellDelegate?
        
        var post: Post!
        var request: Request?
        var likeRef: FIRDatabaseReference!
        var dislikeRef: FIRDatabaseReference!
        var postRefKey: FIRDatabaseReference!
        
        var  DeleteRef: FIRDatabaseReference!
        var  DeleteRef2: FIRDatabaseReference!
        var  DeleteRef3: FIRDatabaseReference!
        var followersRef: FIRDatabaseReference!

        
        var postKey: String!
        
        var contactId: String!
        
        var friendsArray: [String] = []
        
        override func awakeFromNib() {
            super.awakeFromNib()
            
            let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
            tap.numberOfTapsRequired = 1
            likeImage.addGestureRecognizer(tap)
            likeImage.userInteractionEnabled = true
            
            
            
            let tap2 = UITapGestureRecognizer(target: self, action: "dislikeTapped:")
            tap2.numberOfTapsRequired = 1
            dislikeImage.addGestureRecognizer(tap2)
            dislikeImage.userInteractionEnabled = true
            
           FirebaseFanout()
            
        }
        
        override func drawRect(rect: CGRect) {
            profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
            profileImg.clipsToBounds = true
            
            showcaseImg.clipsToBounds = true
        }
        
        override func setSelected(selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        }
        
        
        func  configureCell(post: Post, img: UIImage?, userID: String?) {   // before it was configureCell(post: Post) { }
            
            self.post = post
            
            
            
            
            likeRef = DataService.ds.REF_USERS.child(userID!).child("likes").child(post.postKey)   // check ojo for True or False
            
            // likeRef = DataService.ds.REF_USER_POSTS_USERID.child("likes").child(post.postKey)
            
            dislikeRef = DataService.ds.REF_USER_CURRENT.child("dislikes").child(post.postKey)  // check ojo for True or False
            // dislikeRef = DataService.ds.REF_USER_POSTS_USERID.child("dislikes").child(post.postKey)
            
             postRefKey = DataService.ds.REF_POSTCOMMENTS.child(post.postKey)  //added 6-29-16
            
           // postRefKey = DataService.ds.REF_USER_POST.child(userID!).child(post.postKey)
           // postRefKey = URL_BASE.child("user-posts").child(userID!).child(post.postKey)

            
            print("PostKey PostCell July 6: \(post.postKey)")
            
            
            
            
            self.descriptionText.text = post.postDescription
            self.likeLbl.text = "\(post.likes)"
            
            
            self.dislikeLbl.text = "\(post.dislikes)"
            
            
            
            
            print(" Printing Full Name  \(post.fullName)")
            
            self.profileName.setTitle("\(post.fullName)", forState: .Normal)
            self.profileName.titleLabel!.font = UIFont(name: "Marker Felt", size: 12)
            
            self.contactId =  post.uid
            
            
            
            
            print( "Segue Agosto 1: \(self.contactId)")
            
            self.dislikeLbl.text = "\(post.dislikes)"
            
            
            downloadAvatar(post.avatar!, completion:  { (data) in
                self.profileImg.image = UIImage(data: data)
                self.profileImg.layer.cornerRadius = 20.0
                self.profileImg.clipsToBounds = true
            })
            
            
            
            if post.imageUrl != nil {
                
                if img != nil {
                    self.showcaseImg.image = img
                } else {
                    request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                        
                        if err == nil {
                            let img = UIImage(data: data!)!
                            self.showcaseImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                        }
                    })
                }
                
                
            } else {
                self.showcaseImg.hidden = true
            }
            
            
            likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                
                if (snapshot.value as? NSNull) != nil {   //WE don't like the current post
                    self.likeImage.image = UIImage(named: "heart-empty")
                    
                } else {
                    self.likeImage.image = UIImage(named: "heart-full")
                }
                
                
            })
            
            dislikeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                
                if(snapshot.value as? NSNull) != nil {
                    self.dislikeImage.image = UIImage(named: "heart2-empty")    //  "Thumbs_down_Off"
                } else {
                    self.dislikeImage.image = UIImage(named: "heart2-full")    //  "Thumbs_down_ON"
                }
            })
            
            
            
            
        }
        
        
        
        @IBAction func Comment_Post_Btn(sender: AnyObject) {
            
            let postKey = post.postKey
            print("SNaps July 7 POstKeyxxxxxxxxxxxxxxxx  :\(postKey)")
            
            //let postKey =  post.postKey
            NSUserDefaults.standardUserDefaults().setValue(postKey, forKey: "postKey")
            NSUserDefaults.standardUserDefaults().synchronize()
            if(self.delegate != nil){ //Just to be safe.
                self.delegate!.callSegueFromCell(myData: postKey)
                
            }
        }
        
     /*   func CommentBtnTapped(sender: UITapGestureRecognizer){
            
            postRefKey.observeEventType(.Value, withBlock: { snapshot in
                
                print("SNaps July 6 :\(snapshot)")
                
                
                let postKey =  self.post.postKey
                
                
                
                NSUserDefaults.standardUserDefaults().setValue(postKey, forKey: "postKey")
                // NSUserDefaults.standardUserDefaults().synchronize()
                
                // FeedVC.performSegueWithIdentifier("segue_commentVC, sender: sender)
                
                
            })
        }  */
        
        
        func likeTapped(sender: UITapGestureRecognizer){
            
            likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                
                if (snapshot.value as? NSNull) != nil {   //WE don't like the current post
                    self.likeImage.image = UIImage(named: "heart-full")
                    self.post.adjustLikesByUser(true)
                    self.likeRef.setValue(true)
                    
                    self.dislikeImage.userInteractionEnabled = false
                    
                    
                } else {
                    self.likeImage.image = UIImage(named: "heart-empty")
                    self.post.adjustLikesByUser(false)
                    self.likeRef.removeValue()
                    
                    self.dislikeImage.userInteractionEnabled = true
                    
                }
                
                
            })
            
        }
        
        func dislikeTapped(sender: UITapGestureRecognizer){
            
            dislikeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                
                if (snapshot.value as? NSNull) != nil {
                    self.dislikeImage.image = UIImage(named: "heart2-full")
                    self.post.adjustDislikesByUser(true)
                    self.dislikeRef.setValue(true)
                    
                    
                    self.likeImage.userInteractionEnabled = false
                    
                    
                    
                }else {
                    self.dislikeImage.image = UIImage(named: "heart2-empty")
                    self.post.adjustDislikesByUser(false)
                    self.dislikeRef.removeValue()
                    
                    self.likeImage.userInteractionEnabled = true
                    
                    
                }
            })
            
        }
        
        @IBAction func profileNameBtn(sender: AnyObject) {
            
            
           
                
            
        }
        //download profile image from Facebook
        
        func downloadAvatar(image:String?, completion:(data:NSData)-> ()) {
            
            print("Image:xxxxxxxxx--------xxxxxxxx: \(image)")
            
            let urlString = NSURL(string: (image)!)
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
        
        
        
       
 
        @IBAction func delete_My_Own_Post(sender: AnyObject) {
            
            let   postID = post.postKey
            
            DeleteRef = DataService.ds.REF_POSTS  //("posts")
            DeleteRef.child(postID).removeValue()
            
            DeleteRef2 = DataService.ds.REF_USER_POSTS_BY_USER  //("user-posts")
            DeleteRef2.child(postID).removeValue()
            
            DeleteRef3 = DataService.ds.REF_TIMELINE_POST  //("timeline")
                        
            
            for friendID in self.friendsArray {
                
                DeleteRef3.child(friendID).child(postID).removeValue()
                
                print("Delete BTn Pressed")
                
                
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
                
                
            }
        }
        
        
        func FirebaseFanout(){
            
            
            // followingsRef = DataService.ds.REF_FOLLOWING_USERID
            // followingsRef.observeEventType(.Value, withBlock:  { snapshot in
            followersRef = DataService.ds.REF_FOLLOWER_USERID
            followersRef.observeEventType(.Value, withBlock:  { snapshot in
                
                
                print("new snapshot array: \(snapshot.key)")
                
                
                self.friendsArray = []
                //  self.usersLists = []
                
                for child in snapshot.children {
                    let friendID = child.key as String
                    print("friendID  Array IIIIiiiiiiPostCelliiiiiii: \(friendID)")
                    
                    self.friendsArray.append(friendID)
                    
                    //   _ = Post(followersList: self.friendsArray)
                    
                    // self.usersLists.append(usersList)
                    
                    for friendID in self.friendsArray {
                        print(" Array friendID tonight  PostCell \(friendID)")
                        
                        
                        
                        
                    }
                    
                }
            })
        }
        
}
