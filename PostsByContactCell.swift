//
//  PostsByContactCell.swift
//  pickup
//
//  Created by christian landa on 7/17/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
//import Alamofire
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseMessaging
import FirebaseStorage

protocol PostsByContactCellDelegate {
    func callSegueFromCell(myData dataobject: AnyObject)
}


class PostsByContactCell: UITableViewCell {
    
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
    
    
    var delegate : PostsByContactCellDelegate?
    
    var post: Post!
   // var request: Request?
    var likeRef: DatabaseReference!
    var dislikeRef: DatabaseReference!
    var postRefKey: DatabaseReference!
    var postKey: String!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
//        tap.numberOfTapsRequired = 1
//        likeImage.addGestureRecognizer(tap)
//        likeImage.isUserInteractionEnabled = true
//        
//        
//        
//        let tap2 = UITapGestureRecognizer(target: self, action: "dislikeTapped:")
//        tap2.numberOfTapsRequired = 1
//        dislikeImage.addGestureRecognizer(tap2)
//        dislikeImage.isUserInteractionEnabled = true
//        
        
   /*     let tap3 = UITapGestureRecognizer(target: self, action: #selector(PostCell.CommentBtnTapped(_:)))
        tap3.numberOfTapsRequired = 1
        commentBtn.addGestureRecognizer(tap3)
        commentBtn.userInteractionEnabled = true
        tap3.cancelsTouchesInView = false
    */
        
        
    }
    
    override func draw(_ rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImg.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func  configureCell(post: Post, img: UIImage?) {   // before it was configureCell(post: Post) { }
        
        self.post = post
        
        
        
        likeRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)   // check ojo for True or False
        
        // likeRef = DataService.ds.REF_USER_POSTS_USERID.child("likes").child(post.postKey)
        
        dislikeRef = DataService.ds.REF_USER_CURRENT.child("dislikes").child(post.postKey)  // check ojo for True or False
        // dislikeRef = DataService.ds.REF_USER_POSTS_USERID.child("dislikes").child(post.postKey)
        
        postRefKey = DataService.ds.REF_POSTCOMMENTS.child(post.postKey)  //added 6-29-16
        
        print("PostKey PostCell July 6: \(post.postKey)")
        
      //  NSUserDefaults.standardUserDefaults().setValue(post.postKey, forKey: "postKeyByUser")
      //  NSUserDefaults.standardUserDefaults().synchronize()
        
        self.descriptionText.text = post.postDescription
        self.likeLbl.text = "\(post.likes)"
        
        
        self.dislikeLbl.text = "\(post.dislikes)"
        
        
        
     //   print(" Printing Full Name  \(post.fullName)")
        
        self.profileName.setTitle("\(post.fullName)", for: .normal)
        self.profileName.titleLabel!.font = UIFont(name: "Marker Felt", size: 16)
        
      //  self.contactId =  post.uid
        
        
        
        
     //   print( "Segue Agosto 1: \(self.contactId)")
        
        self.dislikeLbl.text = "\(post.dislikes)"
        
        
        downloadAvatar(image: post.avatar!, completion:  { (data) in
            self.profileImg.image = UIImage(data: data as Data)
            self.profileImg.layer.cornerRadius = 21.0
            self.profileImg.clipsToBounds = true
        })
        
        
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
        
        
//        if post.imageUrl != nil {
//            
//            if img != nil {
//                self.showcaseImg.image = img
//            } else {
//                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
//                    
//                    if err == nil {
//                        let img = UIImage(data: data!)!
//                        self.showcaseImg.image = img
//                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
//                    }
//                })
//            }
//            
//            
//        } else {
//            self.showcaseImg.hidden = true
//        }
        
        
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
    
    
    
    @IBAction func Comment_Post_Btn(sender: AnyObject) {
        
        let postKey = post.postKey
        print("SNaps July 7 POstKeyxxxxxxxxxxxxxxxx  :\(postKey)")
        
        //let postKey =  post.postKey
        UserDefaults.standard.setValue(postKey, forKey: "postKey")
       // UserDefaults.standard.set(value: postKey, forKey: "postKey")
        UserDefaults.standard.synchronize()
        if(self.delegate != nil){ //Just to be safe.
            self.delegate!.callSegueFromCell(myData: postKey as AnyObject)
            
        }
    }
    
   /* func CommentBtnTapped(sender: UITapGestureRecognizer){
        
        postRefKey.observeEventType(.Value, withBlock: { snapshot in
            
            print("SNaps July 6 :\(snapshot)")
            
            
            let postKey =  self.post.postKey
            
            
            
            NSUserDefaults.standardUserDefaults().setValue(postKey, forKey: "postKey")
            // NSUserDefaults.standardUserDefaults().synchronize()
            
            // FeedVC.performSegueWithIdentifier("segue_commentVC, sender: sender)
            
            
        })
    }  */
    
    
    func likeTapped(sender: UITapGestureRecognizer){
        
        likeRef.observeSingleEvent(of: .value, with: { snapshot in
            
            if (snapshot.value as? NSNull) != nil {   //WE don't like the current post
                self.likeImage.image = UIImage(named: "heart-full")
                self.post.adjustLikesByUser(addLike: true)
                self.likeRef.setValue(true)
                
                self.dislikeImage.isUserInteractionEnabled = false
                
                
            } else {
                self.likeImage.image = UIImage(named: "heart-empty")
                self.post.adjustLikesByUser(addLike: false)
                self.likeRef.removeValue()
                
                self.dislikeImage.isUserInteractionEnabled = true
                
            }
            
            
        })
        
    }
    
    func dislikeTapped(sender: UITapGestureRecognizer){
        
        dislikeRef.observeSingleEvent(of: .value, with: { snapshot in
            
            if (snapshot.value as? NSNull) != nil {
                self.dislikeImage.image = UIImage(named: "heart2-full")
                self.post.adjustDislikesByUser(addDislikes: true)
                self.dislikeRef.setValue(true)
                
                
                self.likeImage.isUserInteractionEnabled = false
                
                
                
            }else {
                self.dislikeImage.image = UIImage(named: "heart2-empty")
                self.post.adjustDislikesByUser(addDislikes: false)
                self.dislikeRef.removeValue()
                
                self.likeImage.isUserInteractionEnabled = true
                
                
            }
        })
        
    }
  
    //download profile image from Facebook
    
    func downloadAvatar(image:String, completion:@escaping  (_ data:NSData)-> ()) {
        
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
    
    
}
