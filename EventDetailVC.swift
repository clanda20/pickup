//
//  EventDetailVC.swift
//  pickup
//
//  Created by christian landa on 8/24/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import FirebaseDatabaseUI
import FirebaseAuthUI

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
    
    @IBOutlet weak var tableView: UITableView!
    
    var events = [Event]()
   // var event: Event!
    var eventInfo: NSDictionary?
    var eventKey: String!  // from segue coming from EventVC
    var hostUid: String!  // from segue coming from EventVC
    
    var friendsArray: [String] = []
    
    var comingBtnBool: Bool!
    
    var isComing: Bool = false
    
    var coming_Array: [String] = []
    var comingsRef: FIRDatabaseReference?
    var friendReference: FIRDatabaseReference?
    var followersRef: FIRDatabaseReference?

    var contacts = [Contact]()
    
    var contactInfo: NSDictionary?
    
    var geoFire: GeoFire!
    var geoFireEvent: GeoFire!
    var geoFireRef: FIRDatabaseReference!
    var geoFireEventRef: FIRDatabaseReference!
    
    var postFollowersArray: [String] = []
  //  let refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.hidden = true
        
        QueryMyEvent_Timeline()
     
//refreshControl.addTarget(self, action: "uiRefreshControlAction", forControlEvents: .ValueChanged)
   //     self.tableView.addSubview(refreshControl)
        
        tableView.delegate = self
        tableView.dataSource = self
        
       // QueryUsers()
        
        if  KEY_UID != hostUid{
            
            self.navigationItem.rightBarButtonItems = nil
            
        } else {
            
            
        }
        
        comingsRef = ref.child("users-event-coming").child(self.eventKey).child("coming")
    
        queryFollowing { (coming) in   //(coming: self.isComing)
            
            //coming Btn Status update
            
            if self.isComing {
                self.comingBtn.setTitle("You Status:  YES", forState: .Normal)
                 self.comingBtn.titleLabel!.font = UIFont(name: "Marker Felt", size: 14)
                 self.comingBtn.setTitleColor(UIColor.redColor(), forState: .Normal)
                
            } else {
                self.comingBtn.setTitle("Your Status:  NO", forState: .Normal)
                self.comingBtn.titleLabel!.font = UIFont(name: "Marker Felt", size: 14)
                self.comingBtn.titleLabel?.textAlignment = NSTextAlignment.Center
                self.comingBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                
            }
        }
        
    
    }
    
  /*  func uiRefreshControlAction() {
        self.tableView.reloadData()
        print("uiRefresh")
    }  */
    
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated)
         QueryUsers()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        QueryMyEvent_Timeline()
        //FirebaseFanoutFollowers()
        FirebaseFanoutPostFollowers(eventKey)
        // self.navigationController?.toolbarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.hidden = false
        //self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
       
        // self.navigationItem.leftBarButtonItem = nil
        //self.navigationItem.setHidesBackButton(true, animated: false)
        print("EVentKEy: \(self.eventKey)")
        
        
        FirebaseFanout()
        //QueryUsers()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let contact = contacts[indexPath.row]
        print("testing Full Name: \(contact.fullName)")
        
        
        if let cell =  tableView.dequeueReusableCellWithIdentifier("EventDetailCell") as? EventDetailCell {
            
            cell.configureCell(contact)
            
          
            
            return cell
            
        } else {
            
            return EventCell()
        }
        
        
    }
    
    @IBAction func CommingBtnAction(sender: AnyObject) {
        
            comingContact(isComing) { (comingRef) in
                
        }
      self.tableView.reloadData()
    }
    
    
    func comingContact(isComing:Bool, completion:(comingRef:FIRDatabaseReference!) -> ())  {  //comingsRef = ref.child("users-event-coming").child(self.eventKey).child("coming")
        
       let comingRef = self.comingsRef?.child(KEY_UID!)   //  not needed ,,
        
        //   to set your Status of Firebase,  going or not going
        if isComing {
            
            self.comingBtn.setTitle("Your Status:  NO", forState: .Normal)
            self.comingBtn.titleLabel!.font = UIFont(name: "Marker Felt", size: 16)
            self.comingBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            self.comingBtn.titleLabel?.textAlignment = NSTextAlignment.Center
            
            ref.child("users-event-coming").child(self.eventKey).child("coming").child(KEY_UID!).removeValue()
            ref.child("users-event-coming").child(self.eventKey).child("not-coming").updateChildValues([KEY_UID!: "true"])
            //  perhaps we have to add user->userID-events-  for countuning
            self.isComing = false
            
            dispatch_after(
                dispatch_time(
                    DISPATCH_TIME_NOW,
                    Int64(1.0 * Double(NSEC_PER_SEC))
                ),
                dispatch_get_main_queue(),
                {
                    self.FirebaseFanout()
                    self.QueryUsers()
            })
          
            
        } else {
            
            self.comingBtn.setTitle("You Status:  YES", forState: .Normal)
            self.comingBtn.titleLabel!.font = UIFont(name: "Marker Felt", size: 20)
            self.comingBtn.titleLabel?.textAlignment = NSTextAlignment.Center
            self.comingBtn.setTitleColor(UIColor.redColor(), forState: .Normal)
            
            ref.child("users-event-coming").child(self.eventKey).child("coming").updateChildValues([KEY_UID!: "true"])
            ref.child("users-event-coming").child(self.eventKey).child("not-coming").child(KEY_UID!).removeValue()
            
            self.isComing = true
            
            dispatch_after(
                dispatch_time(
                    DISPATCH_TIME_NOW,
                    Int64(1.0 * Double(NSEC_PER_SEC))
                ),
                dispatch_get_main_queue(),
                {
                    self.FirebaseFanout()
                    self.QueryUsers()
            })
            
        }
        
        
        
        completion(comingRef: comingRef!)
        //self.tableView.reloadData()
    }
  
    // to check if Current User is coming
    
    func queryFollowing( completion:(coming:Bool) -> ()) {
        
        ref.child("users-event-coming").child(self.eventKey).child("coming").observeEventType(.Value, withBlock: { snapshot in
            for child in snapshot.children {
                let userID = child.key as String
                print("USER ID IIIIiiiiiiiiiiiiiiiii: \(userID)")
                
                if userID ==  KEY_UID {
                    
                    self.isComing = true
                }
            }
            completion(coming: self.isComing)
            }, withCancelBlock: { (error) -> Void in
        })
        
    }
    
    //To populate labels 
    
    func QueryMyEvent_Timeline(){
        print("EVentKEy: \(self.eventKey)")
        
        ref.child("events-timeline").child(KEY_UID!).child(self.eventKey!).observeEventType(.Value , withBlock: { (snapshot) in  //observeSingleEventOfType
           
            
            let item = snapshot as FIRDataSnapshot
            print("SNAP-Itemxxxxxxxxxxx: \(item)")
            
            // if let dict = item.value as? NSDictionary{
            
            if let dict = item.value as? [String : AnyObject]{
                
                self.eventInfo = dict
                
              
                self.titleLbl.text = " \(self.eventInfo!["title"]!.uppercaseString!)"
                self.descriptionText.text = " \(self.eventInfo!["description"]!)"
                self.dateLbl.text = " \(self.eventInfo!["date"]!)"
               // self.hostUid = self.eventInfo!["host-uid"]! as! String
                 // print("  host-uid--------- \(self.eventInfo!["host-uid"]!) ")
              
                   // self.mapBtn = self.fullAddressString
                    self.mapBtn.setTitle("\(self.eventInfo!["fullAddressWithBreaks"]!)", forState: .Normal)
                   // self.mapBtn.titleLabel!.font = UIFont(name: "Marker Felt", size: 14)
                   self.mapBtn.titleLabel?.textAlignment = NSTextAlignment.Center
               
                
            }
            
            
            //   completation(imageStr: image!)
            
            }, withCancelBlock: {(error) -> Void in
                
        })
       
    }

    //  getting all those users coming to the event.
     func FirebaseFanout(){
       
        
        ref.child("users-event-coming").child(self.eventKey).child("coming").observeEventType(.Value, withBlock:  { snapshot in
        
            
            
            print("new snapshot coming: \(snapshot.key)")
            
            
            self.coming_Array = []
           
            
            for child in snapshot.children {
                let comingID = child.key as String
                print("ComingID  Array IIIIiiiiiDelete Postiiiiiiiii: \(comingID)")
                
                self.coming_Array.append(comingID)
                
                _ = Post(followersList: self.coming_Array)
                
               
                
                for comingIDx in self.coming_Array {
                    print(" Array Coming 1>>>>>>> \(comingIDx)")
                }
                
            }
            
            
            }, withCancelBlock: { (error) ->  Void in
                
                
        })
    }
    
    func FirebaseFanoutPostFollowers(eventKey: String!){
      
        followersRef = DataService.ds.REF_BASE.child("event-followers").child(eventKey)
        followersRef!.observeEventType(.Value, withBlock:  { snapshot in
            
            
            print("new snapshot array: \(snapshot.key)")
            
            
            self.postFollowersArray = []    // self.friendsArray = [] for  self.postFollowersArray = []
            //  self.usersLists = []
            
            for child in snapshot.children {
                let postFollowersID = child.key as String
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
        
            InsideQueryUsers(comingIDx)
                      print("comingIDx if nil: \(comingIDx)")
        }
    } else {
        let comingIDXX:String = "xx"   //xx is any ramdon string to pass the for-in than doesn't accept Nil arrays
        
        InsideQueryUsers(comingIDXX)
        
        }

}
    func  InsideQueryUsers(comingIDx: String){
        
        
    DataService.ds.REF_USERS.child(comingIDx).observeEventType(.Value, withBlock: { (snapshot) in
    
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
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "goToGeoMapVC" {
            
          
            let destinationVC = segue.destinationViewController as! GeoMapVC
            
                destinationVC.eventKey   = self.eventKey
            
        }
        
             if segue.identifier == "segue_EventCommentVC" {
                 let destinationVC = segue.destinationViewController as! EventCommentVC
                destinationVC.eventKey =  self.eventKey
             
             }
        
        
        
        if segue.identifier == "segue_Edit_Event"
        {
            let destinationVC = segue.destinationViewController as! EditEventVC
           
                destinationVC.eventKey   = self.eventKey
           
        }
        
    }
    
    @IBAction func DeleteEventBtn(sender: AnyObject) {
        
        let optionMenu = UIAlertController(title: nil, message: "Are You Sure!", preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("File Deleted")
            self.deleteEvent()
        })
        
     
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
       
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    
       func deleteEvent() {
        
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
 
 
        geoFireEventRef = FIRDatabase.database().reference().child("geo-user-events").child(KEY_UID!)
        geoFire = GeoFire(firebaseRef: geoFireEventRef)
        geoFire.removeKey(eventKey)
        
        
        geoFireRef = FIRDatabase.database().reference().child("geo-events")
        geoFireEvent = GeoFire(firebaseRef: geoFireRef)
        geoFireEvent.removeKey(eventKey)
      
        
        self.performSegueWithIdentifier("segue_Back_to_Events", sender: nil)
    
        

        
    }
    
    @IBAction func editEvenBtn(sender: AnyObject) {
        
        performSegueWithIdentifier("segue_Edit_Event", sender: nil)
        
        
    }
    
    
   
}
