//
//  EventVC.swift
//  pickup
//
//  Created by christian landa on 8/19/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Firebase

class EventVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var events = [Event]()
    
    
    var contactInfo: NSDictionary?
    
    var hostUid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
      QueryMyEvent_Timeline()
        
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
       // self.navigationController?.setNavigationBarHidden(true , animated: animated);
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
       // self.navigationController?.toolbarHidden = false
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
       // self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.setHidesBackButton(true, animated: false)
       

        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let event = events[indexPath.row]
        
        
        if let cell =  tableView.dequeueReusableCellWithIdentifier("EventCell") as? EventCell {
            
            cell.configureCell(event)
            
            
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
        ref.child("events-timeline").child(KEY_UID!).queryOrderedByChild("dateRaw").queryLimitedToLast(100).observeEventType(.Value , withBlock: { (snapshot) in  //observeSingleEventOfType
            //  self.posts = []
            
            print(snapshot.value)
            
            
            
            self.events = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]  {
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
            
            
            
            }, withCancelBlock: nil)
        
        
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "goToEventDetail" {
            
            let index = tableView.indexPathForSelectedRow
            let eventSelected = events[index!.row]
            
            print("Event Key -xxxxx-----xxxxx-----------------: \(eventSelected.eventKey)")
            let destinationVC = segue.destinationViewController as! EventDetailVC
            
            destinationVC.eventKey   = eventSelected.eventKey
           // destinationVC.hostUid = eventSelected.hostUid
            
            
            
            
        }
        
    }

    
}