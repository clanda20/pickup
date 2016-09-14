//
//  contactProfileVC.swift
//  pickup
//
//  Created by christian landa on 7/12/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class contactProfileVC: UIViewController {
    
    var activeUserRef: FIRDatabaseReference?
    var followingsRef: FIRDatabaseReference?
    var followersRef: FIRDatabaseReference?
    var eventTimelineRef: FIRDatabaseReference?
    var followerRefContactID:FIRDatabaseReference?
    var eventComingRef:FIRDatabaseReference?
    
    var contactId: String?  // from segue coming from FriendsVC
     var contacts = [Contact]()
    
    var posts_Array: [String] = []
    var eventsArray: [String] = []
    
    var activeUserInfo: NSDictionary?
    
    var isFollowed: Bool = false
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    @IBAction func followContactAction(sender: AnyObject) {
        
               followContact(isFollowed) { (followRef) in
                
             print("You are now following \(self.activeUserInfo!["fullName"]!)   ")
                
        }
            
           
            
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        InsideQueryUserEvent()
        //Dismiss Keyboard
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard"))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
        
        //REFERENCES FIREBASE
        activeUserRef = DataService.ds.REF_USER_CURRENT   // user - userID
        followingsRef = activeUserRef?.child("followings")   // followingsRef = users---> userID-----[avatar:, dislikes:, firstname, FOLLOWINGS:...]
        
        
        
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
                
                self.title = " \(self.activeUserInfo!["fullName"]!.uppercaseString!)'s Profile"
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
            
            
            
           
            
            }, withCancelBlock: {(error) -> Void in
                
                print(error.description)
                
        })
        
    
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        FirebaseFanout()
        NSFetchRequest()
        
    }
    
   
    
    func queryFollowing( completion:(following:Bool) -> ()) {
    
    activeUserRef?.child("followings").observeEventType(.Value, withBlock: { snapshot in
        for child in snapshot.children {
            let userID = child.key as String
            print("USER ID IIIIiiiiiiiiiiiiiiiii: \(userID)")
            
            if userID ==  self.contactId {
                
                self.isFollowed = true
            }
        }
        completion(following: self.isFollowed)
        }, withCancelBlock: { (error) -> Void in
    })
    
    }
    
    func followContact(isFollowing:Bool, completion:(followRef:FIRDatabaseReference!) -> ()) {
        
        // followingsRef = users---> userID-----[avatar:, dislikes:, firstname, FOLLOWINGS:...]
        
      let followingRef = self.followingsRef?.child("\(self.activeUserInfo!["id"]!)")  //  puting contactId on child(contactId!) also works
      let followingRef2 = DataService.ds.REF_FOLLOWING_USERID.child("\(self.activeUserInfo!["id"]!)")
        let uid = NSUserDefaults.standardUserDefaults().valueForKey("uid") as? String
        let followerRefContactID = DataService.ds.REF_FOLLOWER.child(contactId!).child(uid!)
        let followerRefUserID = DataService.ds.REF_FOLLOWER.child(KEY_UID!).child(contactId!)
       

        if isFollowing {
            
            followingRef?.removeValue()
            followingRef2.removeValue()
            followerRefContactID.removeValue()
            followerRefUserID.removeValue()
          
            
            // Removing all  posts of the unfollowed user.
            
            for postIDx in self.posts_Array {
                
                DataService.ds.REF_TIMELINE_POST_USERID.child(postIDx).removeValue()
                
                
                print(" Array postID Deleting these Post \(postIDx)")
            }
            
            
            
         
                
             eventTimelineRef = DataService.ds.REF_BASE.child("events-timeline").child(contactId!)
                
                for eventID in self.eventsArray {
                
                    eventTimelineRef!.child(eventID).removeValue()
                    
                }
                
            
            
                for eventID in self.eventsArray {
                    
                    eventComingRef = DataService.ds.REF_BASE.child("usersshar-event-coming").child(eventID).child("coming")
                
                    eventComingRef!.child(contactId!).removeValue()
            
                }
            
            self.followBtn.setTitle("Follow", forState: .Normal)
            self.isFollowed = false
            
            
        } else {
        
            followingRef?.setValue(true)
            followingRef2.setValue(true)
            followerRefContactID.setValue(true)
            followerRefUserID.setValue(true)
            
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segue_contactProfToPost"
        {
            if let destinationVC = segue.destinationViewController as? PostsByContactVC {
              
                destinationVC.userID = contactId
                print("USER ID IIIIiiiiiiiiiiiiiiiii: \(contactId)")            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Keyboard dismiss
    func hideKeyboard()
    {
        self.view.endEditing(true)
    }
    
  
    
    
    
    func FirebaseFanout(){
        
        
        
        followersRef = DataService.ds.REF_USER_POST.child(self.contactId!)
        followersRef!.observeEventType(.Value, withBlock:  { snapshot in
            
            
            print("new snapshot array: \(snapshot.key)")
            
            
            self.posts_Array = []
           
            
            for child in snapshot.children {
                let postID = child.key as String
                print("postID  Array IIIIiiiiiDelete Postiiiiiiiii: \(postID)")
                
                self.posts_Array.append(postID)
                
                _ = Post(followersList: self.posts_Array)
                
               
                
                for postIDx in self.posts_Array {
                    print(" Array postID Delete Post \(postIDx)")
                }
                
            }
            
            
           
            
            }, withCancelBlock: { (error) ->  Void in
                
                
        })
    }
    
    
   

    func  InsideQueryUserEvent(/*comingIDx: String*/){
        
        
        DataService.ds.REF_BASE.child("host-events-id").child(KEY_UID!).observeEventType(.Value, withBlock: { (snapshot) in
            
            
            self.eventsArray = []
            //  self.usersLists = []
            
            for child in snapshot.children {
                let eventID = child.key as String
              //  print("eventID  Array IIIIiiiiiiPostCelliiiiiii: \(eventID)")
                
                self.eventsArray.append(eventID)
                
                //   _ = Post(followersList: self.friendsArray)
                
                // self.usersLists.append(usersList)
                
                for eventID in self.eventsArray {
                    print(" Array eventID tonight  eventID \(eventID)")
                }
                
            }
        })
    }

    

    }
