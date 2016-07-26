//
//  ProfileVC.swift
//  pickup
//
//  Created by christian landa on 7/8/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
   
   // var followingsReg: FIRDatabaseReference?
    
    

    
    var activeUserInfo: NSDictionary?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        var image: String?
        
        
        // Add Edit Button
        
        let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editProfile")
        
        self.tabBarController?.navigationItem.rightBarButtonItem = editButton
        
        DataService.ds.REF_USER_CURRENT.observeEventType(.Value, withBlock: { (snapshot)  in
            
            let item = snapshot as FIRDataSnapshot
            print("SNAP-Itemxxxxxxxxxxx: \(item)")
            
            // if let dict = item.value as? NSDictionary{
            
            if let dict = item.value as? [String : AnyObject]{
                let avatar = dict["avatar"] as! String
                image = avatar
                
                self.activeUserInfo = dict
                
               // self.title = "Welcome \(self.activeUserInfo!["firstName]!)"
                self.title = " \(self.activeUserInfo!["firstName"]!.uppercaseString!)'s Profile"
                self.postsLabel.text = " \(self.activeUserInfo!["postNumber"]!) \n posts"
                self.followersLabel.text = " \(self.activeUserInfo!["followers"]!) \n followers"
                self.followingLabel.text = " \(self.activeUserInfo!["following"]!) \n following"
                
                self.downloadAvatar(avatar, completion: { (data) in
                    
                    self.profileImageView.image = UIImage(data: data)
                    
                    self.profileImageView.layer.cornerRadius = 50.0
                    self.profileImageView.clipsToBounds = true
                })
                
            }
            
            
            
            //   completation(imageStr: image!)
            
            }, withCancelBlock: {(error) -> Void in
                
        })
        
        
    }

    
    
    func editProfile(){
        
        print("edit profile")
        
        self.performSegueWithIdentifier("segue_EditPost", sender: self)
        
        
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segue_passID"
        {
            if let destinationVC = segue.destinationViewController as? PostsByUserVC {
                let uid = NSUserDefaults.standardUserDefaults().valueForKey("uid") as? String
                destinationVC.userID = uid
                
            }
        }
    }
    
    
    
    
    
    
    
    // downloading profile image from Facebook
    
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
