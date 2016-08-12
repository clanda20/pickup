//
//  PostCellTableViewCell.swift
//  pickup
//
//  Created by christian landa on 5/24/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

protocol PostCellDelegate {
    func callSegueFromCell(myData dataobject: AnyObject)
   
}
protocol ContactIDCellDelegate {
    func ContactIDSegueFromCell(contactID dataobject: AnyObject)
    
}

protocol ImageURLSegue_CellDelegate {
    func ImageURLSegue_Cell( postKey_Segue dataobject: AnyObject)
    
}




class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    
    @IBOutlet weak var profileName: UIButton!
   
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var deleteBtn_friends_post: UIButton!
    
    @IBOutlet weak var dislikeLbl: UILabel!
    @IBOutlet weak var dislikeImage: UIImageView!
    @IBOutlet weak var commentBtn: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
   // @IBOutlet weak var date: UIButton!
    
   var delegate : PostCellDelegate?
   var delegate2 : ContactIDCellDelegate?
   var delegate3 : ImageURLSegue_CellDelegate?
    
    var post: Post!
    var request: Request?
    var likeRef: FIRDatabaseReference!
    var dislikeRef: FIRDatabaseReference!
    var postRefKey: FIRDatabaseReference!
    
    var  DeleteRef: FIRDatabaseReference!
    var  DeleteRef2: FIRDatabaseReference!
    var  DeleteRef3: FIRDatabaseReference!
    var  DeleteRef4: FIRDatabaseReference!
    var  DeleteRef5: FIRDatabaseReference!
    var  DeleteRef6: FIRDatabaseReference!

    
    var postKey: String!
    
    var contactId: String!
    
    var imageUrl_Segue: String!
    
    var activeUserInfo: NSDictionary?
   // var image: String?
    
    
  
    
    var followersRef: FIRDatabaseReference!
    var friendsArray: [String] = []
    
     var followersList = []
    

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
        
        
  /*      let tap3 = UITapGestureRecognizer(target: self, action: #selector(deletePostByUID(_:)))
        tap3.numberOfTapsRequired = 1
        deleteBtn.addGestureRecognizer(tap3)
        deleteBtn.userInteractionEnabled = true
       // tap3.cancelsTouchesInView = false
        
    */
        //self.profileName.text = "\(post.fullName)"
        
       // self.profileName.text = "\(post.fullName)"
     //  QueryCurrentUser()
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

    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImg.clipsToBounds = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func  configureCell(post: Post, img: UIImage? ) {   // before it was configureCell(post: Post) { }
        
        self.post = post
        
         // self.followersList = post.followersList
        
        for test in followersList {
            print("Array on PostCell: \(test)")
        }
        
        
       // let postUserID = post.uid
       // print("SNaps July 24  postUserIDxxxxxxxxxxxxxxxx  :\(postUserID)")
        
        //let postKey =  post.postKey
     //  NSUserDefaults.standardUserDefaults().setValue(postUserID, forKey: "postUserID")
      //  NSUserDefaults.standardUserDefaults().synchronize()
        
      // likeRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)   // check ojo for True or False 7-24 REF_USER_POSTS_BY_USER2
        likeRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        
        
       // likeRef = DataService.ds.REF_USER_POSTS_USERID.child("likes").child(post.postKey)
        
        dislikeRef = DataService.ds.REF_USER_CURRENT.child("dislikes").child(post.postKey)  // check ojo for True or False
       // dislikeRef = DataService.ds.REF_USER_POSTS_USERID.child("dislikes").child(post.postKey)
        
        postRefKey = DataService.ds.REF_POSTCOMMENTS.child(post.postKey)  //added 6-29-16
        
         print("PostKey PostCell July 6: \(post.postKey)")
        
        
        
     
        self.descriptionText.text = post.postDescription
        self.likeLbl.text = "\(post.likes)"

       print(" Printing Full Name  \(post.fullName)")
        
        self.profileName.setTitle("\(post.fullName)", forState: .Normal)
        self.profileName.titleLabel!.font = UIFont(name: "Marker Felt", size: 12)
        
      //  self.date.setTitle(post.date, forState: .Normal)
        
        
        self.contactId =  post.uid
    
        // Delete your own post only so hidden Delete button if the post is not yours 
        
        let uid = NSUserDefaults.standardUserDefaults().valueForKey("uid") as? String
        if uid != post.uid {
           
            self.deleteBtn.hidden = true
            self.deleteBtn_friends_post.hidden = false
            
        } else {
            
            self.deleteBtn.hidden = false
            self.deleteBtn_friends_post.hidden = true

        }
        
        
      
       
        
      

        
        print( "Segue Agosto 1: \(self.contactId)")
        
        self.dislikeLbl.text = "\(post.dislikes)"
       
        //  from youtube firebase 3, how to group messagers per user EP 10 min 25aprox
        
        if let  seconds = Double(post.time) {
            let timeStampDate = NSDate(timeIntervalSince1970: seconds)
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss a"
            self.timeLabel.text = dateFormatter.stringFromDate(timeStampDate)
        }
        
        
        
        downloadAvatar(post.avatar!, completion:  { (data) in
            self.profileImg.image = UIImage(data: data)
            self.profileImg.layer.cornerRadius = 20.0
            self.profileImg.clipsToBounds = true
        })
        
       
        
        
  /// the bellow code can be done with youtube video Firebase 3. How to group message EP10 min 11:00
        
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
        
        
        likeRef.observeSingleEventOfType(.ChildAdded, withBlock: { snapshot in
            
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
  /*  let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "HH:MM:SS"
        return label
    }()*/
    
  
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
    
 
    
    
    func likeTapped(sender: UITapGestureRecognizer){
        
        
        let postUserID = post.uid
        print("SNaps July 24  postUserIDxxxxxxxxxxxxxxxx  :\(postUserID)")
        
        //let postKey =  post.postKey
         NSUserDefaults.standardUserDefaults().setValue(postUserID, forKey: "postUserID")
        
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if (snapshot.value as? NSNull) != nil {   //WE don't like the current post
                self.likeImage.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true, followersList: self.friendsArray)
                self.likeRef.setValue(true)
                
               self.dislikeImage.userInteractionEnabled = false
  
            } else {
                self.likeImage.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false, followersList: self.friendsArray)
                self.likeRef.removeValue()
                
               self.dislikeImage.userInteractionEnabled = true
                
            }
            
            
        })
        
    }
    
    func dislikeTapped(sender: UITapGestureRecognizer){
        
        let postUserID = post.uid
        
   
        print("SNaps July 24  postUserIDxxxxxxxxxxxxxxxx  :\(postUserID)")
        
        //let postKey =  post.postKey
        NSUserDefaults.standardUserDefaults().setValue(postUserID, forKey: "postUserID")
        
         dislikeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if (snapshot.value as? NSNull) != nil {
                self.dislikeImage.image = UIImage(named: "heart2-full")
             //   self.post.adjustDislikes(true, followersList: self.post.followersList)
                self.post.adjustDislikes(true, followersList: self.friendsArray)
                self.dislikeRef.setValue(true)
                
                
           self.likeImage.userInteractionEnabled = false

                
                
            }else {
                self.dislikeImage.image = UIImage(named: "heart2-empty")
               self.post.adjustDislikes(false, followersList: self.friendsArray)
                self.dislikeRef.removeValue()
                
                self.likeImage.userInteractionEnabled = true
               
               
            }
        })
        
    }
    
    //download profile image from Facebook
    
    func downloadAvatar(image:String, completion:(data:NSData)-> ()) {
        
        print("Image:xxxxxxxxx--------xxxxxxxx: \(image)")
        
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

    @IBAction func profileNameBtn(sender: AnyObject) {
        
        
        print("SNaps Agosto 2 POstKeyxxxxxxxxxxxxxxxx  :\(self.contactId)")
        
        let contactID_Post_Profile = self.contactId
        
        print("Segue Agosto 1xxxxx: contactID_Post_Profile \(contactID_Post_Profile)")
    
        if(self.delegate2 != nil){ //Just to be safe.
           // self.delegate2!.ContactIDSegueFromCell(contactID: contactID_Post_Profile)
            self.delegate2!.ContactIDSegueFromCell(contactID: self.contactId)
            print("Segue Agosto 1xxxxx: \(self.contactId)")
       // FeedVC.performSegueWithIdentifier("segue_Profile_Name", sender: sender){
        
    }
    }
    
    
    //Delete complete post in all its locations.   Only the User Post. 
    @IBAction func deletePostByUID(sender: AnyObject) {
        
        print("Delete BTn Pressed")
        print("Delete Photo from Storage: \(post.imageUrl!)")
        
        let   postID = post.postKey
        
       DeleteRef = DataService.ds.REF_POSTS  //("posts")
       DeleteRef.child(postID).removeValue()
        
       DeleteRef2 = DataService.ds.REF_USER_POSTS_BY_USER  //("user-posts")
       DeleteRef2.child(postID).removeValue()
        
        DeleteRef4 = DataService.ds.REF_POSTCOMMENTS  //(" post-comments")
        DeleteRef4.child(postID).removeValue()
        
        DeleteRef5 = DataService.ds.REF_USER_USER_POSTS_ID.child(KEY_UID!)  // user-post_id   //maybe a loop is needed.
        DeleteRef5.child(postID).removeValue()
        
        DeleteRef6 = DataService.ds.REF_COMMENTS_USERID.child(postID)  //(" post-comments-userID"//child(postID))
        DeleteRef6.removeValue()
        
       DeleteRef3 = DataService.ds.REF_TIMELINE_POST  //("timeline")
      
        for friendID in self.friendsArray {
            
            DeleteRef3.child(friendID).child(postID).removeValue()
           
            
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
    // Delete only those post on my timeline or Wall
    
    @IBAction func delete_Btn_Not_in_my_timeline(sender: AnyObject) {
        
        let   postID = post.postKey
        
        DeleteRef3 = DataService.ds.REF_TIMELINE_POST_USERID   //child("timeline").child(uid!)
        DeleteRef3.child(postID).removeValue()
        
    }
    
    
    //  Segue Image to a imageVC
    
    @IBAction func imageBtn_To_Segue(sender: AnyObject) {
        
        let postKey_Segue = post.postKey
        
        print("Segue Agosto 7 postKey_Segue \(postKey_Segue)")
        
        if(self.delegate3 != nil){ //Just to be safe.
            
       self.delegate3!.ImageURLSegue_Cell(postKey_Segue: postKey_Segue)
           
            
            
        }
        
        
    }
}


