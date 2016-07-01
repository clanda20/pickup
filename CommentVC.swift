//
//  CommentVC.swift
//  pickup
//
//  Created by christian landa on 6/22/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Firebase



class CommentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var commentField: MaterialTextField!

   var post: Post!
    var comments = [Comment]()
   // var postKey = ""
  
    
   lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference()
   
  //  var postRef: FIRDatabaseReference!
   var commentsRef: FIRDatabaseReference!
  //  var refHandle: FIRDatabaseReference?
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
   //   postRef = ref.child("posts").child(postKey!)
        
      commentsRef = ref.child("post-comments").child("KJ4XBGxp4nJpnmWVd0Q")
        
    //    var posterRef = ref.child("poster").child(POST_KEY_ID)
        
//print("PostKey looking: \(Post.)")
    //   print("PostKey   CommentVC: \(post.postKey)")
    //   DataService.ds.REF_POSTCOMMENTS.observeEventType(.Value, withBlock:  { snapshot in
        
       commentsRef.observeEventType(.Value, withBlock:  { snapshot in
        
       // posterRef.observeEventType(.Value, withBlock: { snapshot in
             print(snapshot.value)
            
           //self.posts = []
             self.comments = []
            

            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    print("SNAP CommentVC: \(snap)")
                    
                    if let commentDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                      
                         let comment = Comment(commentKey: key, dictionary: commentDict)
                        print("SNAP Comment1: \(comment)")
                        self.comments.append(comment)
                         print("SNAP Comment2: \(commentDict)")
                        
                        print("SNAP Comment3: \(comment)")
                    }
                    
                    
                }
            }
            self.tableView.reloadData()
            
        })
    }
    
    
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
            cell.configureCommentCell(comment)
            return cell
        } else {
            return CommentCell()
        }
        
        
        return tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell
    }
    
    

    @IBAction func commentPost(sender: AnyObject) {
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("users").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let uid = uid, commentField = self.commentField, user = snapshot.value as? [String : AnyObject] {
                let comment = [
                    "uid": uid,
                  //  "author": user["username"] as! String,
                    "text": commentField.text!
                ]
                self.commentsRef.childByAutoId().setValue(comment)
                commentField.text = ""
            }
        })
        
    }
    
    
}






