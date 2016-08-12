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
  //  @IBOutlet weak var commentTxt: UITextView!
//   @IBOutlet weak var commentField: MaterialTextField!
    
    @IBOutlet var textFieldToBottomLayoutGuideConstraint: NSLayoutConstraint!

    @IBOutlet weak var commentField: UITextField!
   var comment: Comment!
    var comments = [Comment]()
   
    
    var postID: String! = ""
    var value:  FIRDatabaseReference!
   lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference()
   
 
    var commentsRef: FIRDatabaseReference!
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
        self.navigationItem.title = "COMMENTS"
        
        
        //disable button from the beginning
      //  sendBtn.enabled = false
        
            //
        
       
        
        postID  = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
    
        
        
   //
        commentsRef = ref.child("post-comments").child(postID)
        

   //   print("Value Postkey3:------------>>>> \(postID)")
        
   
     DataService.ds.REF_POST_KEY.observeEventType(.Value, withBlock:  { snapshot in
        
    //  commentsRef.observeEventType(.Value, withBlock:  { snapshot in
        
       // posterRef.observeEventType(.Value, withBlock: { snapshot in
             print(snapshot.value)
            
           //self.posts = []
             self.comments = []
            

            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                   // print("SNAP CommentVC: \(snap)")
                    
                    if let commentDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                      
                         let comment = Comment(commentKey: key, dictionary: commentDict)
                      //  print("SNAP Comment1: \(comment)")
                        self.comments.append(comment)
                       //  print("SNAP Comment2: \(commentDict)")
                        
                       // print("SNAP Comment3: \(comment)")
                    }
                    
                    
                }
            }
            self.tableView.reloadData()
            
        })
    }
    
    // 
   /* func alignment(){
    
    let width  = self.view.frame.size.width
    let height = self.view.frame.size.height
        
    
    tableView.frame = CGRectMake(0, 0, width, height / 1.096 - self.navigationController!.navigationBar.frame.size.height - 20)
    tableView.estimatedRowHeight = width / 5.3333
    tableView.rowHeight = UITableViewAutomaticDimension
        
    commentTxt.frame = CGRectMake(10, tableView.frame.size.height + height / 56.9, width / 1.306, 33)
    commentTxt.layer.cornerRadius = commentTxt.frame.size.width / 50
        
    sendBtn.frame = CGRectMake(commentTxt.frame.origin.x + commentTxt.frame.size.width + width / 32, commentTxt.frame.origin.y,
                               width - ( commentTxt.frame.origin.x + commentTxt.frame.size.width) - (width / 32) * 2, commentTxt.frame.size.height)
     
    tableViewHeight = tableView.frame.size.height
    commentHeight = commentTxt.frame.size.height
    commentY = commentTxt.frame.origin.y
        
    }  */
    
    // func loading when keyboard is shown
   // func keyboarWillShow(notification: NSNotification){

      //  self.view.frame.origin.y = -150
        
      /*  let userInfo : NSDictionary = notification.userInfo!
        
        //define keyboard frame size
        
        let keyboardSize : CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue().size
        
        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue().size
       // keyboard = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]!.CGRectValue)!.size
        
        if keyboardSize.height == offset.height {
            if self.view.frame.origin.y == 0 {
                UIView.animateWithDuration(0.15, animations: { 
                    self.view.frame.origin.y -= keyboardSize.height
                })
            }
        }
        else {
            UIView.animateWithDuration(0.15, animations: { 
                self.view.frame.origin.y += keyboardSize.height - offset.height
            })
            
        }
        
        //move UI up
        
     /*   UIView.animateWithDuration(0.4){
            self.tableView.frame.size.height = self.tableViewHeight - self.keyboard.height - self.commentTxt.frame.size.height + self.commentHeight
            
            self.commentTxt.frame.origin.y = self.commentY - self.keyboard.height - self.commentHeight
            
            self.sendBtn.frame.origin.y = self.commentTxt.frame.origin.y
      */  }   */
 //   }
    
    // func loading when keyboar is hidden
  /*  func keyboarWillHide(notification: NSNotification) {
        
        self.view.frame.origin.y = 0
        
     /*   let userInfo : NSDictionary = notification.userInfo!
         let keyboardSize : CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue().size
        
        self.view.frame.origin.y += keyboardSize.height  */

        
        // move UI down
      /*  UIView.animateWithDuration(0.4) { () -> Void in
            self.tableView.frame.size.height = self.tableViewHeight
            self.commentTxt.frame.origin.y = self.commentY
            self.sendBtn.frame.origin.y = self.commentY
        
        
        }  */
    }
 */
    
    
    
  /* override func viewWillAppear(animated: Bool) {
        postKey = self.postkey
    } */

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let comment = comments[indexPath.row]
        print(comment.commentDescription)
        
        
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell")  as? CommentCell  {
             var img: UIImage?
            
             cell.delegate2 = self            
            if let url = comment.imageUrl2 {
                img = CommentVC.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCommentCell(comment, img: img)
            return cell
        } else {
            return CommentCell()
        }
        
        
        return tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell
    }
    
    

    @IBAction func commentPost(sender: AnyObject) {
        
        let uid = FIRAuth.auth()?.currentUser?.uid
  //  commentsRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
       DataService.ds.REF_BASE.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
        
    
            if let uid = uid, commentField = self.commentField, user = snapshot.value as? [String : AnyObject] {
                
                print("Snapshot CommentVC--------: \(snapshot)")
                let comment = [
                    "uid": uid,
                    
                //    "fullName": self.comment.fullName!,
                    "text": commentField.text!,
                    "fullName": self.profileName,
                    "avatar": self.profileImg,
                ]
              
                
               
                
                if let doesNotExist = snapshot.value as? NSNull {
                    
                   let  postID  = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
                    
                 let  Comment_PostRef = self.ref.child("post-comments").child(postID)

                 Comment_PostRef.setValue(comment)
                    
                 
                    
                 //   self.user_commentRef = DataService.ds.REF_BASE.child("user-comments").child(KEY_UID!).child(postID)
                    
                  //  self.user_commentRef?.setValue(true)
                    
                    
                } else {
                    
              
                    let key = DataService.ds.REF_BASE.child("post-comments").childByAutoId().key
                    
                    let firebaseCommentPost = DataService.ds.REF_POST_KEY.child(key)
                    
                    firebaseCommentPost.setValue(comment)
                    
                    print("Firebase: no NUll ------->>>>\(firebaseCommentPost)")
                    let  postID  = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
                    
                   // self.user_commentRef = DataService.ds.REF_BASE.child("user-comments").child(KEY_UID!).child(key)
                    
                    //self.user_commentRef?.setValue(true)
                    
                    let post_comment_userID_Ref =  DataService.ds.REF_BASE.child("post-comments-userID").child(postID).child(key).child(KEY_UID!)
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
   
}






