//
//  PostsByContactCell.swift
//  pickup
//
//  Created by christian landa on 7/17/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

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
    var request: Request?
    var likeRef: FIRDatabaseReference!
    var dislikeRef: FIRDatabaseReference!
    var postRefKey: FIRDatabaseReference!
    var postKey: String!
    
    
    
    
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
        
        
   /*     let tap3 = UITapGestureRecognizer(target: self, action: #selector(PostCell.CommentBtnTapped(_:)))
        tap3.numberOfTapsRequired = 1
        commentBtn.addGestureRecognizer(tap3)
        commentBtn.userInteractionEnabled = true
        tap3.cancelsTouchesInView = false
    */
        
        
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImg.clipsToBounds = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
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
        
        self.profileName.setTitle("\(post.fullName)", forState: .Normal)
        self.profileName.titleLabel!.font = UIFont(name: "Marker Felt", size: 16)
        
      //  self.contactId =  post.uid
        
        
        
        
     //   print( "Segue Agosto 1: \(self.contactId)")
        
        self.dislikeLbl.text = "\(post.dislikes)"
        
        
        downloadAvatar(post.avatar!, completion:  { (data) in
            self.profileImg.image = UIImage(data: data)
            self.profileImg.layer.cornerRadius = 21.0
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
    
    
}
