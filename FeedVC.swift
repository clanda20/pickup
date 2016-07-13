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


class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PostCellDelegate {
    
   @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
   @IBOutlet weak var imageSelectorImage: UIImageView!
    
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
        
   //     var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("editRow"), userInfo: nil, repeats: false)
      postRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
        
           // print(snapshot.value)
        
      
        
        
        self.posts = []
        
        if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]  {
            
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
            self.tableView.reloadData()
        
      })
 
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
    
   
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]  //keys are stored here

        
        if let cell =  tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            
            cell.delegate = self // july 7, 2016
            
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
           
            //NSUserDefaults.standardUserDefaults().setValue(postKey, forKey: "postKey")
            
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
        
        
   
         // if let txt = postField.text where txt != "" {
          //  if let img = cameraSelector.image where imageSelected == true
        //}
   // }
          //  let picker = UIImagePickerController()
            self.imagePicker = UIImagePickerController()
            //picker.delegate = self
            imagePicker.delegate = self
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
                //picker.sourceType = UIImagePickerControllerSourceType.Camera
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            } else {
                //picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            }
            
        
 
    }
    
 
    
    func imagePickerController(imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
     
     
        
        imagePicker.dismissViewControllerAnimated(true, completion:nil)
        
        let tempImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        imageSelectorImage.image = tempImage
        
        imageSelected = true
        
        // urlTextView.text = "Beginning Upload";
        
        // if it's a photo from the library, not an image from the camera
         if let txt = postField.text where txt != "" {
            
            if let img = imageSelectorImage.image where imageSelected == true {
            
            
        if #available(iOS 8.0, *), let referenceUrl = info[UIImagePickerControllerReferenceURL] {
            let assets = PHAsset.fetchAssetsWithALAssetURLs([referenceUrl as! NSURL], options: nil)
            let asset = assets.firstObject
            asset?.requestContentEditingInputWithOptions(nil, completionHandler: { (contentEditingInput,info) in
                
                 let imageFile = contentEditingInput?.fullSizeImageURL
                 let filePath = FIRAuth.auth()!.currentUser!.uid + "/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000))/\(imageFile!.lastPathComponent!)"
               
            
                // [START uploadimage]
                
                self.storageRef.child(filePath).putFile(imageFile!, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error uploading: \(error)")
                            return
                        }
                        self.uploadSuccess(metadata!, storagePath: filePath)
                       // self.postToFirebase(filePath)
                        print("LINK: \(filePath)")
                    
                    
                    // Create a reference to the file you want to download
                    let starsRef = self.storageRef.child(filePath)
                    // Fetch the download URL
                    starsRef.downloadURLWithCompletion { (URL, error) -> Void in
                        if (error != nil) {
                            // Handle any errors
                        } else {
                            // Get the download URL for 'images/stars.jpg'
                            print("LINK_URL: \(URL)")
                            let urlString: String = (URL?.absoluteString)!
                            
                            self.postToFirebase( urlString)
                            print("LINK_URLString: \(urlString)")
                        }
                    }
                    
                }
                // [END uploadimage]
            })
        }
            else {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            let imageData = UIImageJPEGRepresentation(image, 0.1)
            let imagePath = FIRAuth.auth()!.currentUser!.uid + "/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000)).jpg"
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            self.storageRef.child(imagePath).putData(imageData!, metadata: metadata) { (metadata, error) in
                    if let error = error {
                        print("Error uploading: \(error)")
                        
                        // self.urlTextView.text = "Upload Failed"
                        return
                    }
                    self.uploadSuccess(metadata!, storagePath: imagePath)
                   // print("LINK: \(imagePath)")
                // Create a reference to the file you want to download
                let starsRef = self.storageRef.child(imagePath)
                // Fetch the download URL
                starsRef.downloadURLWithCompletion { (URL, error) -> Void in
                    if (error != nil) {
                        // Handle any errors
                    } else {
                        // Get the download URL for 'images/stars.jpg'
                        print("LINK_URL: \(URL)")
                        let urlString: String = (URL?.absoluteString)!
                        
                        self.postToFirebase( urlString)
                        print("LINK_URLString: \(urlString)")
                    }
                }

                
            }
        }
            } else {
                self.postToFirebase(nil)
            }
        }
    }
    
    
    @IBAction func  selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    func postToFirebase(imgUrl: String?){
        
        var post: Dictionary<String, AnyObject> = [
            "description": postField.text!,
            "likes": 0,
            "dislikes": 0,
          //  "comment": commentBtn.!
        ]
        
        if imgUrl != nil {
            post["imageUrl"] = imgUrl
        }
        
        let firebasePost = postRef.childByAutoId()  //important ojo
        firebasePost.setValue(post)
        
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
        // self.downloadPicButton.enabled = true
    }
    
  
    
    //MARK: - PostCellDelegator Methods
    
    func callSegueFromCell(myData dataobject: AnyObject) {
        
        

        //try not to send self, just to avoid retain cycles(depends on how you handle the code on the next controller)
        self.performSegueWithIdentifier("segue_commentVC", sender:dataobject )
        
    }
    
    
    
    
    
    
    
    
}


























