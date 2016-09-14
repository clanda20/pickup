//
//  GroupCell.swift
//  pickup
//
//  Created by christian landa on 8/19/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {
    @IBOutlet weak var dateTimeLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var locationLBl: UILabel!
    
    
     var events = [Event]()
     var event: Event!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func configureCell(event: Event) {
        
        self.event = event
        
        self.dateTimeLbl.text = event.date
        self.titleLbl.text = event.title
        self.locationLBl.text = event.fullAddress
        
        
       
        
        
        /*   let url_Avatar = NSURL(string: contact.avatar!)
         let data_Url_Avatar = NSData(contentsOfURL: url_Avatar!)
         self.profilePicture.image = UIImage(data: data_Url_Avatar!)  */
        
    }
    
}

