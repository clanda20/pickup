//
//  CommentVC.swift
//  pickup
//
//  Created by christian landa on 6/22/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Firebase



class CommentVC: UIViewController, UITableViewDelegate, UITextFieldDelegate, UITableViewDataSource,ContactIDCommentCellDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var sendBtn: UIButton!
 
    
    @IBOutlet var textFieldToBottomLayoutGuideConstraint: NSLayoutConstraint!

    @IBOutlet weak var commentField: UITextField!
   var comment: Comment!
    var comments = [Comment]()
   
    var notification: Notification!
    var notifications = [Notification]()
    
    var postID: String! = ""
    var value:  FIRDatabaseReference!
   lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference()
   
 
    var commentsRef: FIRDatabaseReference!
    var firebaseCommentPost2 : FIRDatabaseReference!
    var user_commentRef: FIRDatabaseReference!

    var activeUserInfo: NSDictionary?
    var postInfo: NSDictionary?
    
    
    
    var profileName: String!
    var profileImg: String!
    
     static var imageCache = NSCache()
    
    var posts = [Post]()
   var post: Post!
    
    var postUid: String!
  
    var postArray: [String] = []

   var postDictionary = [String: String]()
    
    


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
        
        QueryCurrentUser()
       
        
       //title at the top
        self.navigationItem.title = "COMMENTS"
        
        
       
       
        
        postID  = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
    
        
        
   //
        commentsRef = ref.child("post-comments").child(postID)
        

   
     DataService.ds.REF_POST_KEY.observeEventType(.Value, withBlock:  { snapshot in
        
    
             print(snapshot.value)
        
             self.comments = []
            

            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    if let commentDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                      
                         let comment = Comment(commentKey: key, dictionary: commentDict)
                        self.comments.append(comment)
                        
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
        return comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let comment = comments[indexPath.row]
       // print(comment.commentDescription)
        
        
      
        
    
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell")  as? CommentCell  {
             var img: UIImage?
            
             cell.delegate2 = self            
            if let url = comment.imageUrl2 {
                img = CommentVC.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCommentCell(comment, img: img )
            return cell
        } else {
            return CommentCell()
        }
        
        
        return tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell
    }
    
    

    @IBAction func commentPost(sender: AnyObject) {
        
      if let txt = commentField.text where txt != "" {
        
        let uid = FIRAuth.auth()?.currentUser?.uid
  
            
       DataService.ds.REF_BASE.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
        
    
            if let uid = uid, commentField = self.commentField, user = snapshot.value as? [String : AnyObject] {
                
                print("Snapshot CommentVC--------: \(snapshot)")
                
                let time  = String(Int(NSDate().timeIntervalSince1970))
                
            /*    var dateFormatter = NSDateFormatter()
                
                dateFormatter.dateFormat = "E, d MMM yyyy hh:mm a"
                self.strDate = dateFormatter.stringFromDate(datePicker.date)
                self.dateBtn.setTitle(strDate, forState: .Normal)
                
                self.dateRaw = String(datePicker.date)  */

                
                
                let comment = [
                    "uid": uid,
                    
                //    "fullName": self.comment.fullName!,
                    "text": commentField.text!,
                    "fullName": self.profileName,
                    "avatar": self.profileImg,
                    "date" : time,
                    
                ]
                
              
                
                if let doesNotExist = snapshot.value as? NSNull {
                    
                   let  postID  = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
                    
                 let  Comment_PostRef = self.ref.child("post-comments").child(postID)

                 Comment_PostRef.setValue(comment)
                    
              
                    
                    
                } else {
                    
                  
                    
                    let  postID  = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String

                    let key = DataService.ds.REF_BASE.child("post-comments").childByAutoId().key  //
                    
                  
                    
                    
                    let firebaseCommentPost = DataService.ds.REF_POST_KEY.child(key)   //URL_BASE.child("post-comments").child(postID)
                    
                    
                    firebaseCommentPost.setValue(comment)
                    
                    print("Firebase: no NUll ------->>>>\(firebaseCommentPost)")
                    
                  
                    
                    let post_comment_userID_Ref =  DataService.ds.REF_BASE.child("post-comments-userID").child(postID).child(key).child(KEY_UID!)
                     post_comment_userID_Ref.setValue(true)   // delete it once it delete btn is pressed - needed
                    
                    DataService.ds.REF_BASE.child("post-commentsOnly").child(postID).child(key).setValue(true)
                    
                    //*****NOTIFICATION*******
                    
                    
                    let notificationKey = "N\(key)"  /// notificationKey is the same number of the commentKey but with and N before the number
                    print("notificationKEy  :  \(notificationKey)")
                    
                  //  NSUserDefaults.standardUserDefaults().setValue(notificationKey, forKey: "notificationKey")
                    
                    let notification = [
                        "uid": KEY_UID,
                        "fullName": self.profileName,
                        "avatar": self.profileImg,
                        "date" : time,
                        "postKey" : postID,
                        "commentID": key,
                        "type": "HAS COMMENTED ON YOUR POST",
                        "notificationKey": notificationKey,
                        "checked": "no",
                    ]
                    
       
                    
                    if self.postUid != KEY_UID {
                 
                     DataService.ds.REF_BASE.child("notifications").child(self.postUid!).child(notificationKey).setValue(notification)
                    DataService.ds.REF_BASE.child("notifications-postUID").child(self.postUid!).child(notificationKey).setValue(true)
                    
              
                    } else {
                        // do nothing
                        
                    }
                    
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
       
        QueryPosts()
        //Catch notification if the keyboard is hsown or hidden
        
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: Selector("keyboardWillShow:"),
                                                         name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: Selector("keyboardWillHide:"),
                                                         name: UIKeyboardWillHideNotification, object: nil)
        

    }
    
    
  /*  func QueryMyNotificationTimeline(){
        
        //  FanoutMyFollowing()
        
        // for followingIDx in self.following_Array {
        
        postID  = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        
        DataService.ds.REF_BASE.child("post-notifications").child(postID).observeEventType(.Value , withBlock: { (snapshot) in  //observeSingleEventOfType
            
            print("xxxxxxxxxxxxxxxx: \(snapshot.value)")
            
            self.notifications = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]  {
                
                for snap in snapshots {
                    
                    if let postDict = snap.value as? [String : AnyObject]  {
                        
                        let key = snap.key
                        let notification = Notification(notificationKey: key, dictionary: postDict)
                        
                        self.notifications.append(notification)
                        
                        
                    }
                }
            }
            // self.tableView.reloadData()
            
            }, withCancelBlock: nil)
        
    }   */

    
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
    
    func QueryPosts(){
        
        let  postID  = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String

        
        DataService.ds.REF_BASE.child("posts").child(postID).observeEventType(.Value , withBlock: { (snapshot) in  //observeSingleEventOfType
            
     //postInfo
            
            let item = snapshot as FIRDataSnapshot
            print("SNAP-Itemxxxxxxxxxxx: \(item)")
            
            // if let dict = item.value as? NSDictionary{
            
            if let dict = item.value as? [String : AnyObject]{
              //  let avatar = dict["avatar"] as! String
                // self.image = avatar
                
                self.postInfo = dict
                
                // self.title = "Welcome \(self.activeUserInfo!["firstName]!)"
                self.postUid = "\(self.postInfo!["uid"]!)"
               // self.profileImg = "\(self.activeUserInfo!["avatar"]!)"
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
    
    
    func ContactIDCommentSegueFromCell(contactID dataobject: AnyObject) {
        
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






