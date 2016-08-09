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


class ViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
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
                        
                        
                        NSUserDefaults.standardUserDefaults().setValue(authID, forKey: "uid")
                         NSUserDefaults.standardUserDefaults().setValue(authData?.uid, forKey: "userID") /// temporal to prevent crash 
                        

                        //Write DataBase
                        
                        let user = ["provider": credential.provider,"id": "\(authID!)", "fullName": "\(fullName!)",  "avatar": "\(photoURL!)" ,"likes":"0", "dislikes":"0", "email": "\(email!)","postNumber":"0", "followers": "0", "following": "0"]
                      //  DataService.ds.createFirebaseUser(authID!, user: user )
                        self.createFirebaseUser(authID!, user: user )
                        
                       // NSUserDefaults.standardUserDefaults().setValue(authData?.uid, forKey: "uid")
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }
                })
            }
        
    }


 }
    
    @IBAction func emailBtnPressed(sender: AnyObject!){
        
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            
            
            FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { authData, error in
                
                
                if error != nil {
                    print(error)
                    
                   // if error == STATUS_ACCOUNT_NONEXIST {
                        
                    if error!.code == 17011 { //17011
                        FIRAuth.auth()?.createUserWithEmail(email, password: pwd, completion: { authData, error in
                            
                            if error != nil {
                                self.showErrorAlert("Could not create account", msg: "Problem creating account. Try something else. This Email might be attached to Facebook")
                                
                            } else{
                                print("Logged In Xxxxxxxxx!\(authData?.uid)")
                                
                                let authID = authData?.uid
                                print("Logged In Xxxxxxxxx!\(email)")
                                NSUserDefaults.standardUserDefaults().setValue(authID, forKey: "uid")
                                 NSUserDefaults.standardUserDefaults().setValue(authData?.uid, forKey: "userID") /// temporal to prevent crash 
                                
                              //  FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: nil)
                                
                                FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { authData, error in
                                
                                    let user = ["provider": authData!.providerID,"id": "\(authID!)", "fullName": "fullName",  "avatar": "avatar" ,"likes":"0", "dislikes":"0", "email": "___@youremail.com","postNumber":"0", "followers": "0", "following": "0"]
                                   
                                    self.createFirebaseUser(authID!, user: user as! Dictionary<String, String>)
                                
                              //   NSUserDefaults.standardUserDefaults().setValue(authData?.uid, forKey: "uid")
                                    
                                })
                                
                               // DataService.ds.createFirebaseUser(authID!, user: user )
                                
                                print("Logged In 2 xxxxxxXxxxxxxxx!\(authData?.uid)")
                                
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
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
            
        }) // end spinner
        
        } else {
            showErrorAlert("Email and Password Required", msg: "You must enter an email and a password")
        }
        
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
    
    
    
    

}



