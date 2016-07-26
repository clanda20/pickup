//
//  EditProfileVC.swift
//  pickup
//
//  Created by christian landa on 7/22/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage



class EditProfileVC: UIViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    @IBOutlet weak var importedImageView: UIImageView!
    
    
    var activeUser: String?
    var imageSaved: String?
     var imageData = NSData()
    let imagePC = UIImagePickerController()
    var popover:UIPopoverController?=nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func cancel(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func save(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
      // let avatarRef = DataService.ds.REF_USER_CURRENT
        
        let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\("userPhoto")"
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
                DataService.ds.REF_USER_CURRENT.updateChildValues(["avatar": downloadURL])
            }
            
      /*  if let image = imageSaved {
            
            let post = ["avatar": image]
            
           // filePath.updateChildValues(post)
        }  */
        
 
    }
    }
    
    @IBAction func importImage(sender: AnyObject) {
        
        
        
    /*   // let imagePC = UIImagePickerController()
        imagePC.delegate = self
        imagePC.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePC.allowsEditing = false
        
        self.presentViewController(imagePC, animated: true, completion: nil)
        
      */
        
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
            popover!.presentPopoverFromRect(importedImageView.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        importedImageView.image = image
      //  var imageData = NSData()
        
         imageData = UIImageJPEGRepresentation(image, 0.2)!
        imageSaved = imageData.base64EncodedStringWithOptions([])
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
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
            popover!.presentPopoverFromRect(importedImageView.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }

}
