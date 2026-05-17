//
//  EventDetailVC.swift
//  pickup
//
//  Created by christian landa on 8/24/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseMessaging
import FirebaseStorage
import Foundation

class EventDetailVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    
    @IBOutlet weak var editBTn: UIBarButtonItem!
    @IBOutlet weak var deleteBtn: UIBarButtonItem!
    @IBOutlet weak var addThemeBtn: UIButton!
    @IBOutlet weak var commentsBtn: UIButton!
    @IBOutlet weak var mapBtn: UIButton!
    @IBOutlet weak var comingBtn: UIButton!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    var events = [Event]()
   // var event: Event!
    var eventInfo: NSDictionary?
    var eventCommentInfo: NSDictionary?
    
    var eventKey: String!  // from segue coming from EventVC
    var hostUid: String!  //  now from from QueryEventPosts previously from segue coming from EventVC
    var eventKEY: String! // from QueryEventPosts()
    
    var friendsArray: [String] = []
    
    var comingBtnBool: Bool!
    
    var isComing: Bool = false
    
    var coming_Array: [String] = []
    var comingsRef: DatabaseReference?
    var friendReference: DatabaseReference?
    var followersRef: DatabaseReference?

    var contacts = [Contact]()
    
    var contactInfo: NSDictionary?
    var eventComentInfo: NSDictionary?
    
    var geoFire: GeoFire!
    var geoFireEvent: GeoFire!
    var geoFireRef: DatabaseReference!
    var geoFireEventRef: DatabaseReference!
    
    var postFollowersArray: [String] = []
    var activeUserInfo: NSDictionary?
    var postEventCommentArray: [String] = []
    
    
    var profileName: String!
    var profileImg: String!
    
    var eventCommentID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = false
        
        
        QueryMyEvent_Timeline()
     
//refreshControl.addTarget(self, action: "uiRefreshControlAction", forControlEvents: .ValueChanged)
   //     self.tableView.addSubview(refreshControl)
        
        tableView.delegate = self
        tableView.dataSource = self
        
       QueryEventPosts()
        
//        if  KEY_UID != self.hostUid{
//            
//            self.navigationItem.rightBarButtonItems = nil
//            
//        } else {
//            
//            self.navigationItem.rightBarButtonItem!.customView!.hidden = false
//        }
        
        comingsRef = ref.child("users-event-coming").child(self.eventKey).child("coming")
    
        queryFollowing { (coming) in   //(coming: self.isComing)
            
            //coming Btn Status update
            
            if self.isComing {
                self.comingBtn.setTitle("You Status:  YES", for: .normal)
                 self.comingBtn.titleLabel!.font = UIFont(name: "Marker Felt", size: 14)
                 self.comingBtn.setTitleColor(UIColor.red, for: .normal)
                
            } else {
                self.comingBtn.setTitle("Your Status:  NO", for: .normal)
                self.comingBtn.titleLabel!.font = UIFont(name: "Marker Felt", size: 14)
                self.comingBtn.titleLabel?.textAlignment = NSTextAlignment.center
                self.comingBtn.setTitleColor(UIColor.white, for: .normal)
                
            }
        }
        
    
    }
    
  /*  func uiRefreshControlAction() {
        self.tableView.reloadData()
        print("uiRefresh")
    }  */
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        
       self.tabBarController?.tabBar.isHidden = false
         QueryUsers()
        self.hidesBottomBarWhenPushed = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        QueryMyEvent_Timeline()
        QueryEventPosts()
        //FirebaseFanoutFollowers()
        FirebaseFanoutPostFollowers(eventKey: eventKey)
        // self.navigationController?.toolbarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
      self.tabBarController?.tabBar.isHidden = false
        //self.navigationController?.setNavigationBarHidden(false, animated: animated)
      self.tabBarController?.tabBar.isTranslucent = false
       
      self.hidesBottomBarWhenPushed = false //1/11/17
       self.navigationItem.setHidesBackButton(true, animated: false)
        print("EVentKEy: \(self.eventKey)")
        
        
        FirebaseFanout()
        QueryCurrentUser()
       
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
  //  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    func numberOfSections(in tableView: UITableView) -> Int {
     
    return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let contact = contacts[indexPath.row]
        print("testing Full Name: \(contact.fullName)")
        
        
        if let cell =  tableView.dequeueReusableCell(withIdentifier: "EventDetailCell") as? EventDetailCell {
            
            cell.configureCell(contact: contact)
            
          
            
            return cell
            
        } else {
            
            return EventCell()
        }
        
        
    }
    
    @IBAction func CommingBtnAction(sender: AnyObject) {
        
            comingContact(isComing: isComing) { (comingRef) in
                
        }
      self.tableView.reloadData()
    }
    
    
    func comingContact(isComing:Bool, completion:(_ comingRef:DatabaseReference?) -> ())  {  //comingsRef = ref.child("users-event-coming").child(self.eventKey).child("coming")
        
       let comingRef = self.comingsRef?.child(KEY_UID!)   //  not needed ,,
        
        //   to set your Status of Firebase,  going or not going
        if isComing {
            
            self.comingBtn.setTitle("Your Status:  NO", for: .normal)
            self.comingBtn.titleLabel!.font = UIFont(name: "Marker Felt", size: 16)
            self.comingBtn.setTitleColor(UIColor.white, for: .normal)
            self.comingBtn.titleLabel?.textAlignment = NSTextAlignment.center
            
            ref.child("users-event-coming").child(self.eventKey).child("coming").child(KEY_UID!).removeValue()
            ref.child("users-event-coming").child(self.eventKey).child("not-coming").updateChildValues([KEY_UID!: "true"])
            //  perhaps we have to add user->userID-events-  for countuning
            self.isComing = false
            
            
            
            //Notification
            DataService.ds.REF_BASE.child("notifications").child(self.hostUid!).child("N\(self.eventKey)").removeValue()
            
            DataService.ds.REF_BASE.child("notifications-postUID").child(self.hostUid!).child("N\(self.eventKey)").removeValue()
            DataService.ds.REF_BASE.child("post-commentsOnly").child(self.eventKey).child(self.eventKey).removeValue()
            
            
            let delayInSeconds = 1.0
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                
                self.FirebaseFanout()
                self.QueryUsers()
                
            }
          /*  dispatch_after(
                DispatchTime.now(
                    dispatch_time_t(DISPATCH_TIME_NOW),
                    Int64(1.0 * Double(NSEC_PER_SEC))
                ),
                dispatch_get_main_queue(),
                {
                    self.FirebaseFanout()
                    self.QueryUsers()
            }) */
          
            
        } else {
            
            self.comingBtn.setTitle("You Status:  YES", for: .normal)
            self.comingBtn.titleLabel!.font = UIFont(name: "Marker Felt", size: 20)
            self.comingBtn.titleLabel?.textAlignment = NSTextAlignment.center
            self.comingBtn.setTitleColor(UIColor.red, for: .normal)
            
            ref.child("users-event-coming").child(self.eventKey).child("coming").updateChildValues([KEY_UID!: "true"])
            ref.child("users-event-coming").child(self.eventKey).child("not-coming").child(KEY_UID!).removeValue()
            
            self.isComing = true
            
         /*   dispatch_after(
                DispatchTime.now(
                    dispatch_time_t(DISPATCH_TIME_NOW),
                    Int64(1.0 * Double(NSEC_PER_SEC))
                ),
                DispatchQueue.main,
                {
                    self.FirebaseFanout()
                    self.QueryUsers()
            })  */
            
            let delayInSeconds = 1.0
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                
                self.FirebaseFanout()
                self.QueryUsers()
                
            }
            
            
            
            //Notifications
              let time  = String(Int(NSDate().timeIntervalSince1970))
            //let  postID  = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
            
            let notificationKey = "N\(self.eventKey)"  /// notificationKey is the same number of the commentKey but with and N before the number
            print("notificationKEy  :  \(notificationKey)")
            
            //  NSUserDefaults.standardUserDefaults().setValue(notificationKey, forKey: "notificationKey")
            
            let notification = [
                "uid": KEY_UID,
                "fullName": self.profileName,
                "avatar": self.profileImg,
                "date" : time,
                "postKey" : self.eventKey,
                "commentID": self.eventKey,     // commentID is here consider as eventKey
                "type": "IS GOING TO AN EVENT",
                "notificationKey": notificationKey,
                "checked": "no",
                ]
            
            //   self.postUid =  self.post.uid
            
            if self.hostUid != KEY_UID {
                
                print("HostUID:  \(self.hostUid)")
                
                
                DataService.ds.REF_BASE.child("notifications").child(self.hostUid!).child(notificationKey).setValue(notification)
                
                DataService.ds.REF_BASE.child("notifications-postUID").child(self.hostUid!).child(notificationKey).setValue(true)
                DataService.ds.REF_BASE.child("post-commentsOnly").child(self.eventKey).child(self.eventKey).setValue(true)
                
            } else {
                // do nothing
                
            }
            
        }
        
        
        
        completion(comingRef!)
        //self.tableView.reloadData()
    }
  
    // to check if Current User is coming
    
    func queryFollowing( completion:@escaping (_ coming:Bool) -> ()) {
        
        ref.child("users-event-coming").child(self.eventKey).child("coming").observe(.value, with: { snapshot in
            for child in snapshot.children {
                let userID = (child as AnyObject).key as String
                print("USER ID IIIIiiiiiiiiiiiiiiiii: \(userID)")
                
                if userID ==  KEY_UID {
                    
                    self.isComing = true
                }
            }
            completion(self.isComing)
        }, withCancel: { (error) -> Void in
        })
        
    }
    
    //To populate labels 
    
    func QueryMyEvent_Timeline(){
        print("EVentKEy: \(self.eventKey)")
        
        ref.child("events-timeline").child(KEY_UID!).child(self.eventKey!).observe(.value , with: { (snapshot) in  //observeSingleEventOfType
            
            
            let item = snapshot as DataSnapshot
            print("SNAP-Itemxxxxxxxxxxx: \(item)")
            
            // if let dict = item.value as? NSDictionary{
            
            if let dict = item.value as? [String : AnyObject]{
                
                self.eventInfo = dict as NSDictionary?
                
                
                self.titleLbl.text = " \((self.eventInfo!["title"]! as AnyObject).uppercased!)"
                self.descriptionText.text = " \(self.eventInfo!["description"]!)"
                self.dateLbl.text = " \(self.eventInfo!["date"]!)"
                // self.hostUid = self.eventInfo!["host-uid"]! as! String
                // print("  host-uid--------- \(self.eventInfo!["host-uid"]!) ")
                
                // self.mapBtn = self.fullAddressString
                self.mapBtn.setTitle("\(self.eventInfo!["fullAddressWithBreaks"]!)", for: .normal)
                // self.mapBtn.titleLabel!.font = UIFont(name: "Marker Felt", size: 14)
                self.mapBtn.titleLabel?.textAlignment = NSTextAlignment.center
                
            }
            
            
            //   completation(imageStr: image!)
            
        }, withCancel: {(error) -> Void in
                
        })
       
    }

    //  getting all those users coming to the event.
     func FirebaseFanout(){
       
        
        ref.child("users-event-coming").child(self.eventKey).child("coming").observe(.value, with:  { snapshot in
            
            print("new snapshot coming: \(snapshot.key)")
            
            self.coming_Array = []
            
            
            for child in snapshot.children {
                let comingID = (child as AnyObject).key as String
                print("ComingID  Array IIIIiiiiiDelete Postiiiiiiiii: \(comingID)")
                
                self.coming_Array.append(comingID)
                
                _ = Post(followersList: self.coming_Array)
                
                
                
                for comingIDx in self.coming_Array {
                    print(" Array Coming 1>>>>>>> \(comingIDx)")
                }
                
            }
            
            
        }, withCancel: { (error) ->  Void in
                
                
        })
    }
    
    func FirebaseFanoutPostFollowers(eventKey: String!){
      
        followersRef = DataService.ds.REF_BASE.child("event-followers").child(eventKey)
        followersRef!.observe(.value, with:  { snapshot in
            
            
            print("new snapshot array: \(snapshot.key)")
            
            
            self.postFollowersArray = []    // self.friendsArray = [] for  self.postFollowersArray = []
            //  self.usersLists = []
            
            for child in snapshot.children {
                let postFollowersID = (child as AnyObject).key as String
                print("friendID  Array IIIIiiiiiiPostCelliiiiiii: \(postFollowersID)")
                
                self.postFollowersArray.append(postFollowersID)
                
                
                for postFollowersID in self.postFollowersArray {
                    print(" Array friendID tonight  PostCell \(postFollowersID)")
                }
                
            }
        })
    }


    // 
    func QueryUsers(){
      
           self.contacts = []
        
    if self.coming_Array != [] {
        
        for comingIDx in self.coming_Array {
            
           print(" Array Coming 2>>>>>>> \(comingIDx)")
        
            InsideQueryUsers(comingIDx: comingIDx)
                      print("comingIDx if nil: \(comingIDx)")
        }
    } else {
        let comingIDXX:String = "xx"   //xx is any ramdon string to pass the for-in than doesn't accept Nil arrays
        
        InsideQueryUsers(comingIDx: comingIDXX)
        
        }

}
    func  InsideQueryUsers(comingIDx: String){
        
        
    DataService.ds.REF_USERS.child(comingIDx).observe(.value, with: { (snapshot) in
    
    print("List Snapshot EVent Detail: \(snapshot)")
    
    if let contactDict = snapshot.value as? [String: AnyObject]
    
    {
    print("dictionaryXXXXXX Event Coming \(contactDict) xxxxxxxxxxxx")
    
    
    let key = snapshot.key
    let contact = Contact(contactKey: key, dictionary: contactDict)
    
    self.contacts.append(contact)
    
    //self.tableView.reloadData()
    }
    
    self.tableView.reloadData()              //  dispatch_async(dispatch_get_main_queue(),{
    // self.tableView.reloadData()  //ok
    
    // })
    
    
    })
    }
    
    func QueryCurrentUser(){
        
        DataService.ds.REF_USER_CURRENT.observe(.value, with: { (snapshot)  in
            
            let item = snapshot as DataSnapshot
            print("SNAP-Itemxxxxxxxxxxx: \(item)")
            
            // if let dict = item.value as? NSDictionary{
            
            if let dict = item.value as? [String : AnyObject]{
                let avatar = dict["avatar"] as! String
                // self.image = avatar
                
                self.activeUserInfo = dict as NSDictionary?
                
                // self.title = "Welcome \(self.activeUserInfo!["firstName]!)"
                self.profileName = "\((self.activeUserInfo!["fullName"]! as AnyObject).uppercased!)"
                self.profileImg = "\(self.activeUserInfo!["avatar"]!)"
                // self.followersLabel.text = " \(self.activeUserInfo!["followers"]!) \n followers"
                // self.followingLabel.text = " \(self.activeUserInfo!["following"]!) \n following"
                
                
                
            }
            
            
            
            //   completation(imageStr: image!)
            
        }, withCancel: {(error) -> Void in
                
        })
        
    }
    
    func QueryEventPosts(){
        
        print("Event Key inside : \(self.eventKey)")
        
        DataService.ds.REF_BASE.child("events").child(self.eventKey).observe(.value , with: { (snapshot) in  //observeSingleEventOfType
            
            //postInfo
            
            let item = snapshot as DataSnapshot
            print("SNAP-Itemx-EVent: \(item)")
            
            
            if let dict = item.value as? [String : AnyObject]{
                
                self.eventCommentInfo = dict as NSDictionary?
                
                
                self.hostUid =   self.eventCommentInfo!["host-uid"]! as! String
                self.eventKEY =   self.eventCommentInfo!["eventKey"]! as! String
                
                if  KEY_UID != self.hostUid{
                    
                    self.navigationItem.rightBarButtonItems = nil
                    
                } else {
                    
                    
                }
                
                
            }
            
        }, withCancel: {(error) -> Void in
                
        })
    }

    
    @IBAction func doneBtnFn(sender: AnyObject) {
        //segue_backTo_Event
       performSegue(withIdentifier: "segue_backTo_Event", sender: nil)
        
    }
    
     override func prepare(for forsegue: UIStoryboardSegue, sender: Any?) {
        
        if forsegue.identifier == "goToGeoMapVC" {
            
          
            let destinationVC = forsegue.destination as! GeoMapVC
            
                destinationVC.eventKey   = self.eventKey
            
        }
        
             if forsegue.identifier == "segue_EventCommentVC" {
                 let destinationVC = forsegue.destination as! EventCommentVC
                destinationVC.eventKey =  self.eventKey
             
             }
        
        
        
        if forsegue.identifier == "segue_Edit_Event"
        {
            let destinationVC = forsegue.destination as! EditEventVC
           
                destinationVC.eventKey   = self.eventKey
      //  self.performSegue(withIdentifier: "segue_Edit_Event", sender: nil)

           
        }
        
    }
    
    @IBAction func DeleteEventBtn(sender: AnyObject) {
        
        let optionMenu = UIAlertController(title: nil, message: "Are You Sure!", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("File Deleted")
            self.deleteEvent()
        })
        
     
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
       
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
       func deleteEvent() {
        
        
        // delete notification
        
        DataService.ds.REF_BASE.child("post-commentsOnly").child(self.eventKey).observe(.value, with:  { snapshot in
            
            self.postEventCommentArray = []
            
            for child in snapshot.children {
                let postComment = (child as AnyObject).key as String
                
                self.postEventCommentArray.append(postComment)
                
                for eventComment in self.postEventCommentArray {
                    print(" Array friendID tonight  PostCell \(eventComment)")
                    
                    DataService.ds.REF_BASE.child("notifications").child(KEY_UID!).child("N\(eventComment)").removeValue()
                    DataService.ds.REF_BASE.child("notifications-postUID").child(KEY_UID!).child("N\(eventComment)").removeValue()
                  //  DataService.ds.REF_BASE.child("post-commentsOnly").child(self.eventKey).removeValue()
                    
                    DataService.ds.REF_BASE.child("event-comments").child(KEY_UID!).child(eventComment).removeValue()
                    DataService.ds.REF_BASE.child("event-comments").child(self.eventKey!).child(eventComment).removeValue()
                    DataService.ds.REF_BASE.child("event-comments-userID").child(self.eventKey!).child(eventComment).removeValue()
                    
                }
                DataService.ds.REF_BASE.child("post-commentsOnly").child(self.eventKey).removeValue()
            }
        })
         
        
        
       
        
        
        
       // performSegueWithIdentifier("segue_Back_to_Events", sender: nil)
        
        ref.child("events").child(eventKey).removeValue()
        ref.child("user-events-id").child(KEY_UID!).child(eventKey).removeValue()
        
       
        
        for postFollowersID in self.postFollowersArray {
            
            ref.child("events-timeline").child(postFollowersID).child(eventKey).removeValue()
            
            ref.child("timeline").child(postFollowersID).child(eventKey).removeValue()

            DataService.ds.REF_BASE.child("event-followers").child(eventKey).child(postFollowersID).removeValue()
        }
        
        //Delete your own EVent
        
        ref.child("events-timeline").child(KEY_UID!).child(eventKey).removeValue()
        
        ref.child("timeline").child(KEY_UID!).child(eventKey).removeValue()
        
        DataService.ds.REF_BASE.child("event-followers").child(eventKey).child(KEY_UID!).removeValue()
        
        // end Delte your own event
        
        ref.child("host-events-id").child(KEY_UID!).child(eventKey).removeValue()
        ref.child("user-events").child(KEY_UID!).child(eventKey).removeValue()  // check maybe not needed user-vents
        ref.child("users-event-coming").child(eventKey).removeValue()
        ref.child("users").child(KEY_UID!).child("events").child(eventKey).removeValue()
 
 
        geoFireEventRef = Database.database().reference().child("geo-user-events").child(KEY_UID!)
        geoFire = GeoFire(firebaseRef: geoFireEventRef)
        geoFire.removeKey(eventKey)
        
        
        geoFireRef = Database.database().reference().child("geo-events")
        geoFireEvent = GeoFire(firebaseRef: geoFireRef)
        geoFireEvent.removeKey(eventKey)
        
 
        
        self.performSegue(withIdentifier: "segue_Back_to_Events", sender: nil)
    
       


        
    }
    
    @IBAction func editEvenBtn(sender: AnyObject) {
        
        performSegue(withIdentifier: "segue_Edit_Event", sender: nil)
        
        
    }
    
    
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            self.tabBarController?.tabBar.isHidden = false
        }
    }
   
}
