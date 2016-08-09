//
//  ImageShowVC.swift
//  pickup
//
//  Created by christian landa on 8/7/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Firebase


class ImageShowVC: UIViewController {
    @IBOutlet weak var imageShowView: UIImageView!
    
   var postKey_Segue: String?
 
     var activeUserInfo: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("postKey_Segue:\(postKey_Segue)")
        
        
        
        DataService.ds.REF_POSTS.child(postKey_Segue!).observeEventType(.Value, withBlock: { (snapshot)  in
            
            let item = snapshot as FIRDataSnapshot
            print("SNAP-Itemxxxxxxxxxxx: \(item)")
            
            // if let dict = item.value as? NSDictionary{
            
            if let dict = item.value as? [String : AnyObject]{
                let imageUrl = dict["imageUrl"] as! String
            //    image = avatar
                
                self.activeUserInfo = dict
                
                // self.title = "Welcome \(self.activeUserInfo!["firstName]!)"
                self.title = " \(self.activeUserInfo!["fullName"]!.uppercaseString!)'s Post"
               // self.postsLabel.text = " \(self.activeUserInfo!["postNumber"]!) \n posts"
              //  self.followersLabel.text = " \(self.activeUserInfo!["followers"]!) \n followers"
              //  self.followingLabel.text = " \(self.activeUserInfo!["following"]!) \n following"
                
                self.downloadAvatar(imageUrl, completion: { (data) in
                    
                    self.imageShowView.image = UIImage(data: data)
                    
                  //  self.imageShowView.layer.cornerRadius = 50.0
                  //  self.imageShowView.clipsToBounds = true
                })
                
            }
            
            
            
            //   completation(imageStr: image!)
            
            }, withCancelBlock: {(error) -> Void in
                
        })

        
         
        
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
    
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
       // FirebaseFanout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
