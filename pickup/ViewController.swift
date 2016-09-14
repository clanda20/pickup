//
//  ViewController.swift
//  pickup
//
//  Created by christian landa on 5/20/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import MapKit


class ViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var  fullNameEmailEnter: String!
    
    var myFullNameString: String!
   // var myFullNameStringArr: String!
    
    var firstName: String!
    var lastName: String!

    
// @IBOutlet var textFieldToBottomLayoutGuideConstraint: NSLayoutConstraint!
 //  @IBOutlet var textFieldToBottomLayoutGuideConstraint2: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
  
   //dismiss keyboard
     self.emailField.delegate = self
     self.passwordField.delegate = self
        
    
  
    }
    
      

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey("uid") != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    @IBAction func fbBtnPressed(sender: UIButton!) {
        let facebookLogin = FBSDKLoginManager()
       // let facebookLogin = FBSDKLoginButton()
       // facebookLogin.delegate = self
        
        facebookLogin.logInWithReadPermissions(["email"]) {(facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) ->
            Void in
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else  if facebookResult.isCancelled {
                  print("Facebook login was cancelled.")
            } else {
               
                
               //  [START headless_facebook_auth]
 
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                
                // [END headless_facebook_auth]
              //  self.firebaseLogin(credential)
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (authData, error) in
                
                    if error != nil {
                        print("Login Failed. \(error)")
                    } else {
                         print("Logged In Xxxxxxxxx!\(authData?.uid)")
                        
                         print("Logged In Name!\(authData?.displayName)")
                        
                        
                        print("Logged In email!\(authData?.email)")
                        
                        print("Logged In email!\(authData?.photoURL)")
                        
                        
                       
                        
                        let authID = authData?.uid
                        let fullName = authData?.displayName
                        let email = authData?.email
                        let photoURL =  authData?.photoURL
                        
                        
                        var myFullNameString: String = "\(fullName!.uppercaseString)";
                        var myFullNameStringArr = myFullNameString.componentsSeparatedByString(" ")
                        
                        var firstName: String = myFullNameStringArr [0]
                        var lastName: String = myFullNameStringArr [1]
                        
                        
                        NSUserDefaults.standardUserDefaults().setValue(authID, forKey: "uid")
                         NSUserDefaults.standardUserDefaults().setValue(authData?.uid, forKey: "userID") /// temporal to prevent crash 
                      //  let location = mapView.userLocation.location

                        //Write DataBase
                        
                        let user = ["provider": credential.provider,"id": "\(authID!)", "fullName": "\(fullName!.uppercaseString)", "firstName": firstName, "lastName": lastName,  "avatar": "\(photoURL!)" ,"likes":"0", "dislikes":"0", "email": "\(email!)","postNumber":"0", "followers": "0", "following": "0", "geo":"geo"]
                      //  DataService.ds.createFirebaseUser(authID!, user: user )
                        self.createFirebaseUser(authID!, user: user )
                        
                       // NSUserDefaults.standardUserDefaults().setValue(authData?.uid, forKey: "uid")
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }
                })
            }
        
    }


 }
    //  EMAIL LOGIN 
    
  
    
    @IBAction func forgotClick(sender: AnyObject) {
     
        
     /*   let email = emailField.text
    
        FIRAuth.auth()?.sendPasswordResetWithEmail(email!, completion: { (error) in
            
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                
                if error != nil {
                    
                    // Error - Unidentified Email
                   
                    self.showErrorAlert("Unidentified Email Address", msg: "Please, re-enter the email you have registered with, Above.")
                    
                    
                    
                } else {
                    
                    // Success - Sends recovery email
                    
                   
                    
                    let alertController = UIAlertController(title: "Email Sent", message: "An email has been sent. Please, check your email now.", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                
            }})  */
        
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Reset Password", message: "Enter Email", preferredStyle: .Alert)
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        alertController!.addAction(cancelAction)
        alertController!.addTextFieldWithConfigurationHandler(
            {(textField: UITextField!) in
                textField.placeholder = "re-enter registered email"
        })
        
        let action = UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default, handler: {[weak self]
            (paramAction:UIAlertAction!) in
            if let textFields = alertController?.textFields{
                let theTextFields = textFields as [UITextField]
                let enteredText = theTextFields[0].text
                let email = enteredText
                
                
                FIRAuth.auth()?.sendPasswordResetWithEmail(email!, completion: { (error) in
                    
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        
                        if error != nil {
                            
                            // Error - Unidentified Email
                            
                            self!.showErrorAlert("Unidentified Email Address", msg: "Please, re-enter the email you have registered with.")
                            
                            
                            
                        } else {
                            
                            // Success - Sends recovery email
                            
                            
                            
                            let alertController = UIAlertController(title: "Email Sent", message: "An email has been sent. Please, check your email now.", preferredStyle: .Alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
                                
                                self!.dismissViewControllerAnimated(true, completion: nil)
                            }))
                            self!.presentViewController(alertController, animated: true, completion: nil)
                        }
                        
                    }})
                
                
                
                
            }
            })
        
        alertController?.addAction(action)
        self.presentViewController(alertController!,animated: true,completion:  nil)
        
        
    }
    func showErrorAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>){
       // ref.child("users").childByAutoId().setValue(user)
        ref.child("users").child(uid).updateChildValues(user)

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //dismiss keyboard
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    
    }
    
    @IBAction func emailBtnPressed(sender: AnyObject!){
        
        
        
        AddNewUserEmail()
        
        
    }
   
    func AddNewUserEmail(){
        
       if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            
            
            FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { authData, error in
                
                
                
                if error != nil {
                    print(error)
                    
                    // if error == STATUS_ACCOUNT_NONEXIST {
                    
                    if error!.code == 17011 { //17011
                        
                        
                        
                        FIRAuth.auth()?.createUserWithEmail(email, password: pwd, completion: { authData, error in
                            //
                            if error != nil {
                                self.showErrorAlert("Could not create account", msg: "Problem creating account. Try something else. This Email might be attached to Facebook")
                                
                            } else{
                             
                                print("Logged In Xxxxxxxxx!\(authData?.uid)")
                                
                                let authID = authData?.uid
                                print("Logged In Xxxxxxxxx!\(email)")
                                NSUserDefaults.standardUserDefaults().setValue(authID, forKey: "uid")
                                NSUserDefaults.standardUserDefaults().setValue(authData?.uid, forKey: "userID") /// temporal to prevent crash
                                
                                
                                FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { authData, error in
                                    
                                    var interval = NSDate().timeIntervalSince1970
                                    
                                    var date = NSDate(timeIntervalSince1970: interval)
                                    
                                  //  self.EmailAuthorization(authID, authData: authData, date: date)
                                    
                                self.AddFullNamefromEMail(authID, authData: authData, date: date)
                                    
                                 })
                                
                          /*      FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { authData, error in
                                    
                                    var interval = NSDate().timeIntervalSince1970
                                    
                                    var date = NSDate(timeIntervalSince1970: interval)
                                    
                                    let user = ["provider": authData!.providerID,"id": "\(authID!)", "fullName":  self.myFullNameString, "firstName":  self.firstName, "lastName":  self.lastName,  "avatar": "avatar" ,"likes":"0", "dislikes":"0", "email": authData!.email,"postNumber":"0", "followers": "0", "following": "0", "time": "\(date)"]
                                    authData!
                                    self.createFirebaseUser(authID!, user: user as! Dictionary<String, String>)
                                    
                                    //   NSUserDefaults.standardUserDefaults().setValue(authData?.uid, forKey: "uid")
                                    
                                })  */
                                
                                // DataService.ds.createFirebaseUser(authID!, user: user )
                                
                              //  print("Logged In 2 xxxxxxXxxxxxxxx!\(authData?.uid)")
                                
                              //  self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                                
                                
                            }
                            
                        })
                    }
                    else {
                        
                        self.showErrorAlert("Could not login", msg: "Please check your username and password")
                        
                    }
                    
                } else {
                    
                    NSUserDefaults.standardUserDefaults().setValue(authData?.uid, forKey: "uid")
                    NSUserDefaults.standardUserDefaults().setValue(authData?.uid, forKey: "userID") /// temporal to prevent crash
                    
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    
                }
                
            })
            
        } else {
            showErrorAlert("Email and Password Required", msg: "You must enter an email and a password")
        }
        
        
    }
    
 
    
    func AddFullNamefromEMail(authID: String!, authData: FIRUser?, date:NSDate!){
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Enter Text", message: "Enter your Name and LastName", preferredStyle: .Alert)
        
        alertController!.addTextFieldWithConfigurationHandler(
            {(textField: UITextField!) in
                textField.placeholder = "Enter Name and LastName"
        })
        
        let action = UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default, handler: {[weak self]
            (paramAction:UIAlertAction!) in
            if let textFields = alertController?.textFields{
                let theTextFields = textFields as [UITextField]
                let enteredText = theTextFields[0].text
                let fullNameEmailEnter = enteredText
                
                
                
                self!.myFullNameString =  fullNameEmailEnter!.uppercaseString
                let myFullNameStringArr = self!.myFullNameString.componentsSeparatedByString(" ")
                
                self!.firstName = myFullNameStringArr[0]
                self!.lastName  = myFullNameStringArr[1]
                
                self!.EmailAuthorization(authID, authData: authData, date: date)
                
                
            }
            })
        
        alertController?.addAction(action)
        self.presentViewController(alertController!,animated: true,completion:  nil)
        
    }
    
    func EmailAuthorization(authID: String!, authData: FIRUser?, date:NSDate! ){
        
        let authID = authID
        let authData = authData
        let  date = date
        
        let user = ["provider": authData!.providerID,"id": "\(authID!)", "fullName":  self.myFullNameString, "firstName":  self.firstName, "lastName":  self.lastName,  "avatar": "avatar" ,"likes":"0", "dislikes":"0", "email": authData!.email,"postNumber":"0", "followers": "0", "following": "0", "time": "\(date)"]
        authData!
        self.createFirebaseUser(authID!, user: user as! Dictionary<String, String>)
        
        //   NSUserDefaults.standardUserDefaults().setValue(authData?.uid, forKey: "uid")
        
        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        
        
    }

    
}



