//
//  NotificationCell.swift
//  pickup
//
//  Created by christian landa on 10/5/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit


//protocol NotificationCellDelegate {
//    func callSegueFromCell(myData dataobject: AnyObject)
//    
//}

protocol ContactIDNotificationCellDelegate {
    func ContactIDNotificationSegueFromCell(contactID dataobject: AnyObject)
    
}


class NotificationCell: UITableViewCell {
   // var contact: Contact!
    
    
  
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var fullName: UIButton!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    
    var delegate2 : ContactIDNotificationCellDelegate?
    
    
    //  var image:String?
    
    var Notifications = [Notification]()
    var notification: Notification!
   // var posts = [Post]()
    // var contacts: Contact[]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //  constraints
        
        avatar.translatesAutoresizingMaskIntoConstraints = false
        fullName.translatesAutoresizingMaskIntoConstraints = false
        infoLbl.translatesAutoresizingMaskIntoConstraints = false
        dateLbl.translatesAutoresizingMaskIntoConstraints = false
        
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-5-[ava(30)]-5-[fullname(150)]-5-[info(150)]-5-[date(100)]",
            options: [], metrics: nil, views: ["ava":avatar, "fullname":fullName,"info":infoLbl, "date":dateLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-10-[ava(30)]-10-|",
             options: [], metrics: nil, views: ["ava":avatar]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-10-[fullname(30)]",
             options: [], metrics: nil, views: ["fullname":fullName]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-10-[info(30)]",
             options: [], metrics: nil, views: ["info":infoLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-10-[date(30)]",
            options: [], metrics: nil, views: ["date":dateLbl]))

        
        avatar.layer.cornerRadius = avatar.frame.size.width / 2
        avatar.clipsToBounds = true
        
        
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(notification: Notification) {
        
        self.notification = notification
        
        self.fullName.setTitle(notification.fullName, forState: .Normal)
        
       self.infoLbl.text = notification.type
        
        
        
        
        // calculate post date
        
        let  seconds = Double(((notification.date)))
            let timeStampDate = NSDate(timeIntervalSince1970: seconds!)
            
       //    let dateFormatter = NSDateFormatter()
        //   dateFormatter.dateFormat = "E, d MMM yyyy hh:mm a"
        //   self.dateLbl.text =  dateFormatter.stringFromDate(timeStampDate)
        
        
       
       let from = timeStampDate
        let now = NSDate()
        let components : NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .WeekOfMonth]
        let difference = NSCalendar.currentCalendar().components(components, fromDate: from, toDate: now, options: [])
        
        // logic what to show: seconds, minuts, hours, days or weeks
        if difference.second <= 0 {
            dateLbl.text = "now"
        }
        if difference.second > 0 && difference.minute == 0 {
            dateLbl.text = "\(difference.second)s."
        }
        if difference.minute > 0 && difference.hour == 0 {
            dateLbl.text = "\(difference.minute)m."
        }
        if difference.hour > 0 && difference.day == 0 {
            dateLbl.text = "\(difference.hour)h."
        }
        if difference.day > 0 && difference.weekOfMonth == 0 {
            dateLbl.text = "\(difference.day)d."
        }
        if difference.weekOfMonth > 0 {
           dateLbl.text = "\(difference.weekOfMonth)w."
        }
        
       
        
        
        
    
      //  self.dateLbl.text = notification.date
        
        
        downloadAvatar(notification.avatar!, completion:  { (data) in
            self.avatar.image = UIImage(data: data)
          //  self.avatar.layer.cornerRadius = 30.0
          //  self.avatar.clipsToBounds = true
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
    
   
    @IBAction func fullNameBtn_click(sender: AnyObject) {
        
        
        let contactID_Post_Profile = self.notification.uid
        
     print("Segue Agosto 1xxxxx: contactID_Post_Profile \(contactID_Post_Profile)")
        
        if(self.delegate2 != nil){ //Just to be safe.
            
            self.delegate2!.ContactIDNotificationSegueFromCell(contactID: contactID_Post_Profile!)
            
        }

        
        
    }
    
    

}
