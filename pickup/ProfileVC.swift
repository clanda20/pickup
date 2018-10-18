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
    @IBOutlet weak var notificationLabel: UILabel!
    
   
   // var followingsReg: FIRDatabaseReference?
    
    

    
    var activeUserInfo: NSDictionary?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        var image: String?
        
        
        // Add Edit Button
        
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(ProfileVC.editProfile))
        
        self.tabBarController?.navigationItem.rightBarButtonItem = editButton
        
       
        var signoutButton = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(ProfileVC.signOut))
        
        self.tabBarController?.navigationItem.leftBarButtonItem = signoutButton
        
    // counting number of posts
        DataService.ds.REF_BASE.child("user-posts").child(KEY_UID!).observe(.value, with: { (snapshot)  in
            
            //counting posts
          //  var countingPosts = (snapshot.value as AnyObject).count  // correction for swift 3
            var countingPosts = snapshot.childrenCount
            
            var post = ["postNumber":  (countingPosts) ]
            
            DataService.ds.REF_BASE.child("users").child(KEY_UID!).updateChildValues(post)
            
        }, withCancel: {(error) -> Void in
                
        })
        
        // counting number of posts
        DataService.ds.REF_BASE.child("followers").child(KEY_UID!).observe(.value, with: { (snapshot)  in
            
            //counting posts
            var countingFollowers = (snapshot.value as AnyObject).count
            
            var followers = ["followers":  (countingFollowers!) ]
            
            DataService.ds.REF_BASE.child("users").child(KEY_UID!).updateChildValues(followers)
            
        }, withCancel: {(error) -> Void in
                
        })
        
        
        
        DataService.ds.REF_USER_CURRENT.observe(.value, with: { (snapshot)  in
            
            let item = snapshot as FIRDataSnapshot
            print("SNAP-Itemxxxxxxxxxxx: \(item)")
            
            // if let dict = item.value as? NSDictionary{
            
            if let dict = item.value as? [String : AnyObject]{
                let avatar = dict["avatar"] as! String
                image = avatar
                
                self.activeUserInfo = dict as NSDictionary?
                
                // self.title = "Welcome \(self.activeUserInfo!["firstName]!)"
                self.title = " \((self.activeUserInfo!["firstName"]! as AnyObject).uppercased!)"
                self.postsLabel.text = " \(self.activeUserInfo!["postNumber"]!) \n posts"
                self.followersLabel.text = " \(self.activeUserInfo!["followers"]!) \n followers"  // following and followers got the same number for now.  replaced by Friends
                
                self.followingLabel.text = " \(self.activeUserInfo!["following"]!) \n Friends"
                self.notificationLabel.text = " \(self.activeUserInfo!["notifications"]!)\n notifications"
                
                self.downloadAvatar(image: avatar, completion: { (data) in
                    
                    self.profileImageView.image = UIImage(data: data as Data)
                    
                    self.profileImageView.layer.cornerRadius = 50.0
                    self.profileImageView.clipsToBounds = true
                })
                
            }
            
            
            
            //   completation(imageStr: image!)
            
        }, withCancel: {(error) -> Void in
                
        })
        
        
      
        
        
        
        
    }
    
    
    
    

    override func viewWillDisappear(_ animated: Bool) {
       self.navigationController?.setNavigationBarHidden(true, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    @objc func editProfile(){
        
        print("edit profile")
        
        self.performSegue(withIdentifier: "segue_EditPost", sender: self)
        
        
    }
    
    @objc func signOut(){
        
        print("edit profile")
        
        // unauth() is the logout method for the current user.
        
        try! FIRAuth.auth()!.signOut()
        
        // Remove the user's uid from storage.
        
        UserDefaults.standard.setValue(nil, forKey: "uid")
        
        // Head back to Login!
        
        let ViewController = self.storyboard!.instantiateViewController(withIdentifier: "Login")
        UIApplication.shared.keyWindow?.rootViewController = ViewController
        
    
    }

    
      override func prepare(for forsegue: UIStoryboardSegue, sender: Any?) {
        if forsegue.identifier == "segue_passID"
        {
            if let destinationVC = forsegue.destination as? PostsByUserVC {
                let uid = UserDefaults.standard.value(forKey: "uid") as? String
                destinationVC.userID = uid
                
            }
        }
    }
    
    
    
    
    
    
    
    // downloading profile image from Facebook
    
    func downloadAvatar(image:String, completion:@escaping (_ data:NSData)-> ()) {
        
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
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
