//
//  FriendsCell.swift
//  pickup
//
//  Created by christian landa on 7/14/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit

class FriendsCell: UITableViewCell {

    var contact: Contact!
    
    @IBOutlet weak var firstNameLbl: UILabel!
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    //  var image:String?
    
    var contacts = [Contact]()
    var posts = [Post]()
    // var contacts: Contact[]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(contact: Contact) {
        
        self.contact = contact
        
        self.firstNameLbl.text = contact.fullName
        
        
        downloadAvatar(contact.avatar!, completion:  { (data) in
            self.profilePicture.image = UIImage(data: data)
            self.profilePicture.layer.cornerRadius = 30.0
            self.profilePicture.clipsToBounds = true
        })
        
        
        /*   let url_Avatar = NSURL(string: contact.avatar!)
         let data_Url_Avatar = NSData(contentsOfURL: url_Avatar!)
         self.profilePicture.image = UIImage(data: data_Url_Avatar!)  */
        
    }
    
    
    
    func downloadAvatar(image:String, completion:(data:NSData)-> ()) {
        
        let urlString = NSURL(string: image)
        let request = NSURLSession.sharedSession().dataTaskWithURL(urlString!){ (data, response, error) -> Void in
            
            if error == nil {
                
                if let dataValid = data {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(data: dataValid)
                    })
                    
                }
            }
            
            
        }
        
        request.resume()
    }


}
