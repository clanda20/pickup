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
import MediaPlayer
import MobileCoreServices
import AVKit
import AVFoundation


class FeedVC: UIViewController, UITableViewDelegate,UITextFieldDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PostCellDelegate,ContactIDCellDelegate, ImageURLSegue_CellDelegate,VideoURLSegue_CellDelegate,EventSegue_CellDelegate  {
    
   @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
   @IBOutlet weak var imageSelectorImage: UIImageView!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
   // var image: UIImage!  // commented out sep 14
    let imagePC = UIImagePickerController()
    var popover:UIPopoverController? = nil
    var referenceUrl: AnyObject!
    
    var storageRef:FIRStorageReference!
    
  var friendID: String!
    
    var arrayList = [String]()
    
    var delegate:PostCellDelegate!
    
    var newImage: UIImage!  // to pass image to ImageShowVC
    var videoPicker: NSURL!
    var imageDownload: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 700//358
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
        
        QueryMyTimeline()
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
            
            }, withCancelBlock: {(error) -> Void in
        })
    }
    
    func QueryMyTimeline(){
        
        DataService.ds.REF_TIMELINE_POST_USERID.queryOrderedByChild("time").queryLimitedToLast(50).observeEventType(.Value , withBlock: { (snapshot) in  //observeSingleEventOfType
            
            print(snapshot.value)
            
            self.posts = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]  {
 
                for snap in snapshots {
                   
                    if let postDict = snap.value as? [String : AnyObject]  {
                        
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        
                        self.posts.append(post)
                        
                       
                     }
                 }
            }
            self.posts = self.posts.reverse()
            self.tableView.reloadData()
            
            }, withCancelBlock: nil)
        
    }
    
 
 
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
            cell.videoDelegate4 = self
            cell.EventDelegate5 = self
        
          
            cell.request?.cancel()
            
            var img:  UIImage?
            
            if let url = post.imageUrl {
              img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(post, img: img, urlVideo: nil)
            
            return cell
            
        }else {
            return PostCell()
        }
    }
    
  

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let post = posts[indexPath.row]
        
        if post.mediaType == "VIDEO" || post.mediaType == "PHOTO"{
            return tableView.estimatedRowHeight
        } else {
            
                return 150
            
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        
        
        referenceUrl = info[UIImagePickerControllerReferenceURL]
        
        if let  image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageDownload = image
            imageSelectorImage.image = image
            imageSelected = true
           //makePost( image, video: nil)
        }
        
        else if let video = info[UIImagePickerControllerMediaURL] as? NSURL {
         // let moviePlayer = MPMoviePlayerViewController(contentURL: info[UIImagePickerControllerMediaURL] as! NSURL)
            
            self.videoPicker = video as NSURL
            
           
          let  imageVideo = thumbnailForVideoAtURL(video)
           
          let  fixOrientationImage = UIImage(CGImage: imageVideo!.CGImage!, scale: imageVideo!.scale, orientation:.Up)

           
           // let fixOrientationImage = imageVideo
         imageSelectorImage.image = fixOrientationImage
            
           
            imageSelected = true
            
             self.imageDownload = fixOrientationImage
            
           // self.presentMoviePlayerViewControllerAnimated(moviePlayer)
            //makePost(nil, video: video)
            
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        tableView.reloadData()
       
    }
    
    @IBAction func makePost(sender:  AnyObject) {//(picture: UIImage?, video: NSURL?)   /* (sender:  AnyObject) */{
    
       // sep 14 imageSelected = true
        
        
        if let txt = postField.text where txt != "" {
        
            if let img = imageSelectorImage.image   where imageSelected == true {
                
                
                
                if ( self.imageDownload != nil &&  self.videoPicker == nil){   /////***********************  photo ONly
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.tableView.reloadData()
                    
                    let imageData = UIImageJPEGRepresentation(img, 0.00)
                    let filePath = FIRAuth.auth()!.currentUser!.uid + "/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000))"
                    let metaData = FIRStorageMetadata()
                    metaData.contentType = "image/jpg"
                    storageRef.child(filePath).putData(imageData!, metadata: metaData){(metaData,error) in
                        if let error = error {
                            print(error.localizedDescription)
                            
                            return
                        }else{
                            //store downloadURL
                            let downloadURL = metaData!.downloadURL()!.absoluteString
                            
                            
                            //store downloadURL at database
                            // DataService.ds.REF_USER_POSTS_USERID .updateChildValues(["avatar": downloadURL])
                            self.postToFirebase( downloadURL,vidUrl: nil, mediaType: "PHOTO")
                            self.tableView.reloadData()
                            print("LINK_URLString: \(downloadURL)")
                            
                        }
                        
                    }
                    // } //  en picture = picture
                   
                }
            
            else  if ( self.imageDownload != nil &&  self.videoPicker != nil){   /////*********************** picture and video
                
              
                var downloadURL: String!
        
        self.dismissViewControllerAnimated(true, completion: nil)
            self.tableView.reloadData()
        
        let imageData = UIImageJPEGRepresentation(img, 0.00)
        let filePath = FIRAuth.auth()!.currentUser!.uid + "/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000))"
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.child(filePath).putData(imageData!, metadata: metaData){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                
                return
            }else{
                //store downloadURL
                    downloadURL = metaData!.downloadURL()!.absoluteString
                    
                
                    //store downloadURL at database
                    // DataService.ds.REF_USER_POSTS_USERID .updateChildValues(["avatar": downloadURL])
                   /// self.postToFirebase( downloadURL,vidUrl: nil, mediaType: "PHOTO")
                    self.tableView.reloadData()
                    print("LINK_URLString: \(downloadURL)")
                
                    }
           
                }
                    
                    
                let video  = self.videoPicker
                    
                let videoData2 = NSData(contentsOfURL: video)
                let filePath2 = FIRAuth.auth()!.currentUser!.uid + "/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000))"
                let metaData2 = FIRStorageMetadata()
                metaData2.contentType = "video/mp4"
                let uploadTask = storageRef.child(filePath2).putData(videoData2!, metadata: metaData2){(metaData2,error) in
                    if let error = error {
                        print(error.localizedDescription)
                        
                        return
                    }else{
                        //store downloadURL
                        let downloadVideoURL = metaData2!.downloadURL()!.absoluteString
                        
                        
                        //store downloadURL at database
                        // DataService.ds.REF_USER_POSTS_USERID .updateChildValues(["avatar": downloadURL])
                        self.postToFirebase( downloadURL, vidUrl: downloadVideoURL, mediaType: "VIDEO")
                        self.tableView.reloadData()
                        print("LINK_URLString: \(downloadVideoURL)")
                        
                    }
                    
                }
                
        }
            } else {
                    self.postToFirebase(nil,vidUrl: nil, mediaType: "TEXT")
            
            }
        }
        let optionMenu = UIAlertController(title: nil, message: "Type in something!", preferredStyle: .ActionSheet)
        
       
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
      
        optionMenu.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(optionMenu, animated: true, completion: nil)

        }
    
   
    
   
    
    @IBAction func  selectImage(sender: UITapGestureRecognizer) {
       // presentViewController(imagePicker, animated: true, completion: nil)
        
        let alert:UIAlertController=UIAlertController(title: "Choose Media", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
            self.openGallery()
        }
        
        let galleryVideoAction = UIAlertAction(title: "Video", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
            self.openVideo()
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
        {
            UIAlertAction in
        }
        // Add the actions
        self.imagePC.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(galleryVideoAction)
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
            openGallery()
            openVideo()
        }
    }
    
    
    func openGallery()
    {
        self.imagePC.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(self.imagePC, animated: true, completion: nil)
        }
        
        else
        {
            popover = UIPopoverController(contentViewController: self.imagePC)
            popover!.presentPopoverFromRect(imageSelectorImage.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    func openVideo()
    {
        self.imagePC.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
            
        {
            imagePC.mediaTypes = ["public.movie"]
            self.presentViewController(self.imagePC, animated: true, completion: nil)
        }
            
        else
        {
            popover = UIPopoverController(contentViewController: self.imagePC)
            popover!.presentPopoverFromRect(imageSelectorImage.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    
    func postToFirebase(imgUrl: String?, vidUrl: String?, mediaType: String?){
        
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
            "mediaType": mediaType!
            //  "comment": commentBtn.!
        ]
        
        if imgUrl != nil {
            post["imageUrl"] = imgUrl!
        }
        
        if vidUrl != nil {
            post["videoUrl"] = vidUrl!
        }
        
   
        
     let key = ref.child("user-posts").childByAutoId().key
        
      let childUpadates = ["/posts/\(key)": post,
                           "/user-posts/\(activeUserId)/\(key)/":post]
          ref.updateChildValues(childUpadates)
        
        for friendID in friendsArray {
            
          let childUpadates2 =  ["/timeline/\(friendID)/\(key)/": post]
            ref.updateChildValues(childUpadates2)
            
           
            
        
         ref.child("posts-followers").child(key).child(friendID).setValue(true)  // new sep 13
        ref.child("posts-followers").child(key).child(KEY_UID!).setValue(true)  // post creator will be always be a friend
            
        }
        // POST'S Creator post is always on his/ her timeline
        let childUpadatesUID =  ["/timeline/\(KEY_UID!)/\(key)/": post]
        ref.updateChildValues(childUpadatesUID)
        
        
        ref.child("user-posts-id").child(KEY_UID!).child(key).setValue(true)
        
       
        
        
        postField.text = ""
        imageSelectorImage.image = UIImage(named: "camera")
        imageSelected = false
        
        tableView.reloadData()
    }
    
 
    
  
    
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
    }
    
    func VideoURLSegue_Cell(videoUrl_segue dataobject: AnyObject) {
        
      
            //try not to send self, just to avoid retain cycles(depends on how you handle the code on the next controller)
            self.performSegueWithIdentifier("segue_showVideo", sender:dataobject )
       
       // print( "Segue Agosto 1xxxxx: \(contactId)")
    //
    }
    
   func EventSegue_Cell(eventKey_segue dataobject: AnyObject) {
        
        
        //try not to send self, just to avoid retain cycles(depends on how you handle the code on the next controller)
        self.performSegueWithIdentifier("segueTimeLineToEvent", sender:dataobject )
        
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
    
    if segue.identifier == "segue_showVideo"  //segue_showVideo
    {
        let destinationVC = segue.destinationViewController as? PlayVideoVC
        if let theString = sender as? String {
            destinationVC!.videoUrl_segue =  theString
        }
        
        
    }
    
    //segueTimeLineToEvent
    if segue.identifier == "segueTimeLineToEvent"  //segue_showVideo
    {
        let destinationVC = segue.destinationViewController as? EventDetailVC
        if let theString = sender as? String {
            destinationVC!.eventKey =  theString
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

    private func thumbnailForVideoAtURL(url: NSURL) -> UIImage? {
        
        let asset = AVAsset(URL: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try assetImageGenerator.copyCGImageAtTime(time, actualTime: nil)
            return UIImage(CGImage: imageRef)

        } catch {
            print("error")
            return nil
        }
    }
    
   
    
}

//MARK:- Image Orientation fix


























