//
//  PostCellTableViewCell.swift
//  pickup
//
//  Created by christian landa on 5/24/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
//import Alamofire
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseMessaging
import FirebaseStorage

protocol PostCellDelegate {
    func callSegueFromCell(myData dataobject: AnyObject)
   
}
protocol ContactIDCellDelegate {
    func ContactIDSegueFromCell(contactID dataobject: AnyObject)
    
}

protocol ImageURLSegue_CellDelegate {
    func ImageURLSegue_Cell( postKey_Segue dataobject: AnyObject)
    
}

protocol VideoURLSegue_CellDelegate {
    func VideoURLSegue_Cell( videoUrl_segue dataobject: AnyObject)
    
}


protocol EventSegue_CellDelegate {
    func EventSegue_Cell( eventKey_segue dataobject: AnyObject)
    
}



class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
   
    @IBOutlet weak var newEventBtn: UIButton!
    
    @IBOutlet weak var profileName: UIButton!
   
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var deleteBtn_friends_post: UIButton!
    
    @IBOutlet weak var dislikeLbl: UILabel!
    @IBOutlet weak var dislikeImage: UIImageView!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var changesLbl: UILabel!
  
    
  
  
    
    
   var delegate : PostCellDelegate?
   var delegate2 : ContactIDCellDelegate?
   var delegate3 : ImageURLSegue_CellDelegate?
    var videoDelegate4 : VideoURLSegue_CellDelegate?
    var EventDelegate5: EventSegue_CellDelegate?
    
    var post: Post!
  //  var request: Request?
    var likeRef: DatabaseReference!
    var dislikeRef: DatabaseReference!
    var postRefKey: DatabaseReference!
    
    var  DeleteRef: DatabaseReference!
    var  DeleteRef2: DatabaseReference!
    var  DeleteRef3: DatabaseReference!
    var  DeleteRef4: DatabaseReference!
    var  DeleteRef5: DatabaseReference!
    var  DeleteRef6: DatabaseReference!

    
    var postKey: String!
    
    var contactId: String!
    
    var imageUrl_Segue: String!
    
    var activeUserInfo: NSDictionary?
   
    var followersRef: DatabaseReference!
    var friendsArray: [String] = []
    var postFollowersArray: [String] = []
    
    var followersList: [String] = []   //Array<String>
    
    var notification: Notification!
    var notifications = [Notification]()
    
    var notificationArray: [String] = []
    var postCommentArray: [String] = []
    
   
    var profileUserName: String!
    var profileUserImg: String!
    
    var notificationKey: String!

    override func awakeFromNib() {
        super.awakeFromNib()

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.likeTapped(_:)))
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.isUserInteractionEnabled = true
        
        
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.dislikeTapped(_:)))
        tap2.numberOfTapsRequired = 1
        dislikeImage.addGestureRecognizer(tap2)
        dislikeImage.isUserInteractionEnabled = true
        
      
      QueryCurrentUser()
 
    }
    
    
  


    override func draw(_ rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
      
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func  configureCell(post: Post, img: UIImage? , urlVideo: NSURL? ) {   // before it was configureCell(post: Post) { }
        
        
        
        FirebaseFanoutPostFollowers(postKey: post.postKey)
        
        self.showcaseImg.image = nil
        self.post = post
        
       
        self.postKey = post.postKey
        
        let buttonVideo2 =  post.mediaType
        
        if buttonVideo2  != "VIDEO" {
            
           
        
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(self.tappedImage(_:)))
        tapImage.numberOfTapsRequired = 1
        showcaseImg.addGestureRecognizer(tapImage)
        showcaseImg.isUserInteractionEnabled = true
        
        }
        
        if buttonVideo2  == "VIDEO" {
            
            let tapImage = UITapGestureRecognizer(target: self, action: #selector(self.tappedVideoImage(_:)))
            tapImage.numberOfTapsRequired = 1
            showcaseImg.addGestureRecognizer(tapImage)
           showcaseImg.isUserInteractionEnabled = true
            //self.showcaseImg.isHidden = true
            
        }
        
         // self.followersList = post.followersList
        
        for test in followersList {
            print("Array on PostCell: \(test)")
        }
        
      
        likeRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
     
        
        dislikeRef = DataService.ds.REF_USER_CURRENT.child("dislikes").child(post.postKey)  // check ojo for True or False
      
        
        postRefKey = DataService.ds.REF_POSTCOMMENTS.child(post.postKey)  //added 6-29-16
        
         print("PostKey PostCell July 6: \(post.postKey)")
      //start Sep 14
        if let desc = post.postDescription, post.postDescription != "" {
            self.descriptionText.text = desc
        } else {
            self.descriptionText.isHidden = true
        }
        
        let buttonVideo =  post.mediaType
        
        if buttonVideo  == "VIDEO" {
            self.playBtn.isHidden = false
 
        } else {
            self.playBtn.isHidden = true
 
         
        }
        
        if buttonVideo == "EVENT" {
            self.newEventBtn.isHidden = false
            self.titleLbl.isHidden = false
            self.changesLbl.isHidden = false
            self.likeLbl.isHidden = true
            self.dislikeLbl.isHidden = true
            self.likeImage.isHidden = true
            self.dislikeImage.isHidden = true
            self.commentBtn.isHidden = true
            self.timeLabel.isHidden = true
            
            
            //var capitaliteTitleLbl = post.eventTitle
            
            self.titleLbl.text = (post.eventTitle).uppercased()
            

        } else{
           
            self.newEventBtn.isHidden = true
            self.titleLbl.isHidden = true
            self.likeLbl.isHidden = false
            self.dislikeLbl.isHidden = false
            self.likeImage.isHidden = false
            self.dislikeImage.isHidden = false
            self.commentBtn.isHidden = false
            self.timeLabel.isHidden = false
            


        }
        
        let tittleLabelChanges =  post.eventTitleChanges
        
        if tittleLabelChanges == "CHANGES" {
            
            self.changesLbl.isHidden = false
            
        } else {
            self.changesLbl.isHidden = true
        }
        
        
        
        
     //end Sep14
        //self.descriptionText.text = post.postDescription // commented out sep 14
        
        
        self.likeLbl.text = "\(post.likes)"

       print(" Printing Full Name  \(post.fullName)")
        
        self.profileName.setTitle("\(post.fullName)", for: .normal)
        self.profileName.titleLabel!.font = UIFont(name: "Marker Felt", size: 12)
       
        
        self.contactId =  post.uid
    
        // Delete your own post only to isHidden Delete button if the post is not yours
        
        let uid = UserDefaults.standard.value(forKey: "uid") as? String
        if uid != post.uid {
           
            self.deleteBtn.isHidden = true
            self.deleteBtn_friends_post.isHidden = false
            
        } else {
            
            self.deleteBtn.isHidden = false
            self.deleteBtn_friends_post.isHidden = true

        }
        
        
      

        
        print( "Segue Agosto 1: \(self.contactId)")
        
        self.dislikeLbl.text = "\(post.dislikes)"
       
        //  from youtube firebase 3, how to group messagers per user EP 10 min 25aprox
        
        if let  seconds = Double(((post.time))) {
            let timeStampDate = NSDate(timeIntervalSince1970: seconds)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, d MMM yyyy hh:mm a"
            self.timeLabel.text = dateFormatter.string(from: timeStampDate as Date)
        }
        
        
        
        downloadAvatar(image: post.avatar!, completion:  { (data) in
            self.profileImg.image = UIImage(data: data as Data)
            self.profileImg.layer.cornerRadius = 20.0
            self.profileImg.clipsToBounds = true
            self.showcaseImg.isHidden = false
        })
        
       
   //caching   firebase 3=  youtube Episode 6, time 16:00 aprox
        
  /// the bellow code can be done with youtube video Firebase 3. How to group message EP10 min 11:00
        
        if post.imageUrl != nil {


            if img != nil {
                self.showcaseImg.image = img
            } else {
                let ref = Storage.storage().reference(forURL: post.imageUrl!)
                ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print("JESS: Unable to download image from Firebase storage")
                    } else {
                        print("JESS: Image downloaded from Firebase storage")
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                self.showcaseImg.image = img
                                FeedVC.imageCache.setObject(img, forKey: post.imageUrl! as AnyObject)
                            }
                        }
                    }
                })
            }
       
        }
        
        
        likeRef.observeSingleEvent(of: .value, with: { snapshot in
            
            if (snapshot.value as? NSNull) != nil {   //WE don't like the current post
                self.likeImage.image = UIImage(named: "heart-empty")
                
            } else {
                self.likeImage.image = UIImage(named: "heart-full")
            }
        
        
        })
        
        dislikeRef.observeSingleEvent(of: .value, with: { snapshot in
            
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
    let postKeyUID = post.uid
    print("SNaps oct 4 POstKeyxxxxxxxxxxxxxxxx  :\(postKey)")
    
    //let postKey =  post.postKey
    UserDefaults.standard.setValue(postKey, forKey: "postKey")   ///   postKey
    UserDefaults.standard.synchronize()
    
    UserDefaults.standard.setValue(postKeyUID, forKey: "postKeyUID")   ///   postKey
    UserDefaults.standard.synchronize()
    
    
    if(self.delegate != nil){ //Just to be safe.
        self.delegate!.callSegueFromCell(myData: postKey as AnyObject)
        
       }
    }
    
 
    
    
    @objc func likeTapped(_ sender: UITapGestureRecognizer){
        
        
        let postUserID = post.uid
        print("SNaps July 24  postUserIDxxxxxxxxxxxxxxxx  :\(postUserID)")
        
        //let postKey =  post.postKey
         UserDefaults.standard.setValue(postUserID, forKey: "postUserID")   // is it needed?
        
        
        likeRef.observeSingleEvent(of: .value, with: { snapshot in
            
            if (snapshot.value as? NSNull) != nil {   //WE don't like the current post
                self.likeImage.image = UIImage(named: "heart-full")
                self.post.adjustLikes(addLike: true, followersList: self.postFollowersArray)
                self.likeRef.setValue(true)
                
               self.dislikeImage.isUserInteractionEnabled = false
                
                //adding notification
                 let time  = String(Int(NSDate().timeIntervalSince1970))
                
                guard let key = DataService.ds.REF_BASE.child("notifications").childByAutoId().key else {
                    return
                }
                
                self.notificationKey = "N\(key)"  /// notificationKey is the same number of the commentKey but with and N before the number
                
                let notificationLike : [String : AnyObject] = [
                    "uid": KEY_UID! as AnyObject,
                    "fullName": self.profileUserName as AnyObject,
                    "avatar": self.profileUserImg as AnyObject,
                    "date" : time as AnyObject,
                    "postKey" : self.post.postKey as AnyObject,
                    "commentID": key as AnyObject,
                    "type": "LIKES YOUR POST" as AnyObject,
                    "notificationKey": self.notificationKey as AnyObject,
                    "checked": "no" as AnyObject,
                ]
                
                if self.post.uid != KEY_UID {
                
                DataService.ds.REF_BASE.child("notifications").child(self.post.uid! ).child(self.notificationKey).setValue(notificationLike)
                DataService.ds.REF_BASE.child("notifications-postUID").child(self.post.uid! ).child(self.notificationKey).setValue(true)
                }  else {
                // do nothing
                
                }
            
            
  
            } else {
                self.likeImage.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(addLike: false, followersList: self.postFollowersArray)
                self.likeRef.removeValue()
                
               self.dislikeImage.isUserInteractionEnabled = true
                
                //notification 
                
                if self.post.uid != KEY_UID {
                    
                    DataService.ds.REF_BASE.child("notifications").child(self.post.uid! ).child(self.notificationKey).removeValue()
                    DataService.ds.REF_BASE.child("notifications-postUID").child(self.post.uid! ).child(self.notificationKey).removeValue()
                    
                }  else {
                    // do nothing
                    
                }

                
                
            }
            
            
        })
        
    }
    
    @objc func dislikeTapped(_ sender: UITapGestureRecognizer){
        
        let postUserID = post.uid
        
   
        print("SNaps July 24  postUserIDxxxxxxxxxxxxxxxx_dis  :\(postUserID)")
        
        //let postKey =  post.postKey
        UserDefaults.standard.setValue(postUserID, forKey: "postUserID")
        
         dislikeRef.observeSingleEvent(of: .value, with: { snapshot in
            
            if (snapshot.value as? NSNull) != nil {
                self.dislikeImage.image = UIImage(named: "heart2-full")
             //   self.post.adjustDislikes(true, followersList: self.post.followersList)
                self.post.adjustDislikes(addDislikes: true, followersList: self.postFollowersArray)
                self.dislikeRef.setValue(true)
                
                
           self.likeImage.isUserInteractionEnabled = false
                
                //adding notification
                let time  = String(Int(NSDate().timeIntervalSince1970))
                
                guard let key = DataService.ds.REF_BASE.child("notifications").childByAutoId().key else {
                    return
                }
                
                self.notificationKey = "N\(key)"  /// notificationKey is the same number of the commentKey but with and N before the number
                
                let notificationDislike : [String : AnyObject] = [
                    "uid": KEY_UID! as AnyObject,
                    "fullName": self.profileUserName as AnyObject,
                    "avatar": self.profileUserImg as AnyObject,
                    "date" : time as AnyObject,
                    "postKey" : self.post.postKey as AnyObject,
                    "commentID": key as AnyObject,
                    "type": "DISLIKES YOUR POST" as AnyObject,
                    "notificationKey": self.notificationKey as AnyObject,
                    "checked": "no" as AnyObject,
                ]
                
                if self.post.uid != KEY_UID {
                    
                    DataService.ds.REF_BASE.child("notifications").child(self.post.uid! ).child(self.notificationKey).setValue(notificationDislike)
                    DataService.ds.REF_BASE.child("notifications-postUID").child(self.post.uid! ).child(self.notificationKey).setValue(true)
                }  else {
                    // do nothing
                    
                }
                
  
                
            }else {
                self.dislikeImage.image = UIImage(named: "heart2-empty")
               self.post.adjustDislikes(addDislikes: false, followersList: self.postFollowersArray)
                self.dislikeRef.removeValue()
                
                self.likeImage.isUserInteractionEnabled = true
                
                //notification
                
                if self.post.uid != KEY_UID {
                    
                    DataService.ds.REF_BASE.child("notifications").child(self.post.uid! ).child(self.notificationKey).removeValue()
                    DataService.ds.REF_BASE.child("notifications-postUID").child(self.post.uid! ).child(self.notificationKey).removeValue()
                    
                }  else {
                    // do nothing
                    
                }
               
               
            }
        })
        
    }
    
    //download profile image from Facebook
    
    func downloadAvatar(image:String, completion:@escaping (_ data:NSData)-> ()) {
        
        print("Image:xxxxxxxxx--------xxxxxxxx: \(image)")
        
        let urlString = NSURL(string: image)
        let request = URLSession.shared.dataTask(with: urlString! as URL){ (data, response, error) -> Void in
            
            if error == nil {
                
                if let dataValid = data {
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        completion(dataValid as NSData)
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
            
             self.delegate2!.ContactIDSegueFromCell(contactID: self.contactId as AnyObject)
            print("Segue Agosto 1xxxxx: \(self.contactId)")

        }
    }
    
    
    //Delete complete post in all its locations.   Only the User's Post. 
    @IBAction func deletePostByUID(sender: AnyObject) {
        
        let   postID = post.postKey
        
        // delete notification
        
        DataService.ds.REF_BASE.child("post-commentsOnly").child(postID).observe(.value, with:  { snapshot in
            
            self.postCommentArray = []
            
            for child in snapshot.children {
                let postComment = (child as AnyObject).key as String
                
                self.postCommentArray.append(postComment)
                
                for postComment in self.postCommentArray {
                    print(" Array friendID tonight  PostCell \(postComment)")
                    
                    DataService.ds.REF_BASE.child("notifications").child(KEY_UID!).child("N\(postComment)").removeValue()
                    DataService.ds.REF_BASE.child("notifications-postUID").child(KEY_UID!).child("N\(postComment)").removeValue()
                    DataService.ds.REF_BASE.child("post-commentsOnly").child(postID).removeValue()
                }
                
            }
        })
        
        
        
   
        
        print("Delete BTn Pressed")
        print("Delete Photo from Storage: \(post.imageUrl)")
        
        
        
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
    
        
        
       DataService.ds.REF_TIMELINE_POST_USERID.child(postID).removeValue()   //child("timeline").child(uid!)
        
        // delete your own post
        DeleteRef3.child(KEY_UID!).child(postID).removeValue()   //("timeline")
        DataService.ds.REF_BASE.child("posts-followers").child(postID).child(KEY_UID!).removeValue()
       
      
        for postFollowersID in self.postFollowersArray {
            
            DeleteRef3.child(postFollowersID).child(postID).removeValue()
            DataService.ds.REF_BASE.child("posts-followers").child(postID).child(postFollowersID).removeValue()
           
        }
    
            // Create a reference to the file to delete
             let  imageToDelete = post.mediaType
           // if imageToDelete = "VIDEO" || "PHOTO" {  //"VIDEO" || "PHOTO"
            switch imageToDelete {
                case "VIDEO":
                        DeleteVideo_Photo()
                
                case "PHOTO":
                    
                    DeletePhoto()
                
                case "TEXT":
                    print("Do Nothing")
                
                case "EVENT":
                    print("Do Nothing")
                
                default:
                    print("Do Nothing")
            }
        
    }
    
    func DeletePhoto(){
        let photoPostRef = storage.reference(forURL: (post.imageUrl)!)  // url
        
        //  let desertRef = storageRef.child(post.imageUrl!)
        // Delete the file
        photoPostRef.delete { (error) -> Void in
            if (error != nil) {
                // Uh-oh, an error occurred!
                print("error deleting photo")
            } else {
                // File deleted successfully
                print("Photo File deleted successfully")
            }
        }
       
        
    }
    
    func DeleteVideo_Photo(){
        let photoPostRef = storage.reference(forURL: (post.imageUrl)!)  // url
         let videoPostRef = storage.reference(forURL: (post.videoUrl)!)
        
        photoPostRef.delete { (error) -> Void in
            if (error != nil) {
                // Uh-oh, an error occurred!
                print("error deleting photo")
            } else {
                // File deleted successfully
                print("Photo File deleted successfully")
            }
        }
        videoPostRef.delete { (error) -> Void in
            if (error != nil) {
                // Uh-oh, an error Deleting Video occurred!
                print("error deleting photo")
            } else {
                // Video File deleted successfully
                print(" Video  File deleted successfully")
            }
        }

        
    }
    // Delete only those post on my timeline or Wall
    
    @IBAction func delete_Btn_Not_in_my_timeline(sender: AnyObject) {
        
        let   postID = post.postKey
        
        DeleteRef3 = DataService.ds.REF_TIMELINE_POST_USERID   //child("timeline").child(uid!)
        DeleteRef3.child(postID).removeValue()
      
        
    }
    
   
    @objc func tappedImage(_ sender: UITapGestureRecognizer)
    {
        print("Tapped on Image")
        
        let postKey_Segue = post.postKey
        
        print("Segue Agosto 7 postKey_Segue \(postKey_Segue)")
        
        if(self.delegate3 != nil){ //Just to be safe.
            
            self.delegate3!.ImageURLSegue_Cell(postKey_Segue: postKey_Segue as AnyObject)
    }
}
    
    
    @objc func tappedVideoImage(_ sender: UITapGestureRecognizer)
    {
        
        
        //videoDelegate4
        let videoUrl_segue = post.videoUrl
        
        print("videoURL: \(videoUrl_segue)")
        
        if(self.videoDelegate4 != nil){ //Just to be safe.
            self.videoDelegate4!.VideoURLSegue_Cell(videoUrl_segue: videoUrl_segue! as AnyObject)
            
        }
      
    }
    
  
    @IBAction func playBtnAction(sender: AnyObject) {
        
        let videoUrl_segue = post.videoUrl
        
        print("videoURL: \(videoUrl_segue)")
        
        if(self.videoDelegate4 != nil){ //Just to be safe.
            self.videoDelegate4!.VideoURLSegue_Cell(videoUrl_segue: videoUrl_segue! as AnyObject)
            
        }

    }
   
    @IBAction func linkToEventBTn(sender: UIButton) {
       
        let eventKey_segue = post.eventKey
        
       print("linkToEventBTn pressed:  \(eventKey_segue)")
        
        if(self.EventDelegate5 != nil){ //Just to be safe.
            self.EventDelegate5!.EventSegue_Cell(eventKey_segue: eventKey_segue! as AnyObject)
            
        }
    }
    
    
    func FirebaseFanoutPostFollowers(postKey: String!){
        
        followersRef = DataService.ds.REF_BASE.child("posts-followers").child(postKey)
        followersRef.observe(.value, with:  { snapshot in
            
            
            print("new snapshot array: \(snapshot.key)")
            
            
            self.postFollowersArray = []    // self.friendsArray = [] for  self.postFollowersArray = []
            //  self.usersLists = []
            
            for child in snapshot.children {
                let postFollowersID = (child as AnyObject).key as String
                print("friendID  Array IIIIiiiiiiPostCelliiiiiii: \(postFollowersID)")
                
                self.postFollowersArray.append(postFollowersID)
                
                
                for postFollowersID in self.postFollowersArray {
                    print(" Array friendID tonight  PostCell \(postFollowersID)")
                }
                
            }
        })
    }
    
    func FirebaseFanout(){
        
        followersRef.observe(.value, with:  { snapshot in
           
            print("new snapshot array: \(snapshot.key)")
            
            self.friendsArray = []
            
            for child in snapshot.children {
                let friendID = (child as AnyObject).key as String
                print("friendID  Array IIIIiiiiiiPostCelliiiiiii: \(friendID)")
                
                self.friendsArray.append(friendID)
                
                
                for friendID in self.friendsArray {
                    print(" Array friendID tonight  PostCell \(friendID)")
                }
            }
        })
    }
   
    
    func QuerryNotifications(){
        
        DataService.ds.REF_BASE.child("notifications").child(KEY_UID!).observe(.value, with:{ snapshot in
            
            // print("new way: \(snapshot)")
            // self.contacts = []
            //  let friendID = snapshot.key
            // let friendReference = DataService.ds.REF_USERS.child(friendID)
            
            print(": \(snapshot.value)")
            
            self.notifications = []
            
            // self.notificationArray = []
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]  {
                
                for snap in snapshots {
                    
                    if let notificationDict = snap.value as? [String : AnyObject]  {
                        
                        let key = snap.key
                        let notification = Notification(notificationKey: key, dictionary: notificationDict)
                        
                        self.notifications.append(notification)
                        
                        
                        
                        
                    }
                }
                
                
            }
            
            
            
            // self.tableView.reloadData()
            
            
        }, withCancel: nil)
        
        // }, withCancelBlock: nil)
        
    }
    
    func QueryCurrentUser(){
        
        DataService.ds.REF_USER_CURRENT.observe(.value, with: { (snapshot)  in
            
            let item = snapshot as DataSnapshot
            print("SNAP-Itemxxxxxxxxxxx: \(item)")
            
            // if let dict = item.value as? NSDictionary{
            
            if let dict = item.value as? [String : AnyObject]{
                let avatar = dict["avatar"] as! String
                // self.image = avatar
                
                self.activeUserInfo = dict as NSDictionary?
                
                // self.title = "Welcome \(self.activeUserInfo!["firstName]!)"
                self.profileUserName = "\((self.activeUserInfo!["fullName"]! as AnyObject).uppercased!)"
                self.profileUserImg = "\(self.activeUserInfo!["avatar"]!)"
                // self.followersLabel.text = " \(self.activeUserInfo!["followers"]!) \n followers"
                // self.followingLabel.text = " \(self.activeUserInfo!["following"]!) \n following"
            }
            
        }, withCancel: {(error) -> Void in
        })
    }
    

    
}
