//
//  NotificationVC.swift
//  pickup
//
//  Created by christian landa on 10/5/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Firebase

class NotificationVC: UITableViewController, ContactIDNotificationCellDelegate   {
    
  //  @IBOutlet weak var tableView: UITableView!
    
    var snapshot2Dict = [String: String]()
    
  //  var contacts = [Contact]()
    
    
  //  var contactInfo: NSDictionary?
    
    
    var notification: Notification!
    var notifications = [Notification]()
    
  //  var delegate: NotificationCellDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
      //  tableView.dataSource = self
     //   tableView.delegate = self
        
        QuerryUserFollowing()
    }
    
    func QuerryUserFollowing(){
        
        DataService.ds.REF_BASE.child("notifications").child(KEY_UID!).queryOrderedByChild("date").observeEventType(.Value, withBlock:{ snapshot in
            
          
            
            print("xxxxxxxxxxxxxxxx: \(snapshot.value)")
            
            self.notifications = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]  {
                
                for snap in snapshots {
                    
                    if let notificationDict = snap.value as? [String : AnyObject]  {
                        
                        let key = snap.key
                        let notification = Notification(notificationKey: key, dictionary: notificationDict)
                        
                        self.notifications.append(notification)
                        
                    }
                    }
                }
            
            
             self.notifications = self.notifications.reverse()
                self.tableView.reloadData()
           
                
            }, withCancelBlock: nil)
            
         // }, withCancelBlock: nil)
        
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notifications.count
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let notification = notifications[indexPath.row]
        print("testing Full Name: \(notification.fullName)")
        
        if let cell =  tableView.dequeueReusableCellWithIdentifier("Cell") as? NotificationCell {
            
           // cell.delegate = self // july 7, 2016
            cell.delegate2 = self
            
          //  cell.infoLbl.text = infolbl[[index.row]]
            
            cell.configureCell(notification)
            
            
            
            return cell
            
        } else {
            
            return NotificationCell()
        }
        
    }
    
    
    override func viewDidLayoutSubviews() {
        if let rect = self.navigationController?.navigationBar.frame {
            let y = rect.size.height + rect.origin.y
            self.tableView.contentInset = UIEdgeInsetsMake( y, 0, 0, 0)
        }
    }
    
 
    func ContactIDNotificationSegueFromCell(contactID dataobject: AnyObject) {
        
      //  dispatch_async(dispatch_get_main_queue()){
            //try not to send self, just to avoid retain cycles(depends on how you handle the code on the next controller)
            self.performSegueWithIdentifier("segue_Notification_to_Profile_Name", sender:dataobject )
        
           let  notificationUserId = dataobject
        print("notification 1: \(notificationUserId)")
            
       // }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        // X check profile
        if segue.identifier == "segue_Notification_to_Profile_Name"
        {
            let destinationVC = segue.destinationViewController as? contactProfileVC
            if let theString = sender as? String {
                destinationVC!.contactId =  theString
            }
        }
        
//     //  if contactSelected2.  == "IS GOING TO AN EVENT" {
//        // X join your event
//       if  segue.identifier == "segueNotification_Event"  {                        //var eventKey: String!  // from segue coming from EventVC
//                                                                                     // var hostUid: String!    from segue coming from EventVC
//            
//            let index = tableView.indexPathForSelectedRow
//            let contactSelected = notifications[index!.row]
//            
//          //  print("ContactKEY-Outside-----xxxxx-----------------: \(contactSelected.contactKey)")
//            let destinationVC = segue.destinationViewController as! EventDetailVC
//            
//            destinationVC.eventKey   = contactSelected.postKey   // postKey = eventKey
//            destinationVC.hostUid   = contactSelected.uid
////
//        }
//        
//       // }
//        // X Commented on your post
//       if segue.identifier == "segueNotification_to_Comment_Post"   //CommentVC
//        {
//            let index = tableView.indexPathForSelectedRow
//            let contactSelected = notifications[index!.row]
//            
//            //  print("ContactKEY-Outside-----xxxxx-----------------: \(contactSelected.contactKey)")
//            let destinationVC = segue.destinationViewController as! CommentVC
//            
//             NSUserDefaults.standardUserDefaults().setValue(contactSelected.postKey, forKey: "postKey")    
//            
//          //  destinationVC.eventKey   = contactSelected.postKey   // postKey = eventKey
//         //   destinationVC.hostUid   = contactSelected.uid
//            //
//            
//            
//        }
//        // X likes your post 
//         if segue.identifier == "segue_Notification_T0_Post"
//        {
//            
//            let index = tableView.indexPathForSelectedRow
//            let contactSelected = notifications[index!.row]
//            
//            //  print("ContactKEY-Outside-----xxxxx-----------------: \(contactSelected.contactKey)")
//            let destinationVC = segue.destinationViewController as! FeedVC
//            
//          //  destinationVC.eventKey   = contactSelected.postKey   // postKey = eventKey
//          //  destinationVC.hostUid   = contactSelected.uid
//       
//        
//    }
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        super.viewWillDisappear(animated)
        //self.friendsTableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tableView.reloadData()
    }
    
    // clicked cell
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // call cell for calling cell data
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! NotificationCell
        
        
        // going to event
      if cell.infoLbl.text == "IS GOING TO AN EVENT" {
            
        let index = tableView.indexPathForSelectedRow
                    let contactSelected = notifications[index!.row]
        
        
        
            // go comments
       let event = self.storyboard?.instantiateViewControllerWithIdentifier("EventDetailVC") as! EventDetailVC//("segueNotification_Event") as! EventDetailVC
        
        event.eventKey = contactSelected.postKey
        event.hostUid = contactSelected.uid
        self.navigationController?.pushViewController(event, animated: true)
        }
        
        
        // comment to your own post
       else if cell.infoLbl.text == "HAS COMMENTED ON YOUR POST" {
        
        let index = tableView.indexPathForSelectedRow
        let contactSelected = notifications[index!.row]
        
        let comment = self.storyboard?.instantiateViewControllerWithIdentifier("CommentVC") as!  CommentVC //("segueNotification_to_Comment_Post") as!  CommentVC
        
        
        NSUserDefaults.standardUserDefaults().setValue(contactSelected.postKey, forKey: "postKey")

        
        self.navigationController?.pushViewController(comment, animated: true)
        }
        
        //* comment to your  own event
      else if cell.infoLbl.text == "HAS COMMENTED ON YOUR EVENT" {
        
        let index = tableView.indexPathForSelectedRow
        let contactSelected = notifications[index!.row]
        
        let eventComment = self.storyboard?.instantiateViewControllerWithIdentifier("EventCommentVC") as!  EventCommentVC //("segueNotification_to_Comment_Post") as!  CommentVC
        
        eventComment.eventKey = contactSelected.postKey
       // NSUserDefaults.standardUserDefaults().setValue(contactSelected.postKey, forKey: "postKey")
        
        
        self.navigationController?.pushViewController(eventComment, animated: true)
      }
       
        
        // going to liked post  //var userID: String?
      else  if cell.infoLbl.text == "LIKES YOUR POST" {  // create a separate view controller to display a single post for now let do My Post
            
        let index = tableView.indexPathForSelectedRow
        let contactSelected = notifications[index!.row]
        
            
            
        let likes = self.storyboard?.instantiateViewControllerWithIdentifier("PostsByUserVC") as! PostsByUserVC//("segue_Notification_T0_Post") as! FeedVC
        
        likes.userID = contactSelected.uid
        self.navigationController?.pushViewController(likes, animated: true)
        }
        
        // going to the following user
      else  if cell.infoLbl.text == "IS FOLLOWING YOU" {      //var contactId: String?
            
            let index = tableView.indexPathForSelectedRow
            let contactSelected = notifications[index!.row]
        
        
            let following = self.storyboard?.instantiateViewControllerWithIdentifier("contactProfileVC") as! contactProfileVC //("segue_Notification_to_Profile_Name") as! contactProfileVC
        
            following.contactId = contactSelected.uid
        
            self.navigationController?.pushViewController(following, animated: true)
        }
        
        
    }
  
}

