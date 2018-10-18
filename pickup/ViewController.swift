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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.value(forKey: "uid") != nil {
            self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    
    
    @IBAction func fbBtnPressed(sender: UIButton!) {
       let facebookLogin = FBSDKLoginManager()
    // let loginButton = FBSDKLoginButton()
       //loginButton.delegate = self
        
      facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
             if error != nil {
                print("Facebook login failed. Error \(error)")
            } else  if result?.isCancelled  == true {
                  print("Facebook login was cancelled.")
            } else {
               
                
               //  [START headless_facebook_auth]
 
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                // [END headless_facebook_auth]
              //  self.firebaseLogin(credential)
               // FIRAuth.auth()?.signIn(with: credential, completion: { (authData, error) in //NOV 9
                
                    FIRAuth.auth()?.signIn(with: credential) { (authData, error) in

            
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
                        
                        
                        let myFullNameString: String = "\(fullName!.uppercased())";
                    //    var myFullNameStringArr = myFullNameString.componentsSeparatedByString(" ")
                        var myFullNameStringArr = myFullNameString.components(separatedBy: " ")
                        
                        let firstName: String = myFullNameStringArr [0]
                        let lastName: String = myFullNameStringArr [1]
                        
                        let interval = NSDate().timeIntervalSince1970
                        let date = NSDate(timeIntervalSince1970: interval)
                        
                        
                        UserDefaults.standard.setValue(authID, forKey: "uid")
                         UserDefaults.standard.setValue(authData?.uid, forKey: "userID") /// temporal to prevent crash 
                      //  let location = mapView.userLocation.location

                        //Write DataBase
                        
                        let user = ["provider": credential.provider,"id": "\(authID!)", "fullName": "\(fullName!.uppercased())", "firstName": firstName, "lastName": lastName,  "avatar": "\(photoURL!)" , "email": "\(email!)","notifications": "0","postNumber": "0", "followers": "0", "following": "0", "time": "\(date)"]
                      //  DataService.ds.createFirebaseUser(authID!, user: user )
                        self.createFirebaseUser(uid: authID!, user: user )
                        
                       // NSUserDefaults.standardUserDefaults().setValue(authData?.uid, forKey: "uid")
                        self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
                    }
                }
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
        alertController = UIAlertController(title: "Reset Password", message: "Enter Email", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        alertController!.addAction(cancelAction)
        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "re-enter registered email"
        })
        
        let action = UIAlertAction(title: "Submit", style: UIAlertAction.Style.default, handler: {[weak self]
            (paramAction:UIAlertAction!) in
            if let textFields = alertController?.textFields{
                let theTextFields = textFields as [UITextField]
                let enteredText = theTextFields[0].text
                let email = enteredText
                
                
                FIRAuth.auth()?.sendPasswordReset(withEmail: email!, completion: { (error) in
                    
                    
                    OperationQueue.main.addOperation {
                        
                        if error != nil {
                            
                            // Error - Unidentified Email
                            
                            self!.showErrorAlert(title: "Unidentified Email Address", msg: "Please, re-enter the email you have registered with.")
                            
                            
                            
                        } else {
                            
                            // Success - Sends recovery email
                            
                            
                            
                            let alertController = UIAlertController(title: "Email Sent", message: "An email has been sent. Please, check your email now.", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                
                                self!.dismiss(animated: true, completion: nil)
                            }))
                            self!.present(alertController, animated: true, completion: nil)
                        }
                        
                    }})
                
                
                
                
            }
            })
        
        alertController?.addAction(action)
        self.present(alertController!,animated: true,completion:  nil)
        
        
    }
    func showErrorAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>){
       // ref.child("users").childByAutoId().setValue(user)
        ref.child("users").child(uid).updateChildValues(user)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //dismiss keyboard
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    
    }
    
    @IBAction func emailBtnPressed(sender: AnyObject!){
        
        
        
        AddNewUserEmail()
        
        
    }
   
    func AddNewUserEmail(){
        
       if let email = emailField.text, email != "", let pwd = passwordField.text, pwd != "" {
            
            
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { authData, error in
                
                
                
                if error != nil {
                    print(error!)
                    
                    // if error == STATUS_ACCOUNT_NONEXIST {
                    
                    if error!._code == 17011 { //17011
                        
                        
                        
                        FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { authData, error in
                            //
                            if error != nil {
                                self.showErrorAlert(title: "Could not create account", msg: "Problem creating account. Try something else. This Email might be attached to Facebook")
                                
                            } else{
                             
                                print("Logged In Xxxxxxxxx!\(authData?.uid)")
                                
                                let authID = authData?.uid
                                print("Logged In Xxxxxxxxx!\(email)")
                                UserDefaults.standard.setValue(authID, forKey: "uid")
                                UserDefaults.standard.setValue(authData?.uid, forKey: "userID") /// temporal to prevent crash
                                
                                
                                FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { authData, error in
                                    
                                    let interval = NSDate().timeIntervalSince1970
                                    
                                    let date = NSDate(timeIntervalSince1970: interval)
                                    
                                  //  self.EmailAuthorization(authID, authData: authData, date: date)
                                    
                                self.AddFullNamefromEMail(authID: authID, authData: authData, date: date)
                                    
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
                        
                        self.showErrorAlert(title: "Could not login", msg: "Please check your username and password")
                        
                    }
                    
                } else {
                    
                    UserDefaults.standard.setValue(authData?.uid, forKey: "uid")
                    UserDefaults.standard.setValue(authData?.uid, forKey: "userID") /// temporal to prevent crash
                    
                    self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
                    
                }
                
            })
            
        } else {
            showErrorAlert(title: "Email and Password Required", msg: "You must enter an email and a password")
        }
        
        
    }
    
 
    
    func AddFullNamefromEMail(authID: String!, authData: FIRUser?, date:NSDate!){
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Enter Text", message: "Enter your Name and LastName", preferredStyle: .alert)
        
        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Enter Name and LastName"
        })
        
        let action = UIAlertAction(title: "Submit", style: UIAlertAction.Style.default, handler: {[weak self]
            (paramAction:UIAlertAction!) in
            if let textFields = alertController?.textFields{
                let theTextFields = textFields as [UITextField]
                let enteredText = theTextFields[0].text
                let fullNameEmailEnter = enteredText
                
                
                
                self!.myFullNameString =  fullNameEmailEnter!.uppercased()
                let myFullNameStringArr = self!.myFullNameString.components(separatedBy: " ")  // componentsSeparated(by: " ")
                
                self!.firstName = myFullNameStringArr[0]
                self!.lastName  = myFullNameStringArr[1]
                
                self!.EmailAuthorization(authID: authID, authData: authData, date: date)
                
                
            }
            })
        
        alertController?.addAction(action)
        self.present(alertController!,animated: true,completion:  nil)
        
    }
    
    func EmailAuthorization(authID: String!, authData: FIRUser?, date:NSDate! ){
        
        let authID = authID
        let authData = authData
        let  date = date!
        
        let user = ["provider": authData!.providerID,"id": "\(authID!)", "fullName":  self.myFullNameString, "firstName":  self.firstName, "lastName":  self.lastName,"notifications": "0","avatar": "avatar" ,"likes":"0", "dislikes":"0", "email": authData!.email,"postNumber":"0", "followers": "0", "following": "0", "time": "\(date)"]
      //  authData!
        self.createFirebaseUser(uid: authID!, user: user as! Dictionary<String, String>)
        
        //   NSUserDefaults.standardUserDefaults().setValue(authData?.uid, forKey: "uid")
        
        self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
        
        
    }
    
//    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
//        print("User Logged In")
//        
//        if ((error) != nil)
//        {
//            // Process error
//        }
//        else if result.isCancelled {
//            // Handle cancellations
//        }
//        else {
//            // If you ask for multiple permissions at once, you
//            // should check if specific permissions missing
//            if result.grantedPermissions.contains("email")
//            {
//                // Do work
//            }
//        }
//    }
//    
//    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
//        print("User Logged Out")
//    }

    
}



