//
//  ContactSearchTable.swift
//  pickup
//
//  Created by christian landa on 9/6/16.
//  Copyright © 2016 christian landa. All rights reserved.
//



import UIKit
class ContactSearchTable : UITableViewController {
    
     var filteredData: [String]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
       QueryFullName()

        
    }
    
    
    
}



extension ContactSearchTable : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
    }
}

extension ContactSearchTable {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // return matchingItems.count
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
      //  let selectedItem = matchingItems[indexPath.row].placemark
       // cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = ""
        return cell
    }
    
 /*   func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            filteredData = data //use your array in place od data
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredData = data.filter({(dataItem: String) -> Bool in
                // If dataItem matches the searchText, return true to include it
                if dataItem.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        self.tableView.reloadData()
    }  */
    
    
 
    
    func QueryFullName(){
        
        DataService.ds.REF_BASE.child("users")
            .queryOrderedByChild("fullName")
            .queryEqualToValue("Christian Landa")
            .observeSingleEventOfType(.Value, withBlock: { (snapshot) -> Void in
                
                print("Search:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \(snapshot.value)")
                
                
            })
    }
}