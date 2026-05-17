//
//  EventCommentVC.swift
//  pickup
//
//  Created by christian landa on 9/5/16.
//  Copyright © 2016 christian landa. All rights reserved.
//  //segue_EventCommentVC

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseMessaging
import FirebaseStorage



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
    var value:  DatabaseReference!
    lazy var ref: DatabaseReference = Database.database().reference()
    
    
    var eventcommentsRef: DatabaseReference!
    var firebaseCommentPost2 : DatabaseReference!
    var user_commentRef: DatabaseReference!
    
    var activeUserInfo: NSDictionary?
    var profileName: String!
    var profileImg: String!
    
    static var imageCache = NSCache<AnyObject, AnyObject>()
    
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
        self.tableView.rowHeight = UITableView.automaticDimension;
        
        
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.tableView.contentInset = UIEdgeInsets.init(top: 20, left: 0, bottom: 0, right: 0)
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //   self.sendBtn.delegate = self
        self.commentField.delegate = self
        
        
        //Keyboard dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EventCommentVC.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
         QueryEventPosts()
        QueryCurrentUser()
       
        //  alignment()
        
        //title at the top
        self.navigationItem.title = "EVENT COMMENTS"
        
        
    
        
        
        
        //
        eventcommentsRef = ref.child("event-comments").child(eventKey)
        
        
        
        DataService.ds.REF_BASE.child("event-comments").child(eventKey).observe(.value, with:  { snapshot in
            
            
            print(snapshot.value)
            
            self.eventcomments = []
            
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                
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
    
    
    
    
  //  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    
    func numberOfSections(in tableView: UITableView) -> Int {
     
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    return eventcomments.count
    }
    
  //  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath-> UITableViewCell {
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let eventcomment = eventcomments[indexPath.row]
   //     print(eventcomment.commentDescription ?? <#default value#>)
        
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "EventCommentCell")  as? EventCommentCell  {
            var img: UIImage?
            
            cell.delegate2 = self
            if let url = eventcomment.imageUrl2 {
                img = EventCommentVC.imageCache.object(forKey: url as AnyObject) as? UIImage
            }
            
            cell.configureEventCommentCell(eventcomment: eventcomment, img: img, eventKey: self.eventKey)
            return cell
        } else {
            return EventCommentCell()
        }
        
        
        return tableView.dequeueReusableCell(withIdentifier: "EventCommentCell") as! EventCommentCell
    }
    
    
    
    @IBAction func commentPost(sender: AnyObject) {
        
        if let txt = commentField.text, txt != "" {
            
            let uid = Auth.auth().currentUser?.uid
            //  commentsRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            DataService.ds.REF_BASE.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let key = DataService.ds.REF_BASE.child("event-comments").childByAutoId().key else {
                    return
                }
                
                if let uid = uid, let commentField = self.commentField, let user = snapshot.value as? [String : AnyObject] {
                    
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
                    
                    
                    
                    
                    if (snapshot.value as? NSNull) != nil {
                        
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
                            "checked": "no",
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
        
        //Catch notification if the keyboard is hsown or hidden
        
        
        NotificationCenter.default.addObserver(self,
                                                         selector: Selector(("keyboardWillShow:")),
                                                         name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                                         selector: Selector(("keyboardWillHide:")),
                                                         name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
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
                
                self.profileName = "\((self.activeUserInfo!["fullName"]! as AnyObject).uppercased!)"
                self.profileImg = "\(self.activeUserInfo!["avatar"]!)"
                
            }
            
            
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
                
                self.eventInfo = dict as NSDictionary?
                
                
                self.eventUid =   self.eventInfo!["host-uid"]! as! String
                self.eventKEY =   self.eventInfo!["eventKey"]! as! String
                
                
            }
            
        }, withCancel: {(error) -> Void in
                
        })
    }
    
    
    
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.textFieldToBottomLayoutGuideConstraint?.constant += keyboardSize.height
            
            var keyboardHeight = keyboardSize.height
            
            
            
            
            
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
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
    
    
    func ContactIDEventCommentSegueFromCell(contactID dataobject: AnyObject) {
        
        DispatchQueue.main.async  {
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





