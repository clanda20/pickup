//
//  FriendsVC.swift
//  pickup
//
//  Created by christian landa on 7/14/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Firebase


class FriendsVC: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var friendsTableView: UITableView!
    
   var snapshot2Dict = [String: String]()
    
    var contacts = [Contact]()
    
    
    var contactInfo: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        friendsTableView.dataSource = self
        QuerryUserFollowing()
}
    
    func QuerryUserFollowing(){
        
        DataService.ds.REF_USER_CURRENT.child("followings").observeEventType(.ChildAdded, withBlock:{ snapshot in
            
           
            
            self.contacts = []
            let friendID = snapshot.key
            let friendReference = DataService.ds.REF_USERS.child(friendID)
            
            friendReference.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                print("new way: \(snapshot)")
                
                if let contactDict = snapshot.value as? [String: AnyObject]
                    
                {
                    print("dictionary \(contactDict)")
                    
                    
                    let key = snapshot.key
                    let contact = Contact(contactKey: key, dictionary: contactDict)
                    
                    self.contacts.append(contact)
                    
                }
                
                self.friendsTableView.reloadData()
                
                
            })
            
            }, withCancelBlock: nil)
        
    }


        
   
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return contacts.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let contact = contacts[indexPath.row]
        print("testing Full Name: \(contact.fullName)")
        
        if let cell =  tableView.dequeueReusableCellWithIdentifier("friendsCell") as? FriendsCell {
            
            cell.configureCell(contact)
            
            
            return cell
            
        } else {
            
            return ContactCell()
        }
        
    }
    
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "goFromFriendstoUserProfile" {
            
            let index = friendsTableView.indexPathForSelectedRow
            let contactSelected = contacts[index!.row]
            
            print("ContactKEY-Outside-----xxxxx-----------------: \(contactSelected.contactKey)")
            let destinationVC = segue.destinationViewController as! contactProfileVC
            
            destinationVC.contactId   = contactSelected.contactKey
            
            
            
            
        }
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        super.viewWillDisappear(animated)
        //self.friendsTableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        friendsTableView.reloadData()
    }
    
    
}

