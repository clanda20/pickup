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

override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    }
    func configureCell(contact: Contact) {
        
        self.contact = contact
        
        self.fullNameLbl.text = contact.fullName
        
        
        downloadAvatar(image: contact.avatar!, completion:  { (data) in
            self.profileImage.image = UIImage(data: data as Data)
            self.profileImage.layer.cornerRadius = 25.0
            self.profileImage.clipsToBounds = true
        })
        
        
        /*   let url_Avatar = NSURL(string: contact.avatar!)
         let data_Url_Avatar = NSData(contentsOfURL: url_Avatar!)
         self.profilePicture.image = UIImage(data: data_Url_Avatar!)  */
        
    }
    
    
    
    func downloadAvatar(image:String, completion:@escaping   (_ data:NSData)-> ()) {
        
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

