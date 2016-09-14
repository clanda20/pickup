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
    
    //
    var keyboardHeight: CGFloat!
    
    //variable to hold keyboard frame
    // var keyboard = CGRect()
    
    
    // values for seting UI to default
    //    var tableViewHeight : CGFloat = 0
    //   var commentY : CGFloat = 0
    //   var commentHeight : CGFloat = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //  tableView.backgroundColor = .redColor()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //   self.sendBtn.delegate = self
        self.commentField.delegate = self
        
        
        //Keyboard dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard"))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
        
        QueryCurrentUser()
        //  alignment()
        
        //title at the top
        self.navigationItem.title = "EVENT COMMENTS"
        
        
        //disable button from the beginning
        //  sendBtn.enabled = false
        
        //
        
        
        
      //  postID  = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String   // postkey  change for eventKEy
        
        
        
        //
        eventcommentsRef = ref.child("event-comments").child(eventKey)
        
        
        //   print("Value Postkey3:------------>>>> \(postID)")
        
        
     //9-5   DataService.ds.REF_POST_KEY.observeEventType(.Value, withBlock:  { snapshot in  //let postKey = URL_BASE.child("post-comments").child(postID)
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
        
        let uid = FIRAuth.auth()?.currentUser?.uid
       
        
        DataService.ds.REF_BASE.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            
            if let uid = uid, commentField = self.commentField, user = snapshot.value as? [String : AnyObject] {
                
                print("Snapshot CommentVC--------: \(snapshot)")
                let eventcomment = [
                    "uid": uid,
                    
                    //    "fullName": self.comment.fullName!,
                    "text": commentField.text!,
                    "fullName": self.profileName,
                    "avatar": self.profileImg,
                ]
                
                
                
                
                if let doesNotExist = snapshot.value as? NSNull {
                    
                  //  let  postID  = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
                    
                    let  EventComment_PostRef = self.ref.child("event-comments").child(self.eventKey)
                    
                    EventComment_PostRef.setValue(eventcomment)
                    
                    
                    
                    //   self.user_commentRef = DataService.ds.REF_BASE.child("user-comments").child(KEY_UID!).child(postID)
                    
                    //  self.user_commentRef?.setValue(true)
                    
                    
                } else {
                    
                    
                    let key = DataService.ds.REF_BASE.child("event-comments").childByAutoId().key
                    
                   // let firebaseCommentPost = DataService.ds.REF_POST_KEY.child(key)
                    let firebaseEventCommentPost = DataService.ds.REF_BASE.child("event-comments").child(self.eventKey).child(key)
                    
                    firebaseEventCommentPost.setValue(eventcomment)
                    
                    print("Firebase: no NUll ------->>>>\(firebaseEventCommentPost)")
                   // let  postID  = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
                    
                    
                    
                    let post_comment_userID_Ref =  DataService.ds.REF_BASE.child("event-comments-userID").child(self.eventKey).child(key).child(KEY_UID!)
                    post_comment_userID_Ref.setValue(true)   // delete it once it delete btn is pressed - needed
                }
                commentField.text = ""
                self.tableView.reloadData()
            }
        })
        
    }
    
    
    
    
    
    //Keyboard dismiss
    func hideKeyboard()
    {
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        super.viewWillDisappear(animated)
        
        
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
                
                // self.title = "Welcome \(self.activeUserInfo!["firstName]!)"
                self.profileName = "\(self.activeUserInfo!["fullName"]!.uppercaseString!)"
                self.profileImg = "\(self.activeUserInfo!["avatar"]!)"
                // self.followersLabel.text = " \(self.activeUserInfo!["followers"]!) \n followers"
                // self.followingLabel.text = " \(self.activeUserInfo!["following"]!) \n following"
                
                
                
            }
            
            
            
            //   completation(imageStr: image!)
            
            }, withCancelBlock: {(error) -> Void in
                
        })
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.textFieldToBottomLayoutGuideConstraint?.constant += keyboardSize.height
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
    
    // deinit {
    //   NSNotificationCenter.defaultCenter().removeObserver(self)
    // }
    func textFieldDidBeginEditing(textField: UITextField) {
        
        // getKeyboardHeight(notification)
        
        animateViewMoving(true, moveValue: 270)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        animateViewMoving(false, moveValue: 270)
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
    
}






