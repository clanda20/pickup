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




class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    
    @IBOutlet weak var dislikeLbl: UILabel!
    @IBOutlet weak var dislikeImage: UIImageView!
    @IBOutlet weak var commentBtn: UIButton!
    
    var post: Post!
    var request: Request?
    var likeRef: FIRDatabaseReference!
    var dislikeRef: FIRDatabaseReference!
    var postRefKey: FIRDatabaseReference!
    
    var tapAction: ((UITableViewCell) -> Void)?
    

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
        
        
        
        
        
    }

    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImg.clipsToBounds = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func  configureCell(post: Post, img: UIImage?) {
        
        self.post = post        
        
        likeRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        
        dislikeRef = DataService.ds.REF_USER_CURRENT.child("dislikes").child(post.postKey)  // check ojo
        
        postRefKey = DataService.ds.REF_POSTS.child(post.postKey)  //added 6-29-16
        
         print("PostKey PostCell: \(post.postKey)")
        
        
        
    //    let postID = NSUserDefaults.standardUserDefaults().valueForKey(post.postKey) as! String
        
        self.descriptionText.text = post.postDescription
        self.likeLbl.text = "\(post.likes)"
        
        self.dislikeLbl.text = "\(post.dislikes)"
        
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
    
    func likeTapped(sender: UITapGestureRecognizer){
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if (snapshot.value as? NSNull) != nil {   //WE don't like the current post
                self.likeImage.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
                
               self.dislikeImage.userInteractionEnabled = false
                
                
            } else {
                self.likeImage.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
                
               self.dislikeImage.userInteractionEnabled = true
                
            }
            
            
        })
        
    }
    
    func dislikeTapped(sender: UITapGestureRecognizer){
        
         dislikeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if (snapshot.value as? NSNull) != nil {
                self.dislikeImage.image = UIImage(named: "heart2-full")
                self.post.adjustDislikes(true)
                self.dislikeRef.setValue(true)
                
                
           self.likeImage.userInteractionEnabled = false

                
                
            }else {
                self.dislikeImage.image = UIImage(named: "heart2-empty")
                self.post.adjustDislikes(false)
                self.dislikeRef.removeValue()
                
                self.likeImage.userInteractionEnabled = true
               
               
            }
        })
        
    }
    
    @IBAction func commentBtn_click(sender: AnyObject) {
        
        tapAction?(self)
            
        
  /*    FeedVC.performSegueWithIdentifier("segue_pass_postKey", sender: nil)
        
            postRefKey = DataService.ds.REF_POSTS.child(post.postKey)  //added 6-29-16
            
            print("PostKey PostCell button: \(post.postKey)")
           // print("PostKey PostCell button: \( postRefKey)")
    */
    

    
    }


}


