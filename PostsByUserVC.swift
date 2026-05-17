//
//  PostsByUserVC.swift
//  pickup
//
//  Created by christian landa on 7/14/16.
//  Copyright © 2016 christian landa. All rights reserved.
//
import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseMessaging
import FirebaseStorage
import FirebaseDatabase
import Photos
import FirebaseAuth
import FirebaseStorage
//import Alamofire


class PostsByUserVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, PostsByUserCellDelegate {  //, PostsByUserCellDelegate
    
    @IBOutlet weak var tableView: UITableView!
  //  @IBOutlet weak var postField: MaterialTextField!
  //  @IBOutlet weak var imageSelectorImage: UIImageView!
    
    
    var followersRef: DatabaseReference!
    
    var postKey: String!
    
    var myData:String?
    
    var userID: String?   // from Segue destinationVC.userID = uid
    
   
     var friendsArray: [String] = []
    
    
    let kSectionComments = 1
    let kSectionPost = 0
    
    
    
    
    var imagePicker: UIImagePickerController!
   
    var post: Post!
    
    var imageSelected = false
    
    var posts = [Post]()
    static var imageCache = NSCache<AnyObject, AnyObject>()
    
    var storageRef:StorageReference!
    
    var delegate:PostsByUserCellDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 358
//        imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
        
       UserDefaults.standard.setValue(userID, forKey: "userID")
        UserDefaults.standard.synchronize()
        
        let storage = Storage.storage()
        storageRef = storage.reference(forURL: "gs://pickup-9b67a.appspot.com")
        
        print("Segue: ----------\(userID!)")
        
        // DataService.ds.REF_USER_POST.child(userID!).queryOrdered(byChild: "time").queryLimited(toLast: 50).observe(.value , with: { (snapshot) in  //observeSingleEventOfType

     //   DataService.ds.REF_USER_POST.child(userID!).observe(DataEventType.value, with: { (snapshot) in
        DataService.ds.REF_USER_POST.child(userID!).queryOrdered(byChild: "time").queryLimited(toLast: 50).observe(.value , with: { (snapshot) in  //observeSingleEventOfType
 
       
            
            self.posts = []
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]  {
                
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    
                    //  if  let postDict = snapshot.value as? Dictionary <String, AnyObject> {
                    
                    if let postDict = snap.value as? [String : AnyObject]  {
                        
                        
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        
                        
                        
                        
                        self.posts.append(post)
                        print("SNAP post1xxxxxx: \(postDict)")
                        
                        
                    }
                }
            }
            self.posts = self.posts.reversed()
            self.tableView.reloadData()
            
        })
        
        
        
    }
    
    
  
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return tableView.reloadData()
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    
        let post = posts[indexPath.row]  //keys are stored here
        
        
        if let cell =  tableView.dequeueReusableCell(withIdentifier: "PostsByUserCell") as? PostsByUserCell {
            
            cell.delegate = self // july 7, 2016
            
            // cell.commentBtn.tag = indexPath.row
            // cell.commentBtn.addTarget(self, action: "runAfterDelay(delay):", forControlEvents: .TouchUpInside)
            
          //  cell.request?.cancel()
            
         
            
            var img: UIImage?
            
            if let url = post.imageUrl {
                img = PostsByUserVC.imageCache.object(forKey: url as AnyObject) as? UIImage
            }
            
            
            
            
            print("PostKEY-Outside----------------------: \(post.postKey)")
            cell.configureCell(post: post, img: img, userID: userID)
            
            //let postKey =  post.postKey
            
            print("SNaps July 6 :\(post.postKey)")
            
            
            return cell
            
        }else {
            return  PostsByUserCell()  //PostCell()
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 150
        }else{
            return tableView.estimatedRowHeight
        }
    }
    
    
    
//    @IBAction func makePost(sender: AnyObject) {
//        
//        
//        
//        // if let txt = postField.text where txt != "" {
//        //  if let img = cameraSelector.image where imageSelected == true
//        //}
//        // }
//        //  let picker = UIImagePickerController()
//        self.imagePicker = UIImagePickerController()
//        //picker.delegate = self
//        imagePicker.delegate = self
//        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
//            //picker.sourceType = UIImagePickerControllerSourceType.Camera
//            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
//        } else {
//            //picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
//        }
//        
//        
//        
//    }
    
    
    
//    func imagePickerController(imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        
//        
//        
//        imagePicker.dismiss(animated: true, completion:nil)
//        
//        let tempImage = info[UIImagePickerControllerOriginalImage] as! UIImage
//        
//        imageSelectorImage.image = tempImage
//        
//        imageSelected = true
//        
//        // urlTextView.text = "Beginning Upload";
//        
//        // if it's a photo from the library, not an image from the camera
//        if let txt = postField.text, txt != "" {
//            
//            if let img = imageSelectorImage.image, imageSelected == true {
//                
//                
//                if #available(iOS 8.0, *), let referenceUrl = info[UIImagePickerControllerReferenceURL] {
//                    let assets = PHAsset.fetchAssets(withALAssetURLs: [(referenceUrl as! NSURL) as URL], options: nil)
//                    let asset = assets.firstObject
//                    asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput,info) in
//                        
//                        let imageFile = contentEditingInput?.fullSizeImageURL
//                        let filePath = Auth.auth()!.currentUser!.uid + "/\(Int(NSDate.timeIntervalSinceReferenceDate * 1000))/\(imageFile!.lastPathComponent)"
//                        
//                        
//                        // [START uploadimage]
//                        
//                        self.storageRef.child(filePath).putFile(imageFile!, metadata: nil) { (metadata, error) in
//                            if let error = error {
//                                print("Error uploading: \(error)")
//                                return
//                            }
//                            self.uploadSuccess(metadata: metadata!, storagePath: filePath)
//                            // self.postToFirebase(filePath)
//                            print("LINK: \(filePath)")
//                            
//                            
//                            // Create a reference to the file you want to download
//                            let starsRef = self.storageRef.child(filePath)
//                            // Fetch the download URL
//                            starsRef.downloadURL { (URL, error) -> Void in
//                                if (error != nil) {
//                                    // Handle any errors
//                                } else {
//                                    // Get the download URL for 'images/stars.jpg'
//                                    print("LINK_URL: \(URL)")
//                                    let urlString: String = (URL?.absoluteString)!
//                                    
//                                    self.postToFirebase( imgUrl: urlString)
//                                    print("LINK_URLString: \(urlString)")
//                                }
//                            }
//                            
//                        }
//                        // [END uploadimage]
//                    })
//                }
//                else {
//                    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
//                    let imageData = UIImageJPEGRepresentation(image, 0.02)
//                    let imagePath = Auth.auth()!.currentUser!.uid + "/\(Int(NSDate.timeIntervalSinceReferenceDate * 1000)).jpg"
//                    let metadata = StorageMetadata()
//                    metadata.contentType = "image/jpeg"
//                    self.storageRef.child(imagePath).put(imageData!, metadata: metadata) { (metadata, error) in
//                        if let error = error {
//                            print("Error uploading: \(error)")
//                            
//                            // self.urlTextView.text = "Upload Failed"
//                            return
//                        }
//                        self.uploadSuccess(metadata: metadata!, storagePath: imagePath)
//                        // print("LINK: \(imagePath)")
//                        // Create a reference to the file you want to download
//                        let starsRef = self.storageRef.child(imagePath)
//                        // Fetch the download URL
//                        starsRef.downloadURL { (URL, error) -> Void in
//                            if (error != nil) {
//                                // Handle any errors
//                            } else {
//                                // Get the download URL for 'images/stars.jpg'
//                                print("LINK_URL: \(URL)")
//                                let urlString: String = (URL?.absoluteString)!
//                                
//                                self.postToFirebase( imgUrl: urlString)
//                                print("LINK_URLString: \(urlString)")
//                            }
//                        }
//                        
//                        
//                    }
//                }
//            } else {
//                self.postToFirebase(imgUrl: nil)
//            }
//        }
//    }
    
//    
//    @IBAction func  selectImage(sender: UITapGestureRecognizer) {
//        present(imagePicker, animated: true, completion: nil)
//    }
    
    
//    func postToFirebase(imgUrl: String?){
//        
//        let  activeUserId  = UserDefaults.standard.value(forKey: "uid") as! String
//        var post: Dictionary<String, AnyObject> = [
//            "description": postField.text! as AnyObject,
//            "likes": 0 as AnyObject,
//            "dislikes": 0 as AnyObject,
//            "uid":  activeUserId as AnyObject,
//            //  "comment": commentBtn.!
//        ]
//        
//        if imgUrl != nil {
//            post["imageUrl"] = imgUrl as AnyObject?
//        }
//        
//        
//        
//        
//        // To Here
//        
//        let key = ref.child("user-posts").childByAutoId().key
//        
//        let childUpadates = ["/posts/\(key)": post,
//                             "/user-posts/\(activeUserId)/\(key)/":post]
//        ref.updateChildValues(childUpadates)
//        
//        for friendID in friendsArray {
//            
//            let childUpadates2 =  ["/timeline/\(friendID)/\(key)/": post]
//            ref.updateChildValues(childUpadates2)
//            print(" Array inside \(friendID)")
//            
//        }
//        
//        //    var uuid = NSUUID().UUIDString
//        
//        //let AutoIdString = "\(AutoId)"
//        
//        // let firebasePost = postRef.child(uuid)  //important ojo
//        
//        // let firebasePost = postRef.childByAutoId()
//        
//        //  firebasePost.setValue(post)
//        
//        let firebasePost2 = DataService.ds.REF_USER_POSTS_USERID.childByAutoId()  //important ojo
//        firebasePost2.setValue(post)
//        
//        
//        postField.text = ""
//        //  commentBtn.text = ""
//        imageSelectorImage.image = UIImage(named: "camera")
//        imageSelected = false
//        
//        tableView.reloadData()
//    }
    
    
    
    
//    func uploadSuccess(metadata: StorageMetadata, storagePath: String) {
//        print("Upload Succeeded!")
//        //  self.urlTextView.text = metadata.downloadURL()!.absoluteString
//        UserDefaults.standard.set(storagePath, forKey: "storagePath")
//        UserDefaults.standard.synchronize()
//        // self.downloadPicButton.enabled = true
//    }
//    
    
    
    //MARK: - PostCellDelegator Methods
    
    func callSegueFromCell(myData dataobject: AnyObject) {
        
        
        
        //try not to send self, just to avoid retain cycles(depends on how you handle the code on the next controller)
        self.performSegue(withIdentifier: "segue_commentVC2", sender:dataobject )
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    func FirebaseFanout(){
        
        
        // followingsRef = DataService.ds.REF_FOLLOWING_USERID
        // followingsRef.observeEventType(.Value, withBlock:  { snapshot in
        followersRef = DataService.ds.REF_FOLLOWER_USERID
        followersRef.observe(.value, with:  { snapshot in
            
            
            print("new snapshot array: \(snapshot.key)")
            
            
            self.friendsArray = []
            //   self.usersLists = []
            
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


}
