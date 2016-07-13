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
    
    var contactX: String?
     var contacts = [Contact]()
    var activeUserInfo: NSDictionary?
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    @IBAction func followContactAction(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        print("ContactKEY- Destination-----xxxxx-----------------: \(contactX)")
        
        var image: String?
        
        DataService.ds.REF_USERS.child(contactX!).observeEventType(.Value, withBlock: { (snapshot)  in
            
            let item = snapshot as FIRDataSnapshot
            print("SNAP-Itemxxxxxxxxxxx: \(item)")
            
            // if let dict = item.value as? NSDictionary{
            
            if let dict = item.value as? [String : AnyObject]{
                let avatar = dict["avatar"] as! String
                image = avatar
                
                self.activeUserInfo = dict
                
                self.title = " \(self.activeUserInfo!["firstName"]!.uppercaseString!)'s Profile"
                self.postsLabel.text = " \(self.activeUserInfo!["postNumber"]!) \n posts"
                self.followersLabel.text = " \(self.activeUserInfo!["followers"]!) \n followers"
                self.followingLabel.text = " \(self.activeUserInfo!["following"]!) \n following"
                
                self.downloadAvatar(avatar, completion: { (data) in
                    
                    self.avatarImageView.image = UIImage(data: data)
                    
                    self.avatarImageView.layer.cornerRadius = 50.0
                    self.avatarImageView.clipsToBounds = true
                })
                
            }
            
            
            
            //   completation(imageStr: image!)
            
            }, withCancelBlock: {(error) -> Void in
                
        })
        
    
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
