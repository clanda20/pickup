//
//  PostsByUserCell.swift
//  pickup
//
//  Created by christian landa on 7/15/16.
//  Copyright © 2016 christian landa. All rights reserved.
//


    import UIKit
  //  import Alamofire
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
        @IBOutlet weak var commentBtn: UIButton!
        
 
        var delegate : PostsByUserCellDelegate?
        
        var post: Post!
       // var request: Request?
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
            
//            let tap = UITapGestureRecognizer(target: self, action: Selector("likeTapped:"))
//            tap.numberOfTapsRequired = 1
//            likeImage.addGestureRecognizer(tap)
//            likeImage.isUserInteractionEnabled = true
//            
            
            
//            let tap2 = UITapGestureRecognizer(target: self, action: Selector(("dislikeTapped:")))
//            tap2.numberOfTapsRequired = 1
//            dislikeImage.addGestureRecognizer(tap2)
//            dislikeImage.isUserInteractionEnabled = true
            
           FirebaseFanout()
            
        }
        
        override func draw(_ rect: CGRect) {
            profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
            profileImg.clipsToBounds = true
            
            showcaseImg.clipsToBounds = true
        }
        
        override func setSelected(_ selected: Bool, animated: Bool) {
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
            
            self.profileName.setTitle("\(post.fullName)", for: .normal)
            self.profileName.titleLabel!.font = UIFont(name: "Marker Felt", size: 12)
            
            self.contactId =  post.uid
            
            
            
            
            print( "Segue Agosto 1: \(self.contactId)")
            
            self.dislikeLbl.text = "\(post.dislikes)"
            
            
            downloadAvatar(image: post.avatar!, completion:  { (data) in
                self.profileImg.image = UIImage(data: data as Data)
                self.profileImg.layer.cornerRadius = 20.0
                self.profileImg.clipsToBounds = true
            })
            
            if post.imageUrl != nil {
                
                
                if img != nil {
                    self.showcaseImg.image = img
                } else {
                    let ref = FIRStorage.storage().reference(forURL: post.imageUrl!)
                    ref.data( withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
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
            


            
            
        }
        
        
        
        @IBAction func Comment_Post_Btn2(sender: AnyObject) {
            
            let postKey = post.postKey
            print("SNaps July 7 POstKeyxxxxxxxxxxxxxxxx  :\(postKey)")
            
            //let postKey =  post.postKey
          //  UserDefaults.standard.setValue(postKey, forKey: "postKey")
            UserDefaults.standard.set(postKey, forKey: "postKey")
            UserDefaults.standard.synchronize()
            if(self.delegate != nil){ //Just to be safe.
                self.delegate!.callSegueFromCell(myData: postKey as AnyObject)
            
                
            }
        }
        
        
        @IBAction func profileNameBtn(sender: AnyObject) {
            
            
           
                
            
        }
        //download profile image from Facebook
        
        func downloadAvatar(image:String?, completion:@escaping (_ data:NSData)-> ()) {
            
            print("Image:xxxxxxxxx--------xxxxxxxx: \(image)")
            
            let urlString = NSURL(string: (image)!)
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
                let photoPostRef = storage.reference(forURL: post.imageUrl!)  // url
                
                //  let desertRef = storageRef.child(post.imageUrl!)
                // Delete the file
                photoPostRef.delete { (error) -> Void in
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
            followersRef.observe(.value, with:  { snapshot in
                
                
                print("new snapshot array: \(snapshot.key)")
                
                
                self.friendsArray = []
                //  self.usersLists = []
                
                for child in snapshot.children {
                    let friendID = (child as AnyObject).key as String
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
