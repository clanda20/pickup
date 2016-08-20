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


class FeedVC: UIViewController, UITableViewDelegate,UITextFieldDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PostCellDelegate,ContactIDCellDelegate, ImageURLSegue_CellDelegate {
    
   @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
   @IBOutlet weak var imageSelectorImage: UIImageView!
    
    var imageData = NSData()
    var imageSaved: String?


    var followingsRef: FIRDatabaseReference!
   var followingsSnap: FIRDataSnapshot!
    
    var followersRef: FIRDatabaseReference!
 
    
    var postKey: String!
    
    var myData:String?
    
    var imageUrl_Segue:String?
    
    let kSectionComments = 1
    let kSectionPost = 0
    
    
//    @IBOutlet weak var commentField: MaterialTextField!
  // @IBOutlet weak var commentBtn: UIButton!
    
    var imagePicker: UIImagePickerController!
    
    //var dataSource: FirebaseTableViewDataSource?
    var post: Post!
    var usersList: Post!
    
    
    var listUser: Post!
    
    var items = [ArrayList]()
    
    var imageSelected = false
    
    var posts = [Post]()
    var listUsers = [Post]()
    var usersLists = [String]()
    
    var friendsArray: [String] = []  /// Array's list of followed
    
    var activeUserInfo: NSDictionary?
    var profileName: String!
    var profileImg: String!
    
   // var friendsArray: [String]
    
    static var imageCache = NSCache()
    var image: UIImage!
    let imagePC = UIImagePickerController()
    var popover:UIPopoverController? = nil
    var referenceUrl: AnyObject!
    
    var storageRef:FIRStorageReference!
    
  var friendID: String!
    
    var arrayList = [String]()
    
    var delegate:PostCellDelegate!
    
    var newImage: UIImage!  // to pass image to ImageShowVC
    
    
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
        
        
        
         //  self.tableView.reloadData()
     //  QueryMyFriendsPost()
        
        QueryMyTimeline()
        //FirebaseFanout()
        QueryCurrentUser()
    }

    override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
      //  FirebaseFanout({ (friendID) -> () in })
       self.navigationController?.setNavigationBarHidden(true, animated: animated)

       FirebaseFanout()
     //self.tableView.reloadData()
    }

    


    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
  self.navigationItem.setLeftBarButtonItem(nil, animated: true)
        // FirebaseFanout()
       // QueryMyTimeline()
       
        
        
    }
    
    func FirebaseFanout(){
        
        
       // followingsRef = DataService.ds.REF_FOLLOWING_USERID
       // followingsRef.observeEventType(.Value, withBlock:  { snapshot in
        followersRef = DataService.ds.REF_FOLLOWER_USERID
        followersRef.observeEventType(.Value, withBlock:  { snapshot in
            
        
            print("new snapshot array: \(snapshot.key)")
            
          
            self.friendsArray = []
            //self.usersLists = []
            
            for child in snapshot.children {
                let friendID = child.key as String
                print("friendID  Array IIIIiiiiiiiiiiiiiiiii: \(friendID)")
                
                self.friendsArray.append(friendID)
                
                _ = Post(followersList: self.friendsArray)
                
               // self.usersLists.append(usersList)
                
                for friendID in self.friendsArray {
                    print(" Array friendID tonight \(friendID)")
                }

            }
            
          
            self.tableView.reloadData()
            
            }, withCancelBlock: { (error) ->  Void in
        
    
        })
    }
    
    
    
    
    func QueryMyTimeline(){
        
        
        DataService.ds.REF_TIMELINE_POST_USERID.observeEventType(.Value , withBlock: { (snapshot) in  //observeSingleEventOfType
            //  self.posts = []
            
            print(snapshot.value)
            
            
            
            self.posts = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]  {
               // print("snapshot july 25: \(snapshot)")
                for snap in snapshots {
                 //   print("SNAP: july 26 \(snap)")
                    
                    
                    
                    if let postDict = snap.value as? [String : AnyObject]  {
                        
                        
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        
                        
                        
                        
                        //  self.contacts.insert(contact, atIndex: 0)  //self.posts.append(post)
                        self.posts.append(post)
                        
                        print("SNAP ContactsXXXXX: \(self.posts)")
                     }
                 }
            }
            self.tableView.reloadData()
            
            
            
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
            cell.delegate2 = self
            cell.delegate3 = self
            
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
            print("SNap Agost 1 Full Name:\(post.fullName)")
            
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
        
       let interval = NSDate().timeIntervalSince1970

        let time  = String(Int(NSDate().timeIntervalSince1970))
        
         let  activeUserId  = NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String
        var post: Dictionary<String, AnyObject> = [
            "description": postField.text!,
            "likes": 0,
            "dislikes": 0,
            "uid":  activeUserId,
            "fullName": self.profileName,
            "avatar": self.profileImg,
            "time" : time,
            //  "comment": commentBtn.!
        ]
        
        if imgUrl != nil {
            post["imageUrl"] = imgUrl
        }
        
   //From Here  
    

        
 // To Here
        
     let key = ref.child("user-posts").childByAutoId().key
        
      let childUpadates = ["/posts/\(key)": post,
                           "/user-posts/\(activeUserId)/\(key)/":post]
          ref.updateChildValues(childUpadates)
        
        for friendID in friendsArray {
            
          let childUpadates2 =  ["/timeline/\(friendID)/\(key)/": post]
            ref.updateChildValues(childUpadates2)
              print(" Array inside \(friendID)")
            
        ref.child("user-posts-id").child(KEY_UID!).child(key).setValue(true)
            
        }
        
        
        
        //self.user_commentRef = DataService.ds.REF_BASE.child("user-comments").child(KEY_UID!).child(key)
        
        //self.user_commentRef?.setValue(true)
      
        
    // let firebasePost2 = DataService.ds.REF_USER_POSTS_USERID.childByAutoId()  //important ojo
    //   firebasePost2.setValue(post)
        
        
        postField.text = ""
      //  commentBtn.text = ""
        imageSelectorImage.image = UIImage(named: "camera")
        imageSelected = false
        
        tableView.reloadData()
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
    
    
  /*  func uploadSuccess(metadata: FIRStorageMetadata, storagePath: String) {
        print("Upload Succeeded!")
        //  self.urlTextView.text = metadata.downloadURL()!.absoluteString
        NSUserDefaults.standardUserDefaults().setObject(storagePath, forKey: "storagePath")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.tableView.reloadData()
        // self.downloadPicButton.enabled = true
    }  */
    
  
    
    //MARK: - PostCellDelegator Methods
    
    func callSegueFromCell(myData dataobject: AnyObject) {
        
        

        //try not to send self, just to avoid retain cycles(depends on how you handle the code on the next controller)
        self.performSegueWithIdentifier("segue_commentVC", sender:dataobject )
        
    }
    
    //  Go to profile from Main Post
    
   func ContactIDSegueFromCell(contactID dataobject: AnyObject) {
    
        dispatch_async(dispatch_get_main_queue()){
        //try not to send self, just to avoid retain cycles(depends on how you handle the code on the next controller)
       self.performSegueWithIdentifier("segue_Profile_Name", sender:dataobject )
      
    }
    
       // print( "Segue Agosto 1xxxxx: \(contactId)")
    //
    }
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segue_Profile_Name"
        {
             let destinationVC = segue.destinationViewController as? contactProfileVC
            if let theString = sender as? String {
                destinationVC!.contactId =  theString
            }
            
            
        }
    if segue.identifier == "segue_Postimage_to_showVC"
    {
        let destinationVC = segue.destinationViewController as? ImageShowVC
        if let theString = sender as? String {
            destinationVC!.postKey_Segue =  theString
        }
        
        
    }
    }
    
    
    
    
    //MARK: - ImageURLSegue_CellDelegate Methods
    
    func ImageURLSegue_Cell(postKey_Segue dataobject: AnyObject) {
        
        
        
        //try not to send self, just to avoid retain cycles(depends on how you handle the code on the next controller)
        self.performSegueWithIdentifier("segue_Postimage_to_showVC", sender:dataobject )
        
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
    
   
  /*  // Segue to ImageShowVC  to show full size image
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "segue_MainPost_to_Picture" {
            let dvc = segue.destinationViewController as! ImageShowVC
            dvc.newImage = postingImage.image
        }
    }  */
    
    
/*    @IBAction func profileNameBtn(sender: AnyObject) {  //profileNameBtn
        
        
        
    }
 */
   /* override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segue_Profile_Name"
        {
            let destinationVC = segue.destinationViewController as? contactProfileVC
            // NSUserDefaults.standardUserDefaults().setValue(contactID_Post_Profile, forKey: "contactID_Post_Profile")
            let contactID_Post_Profile = NSUserDefaults.standardUserDefaults().valueForKey("contactID_Post_Profile") as? String
            destinationVC!.contactId =  contactID_Post_Profile
            
            
        }
    }  */

    
}



























