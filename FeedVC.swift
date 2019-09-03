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
//import Alamofire

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
    
//    @IBOutlet weak var progressView: UIProgressView!
//    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
    
    static var imageCache = NSCache<AnyObject, AnyObject>()
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
        
        tableView.estimatedRowHeight = 680//358
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        let storage = FIRStorage.storage()
        storageRef = storage.reference(forURL: "gs://pickup-9b67a.appspot.com")
        
        //Enable offline capabilities 
        
      //  FIRDatabase.database().persistenceEnabled = true
        
        //Dismiss Keyboard
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FeedVC.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
      
        self.postField.delegate = self
        
        QueryMyTimeline()
        QueryCurrentUser()
        
        
    
        
    }

    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
      //  FirebaseFanout({ (friendID) -> () in })
       self.navigationController?.setNavigationBarHidden(true, animated: animated)
       FirebaseFanout()
     //self.tableView.reloadData()
        self.tabBarController?.tabBar.isHidden = false  // jan 11, 2017 might not be needed
    }

    


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.setLeftBarButton(nil, animated: true)
        
        // FirebaseFanout()
       // QueryMyTimeline()
        
        
    }
    
    
    
    func FirebaseFanout(){
        
        
       // followingsRef = DataService.ds.REF_FOLLOWING_USERID
       // followingsRef.observeEventType(.Value, withBlock:  { snapshot in
        followersRef = DataService.ds.REF_FOLLOWER_USERID
        followersRef.observe(.value, with:  { snapshot in
            
            
            print("new snapshot array: \(snapshot.key)")
            
            
            self.friendsArray = []
            //self.usersLists = []
            
            for child in snapshot.children {
                let friendID = (child as AnyObject).key as String
                print("friendID  Array IIIIiiiiiiiiiiiiiiiii: \(friendID)")
                
                self.friendsArray.append(friendID)
                
                _ = Post(followersList: self.friendsArray)
                
                // self.usersLists.append(usersList)
                
                for friendID in self.friendsArray {
                    print(" Array friendID tonight \(friendID)")
                }
                
            }
            
            
            self.tableView.reloadData()
            
        }, withCancel: { (error) ->  Void in
        
    
        })
    }
    
    
    func QueryCurrentUser(){
        
        DataService.ds.REF_USER_CURRENT.observe(.value, with: { (snapshot)  in
            
            let item = snapshot as FIRDataSnapshot
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
            
        }, withCancel: {(error) -> Void in
        })
    }
    
    func QueryMyTimeline(){
        
        DataService.ds.REF_TIMELINE_POST_USERID.queryOrdered(byChild: "time").queryLimited(toLast: 50).observe(.value , with: { (snapshot) in  //observeSingleEventOfType
            
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
            self.posts = self.posts.reversed()
            self.tableView.reloadData()
            
        }, withCancel: nil)
        
    }
    
 
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
  //  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    func numberOfSections(in tableView: UITableView) -> Int {
      
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return tableView.reloadData()
    }
   
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]  //keys are stored here
        
        
        if let cell =  tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            cell.delegate = self // july 7, 2016
            cell.delegate2 = self
            cell.delegate3 = self
            cell.videoDelegate4 = self
            cell.EventDelegate5 = self
        
          
          ///  cell.request?.cancel()
            
            var img:  UIImage?
            
            if let url = post.imageUrl {
              img = FeedVC.imageCache.object(forKey: url as AnyObject) as? UIImage
            }
            
            cell.configureCell(post: post, img: img, urlVideo: nil)
            
            return cell
            
        }else {
            return PostCell()
        }
    }
    
  

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let post = posts[indexPath.row]
        
        if post.mediaType == "VIDEO" || post.mediaType == "PHOTO"{
            return tableView.estimatedRowHeight
        } else {
            
                return 170
            
        }
    }
    
    
  //  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        referenceUrl = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.referenceURL)] as AnyObject?
        
        if let  image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            self.imageDownload = image
            imageSelectorImage.image = image
            imageSelected = true
           //makePost( image, video: nil)
        }
        
        else if let video = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? NSURL {
         // let moviePlayer = MPMoviePlayerViewController(contentURL: info[UIImagePickerControllerMediaURL] as! NSURL)
            
            self.videoPicker = video as NSURL
            
           
          let  imageVideo = thumbnailForVideoAtURL(url: video)
           
          let  fixOrientationImage = UIImage(cgImage: imageVideo!.cgImage!, scale: imageVideo!.scale, orientation:.up)

           
           // let fixOrientationImage = imageVideo
         imageSelectorImage.image = fixOrientationImage
            
           
            imageSelected = true
            
             self.imageDownload = fixOrientationImage
            
           // self.presentMoviePlayerViewControllerAnimated(moviePlayer)
            //makePost(nil, video: video)
            
        }
        self.dismiss(animated: true, completion: nil)
        tableView.reloadData()
       
    }
    
    @IBAction func makePost(sender:  AnyObject) {//(picture: UIImage?, video: NSURL?)   /* (sender:  AnyObject) */{
    
       // sep 14 imageSelected = true
        
        
        if let txt = postField.text, txt != "" {
        
            if let img = imageSelectorImage.image, imageSelected == true {
                
                
                
                if ( self.imageDownload != nil &&  self.videoPicker == nil){   /////***********************  photo ONly
                    
                    self.dismiss(animated: true, completion: nil)
                    self.tableView.reloadData()
                    
                    let imageData = img.jpegData(compressionQuality: 0.00)
                    let filePath = FIRAuth.auth()!.currentUser!.uid + "/\(Int(NSDate.timeIntervalSinceReferenceDate * 1000))"
                    let metaData = FIRStorageMetadata()
                    metaData.contentType = "image/jpg"
                    storageRef.child(filePath).put(imageData!, metadata: metaData){(metaData,error) in
                        if let error = error {
                            print(error.localizedDescription)
                            
                            return
                        }else{
                            //store downloadURL
                            let downloadURL = metaData!.downloadURL()!.absoluteString
                            
                            
                            //store downloadURL at database
                            // DataService.ds.REF_USER_POSTS_USERID .updateChildValues(["avatar": downloadURL])
                            self.postToFirebase( imgUrl: downloadURL,vidUrl: nil, mediaType: "PHOTO")
                            self.tableView.reloadData()
                            print("LINK_URLString: \(downloadURL)")
                            
                        }
                        
                    }
                    // } //  en picture = picture
                   
                }
            
            else  if ( self.imageDownload != nil &&  self.videoPicker != nil){   /////*********************** picture and video
                
              
                var downloadURL: String!
        
        self.dismiss(animated: true, completion: nil)
            self.tableView.reloadData()
        
        let imageData = img.jpegData(compressionQuality: 0.00)
        let filePath = FIRAuth.auth()!.currentUser!.uid + "/\(Int(NSDate.timeIntervalSinceReferenceDate * 1000))"
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.child(filePath).put(imageData!, metadata: metaData){(metaData,error) in
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
                    
                let videoData2 = NSData(contentsOf: video as! URL)
                let filePath2 = FIRAuth.auth()!.currentUser!.uid + "/\(Int(NSDate.timeIntervalSinceReferenceDate * 1000))"
                let metaData2 = FIRStorageMetadata()
                metaData2.contentType = "video/mp4"
                _ = storageRef.child(filePath2).put(videoData2! as Data, metadata: metaData2){(metaData2,error) in
                    if let error = error {
                        print(error.localizedDescription)
                        
                        return
                    }else{
                        //store downloadURL
                        let downloadVideoURL = metaData2!.downloadURL()!.absoluteString
                        
                        
                        //store downloadURL at database
                        // DataService.ds.REF_USER_POSTS_USERID .updateChildValues(["avatar": downloadURL])
                        self.postToFirebase( imgUrl: downloadURL, vidUrl: downloadVideoURL, mediaType: "VIDEO")
                        self.tableView.reloadData()
                        print("LINK_URLString: \(downloadVideoURL)")
                        
                    }
                    
                }
                
        }
            } else {
                    self.postToFirebase(imgUrl: nil,vidUrl: nil, mediaType: "TEXT")
            
            }
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
   
    
    @IBAction func  selectImage(_ sender: UITapGestureRecognizer) {
       // presentViewController(imagePicker, animated: true, completion: nil)
        
        let alert:UIAlertController=UIAlertController(title: "Choose Media", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openGallery()
        }
        
        let galleryVideoAction = UIAlertAction(title: "Video", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openVideo()
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        {
            UIAlertAction in
        }
        // Add the actions
        self.imagePC.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(galleryVideoAction)
        alert.addAction(cancelAction)
        // Present the controller
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            popover = UIPopoverController(contentViewController: alert)
            popover!.present(from: imageSelectorImage.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
        
    }

    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            self.imagePC.sourceType = UIImagePickerController.SourceType.camera
            self .present(self.imagePC, animated: true, completion: nil)
        }
        else
        {
            openGallery()
            openVideo()
        }
    }
    
    
    func openGallery()
    {
      if UIImagePickerController.isSourceTypeAvailable(.camera) {
        self.imagePC.allowsEditing = false
        self.imagePC.sourceType = .photoLibrary
        imagePC.mediaTypes = ["public.image"]
        // self.imagePC.modalPresentationStyle = .popover
        present(self.imagePC, animated: true, completion: nil)
      //  self.imagePC.popoverPresentationController?.barButtonItem = self.imagePC
      } else {
        noCamera()
        }
        
//        self.imagePC.sourceType = UIImagePickerControllerSourceType.photoLibrary
//        self.imagePC.delegate = self
//        if UIDevice.current.userInterfaceIdiom == .phone
//        {
//            
//            self.present(self.imagePC, animated: true, completion: nil)
//        }
//        
//        else
//        {
//            popover = UIPopoverController(contentViewController: self.imagePC)
//            popover!.present(from: imageSelectorImage.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
//        }
    }
    
    func openVideo()
    {
        self.imagePC.sourceType = UIImagePickerController.SourceType.photoLibrary
        if UIDevice.current.userInterfaceIdiom == .phone
            
        {
           imagePC.mediaTypes = ["public.movie"]
         // imagePC.mediaTypes = ["public.image"]
            self.present(self.imagePC, animated: true, completion: nil)
        }
            
        else
        {
            popover = UIPopoverController(contentViewController: self.imagePC)
         //   popover!.presentfrom;:   inPopoverFromRect(imageSelectorImage.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            popover!.present(from: imageSelectorImage.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
    }
    
    }
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
    func postToFirebase(imgUrl: String?, vidUrl: String?, mediaType: String?){
        
       let interval = NSDate().timeIntervalSince1970

        let time  = String(Int(NSDate().timeIntervalSince1970))
        
         let  activeUserId  = UserDefaults.standard.value(forKey: "uid") as! String
        var post: Dictionary<String, AnyObject> = [
            "description": postField.text! as AnyObject,
            "likes": 0 as AnyObject,
            "dislikes": 0 as AnyObject,
            "uid":  activeUserId as AnyObject,
            "fullName": self.profileName as AnyObject,
            "avatar": self.profileImg as AnyObject,
            "time" : time as AnyObject,
            "mediaType": mediaType! as AnyObject
            //  "comment": commentBtn.!
        ]
        
        if imgUrl != nil {
            post["imageUrl"] = imgUrl! as AnyObject?
        }
        
        if vidUrl != nil {
            post["videoUrl"] = vidUrl! as AnyObject?
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
        self.performSegue(withIdentifier: "segue_commentVC", sender:dataobject )
        
    }
    
    //  Go to profile from Main Post
    
   func ContactIDSegueFromCell(contactID dataobject: AnyObject) {
    
        DispatchQueue.main.async(){
        //try not to send self, just to avoid retain cycles(depends on how you handle the code on the next controller)
       self.performSegue(withIdentifier: "segue_Profile_Name", sender:dataobject )
      
    }
    }
    
    func VideoURLSegue_Cell(videoUrl_segue dataobject: AnyObject) {
        
      
            //try not to send self, just to avoid retain cycles(depends on how you handle the code on the next controller)
            self.performSegue(withIdentifier: "segue_showVideo", sender:dataobject )
       
       // print( "Segue Agosto 1xxxxx: \(contactId)")
    //
    }
    
   func EventSegue_Cell(eventKey_segue dataobject: AnyObject) {
        
        
        //try not to send self, just to avoid retain cycles(depends on how you handle the code on the next controller)
        self.performSegue(withIdentifier: "segueTimeLineToEvent", sender:dataobject )
        
        // print( "Segue Agosto 1xxxxx: \(contactId)")
        //
    }
   
    
  override func prepare(for forsegue: UIStoryboardSegue, sender: Any?) {
        if forsegue.identifier == "segue_Profile_Name"
        {
             let destinationVC = forsegue.destination as? contactProfileVC
            if let theString = sender as? String {
                destinationVC!.contactId =  theString
            }
            
            
        }
    if forsegue.identifier == "segue_Postimage_to_showVC"
    {
        let destinationVC = forsegue.destination as? ImageShowVC
        if let theString = sender as? String {
            destinationVC!.postKey_Segue =  theString
        }
        
    }
    
    if forsegue.identifier == "segue_showVideo"  //segue_showVideo
    {
        let destinationVC = forsegue.destination as? PlayVideoVC
        if let theString = sender as? String {
            destinationVC!.videoUrl_segue =  theString
        }
        
        
    }
    
    //segueTimeLineToEvent
    if forsegue.identifier == "segueTimeLineToEvent"  //
    {
        let destinationVC = forsegue.destination as? EventDetailVC
        if let theString = sender as? String {
            destinationVC!.eventKey =  theString
        }
        
        
    }
    
    }
    
    
    
    
    //MARK: - ImageURLSegue_CellDelegate Methods
    
    func ImageURLSegue_Cell(postKey_Segue dataobject: AnyObject) {
        
        
        
        //try not to send self, just to avoid retain cycles(depends on how you handle the code on the next controller)
        self.performSegue(withIdentifier: "segue_Postimage_to_showVC", sender:dataobject )
        
    }
    
    
    
    
        
        
    
    // Dismiss keyBoard
    
    @objc func hideKeyboard()
    {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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

     func thumbnailForVideoAtURL(url: NSURL) -> UIImage? {
        
        let asset = AVAsset(url: url as URL)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)

        } catch {
            print("error")
            return nil
        }
    }
    
   
    
}

//MARK:- Image Orientation fix



























// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
