//
//  tabbarVC.swift
//  pickup
//
//  Created by christian landa on 10/12/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Firebase

//global variable of icons

var  icons =  UIScrollView()
var corner = UIImageView()
var dot = UIView()


class tabbarVC: UITabBarController {
    
     var notificationInfo: NSDictionary?
  
    
    var typeNotification: String!
    var checkedNotification: String!
    var fullName: String!
    
    var countNotification: Int = 0
    
  
    
     var notificationPostIDArray: [String] = []
    
  
    
   lazy var likeCount:Int = 0
   lazy var countComment: Int = 0
   lazy var countFollowing: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        FanoutNotificationUserID()

        // create total icons
      //  icons.frame = CGRectMake(self.view.frame.size.width / 5 * 3 + 10, self.view.frame.size.height - self.tabBar.frame.size.height * 2 - 3, 50, 35)
        icons.frame = CGRect(x: self.view.frame.size.width / 5 * 3 + 10, y: self.view.frame.size.height - self.tabBar.frame.size.height * 2 - 3, width: 50, height: 35)
        self.view.addSubview(icons)
        
        // create corner
        //corner.frame = CGRectMake(icons.frame.origin.x, icons.frame.origin.y + icons.frame.size.height, 20, 14)
        corner.frame = CGRect(x: icons.frame.origin.x, y: icons.frame.origin.y + icons.frame.size.height, width: 20, height: 14)
        corner.center.x = icons.center.x
        corner.image = UIImage(named: "corner.png")
        corner.isHidden = true
        self.view.addSubview(corner)
        
        // create dot
       // dot.frame = CGRectMake(self.view.frame.size.width / 5 * 3, self.view.frame.size.height - 5, 7, 7)
        dot.frame = CGRect(x: self.view.frame.size.width / 5 * 3, y: self.view.frame.size.height - 5, width: 7, height: 7)
        dot.center.x = self.view.frame.size.width / 5 * 3 + (self.view.frame.size.width / 5) / 2
        dot.backgroundColor = UIColor(red: 251/255, green: 103/255, blue: 29/255, alpha: 1)
        dot.layer.cornerRadius = dot.frame.size.width / 2
        dot.isHidden = true
        self.view.addSubview(dot)
    
        
      

       
}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        
        
                likeCount = 0
                countComment = 0
                countFollowing = 0
        
       //  FanoutNotificationUserID()
        
    }


    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        if self.countComment > 0 {
        
        let imageComm = UIImage(named: "commentIcon.png")
        self.placeIcon(image: imageComm!, text: "\(self.countComment)")
            
        }
        
        if self.likeCount > 0 {

            let image = UIImage(named: "likeIcon.png")

            self.placeIcon(image: image!, text: "\(self.likeCount)")
        }
        
        if self.countFollowing > 0  {
            let imageFollow = UIImage(named: "followIcon.png")
            self.placeIcon(image: imageFollow!, text: "\(self.countFollowing)")
        
        }
        
        
        //add number of notifications to user
        
        let notific = ["notifications": self.countNotification ]
        
        DataService.ds.REF_BASE.child("users").child(KEY_UID!).updateChildValues(notific)
        
        
    }
    

  
  
  
    
   func  FanoutNotificationUserID(){
    

    DataService.ds.REF_BASE.child("notifications-postUID").child(KEY_UID!).observe(.value ,  with:  { snapshot in  //observeSingleEventOfType, observeEventType
        
        
        print("new snapshot Notification arrays: \(snapshot.key)")
        
   
        
        
        
        for child in snapshot.children {
            let notificationUserID = (child as AnyObject).key as String
            print("notificationUserID: \(notificationUserID)")
            
            self.notificationPostIDArray.append(notificationUserID)
            
            self.countNotification = 0
         
        
            var countGoingEventNotification2 = 0
            var countCommentPostNotification2 = 0
            var countCommentEventNotification2 = 0
            var countLikeNotification2 = 0
            var countDislikeNotification2 = 0
            var followingNotification2 = 0
            

            
            for notificationUserID in self.notificationPostIDArray {
                print(" Array notificationUserID: \(notificationUserID)")
                
                   self.countNotification += 1

                   print("Count Notification: \(self.countNotification )")
                
                
                

                
                DataService.ds.REF_BASE.child("notifications").child(KEY_UID!).child(notificationUserID).observe(.value, with: { (snapshot)  in
                    
                    
                    let item = snapshot as FIRDataSnapshot
                    print("SNAP-ItemxTAbBARx: \(item)")
                    
                    //   var commentArray = []
                    
                    if let dict = item.value as? [String : AnyObject]{
                        
                        self.notificationInfo = dict as NSDictionary?
                        
                        let notificationInfo2 = dict
                        
                        
                        self.fullName              = self.notificationInfo!["fullName"]! as! String
                        self.typeNotification   = self.notificationInfo!["type"]! as! String
                        self.checkedNotification = self.notificationInfo!["checked"]! as! String
                        
                        
                        
                        var fullName2              = notificationInfo2["fullName"]! as! String
                        let typeNotification2   = notificationInfo2["type"]! as! String
                        var checkedNotification2 = notificationInfo2["checked"]! as! String
                        
                        print("Fullname: \(self.fullName)")
                        print("Type: \(self.typeNotification)")
                        print("Checked: \(self.checkedNotification)")
                        
                        if  checkedNotification2 == "no" &&  typeNotification2 == "IS GOING TO AN EVENT"{
                            
                            
                        } else if checkedNotification2 == "no" && typeNotification2 == "HAS COMMENTED ON YOUR POST"{
                            countCommentPostNotification2 += 1
                            
                            print("countCommentPostNotification2: \(countCommentPostNotification2)")
                            self.countComment = countCommentPostNotification2
                            
                          
                            
                        }else  if checkedNotification2 == "no" && typeNotification2 == "LIKES YOUR POST"{
                            countLikeNotification2 += 1
                            print("countLikeNotification2: \(countLikeNotification2)")
                            self.likeCount = countLikeNotification2
                            
                            
                            
                        } else if  checkedNotification2 == "no" &&  typeNotification2 ==  "DISLIKES YOUR POST" {
                            //   countDislikeNotification2 += 1
                            //   print("countDislikeNotification2: \(countDislikeNotification2)")
                            
                        }else  if  checkedNotification2 == "no" &&  typeNotification2 ==  "IS FOLLOWING YOU"{
                            followingNotification2 += 1
                            
                            self.countFollowing = followingNotification2
                            
                            
                            print("followingNotification2: \( followingNotification2)")
              
                            
                        }
                        
                    }
          
                    
                })
   
            }
            
            
            
        }
        
        print("Complettion2:  \(self.countComment), \(self.likeCount), \(self.countFollowing)")
        

    })
    

    
    }
    
    // multiple icons
    func placeIcon (image:UIImage?, text:String?) {
        
        // create separate icon
       // let view = UIImageView(frame: CGRectMake(icons.contentSize.width, 0, 50, 35))
        let view = UIImageView(frame: CGRect(x: icons.contentSize.width, y: 0, width: 50, height: 35))
        view.image = image
        icons.addSubview(view)
        
        
        if image == nil {
            icons.isHidden = true
            corner.isHidden = true
            dot.isHidden = true
            
            
        }
        
        // create label
       // let label = UILabel(frame: CGRectMake(view.frame.size.width / 2, 0, view.frame.size.width / 2, view.frame.size.height))
        let label = UILabel(frame: CGRect(x: view.frame.size.width / 2, y: 0, width: view.frame.size.width / 2, height: view.frame.size.height))
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        label.text = text
        label.textAlignment = .center
        label.textColor = .white
        view.addSubview(label)
        
        // update icons view frame
        icons.frame.size.width = icons.frame.size.width + view.frame.size.width - 4
        icons.contentSize.width = icons.contentSize.width + view.frame.size.width - 4
        icons.center.x = self.view.frame.size.width / 5 * 4 - (self.view.frame.size.width / 5) / 4
        
        // unhide elements
        corner.isHidden = false
        dot.isHidden = false
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
     }
    

  
    
}
