//
//  CommentVC.swift
//  pickup
//
//  Created by christian landa on 6/22/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseMessaging
import FirebaseStorage



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
    var value:  DatabaseReference!
   lazy var ref: DatabaseReference = Database.database().reference()
   
 
    var commentsRef: DatabaseReference!
    var firebaseCommentPost2 : DatabaseReference!
    var user_commentRef: DatabaseReference!

    var activeUserInfo: NSDictionary?
    var postInfo: NSDictionary?
    
    
    
    var profileName: String!
    var profileImg: String!
    
     static var imageCache = NSCache<AnyObject, AnyObject>()
    
    var posts = [Post]()
   var post: Post!
    
    var postUid: String!
  
    var postArray: [String] = []

   var postDictionary = [String: String]()
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 80.0;
         self.tableView.rowHeight = UITableView.automaticDimension;
        
        
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.tableView.contentInset = UIEdgeInsets.init(top: 20, left: 0, bottom: 0, right: 0)
        
     

        tableView.delegate = self
        tableView.dataSource = self
        
     //   self.sendBtn.delegate = self
         self.commentField.delegate = self
        
  
       //Keyboard dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CommentVC.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
        
        QueryCurrentUser()
       
        
       //title at the top
        self.navigationItem.title = "COMMENTS"
        
        
       
       
        
        postID  = UserDefaults.standard.value(forKey: "postKey") as! String
    
        
        
   //
        commentsRef = ref.child("post-comments").child(postID)
        

   
     DataService.ds.REF_POST_KEY.observe(.value, with:  { snapshot in
        
    
            // print(snapshot.value)
        
             self.comments = []
            

            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                
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
    
 

//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let comment = comments[indexPath.row]
       // print(comment.commentDescription)
        
        
      
        
    
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell")  as? CommentCell  {
             var img: UIImage?
            
             cell.delegate2 = self            
            if let url = comment.imageUrl2 {
                img = CommentVC.imageCache.object(forKey: url as AnyObject) as? UIImage
            }
            
            cell.configureCommentCell(comment: comment, img: img )
            return cell
        } else {
            return CommentCell()
        }
        
        
        return tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
    }
    
    

    @IBAction func commentPost(sender: AnyObject) {
        
      if let txt = commentField.text, txt != "" {
        
        let uid = Auth.auth().currentUser?.uid
  
            
       DataService.ds.REF_BASE.observeSingleEvent(of: .value, with: { (snapshot) in
        
    
            if let uid = uid, let commentField = self.commentField, let user = snapshot.value as? [String : AnyObject] {
                
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
                    
                   let  postID  = UserDefaults.standard.value(forKey: "postKey") as! String
                    
                 let  Comment_PostRef = self.ref.child("post-comments").child(postID)

                 Comment_PostRef.setValue(comment)
                    
              
                    
                    
                } else {
                    
                  
                    
                    let  postID  = UserDefaults.standard.value(forKey: "postKey") as! String

                    guard let key = DataService.ds.REF_BASE.child("post-comments").childByAutoId().key else {
                        return
                    }
                    
                  
                    
                    
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
        let optionMenu = UIAlertController(title: nil, message: "Type in something!", preferredStyle: .actionSheet)
        
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
   
    
    //Keyboard dismiss
    @objc func hideKeyboard()
    {
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       
        super.viewWillDisappear(animated)
        
         self.navigationController?.setNavigationBarHidden(true, animated: animated);
        
        //tableViewHeightConstraint.constant = tableView.contentSize.height

        
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
       
        QueryPosts()
        //Catch notification if the keyboard is hsown or hidden
        
        
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(CommentVC.keyboardWillShow(_:)),
                                                         name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(CommentVC.keyboardWillHide(_:)),
                                                         name: UIResponder.keyboardWillHideNotification, object: nil)
        

    }
    
    
  /*  func QueryMyNotificationTimeline(){
        
        //  FanoutMyFollowing()
        
        // for followingIDx in self.following_Array {
        
        postID  = NSUserDefaults.standardUserDefaults().valueForKey("postKey") as! String
        
        DataService.ds.REF_BASE.child("post-notifications").child(postID).observeEventType(.Value , withBlock: { (snapshot) in  //observeSingleEventOfType
            
            print("xxxxxxxxxxxxxxxx: \(snapshot.value)")
            
            self.notifications = []
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]  {
                
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
    
    func QueryPosts(){
        
        let  postID  = UserDefaults.standard.value(forKey: "postKey") as! String

        
        DataService.ds.REF_BASE.child("posts").child(postID).observe(.value , with: { (snapshot) in  //observeSingleEventOfType
            
            //postInfo
            
            let item = snapshot as DataSnapshot
            print("SNAP-Itemxxxxxxxxxxx: \(item)")
            
            // if let dict = item.value as? NSDictionary{
            
            if let dict = item.value as? [String : AnyObject]{
                //  let avatar = dict["avatar"] as! String
                // self.image = avatar
                
                self.postInfo = dict as NSDictionary?
                
                // self.title = "Welcome \(self.activeUserInfo!["firstName]!)"
                self.postUid = "\(self.postInfo!["uid"]!)"
                // self.profileImg = "\(self.activeUserInfo!["avatar"]!)"
                // self.followersLabel.text = " \(self.activeUserInfo!["followers"]!) \n followers"
                // self.followingLabel.text = " \(self.activeUserInfo!["following"]!) \n following"
                
                
                
            }
            
            
            
            //   completation(imageStr: image!)
            
        }, withCancel: {(error) -> Void in
                
        })
    }
    
    
    
      
    
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.textFieldToBottomLayoutGuideConstraint?.constant += keyboardSize.height
            
           var keyboardHeight = keyboardSize.height
            
          
            
            
            
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.textFieldToBottomLayoutGuideConstraint?.constant -= keyboardSize.height
            
          //  self.keyboardHeight = keyboardSize.height
            
            
            
        }
    }
    
    
    func getKeyboardHeight( notification : NSNotification ) -> CGFloat {
        return (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.height
    }
    
    

   
   func textFieldDidBeginEditing(_ textField: UITextField) {
        
    
        animateViewMoving(up: true, moveValue: 260)   // 260
    }
    
   
    
   func textFieldDidEndEditing(_ textField: UITextField) {
    
        
     
        animateViewMoving(up: false, moveValue: 260)    //260
    }
    
    // Lifting the view up
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    
    func ContactIDCommentSegueFromCell(contactID dataobject: AnyObject) {
        
        DispatchQueue.main.async(){
            //try not to send self, just to avoid retain cycles(depends on how you handle the code on the next controller)
            self.performSegue(withIdentifier: "segue_commentVC_to_ContactProfileVC", sender:dataobject )
            
        }
        
        // print( "Segue Agosto 1xxxxx: \(contactId)")
        //
    }
     override func prepare(for forsegue: UIStoryboardSegue, sender: Any?) {
        if forsegue.identifier == "segue_commentVC_to_ContactProfileVC"
        {
            let destinationVC = forsegue.destination as? contactProfileVC
            if let theString = sender as? String {
                destinationVC!.contactId =  theString
            }
            
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        commentField.resignFirstResponder()
       
        return true
    }
   

    
}





