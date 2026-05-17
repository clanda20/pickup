//
//  EventVC.swift
//  pickup
//
//  Created by christian landa on 8/19/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseMessaging
import FirebaseStorage

class EventVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var events = [Event]()
    
    
    var contactInfo: NSDictionary?
    
    var hostUid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = false
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
      QueryMyEvent_Timeline()
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       // self.navigationController?.setNavigationBarHidden(true , animated: animated);
        self.tabBarController?.tabBar.isHidden = false

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
      
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
      
     //   self.navigationItem.setHidesBackButton(true, animated: false)
       
        self.tabBarController?.tabBar.isHidden = false
        //jan 11, 2017  
        self.tabBarController?.tabBar.isTranslucent = false
        
    }
    
    
   // func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    func numberOfSections(in tableView: UITableView) -> Int {
     
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let event = events[indexPath.row]
        
        
        if let cell =  tableView.dequeueReusableCell(withIdentifier: "EventCell") as? EventCell {
            
            cell.configureCell(event: event)
            
            
            return cell
            
        } else {
            
            return EventCell()
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func QueryMyEvent_Timeline(){
        
        //DataService.ds.REF_TIMELINE_POST_USERID.queryOrderedByChild("time").queryLimitedToLast(50).observeEventType(.Value
        ref.child("events-timeline").child(KEY_UID!).queryOrdered(byChild: "dateRaw").queryLimited(toLast: 100).observe(.value , with: { (snapshot) in  //observeSingleEventOfType
            //  self.posts = []
            
            print(snapshot.value)
            
            
            
            self.events = []
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]  {
                print("snapshot Events: \(snapshot)")
                for snap in snapshots {
                    //   print("SNAP: july 26 \(snap)")
                    
                    
                    
                    if let eventDict = snap.value as? [String : AnyObject]  {
                        
                        
                        let key = snap.key
                        let event = Event(eventKey: key, dictionary: eventDict)
                        
                        self.hostUid = eventDict["host-uid"]! as! String
                        
                        print("HOstUID:  \(self.hostUid)")
                        
                        //  self.contacts.insert(contact, atIndex: 0)  //self.posts.append(post)
                        self.events.append(event)
                        
                        print("SNAP Events: \(self.events)")
                    }
                }
            }
            //self.events = self.events.reverse()
            self.tableView.reloadData()
            
            
            
        }, withCancel: nil)
        
        
        
        
    }
    
      override func prepare(for forsegue: UIStoryboardSegue, sender: Any?) {
        
        if forsegue.identifier == "goToEventDetail" {
            
            let index = tableView.indexPathForSelectedRow
            let eventSelected = events[index!.row]
            
            print("Event Key -xxxxx-----xxxxx-----------------: \(eventSelected.eventKey)")
            let destinationVC = forsegue.destination as! EventDetailVC
            
            destinationVC.eventKey   = eventSelected.eventKey
           // destinationVC.hostUid = eventSelected.hostUid
            
            
            
            
        }
        
    }
    //  parece no funciona.
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            self.tabBarController?.tabBar.isHidden = false
        }
    }


    
}
