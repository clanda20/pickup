//
//  contactProfileVC.swift
//  pickup
//
//  Created by christian landa on 7/12/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseMessaging
import FirebaseStorage
import CoreData

class contactProfileVC: UIViewController {
    
    var activeUserRef: DatabaseReference?
    var followingsRef: DatabaseReference?
    var followersRef: DatabaseReference?
    var eventTimelineRef: DatabaseReference?
    var followerRefContactID:DatabaseReference?
    var eventComingRef:DatabaseReference?
    
    var contactId: String?  // from segue coming from FriendsVC
     var contacts = [Contact]()
    
    var posts_Array: [String] = []
    var eventsArray: [String] = []
    var event_Array: [String] = []
    var posts_contactID_Array: [String] = []
    
    var activeUserInfo: NSDictionary?
    var userWhoWillFollowInfo: NSDictionary?
    
    var isFollowed: Bool = false
    
    var fullName: String!
    var profileUserImg: String!
    var userID: String!
    var userContactID: String!
    var notificationKey: String!
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    @IBAction func followContactAction(sender: AnyObject) {
        
               followContact(isFollowing: isFollowed) { (followRef) in
                
             print("You are now following \(self.activeUserInfo!["fullName"]!)   ")
                
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        InsideQueryUserEvent()
        //Dismiss Keyboard
        FirebaseFanout()
        //  NSFetchRequest()
        FirebaseFanoutEvent()
        FirebaseFanout_ContactID()
        QueryCurrentUser()
        fanoutToBeFollowedUser()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(contactProfileVC.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
        
        //REFERENCES FIREBASE
        activeUserRef = DataService.ds.REF_USER_CURRENT   // user - userID
        followingsRef = activeUserRef?.child("followings")   // followingsRef = users---> userID-----[avatar:, dislikes:, firstname, FOLLOWINGS:...]
        
        
        
        queryFollowing { (following) in
        
            //following Btn Status update
            
            if self.isFollowed {
                self.followBtn.setTitle("Following", for: .normal)
                
                // Notification Begin

                
                
                print("Following  Right now Notification ")
                
                // Notification Ended
                
                
                
            } else {
                self.followBtn.setTitle("Follow", for: .normal)
                
                
                print("Noooo  Following  Right now Notification ")
            }
        }
        
      
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
       // FirebaseFanout()
      //  NSFetchRequest()
        //FirebaseFanoutEvent()
        
    }
    
   
    
    func queryFollowing( completion:@escaping (_ following:Bool) -> ()) {
    
        activeUserRef?.child("followings").observe(.value, with: { snapshot in    //activeUserRef = DataService.ds.REF_USER_CURRENT   // user - userID
            
            //counting followings
           // let countingFollowings = (snapshot.value as AnyObject).count
            let countingFollowings = snapshot.childrenCount
         //   print("countingFollowings: \(countingFollowings!)")
            //  self.followingLabel.text =  "\(self.countingFollowings!) \n Following"
            
            let following = ["following":  (countingFollowings) ]
            
            DataService.ds.REF_BASE.child("users").child(KEY_UID!).updateChildValues(following)
            
            
            for child in snapshot.children {
                let userID = (child as AnyObject).key as String
                print("USER ID IIIIiiiiiiiiiiiiiiiii: \(userID)")
                
                if userID ==  self.contactId {
                    
                    self.isFollowed = true
                }
            }
            completion(self.isFollowed)
        }, withCancel: { (error) -> Void in
    })
    
    }
    
    func followContact(isFollowing:Bool, completion:(_ followRef:DatabaseReference?) -> ()) {
        
        // followingsRef = users---> userID-----[avatar:, dislikes:, firstname, FOLLOWINGS:...]
        
      let followingRef = self.followingsRef?.child("\(self.activeUserInfo!["id"]!)")  //  puting contactId on child(contactId!) also works
      let followingRef2 = DataService.ds.REF_FOLLOWING_USERID.child("\(self.activeUserInfo!["id"]!)")
        let uid = UserDefaults.standard.value(forKey: "uid") as? String
        let followerRefContactID = DataService.ds.REF_FOLLOWER.child(contactId!).child(uid!)
        let followerRefUserID = DataService.ds.REF_FOLLOWER.child(KEY_UID!).child(contactId!)
        
        
       

        if isFollowing {
            
            followingRef?.removeValue()
            followingRef2.removeValue()
            followerRefContactID.removeValue()
            followerRefUserID.removeValue()
          
            
            
       
            
            
            //Events Delete
            
            //Remove Notification
            
            if self.userContactID != nil {
            
            DataService.ds.REF_BASE.child("notifications").child(self.userContactID).child(self.notificationKey).removeValue()
            DataService.ds.REF_BASE.child("notifications-postUID").child(self.userContactID).child(self.notificationKey).removeValue()
            
            DataService.ds.REF_BASE.child("notifications").child(KEY_UID!).child(self.notificationKey).removeValue()
            DataService.ds.REF_BASE.child("notifications-postUID").child(KEY_UID!).child(self.notificationKey).removeValue()
            
            }
            
            //End Of Remove Notification
            
            for event2IDx in self.event_Array {   //   delete  event from timeline of the deleted user
                
                DataService.ds.REF_BASE.child("timeline").child(KEY_UID!).child(event2IDx).removeValue()
                DataService.ds.REF_BASE.child("events-timeline").child(KEY_UID!).child(event2IDx).removeValue()
                DataService.ds.REF_BASE.child("event-followers").child(event2IDx).child(contactId!).removeValue()
            }
            
        
            
                
             eventTimelineRef = DataService.ds.REF_BASE.child("events-timeline").child(contactId!)
                
                for eventID in self.eventsArray {
                
                    eventTimelineRef!.child(eventID).removeValue()
                    
                    DataService.ds.REF_BASE.child("event-followers").child(eventID).child(contactId!).removeValue()  // probably delete
                   
                    
                    
                    DataService.ds.REF_BASE.child("timeline").child(contactId!).child(eventID).removeValue()
                    

                    
                }
                
            
            
                for eventID in self.eventsArray {
                    
                    eventComingRef = DataService.ds.REF_BASE.child("users-event-coming").child(eventID).child("coming")
                
                    eventComingRef!.child(contactId!).removeValue()
            
                }
            
           //posts delete
            
            for postIDx_ContactID in self.posts_contactID_Array {    // own my timeline
                
                DataService.ds.REF_BASE.child("timeline").child(KEY_UID!).child(postIDx_ContactID).removeValue()  // ok
                
            }
          
           
            for postIDx in self.posts_Array {  // on follower time line
                
               // DataService.ds.REF_BASE.child("timeline").child(KEY_UID!).child(postIDx).removeValue()
            
                DataService.ds.REF_BASE.child("timeline").child(contactId!).child(postIDx).removeValue()
            
           }
            
            self.followBtn.setTitle("Follow", for: .normal)
            self.isFollowed = false
            
           
            
            
        } else {
        
            followingRef?.setValue(true)
            followingRef2.setValue(true)
            followerRefContactID.setValue(true)
            followerRefUserID.setValue(true)
            
            self.followBtn.setTitle("Following", for: .normal)
            self.isFollowed = true
            
            
            //posible notification
            
            
            let time  = String(Int(NSDate().timeIntervalSince1970))
            
            guard let key = DataService.ds.REF_BASE.child("notification").childByAutoId().key else {
                return
            }
            
            self.notificationKey = "(N\(key))!"  /// notificationKey is the same number of the commentKey but with and N before the number
            
            let notificationFollowing : [String : AnyObject] = [
                "uid": KEY_UID! as AnyObject,
                "fullName": self.fullName! as AnyObject,
                "avatar": self.profileUserImg as AnyObject,
                "date" : time as AnyObject,
                "postKey" : "" as AnyObject,
                "commentID": "" as AnyObject,
                "type": "IS FOLLOWING YOU" as AnyObject,
                "notificationKey": notificationKey as AnyObject,
                "checked": "no" as AnyObject,
                ]
            
            
            
            if self.userContactID != KEY_UID {
                
                DataService.ds.REF_BASE.child("notifications").child(self.userContactID).child(self.notificationKey).setValue(notificationFollowing)
                DataService.ds.REF_BASE.child("notifications-postUID").child(self.userContactID).child(self.notificationKey).setValue(true)
                
                
            } else {
                // do nothing
                
            }
            
            // end notification
            
        }
        
        completion(followingRef!)
        
    }
    
  
    
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
    
    override func prepare(for forsegue: UIStoryboardSegue, sender: Any?) {
        if forsegue.identifier == "segue_contactProfToPost"
        {
            if let destinationVC = forsegue.destination as? PostsByContactVC {
              
                destinationVC.userID = contactId
                print("USER ID IIIIiiiiiiiiiiiiiiiii: \(contactId)")            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Keyboard dismiss
    @objc func hideKeyboard()
    {
        self.view.endEditing(true)
    }
    
  
    
    
    
    func FirebaseFanout(){
        
        
        
        followersRef = DataService.ds.REF_BASE.child("user-posts-id").child(KEY_UID!) // followersRef = DataService.ds.REF_USER_POST.child(self.contactId!)
        followersRef!.observe(.value, with:  { snapshot in
            
            
            print("new snapshot array: \(snapshot.key)")
            
            
            self.posts_Array = []
            
            
            for child in snapshot.children {
                let postID = (child as AnyObject).key as String
                print("postID  Array IIIIiiiiiDelete Postiiiiiiiii: \(postID)")
                
                self.posts_Array.append(postID)
                
                _ = Post(followersList: self.posts_Array)
                
                
                
                for postIDx in self.posts_Array {
                    print(" Array postID Delete Post \(postIDx)")
                }
                
            }
            
            
            
            
        }, withCancel: { (error) ->  Void in
                
                
        })
    }
    
    func FirebaseFanout_ContactID(){
        
        
        
        followersRef = DataService.ds.REF_BASE.child("user-posts-id").child(self.contactId!) // followersRef = DataService.ds.REF_USER_POST.child(self.contactId!)
        followersRef!.observe(.value, with:  { snapshot in
            
            
            print("new snapshot array: \(snapshot.key)")
            
            
            self.posts_contactID_Array = []
            
            
            for child in snapshot.children {
                let postID = (child as AnyObject).key as String
                print("postID  Array IIIIiiiiiDelete Postiiiiiiiii: \(postID)")
                
                self.posts_contactID_Array.append(postID)
                
                _ = Post(followersList: self.posts_contactID_Array)
                
                
                
                for postIDx_ContactID in self.posts_contactID_Array {
                    print(" Array postID Delete Post \(postIDx_ContactID)")
                }
                
            }
            
            
            
            
        }, withCancel: { (error) ->  Void in
                
                
        })
    }

    
    func FirebaseFanoutEvent(){
        
        
        
        followersRef = DataService.ds.REF_BASE.child("host-events-id").child(self.contactId!)
        followersRef!.observe(.value, with:  { snapshot in
            
            
            print("new snapshot array: \(snapshot.key)")
            
            
            self.event_Array = []
            
            
            for child in snapshot.children {
                let eventID = (child as AnyObject).key as String
                
                
                self.event_Array.append(eventID)
                
                _ = Post(followersList: self.event_Array)
                
                
                
                for event2IDx in self.event_Array {
                    print(" Array event host id \(event2IDx)")
                }
                
            }
            
            
            
            
        }, withCancel: { (error) ->  Void in
                
                
        })
    }
    

    
   

    func  InsideQueryUserEvent(/*comingIDx: String*/){
        
        
        DataService.ds.REF_BASE.child("host-events-id").child(KEY_UID!).observe(.value, with: { (snapshot) in
            
            
            self.eventsArray = []
            //  self.usersLists = []
            
            for child in snapshot.children {
                let eventID = (child as AnyObject).key as String
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

    func fanoutToBeFollowedUser() {
    
    var image: String?
    
    DataService.ds.REF_USERS.child(contactId!).observe(.value, with: { (snapshot)  in
    
    let item = snapshot as DataSnapshot
    print("SNAP-Itemxxxxxxxxxxx: \(item)")
    
    // if let dict = item.value as? NSDictionary{
    
    if let dict = item.value as? [String : AnyObject]{
    let avatar = dict["avatar"] as! String
    image = avatar
    
    self.activeUserInfo = dict as NSDictionary?
    
    //contact's information
    
    self.title = " \((self.activeUserInfo!["fullName"]! as AnyObject).uppercased!)'s Profile"
    self.postsLabel.text = " \(self.activeUserInfo!["postNumber"]!) \n posts"
    self.followersLabel.text = " \(self.activeUserInfo!["followers"]!) \n followers"
    self.followingLabel.text = " \(self.activeUserInfo!["following"]!) \n following"
    self.userContactID = "\(self.activeUserInfo!["id"]!)"
    
    let  activeUserInfoID = self.activeUserInfo!["id"] as! String
    
    print("activeUserInfoID----xxxx-------:\(activeUserInfoID)")
    
    
    
    self.downloadAvatar(image: avatar, completion: { (data) in
    
    self.avatarImageView.image = UIImage(data: data as Data)
    
    self.avatarImageView.layer.cornerRadius = 50.0
    self.avatarImageView.clipsToBounds = true
    })
    
    }
    
  
    
    }) {(error)  in
    
    print(error.localizedDescription)
    
    }
    }
    
    func QueryCurrentUser(){
     
        DataService.ds.REF_USER_CURRENT.observe(.value, with: { (snapshot)  in
            
            let item = snapshot as DataSnapshot
            print("SNAP-Itemxxxxxxxxxxx: \(item)")
            
            
            
            if let dict = item.value as? [String : AnyObject]{
                let avatar = dict["avatar"] as! String
                // self.image = avatar
                
                self.userWhoWillFollowInfo = dict as NSDictionary?
                
                self.fullName = self.userWhoWillFollowInfo!["fullName"]! as! String
                self.profileUserImg = "\(self.userWhoWillFollowInfo!["avatar"]!)"
                self.userID = "\(self.userWhoWillFollowInfo!["id"]!)"
                
                
            }
            
        }, withCancel: {(error) -> Void in
        })
    }

    }
