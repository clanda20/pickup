//
//  EventCommentVC.swift
//  pickup
//
//  Created by christian landa on 9/5/16.
//  Copyright © 2016 christian landa. All rights reserved.
//  //segue_EventCommentVC

import UIKit
import Firebase



class EventCommentVC: UIViewController, UITableViewDelegate, UITextFieldDelegate, UITableViewDataSource, ContactIDEventCommentCellDelegate  {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sendBtn: UIButton!
    //  @IBOutlet weak var commentTxt: UITextView!
    //   @IBOutlet weak var commentField: MaterialTextField!
    
    @IBOutlet var textFieldToBottomLayoutGuideConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var commentField: UITextField!
    var eventcomment: EventComment!
    var eventcomments = [EventComment]()
    
    var eventKey: String! // from segue EventDetailVC
    
    var eventKEY: String! 
    
    
    var postID: String! = ""
    var value:  FIRDatabaseReference!
    lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    
    
    var eventcommentsRef: FIRDatabaseReference!
    var firebaseCommentPost2 : FIRDatabaseReference!
    var user_commentRef: FIRDatabaseReference!
    
    var activeUserInfo: NSDictionary?
    var profileName: String!
    var profileImg: String!
    
    static var imageCache = NSCache()
    
    var eventInfo: NSDictionary?
    var eventUid: String!
    
    //
    
    
    //variable to hold keyboard frame
    // var keyboard = CGRect()
    
    
    // values for seting UI to default
    //    var tableViewHeight : CGFloat = 0
    //   var commentY : CGFloat = 0
    //   var commentHeight : CGFloat = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 80.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        
        
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //   self.sendBtn.delegate = self
        self.commentField.delegate = self
        
        
        //Keyboard dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard"))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
         QueryEventPosts()
        QueryCurrentUser()
       
        //  alignment()
        
        //title at the top
        self.navigationItem.title = "EVENT COMMENTS"
        
        
    
        
        
        
        //
        eventcommentsRef = ref.child("event-comments").child(eventKey)
        
        
        
        DataService.ds.REF_BASE.child("event-comments").child(eventKey).observeEventType(.Value, withBlock:  { snapshot in
            
            
            print(snapshot.value)
            
            self.eventcomments = []
            
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    if let eventcommentDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        
                        let eventcomment = EventComment(commentKey: key, dictionary: eventcommentDict)
                        self.eventcomments.append(eventcomment)
                        
                    }
                    
                    
                }
            }
            self.tableView.reloadData()
            
        })
    }
    
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventcomments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let eventcomment = eventcomments[indexPath.row]
        print(eventcomment.commentDescription)
        
        
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("EventCommentCell")  as? EventCommentCell  {
            var img: UIImage?
            
            cell.delegate2 = self
            if let url = eventcomment.imageUrl2 {
                img = EventCommentVC.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureEventCommentCell(eventcomment, img: img, eventKey: self.eventKey)
            return cell
        } else {
            return EventCommentCell()
        }
        
        
        return tableView.dequeueReusableCellWithIdentifier("EventCommentCell") as! EventCommentCell
    }
    
    
    
    @IBAction func commentPost(sender: AnyObject) {
        
        if let txt = commentField.text where txt != "" {
            
            let uid = FIRAuth.auth()?.currentUser?.uid
            //  commentsRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            DataService.ds.REF_BASE.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                let key = DataService.ds.REF_BASE.child("event-comments").childByAutoId().key  // creating CommentKey
                
                if let uid = uid, commentField = self.commentField, user = snapshot.value as? [String : AnyObject] {
                    
                    print("Snapshot CommentVC--------: \(snapshot)")
                    
                    let time  = String(Int(NSDate().timeIntervalSince1970))
                    
                    
                    
                    let eventcomment = [
                        "uid": uid,
                        
                        //    "fullName": self.comment.fullName!,
                        "text": commentField.text!,
                        "fullName": self.profileName,
                        "avatar": self.profileImg,
                        "date" : time,
                        "commentKey": key,
                        
                    ]
                    
                    
                    
                    
                    if let doesNotExist = snapshot.value as? NSNull {
                        
                        let  EventComment_PostRef = self.ref.child("event-comments").child(self.eventKey)
                        
                        EventComment_PostRef.setValue(eventcomment)
                        
                      
                        
                        
                    } else {
                        
                        
                      //  let key = DataService.ds.REF_BASE.child("event-comments").childByAutoId().key
                        
                        // let firebaseCommentPost = DataService.ds.REF_POST_KEY.child(key)
                        let firebaseEventCommentPost = DataService.ds.REF_BASE.child("event-comments").child(self.eventKey).child(key)
                        
                        firebaseEventCommentPost.setValue(eventcomment)
                        
                        print("Firebase: no NUll ------->>>>\(firebaseEventCommentPost)")
                        // let  postID  = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
                        
                        
                        
                        let post_comment_userID_Ref =  DataService.ds.REF_BASE.child("event-comments-userID").child(self.eventKey).child(key).child(KEY_UID!)
                        post_comment_userID_Ref.setValue(true)   // delete it once it delete btn is pressed - needed
                        
                        DataService.ds.REF_BASE.child("post-commentsOnly").child(self.eventKey).child(key).setValue(true)
                        //*****NOTIFICATION*******
                        
                        
                        let notificationKey = "N\(key)"  /// notificationKey is the same number of the commentKey but with and N before the number
                        print("notificationKEy  :  \(notificationKey)")
                        
                        //postKey = eventKey here
                        
                        let notification = [
                            "uid": KEY_UID,
                            "fullName": self.profileName,
                            "avatar": self.profileImg,
                            "date" : time,
                            "postKey" : self.eventKey,
                            "commentID": key,
                            "type": "HAS COMMENTED ON YOUR EVENT",
                            "notificationKey": notificationKey,
                        ]
                        
                        
                        
                        if self.eventUid != KEY_UID {
                            
                            print("EVENTUID: \(self.eventUid)")
                            
                            DataService.ds.REF_BASE.child("notifications").child(self.eventUid!).child(notificationKey).setValue(notification)
                            DataService.ds.REF_BASE.child("notifications-postUID").child(self.eventUid!).child(notificationKey).setValue(true)
                            
                            
                        } else {
                            // do nothing
                            
                        }
                        
                        
                        //**END NOTIFICATION**
                        
                        
                    }
                    commentField.text = ""
                    self.tableView.reloadData()
                    
                    
                    
                    
                }
            })
            
            
            commentField.resignFirstResponder()
            
        } else {
            
            typeInSomethingAlert()
        }
        
    }
    
    
    func typeInSomethingAlert(){
        let optionMenu = UIAlertController(title: nil, message: "Type in something!", preferredStyle: .ActionSheet)
        
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    
    
    //Keyboard dismiss
    func hideKeyboard()
    {
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        
        //tableViewHeightConstraint.constant = tableView.contentSize.height
        
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        //Catch notification if the keyboard is hsown or hidden
        
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: Selector("keyboardWillShow:"),
                                                         name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: Selector("keyboardWillHide:"),
                                                         name: UIKeyboardWillHideNotification, object: nil)
        
        
    }
    
    func QueryCurrentUser(){
        
        DataService.ds.REF_USER_CURRENT.observeEventType(.Value, withBlock: { (snapshot)  in
            
            let item = snapshot as FIRDataSnapshot
            print("SNAP-Itemxxxxxxxxxxx: \(item)")
            
            // if let dict = item.value as? NSDictionary{
            
            if let dict = item.value as? [String : AnyObject]{
                let avatar = dict["avatar"] as! String
                // self.image = avatar
                
                self.activeUserInfo = dict
                
                self.profileName = "\(self.activeUserInfo!["fullName"]!.uppercaseString!)"
                self.profileImg = "\(self.activeUserInfo!["avatar"]!)"
               
            }
            
            
            }, withCancelBlock: {(error) -> Void in
                
        })
        
    }
    
    func QueryEventPosts(){
        
        print("Event Key inside : \(self.eventKey)")
        
        DataService.ds.REF_BASE.child("events").child(self.eventKey).observeEventType(.Value , withBlock: { (snapshot) in  //observeSingleEventOfType
            
            //postInfo
            
            let item = snapshot as FIRDataSnapshot
            print("SNAP-Itemx-EVent: \(item)")
            
            
            if let dict = item.value as? [String : AnyObject]{
               
                 self.eventInfo = dict
                
               
              self.eventUid =   self.eventInfo!["host-uid"]! as! String
              self.eventKEY =   self.eventInfo!["eventKey"]! as! String
                
                
            }
            
            }, withCancelBlock: {(error) -> Void in
                
        })
    }
    
    
    
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.textFieldToBottomLayoutGuideConstraint?.constant += keyboardSize.height
            
            var keyboardHeight = keyboardSize.height
            
            
            
            
            
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.textFieldToBottomLayoutGuideConstraint?.constant -= keyboardSize.height
            
            //  self.keyboardHeight = keyboardSize.height
            
            
            
        }
    }
    
    
    func getKeyboardHeight( notification : NSNotification ) -> CGFloat {
        return (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue().height
    }
    
    
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        
        animateViewMoving(true, moveValue: 260)   // 260
    }
    
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        
        animateViewMoving(false, moveValue: 260)    //260
    }
    
    // Lifting the view up
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
    
    func ContactIDEventCommentSegueFromCell(contactID dataobject: AnyObject) {
        
        dispatch_async(dispatch_get_main_queue()){
            //try not to send self, just to avoid retain cycles(depends on how you handle the code on the next controller)
            self.performSegueWithIdentifier("segue_commentVC_to_ContactProfileVC", sender:dataobject )
            
        }
        
        // print( "Segue Agosto 1xxxxx: \(contactId)")
        //
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segue_commentVC_to_ContactProfileVC"
        {
            let destinationVC = segue.destinationViewController as? contactProfileVC
            if let theString = sender as? String {
                destinationVC!.contactId =  theString
            }
            
            
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        commentField.resignFirstResponder()
        
        return true
    }
    
    
    
}






