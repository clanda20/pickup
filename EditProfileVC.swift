//
//  EditProfileVC.swift
//  pickup
//
//  Created by christian landa on 7/22/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseMessaging
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

    @IBAction func cancel(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func save(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
        
      // let avatarRef = DataService.ds.REF_USER_CURRENT

        guard let currentUser = Auth.auth().currentUser else {
            return
        }

        let filePath = "\(currentUser.uid)/userPhoto"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        let avatarRef = storageRef.child(filePath)
        avatarRef.putData(imageData as Data, metadata: metaData){ (_, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            avatarRef.downloadURL { url, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }

                guard let downloadURL = url?.absoluteString else {
                    return
                }

                DataService.ds.REF_USER_CURRENT.updateChildValues(["avatar": downloadURL])
            }

      /*  if let image = imageSaved {
            
            let post = ["avatar": image]
            
           // filePath.updateChildValues(post)
        }  */
        
 
    }
    }
    
    @IBAction func importImage(_ sender: AnyObject) {
        
        
        
    /*   // let imagePC = UIImagePickerController()
        imagePC.delegate = self
        imagePC.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePC.allowsEditing = false
        
        self.presentViewController(imagePC, animated: true, completion: nil)
        
      */
        
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        {
            UIAlertAction in
        }
        // Add the actions
        self.imagePC.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the controller
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            popover = UIPopoverController(contentViewController: alert)
            popover!.present(from: importedImageView.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
        
    }
    
    
   // func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
    func  imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

      
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        importedImageView.image = image
      //  var imageData = NSData()
        
         imageData = image.jpegData(compressionQuality: 0.05)! as NSData
        imageSaved = imageData.base64EncodedString(options: [])
        
        self.dismiss(animated: true, completion: nil)
        
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
            openGallary()
        }
    }
    
    
    func openGallary()
    {
        self.imagePC.sourceType = UIImagePickerController.SourceType.photoLibrary
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.present(self.imagePC, animated: true, completion: nil)
        }
        else
        {
            popover=UIPopoverController(contentViewController: self.imagePC)
            popover!.present(from: importedImageView.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
