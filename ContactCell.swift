//
//  ContactCell.swift
//  pickup
//
//  Created by christian landa on 7/11/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Firebase

class ContactCell: UITableViewCell {
   // var contact: Contact!
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(contact: Contact) {
        
        self.contact = contact
        
        self.firstNameLbl.text = contact.fullName
        
        
         downloadAvatar(image: contact.avatar!, completion:  { (data) in
            self.profilePicture.image = UIImage(data: data as Data)
            self.profilePicture.layer.cornerRadius = 30.0
            self.profilePicture.clipsToBounds = true
        })
 
  
    /*   let url_Avatar = NSURL(string: contact.avatar!)
        let data_Url_Avatar = NSData(contentsOfURL: url_Avatar!)
        self.profilePicture.image = UIImage(data: data_Url_Avatar!)  */
    
}

 
 
    func downloadAvatar(image:String, completion:@escaping (_ data:NSData)-> ()) {
        
        let urlString = NSURL(string: image)
        let request = URLSession.shared.dataTask(with: urlString! as URL){ (data, response, error) -> Void in
            
            if error == nil {
                
                if let dataValid = data {
                    DispatchQueue.main.async(execute: { () -> Void in
                        completion(dataValid as NSData)
                    })
                    
                }
            }
            
            
        }
        
        request.resume()
    }

}
