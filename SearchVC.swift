//
//  SearchVC.swift
//  pickup
//
//  Created by christian landa on 9/8/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Firebase

class SearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate, CustomSearchControllerDelegate {
//    @available(iOS 8.0, *)
//    public func updateSearchResults(for searchController: UISearchController) {
//        //<#code#>
//    }

    
    @IBOutlet weak var tblSearchResults: UITableView!
    
    var dataArray = [String]()
    var contacts = [Contact]()
    

    
    var filteredArray = [String]()
    
    var filteredContacts =  [Contact]()
    
   // var  contactsSearch = [Contact]()
    
    var searchStringOut: String!
    var  fullName: String!
    
    
    
    var shouldShowSearchResults = false
    
    var searchController: UISearchController!
    
    var customSearchController: CustomSearchController!
    
  
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        QueryUsers()
        
        
        
        tblSearchResults.delegate = self
        tblSearchResults.dataSource = self
        
      //  loadListOfCountries()
        
        // Uncomment the following line to enable the default search controller.
        // configureSearchController()
        
        // Comment out the next line to disable the customized search controller and search bar and use the default ones. Also, uncomment the above line.
        configureCustomSearchController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UITableView Delegate and Datasource functions
    
    func numberOfSections( in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return filteredContacts.count
        }
        else {
            return contacts.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // let cell = tableView.dequeueReusableCellWithIdentifier("idCell", forIndexPath: indexPath)
        
       // let contact = contacts[indexPath.row]
        
       let cell =  tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath as IndexPath) as? SearchCell
        if shouldShowSearchResults {
           // cell!.textLabel?.text = filteredArray[indexPath.row]
             let filtercontact = filteredContacts[indexPath.row]
            cell!.configureCell(contact: filtercontact)
            return cell!
        }
        else {
           // cell.textLabel?.text = dataArray[indexPath.row]
           let contact = contacts[indexPath.row]
             cell!.configureCell(contact: contact)
            return cell!
        }
        return ContactCell()
    }
        

    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    
    // MARK: Custom functions
    
 /*   func loadListOfCountries() {
        // Specify the path to the countries list file.
        let pathToFile = NSBundle.mainBundle().pathForResource("countries", ofType: "txt")
        
        if let path = pathToFile {
            // Load the file contents as a string.
            let countriesString = try! String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            
            // Append the countries from the string to the dataArray array by breaking them using the line change character.
            dataArray = countriesString.componentsSeparatedByString("\n")
            
            // Reload the tableview.
            tblSearchResults.reloadData()
        }
    } */
    
    func configureSearchController() {
        // Initialize and perform a minimum configuration to the search controller.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        // Place the search bar view to the tableview headerview.
        tblSearchResults.tableHeaderView = searchController.searchBar
    }
    
    
    func configureCustomSearchController() {
       // customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRectMake(0.0, 0.0, tblSearchResults.frame.size.width, 50.0), searchBarFont: UIFont(name: "Futura", size: 16.0)!, searchBarTextColor: UIColor.orangeColor(), searchBarTintColor: UIColor.blackColor())
        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRect(x: 0.0, y: 0.0, width: tblSearchResults.frame.size.width, height: 50.0 ), searchBarFont: UIFont(name: "Futura", size: 16.0)!, searchBarTextColor: UIColor.orange, searchBarTintColor: UIColor.black)
         customSearchController.customSearchBar.placeholder = "Search by Name only..."
        tblSearchResults.tableHeaderView = customSearchController.customSearchBar
        
        customSearchController.customDelegate = self
    }
    
    
    // MARK: UISearchBarDelegate functions
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tblSearchResults.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tblSearchResults.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tblSearchResults.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    
    // MARK: UISearchResultsUpdating delegate function
    
   func updateSearchResults(for searchController: UISearchController) {
        guard let searchString = searchController.searchBar.text else {
            return
        }
        
        // Filter the data array and get only those countries that match the search text.
      //  self.filteredContacts = contacts.filter({ (fullName) -> Bool in
            
       self.filteredContacts = contacts.filter({ (contacts) -> Bool in
      //  QuerySearchUser()
        
            let fullNameText:NSString = self.fullName as NSString
            
            return (fullNameText.range(of: searchString, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound //  .CaseInsensitiveSearch).location) != NSNotFound
        
        })
        
        // Reload the tableview.
        tblSearchResults.reloadData()
    }
    
    
    // MARK: CustomSearchControllerDelegate functions
    
    func didStartSearching() {
        shouldShowSearchResults = true
     //   QuerySearchUser()
        tblSearchResults.reloadData()
    }
    
    
    func didTapOnSearchButton() {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
          
            tblSearchResults.reloadData()
        }
    }
    
    
    func didTapOnCancelButton() {
        shouldShowSearchResults = false
        tblSearchResults.reloadData()
    }
    
    
    func didChangeSearchText(searchText: String) {
        // Filter the data array and get only those countries that match the search text.
        // self.filteredContacts = contacts.filter({ (fullName) -> Bool in
              QuerySearchUser(searchText: searchText)
            
//let fullNameText:NSString = self.fullName
            
            //(fullNameText.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
       // })
        
     //     var (snapshot.value)
        
        // Reload the tableview.
        tblSearchResults.reloadData()
    }
    
    func QueryUsers(){
    
    DataService.ds.REF_USERS.queryLimited(toLast: 8).observe(FIRDataEventType.value, with: { (snapshot) in
    
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
    
    print("SNAP Contacts Search  -------------------XXXXX: \(self.contacts)")
    print("Before Search USer----------------------: \(contact.contactKey)")                    }
    }
    }
   self.tblSearchResults.reloadData()
    
    })

    }
    
    
    func QuerySearchUser(searchText: String){
        
        let searchStringOut2 = searchText.uppercased()
        
        print("Upper CASE:  \(searchStringOut2)")
        
        DataService.ds.REF_BASE.child("users")
            .queryOrdered(byChild: "firstName")
            .queryEqual(toValue: searchStringOut2)
            .observeSingleEvent(of: .value, with: {
              //  snapshot in
             
     /*   DataService.ds.REF_BASE.child("users").queryOrderedByChild("fullName").queryStartingAtValue(searchStringOut2).queryEndingAtValue("b\u{f8ff}")
            .observeEventType(.Value, withBlock: { */
               (snapshot) -> Void in
                
                 print("Search:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \(snapshot.value)")
                
                self.filteredContacts = []
                
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]  {
                    
                    for snap in snapshots {
                        print("SNAP Search: \(snap)")
                        
                        
                        
                        if let contactDictSearch = snap.value as? [String : AnyObject]  {
                            
                            
                            let key = snap.key
                            let contactSearch = Contact(contactKey: key, dictionary: contactDictSearch)
                            
                            
                            
                            
                            //  self.contacts.insert(contact, atIndex: 0)  //self.posts.append(post)
                            self.filteredContacts.append(contactSearch)
                            
                            print("SNAP Contacts filteredContactsSearch  -------------------XXXXX: \(self.filteredContacts)")
                            print("Before Search filteredContacts USer----------------------: \(contactSearch.contactKey)")                    }
                    }
                }
                self.tblSearchResults.reloadData()
 
                
            })
        
    }
    
     override func prepare(for forsegue: UIStoryboardSegue, sender: Any?) {
        
        if forsegue.identifier == "goToContactProfile" &&  shouldShowSearchResults  != false{
            
            let index = tblSearchResults.indexPathForSelectedRow
            let contactSelected = filteredContacts[index!.row]
            
            print("ContactKEY-Outside-----xxxxx-----------------: \(contactSelected.contactKey)")
            let destinationVC = forsegue.destination as! contactProfileVC
            
            destinationVC.contactId   = contactSelected.contactKey
            
            
        } else {
            
            let index = tblSearchResults.indexPathForSelectedRow
            let contactSelected = contacts[index!.row]
            
            print("ContactKEY-Outside-----xxxxx-----------------: \(contactSelected.contactKey)")
            let destinationVC = forsegue.destination as! contactProfileVC
            
            destinationVC.contactId   = contactSelected.contactKey
            
        }
        
    }

    
}
