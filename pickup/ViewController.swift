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


class ViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
  
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    @IBAction func fbBtnPressed(sender: UIButton!) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"]) {(facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) ->
            Void in
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else {
                //let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
               // print("Sucessfully logged in with facebook. \(accessToken)")
                
               //  [START headless_facebook_auth]
 
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                
                // [END headless_facebook_auth]
              //  self.firebaseLogin(credential)
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (authData, error) in
                
                    if error != nil {
                        print("Login Failed. \(error)")
                    } else {
                        print("Logged In X!\(authData)")
                        
                        //Write DataBase
                        
                       // let user = ["provider": authData?.providerID, "blah":"test"]
                           let user = ["provider": credential.provider]
                        self.createFirebaseUser((authData?.uid)!, user: user as! Dictionary<String, String>)
                        
                        
                        NSUserDefaults.standardUserDefaults().setValue(authData?.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }
                })
            }
        
    }


 }
    
    @IBAction func emailBtnPressed(sender: UIButton!){
        
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            
            FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { authData, error in
                
                
                if error != nil {
                    print(error)
                    
                   // if error == STATUS_ACCOUNT_NONEXIST {
                        
                    if error!.code == 17011 { //17011{
                        FIRAuth.auth()?.createUserWithEmail(email, password: pwd, completion: { authData, error in
                            
                            if error != nil {
                                self.showErrorAlert("Could not create account", msg: "Problem creating account. Try something else. This Email might be attached to Facebook")
                                
                            } else{
                                
                                NSUserDefaults.standardUserDefaults().setValue(authData!.uid, forKey: KEY_UID)
                                
                              //  FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: nil)
                                    
                                FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { authData, error in
                                
                                    let user = ["provider": authData!.providerID, "blah":"emailTest"]
                                    self.createFirebaseUser((authData?.uid)!, user: user as! Dictionary<String, String>)
                                
                                })
                                    
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                            
                        })
                        
                    }
                    else {
                        self.showErrorAlert("Could not login", msg: "Please check your username and password")
                        
                    }
                    
                } else {
                
                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                
                }
            })
            
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
        ref.child("users").childByAutoId().setValue(user)
    }

}