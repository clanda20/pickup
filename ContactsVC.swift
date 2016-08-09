//
//  ContactsVC.swift
//  pickup
//
//  Created by christian landa on 7/11/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class ContactsVC: UIViewController, UITableViewDataSource {

    @IBOutlet weak var contactsTableView: UITableView!
    
 
    
    var contacts = [Contact]()
    
    var contactInfo: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        contactsTableView.dataSource = self
        
        
       DataService.ds.REF_USERS.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            
         print(snapshot.value)
            
         
            
            self.contacts = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]  {
                
                for snap in snapshots {
                   print("SNAP: \(snap)")
                    
                    
                    
                    if let contactDict = snap.value as? [String : AnyObject]  {
                        
                        
                        let key = snap.key
                        let contact = Contact(contactKey: key, dictionary: contactDict)
                        
                        
                       
                        
                      //  self.contacts.insert(contact, atIndex: 0)  //self.posts.append(post)
                        self.contacts.append(contact)
                        
                         print("SNAP ContactsXXXXX: \(self.contacts)")
                        print("ContactKEY-Outside----------------------: \(contact.contactKey)")                    }
                }
            }
            self.contactsTableView.reloadData()
            
        })

    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return contacts.count
    }
    
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let contact = contacts[indexPath.row]
        
        if let cell =  tableView.dequeueReusableCellWithIdentifier("cell") as? ContactCell {
            
        cell.configureCell(contact)
            
        
        return cell
            
        } else {
            
            return ContactCell()
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "goToContactProfile" {
            
             let index = contactsTableView.indexPathForSelectedRow
             let contactSelected = contacts[index!.row]
            
             print("ContactKEY-Outside-----xxxxx-----------------: \(contactSelected.contactKey)")
            let destinationVC = segue.destinationViewController as! contactProfileVC
            
                 destinationVC.contactId   = contactSelected.contactKey
            
           // NSUserDefaults.standardUserDefaults().setValue(contactSelected, forKey: "contactSelected")
            
            
            
        }
        
    }
    
    
  

    }
     
