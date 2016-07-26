//
//  FeedVCViewController.swift
//  pickup
//
//  Created by christian landa on 5/24/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Photos
import FirebaseAuth
import FirebaseStorage
import Alamofire

import FirebaseDatabaseUI
import FirebaseAuthUI


class FeedVC: UIViewController, UITableViewDelegate,UITextFieldDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PostCellDelegate {
    
   @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
   @IBOutlet weak var imageSelectorImage: UIImageView!
    
    var imageData = NSData()
    var imageSaved: String?
    
    
    var postKey: String!
    
    var myData:String?
    
    
    let kSectionComments = 1
    let kSectionPost = 0
    
    
//    @IBOutlet weak var commentField: MaterialTextField!
  // @IBOutlet weak var commentBtn: UIButton!
    
    var imagePicker: UIImagePickerController!
    
    //var dataSource: FirebaseTableViewDataSource?
    var post: Post!
    
    var imageSelected = false
    
    var posts = [Post]()
    static var imageCache = NSCache()
    var image: UIImage!
    let imagePC = UIImagePickerController()
    var popover:UIPopoverController? = nil
    var referenceUrl: AnyObject!
    
    var storageRef:FIRStorageReference!
    
    var delegate:PostCellDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 358
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let storage = FIRStorage.storage()
        storageRef = storage.referenceForURL("gs://pickup-9b67a.appspot.com")
        
        //Enable offline capabilities 
        
      //  FIRDatabase.database().persistenceEnabled = true
        
        //Dismiss Keyboard
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard"))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
        
        
        
        self.postField.delegate = self
       
        self.tableView.reloadData()
       QueryMyFriendsPost()
        
        
       
            
        
        
        
        DataService.ds.REF_USER_POST.observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
            
            self.tableView.reloadData()
        })
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        QueryMyFriendsPost()        
        
        
    }
    
    
    
    
    
    
    
    
        func QueryMyFriendsPost() {
            // self.posts = []
            
            DataService.ds.REF_USER_CURRENT.child("followings").observeEventType(.ChildAdded, withBlock:{ snapshots2 in
                //for snapshot2 in snapshots2.children {
                
                self.posts = []
                print("new wayxx: \(snapshots2)")
                
              // if snapshot.childrenCount > 0  {
                    
                let friendID = snapshots2.key
                
                let friendReference = DataService.ds.REF_USER_POST.child(friendID)
                
                
                
                friendReference.observeEventType(.Value , withBlock: { (snapshot) in  //observeSingleEventOfType
                 //  self.posts = []
                    
                    print("new way 2: \(snapshot)")
                    
                   
                        
                        
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]  {
                        
                     // if let snapshots = snapshot.value as? [FIRDataSnapshot]  {
                        
                        for snap in snapshots {
                            print("SNAP: \(snap)")
                            
                            //  if  let postDict = snapshot.value as? Dictionary <String, AnyObject> {
                            
                            if let postDict = snap.value as? [String : AnyObject]  {
                                
                                
                                let key = snap.key
                                let post = Post(postKey: key, dictionary: postDict)
                                
                                
                                
                                self.posts.append(post)
                                print("SNAP post1xxxxxx: \(postDict)")
                                
                                                            }
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                self.tableView.reloadData()
                            })
                        }
                        
                        
                        
                    }
                    
                   dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                    
                    
                    
                }, withCancelBlock: nil)
               // }// loop to childrencount > 0
            // self.tableView.reloadData()
                
         //   }
            
                }, withCancelBlock: nil)
        }
    
 /*   override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        self.runAfterDelay(2) {
            self.performSegueWithIdentifier("segue_commentVC", sender: self)
        }
    } */
 
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        return tableView.reloadData()
    }
   
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]  //keys are stored here

        
        if let cell =  tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            
            cell.delegate = self // july 7, 2016
            
        //    NSUserDefaults.standardUserDefaults().setValue(post.uid, forKey: "post_userID")
         //   NSUserDefaults.standardUserDefaults().synchronize()

            
           // cell.commentBtn.tag = indexPath.row
           // cell.commentBtn.addTarget(self, action: "runAfterDelay(delay):", forControlEvents: .TouchUpInside)
          
            cell.request?.cancel()
            
            var img: UIImage?
            
            if let url = post.imageUrl {
               img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            
            
         
            
            print("PostKEY-Outside----------------------: \(post.postKey)")
            cell.configureCell(post, img: img)
            
            //let postKey =  post.postKey
            
           print("SNaps July 6 :\(post.postKey)")
           print("SNaps July 24 :\(post.uid)")
            
            //self.tableView.reloadData()
            
            return cell
            
        }else {
            return PostCell()
        }
    }
    
  

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 150
        }else{
            return tableView.estimatedRowHeight
        }
    }
    
    
    
    @IBAction func makePost(sender: AnyObject) {
        
        imageSelected = true
        
        
        if let txt = postField.text where txt != "" {
        
        if let img = imageSelectorImage.image where imageSelected == true {
            
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
            self.tableView.reloadData()
        
        // let avatarRef = DataService.ds.REF_USER_CURRENT
        
       // let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\("userPhoto")"
      //  let imageFile = contentEditingInput?.fullSizeImageURL
        let filePath = FIRAuth.auth()!.currentUser!.uid + "/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000))"
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.child(filePath).putData(imageData, metadata: metaData){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                
                return
            }else{
                //store downloadURL
                let downloadURL = metaData!.downloadURL()!.absoluteString
                //store downloadURL at database
               // DataService.ds.REF_USER_POSTS_USERID .updateChildValues(["avatar": downloadURL])
                self.postToFirebase( downloadURL)
                self.tableView.reloadData()
                print("LINK_URLString: \(downloadURL)")
                            }
            
          
            
            
        }
   
        }
    }
        }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        
        
        referenceUrl = info[UIImagePickerControllerReferenceURL]
         image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageSelectorImage.image = image
        //  var imageData = NSData()
        
        imageData = UIImageJPEGRepresentation(image, 0.2)!
        imageSaved = imageData.base64EncodedStringWithOptions([])
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func  selectImage(sender: UITapGestureRecognizer) {
       // presentViewController(imagePicker, animated: true, completion: nil)
        
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
        {
            UIAlertAction in
        }
        // Add the actions
        self.imagePC.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the controller
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            popover = UIPopoverController(contentViewController: alert)
            popover!.presentPopoverFromRect(imageSelectorImage.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
        
    }

    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            self.imagePC.sourceType = UIImagePickerControllerSourceType.Camera
            self .presentViewController(self.imagePC, animated: true, completion: nil)
        }
        else
        {
            openGallary()
        }
    }
    
    
    func openGallary()
    {
        self.imagePC.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(self.imagePC, animated: true, completion: nil)
        }
        else
        {
            popover=UIPopoverController(contentViewController: self.imagePC)
            popover!.presentPopoverFromRect(imageSelectorImage.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    
    func postToFirebase(imgUrl: String?){
        
         let  activeUserId  = NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String
        var post: Dictionary<String, AnyObject> = [
            "description": postField.text!,
            "likes": 0,
            "dislikes": 0,
            "uid":  activeUserId,
          //  "comment": commentBtn.!
        ]
        
        if imgUrl != nil {
            post["imageUrl"] = imgUrl
        }
        
   
        
     let firebasePost2 = DataService.ds.REF_USER_POSTS_USERID.childByAutoId()  //important ojo
       firebasePost2.setValue(post)
        
        
        postField.text = ""
      //  commentBtn.text = ""
        imageSelectorImage.image = UIImage(named: "camera")
        imageSelected = false
        
        tableView.reloadData()
    }
    
 
    
    
    func uploadSuccess(metadata: FIRStorageMetadata, storagePath: String) {
        print("Upload Succeeded!")
        //  self.urlTextView.text = metadata.downloadURL()!.absoluteString
        NSUserDefaults.standardUserDefaults().setObject(storagePath, forKey: "storagePath")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.tableView.reloadData()
        // self.downloadPicButton.enabled = true
    }
    
  
    
    //MARK: - PostCellDelegator Methods
    
    func callSegueFromCell(myData dataobject: AnyObject) {
        
        

        //try not to send self, just to avoid retain cycles(depends on how you handle the code on the next controller)
        self.performSegueWithIdentifier("segue_commentVC", sender:dataobject )
        
    }
    // Dismiss keyBoard
    
    func hideKeyboard()
    {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
    
    
}


























