//
//  contactProfileVC.swift
//  pickup
//
//  Created by christian landa on 7/12/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Firebase

class contactProfileVC: UIViewController {
    
    var activeUserRef: FIRDatabaseReference?
    var followingsRef: FIRDatabaseReference?

    
    var contactId: String?
     var contacts = [Contact]()
    
    var activeUserInfo: NSDictionary?
    
    var isFollowed: Bool = false
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    @IBAction func followContactAction(sender: AnyObject) {
        
               followContact(isFollowed) { (followRef) in
                
             print("You are now following \(self.activeUserInfo!["firstName"]!)   ")
                
        }
            
           
            
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //REFERENCES FIREBASE
        activeUserRef = DataService.ds.REF_USER_CURRENT
        followingsRef = activeUserRef?.child("followings")
        
        
        
        queryFollowing { (following) in
        
            //following Btn Status update
            
            if self.isFollowed {
                self.followBtn.setTitle("Following", forState: .Normal)
                
            } else {
                self.followBtn.setTitle("Follow", forState: .Normal)
            }
        }
        
       
        
        
        
        
      
        print("ContactKEY- Destination-----xxxxx-----------------: \(contactId)")
        
        var image: String?
        
        DataService.ds.REF_USERS.child(contactId!).observeEventType(.Value, withBlock: { (snapshot)  in
            
            let item = snapshot as FIRDataSnapshot
            print("SNAP-Itemxxxxxxxxxxx: \(item)")
            
            // if let dict = item.value as? NSDictionary{
            
            if let dict = item.value as? [String : AnyObject]{
                let avatar = dict["avatar"] as! String
                image = avatar
                
                self.activeUserInfo = dict
                
                //contact's information
                
                self.title = " \(self.activeUserInfo!["firstName"]!.uppercaseString!)'s Profile"
                self.postsLabel.text = " \(self.activeUserInfo!["postNumber"]!) \n posts"
                self.followersLabel.text = " \(self.activeUserInfo!["followers"]!) \n followers"
                self.followingLabel.text = " \(self.activeUserInfo!["following"]!) \n following"
                
                let  activeUserInfoID = self.activeUserInfo!["id"] as! String
                
                print("activeUserInfoID----xxxx-------:\(activeUserInfoID)")
                
                
                
                self.downloadAvatar(avatar, completion: { (data) in
                    
                    self.avatarImageView.image = UIImage(data: data)
                    
                    self.avatarImageView.layer.cornerRadius = 50.0
                    self.avatarImageView.clipsToBounds = true
                })
                
            }
            
            
            
            //   completation(imageStr: image!)
            
            }, withCancelBlock: {(error) -> Void in
                
                print(error.description)
                
        })
        
    
    }
    
    func queryFollowing( completion:(following:Bool) -> ()) {
        
        activeUserRef?.observeEventType(.Value, withBlock: { (snapshot) in
            
            let item = snapshot as FIRDataSnapshot
            
            if let dict = item.value as? NSDictionary {
                
                if let followings = dict["followings"] as? NSDictionary {
                    
                    for following in followings {
                        
                        let user = following.value as! NSDictionary
                        let userID = user["id"] as! String
                        
                        
                 //   print("UserIDZZZZZZZ:\(user)")
                    
                        
                     if userID ==  self.contactId {
                            
                            self.isFollowed = true
                        }
                    }
                }
                
            }
            completion(following: self.isFollowed)
            }, withCancelBlock: { (error) -> Void in
                

        })
        
    }
    
    
    func followContact(isFollowing:Bool, completion:(followRef:FIRDatabaseReference!) -> ()) {
        
      let followingRef = self.followingsRef?.child(contactId!)
        
        print("followigREFXXXXXX: \(followingRef)")
        
        let following = ["id": "\(self.activeUserInfo!["id"]!)", "firstName": "\(self.activeUserInfo!["firstName"]!)", "lastName":"\(self.activeUserInfo!["lastName"]!)", "username": "\(self.activeUserInfo!["username"]!)", "avatar": "\(self.activeUserInfo!["avatar"]!)" ,"likes":"\(self.activeUserInfo!["likes"])", "dislikes":"\(self.activeUserInfo!["dislikes"])", "email": "\(self.activeUserInfo!["email"]!)","postNumber":"\(self.activeUserInfo!["postNumber"]!)", "followers": "\(self.activeUserInfo!["followers"]!)", "following": "\(self.activeUserInfo!["following"]!)","followings": "\(self.activeUserInfo!["followings"])"]
        
        if isFollowing {
            
            followingRef?.removeValue()
            self.followBtn.setTitle("Follow", forState: .Normal)
            self.isFollowed = false
            
            
        } else {
        
            followingRef?.setValue(following)
            self.followBtn.setTitle("Following", forState: .Normal)
            self.isFollowed = true
            
        }
        
        completion(followRef: followingRef!)
        
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
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    

}
