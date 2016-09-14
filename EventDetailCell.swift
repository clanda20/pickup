//
//  EventDetailCell.swift
//  pickup
//
//  Created by christian landa on 8/24/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit

class EventDetailCell: UITableViewCell{

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var fullNameLbl: UILabel!
    
     var contact: Contact!


override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
}

override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    }
    func configureCell(contact: Contact) {
        
        self.contact = contact
        
        self.fullNameLbl.text = contact.fullName
        
        
        downloadAvatar(contact.avatar!, completion:  { (data) in
            self.profileImage.image = UIImage(data: data)
            self.profileImage.layer.cornerRadius = 25.0
            self.profileImage.clipsToBounds = true
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

