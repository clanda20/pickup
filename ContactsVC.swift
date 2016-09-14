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

class ContactsVC: UIViewController, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var contactsTableView: UITableView!
    
    
    //declare searchBar
    var searchBar = UISearchBar()
    
    var resultSearchController:UISearchController? = nil
 
    
    var contacts = [Contact]()
    
    var contactInfo: NSDictionary?
    
    //added sep 9
    
    var shouldShowSearchResults = false
    
    //end added sep 9
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
        //implement search bar
      /* 9-7  searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for a Friend"
        searchBar.tintColor = UIColor.groupTableViewBackgroundColor()
        searchBar.frame.size.width = self.view.frame.size.width - 30
        
        navigationItem.titleView = resultSearchController?.searchBar
        let searchItem = UIBarButtonItem(customView: searchBar)
        
        
        self.navigationItem.leftBarButtonItem = searchItem  //9-7 */
        
        
        
      /*  searchBar = ContactSearchTable!.searchBar
        searchBar.sizeToFit()
       searchBar.placeholder = "Search for places"
      //  navigationItem.titleView = resultSearchController?.searchBar  */
        self.automaticallyAdjustsScrollViewInsets = false
        
        
        let contactSearchTable = storyboard!.instantiateViewControllerWithIdentifier("ContactSearchTable") as! ContactSearchTable
        resultSearchController = UISearchController(searchResultsController: contactSearchTable)
        resultSearchController?.searchResultsUpdater = contactSearchTable
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        
        
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
    
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if shouldShowSearchResults {
         return  0
        }
       else {
        return contacts.count
        }
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
           
            
        }
        
    }
    
  
        
    }
    
    
  

    
     
