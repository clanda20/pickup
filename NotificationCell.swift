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
        
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-10-[ava(30)]-2-[fullname(120)]-2-[info(125)]-2-[date(25)]-5-|",
            options: [], metrics: nil, views: ["ava":avatar, "fullname":fullName,"info":infoLbl, "date":dateLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[ava(30)]-10-|",
             options: [], metrics: nil, views: ["ava":avatar]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[fullname(30)]",
             options: [], metrics: nil, views: ["fullname":fullName]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[info(30)]",
             options: [], metrics: nil, views: ["info":infoLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[date(30)]",
            options: [], metrics: nil, views: ["date":dateLbl]))

        
        avatar.layer.cornerRadius = avatar.frame.size.width / 2
        avatar.clipsToBounds = true
        
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(notification: Notification) {
        
        self.notification = notification
        
        self.fullName.setTitle(notification.fullName, for: .normal)
        
       self.infoLbl.text = notification.type
        
        
        
        
        // calculate post date
        
        let  seconds = Double(((notification.date)))
            let timeStampDate = NSDate(timeIntervalSince1970: seconds!)
            
       //    let dateFormatter = NSDateFormatter()
        //   dateFormatter.dateFormat = "E, d MMM yyyy hh:mm a"
        //   self.dateLbl.text =  dateFormatter.stringFromDate(timeStampDate)
        
        
       
       let from = timeStampDate
        let now = NSDate()
        
      //  var calendar = NSCalendar.current
        
      //  let components : NSCalendar.Unit = [.second, .minute, .hour, .Day, .WeekOfMonth]
        
        // let components = Set<Calendar.Component>(arrayLiteral: .second, .minute, .hour, .day, .weekOfMonth)
        let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
        
        // let difference = NSCalendar.currentCalendar.components(components, fromDate: from, toDate: now, options: [])
       // let difference = Calendar.current.dateComponents(components, from: from as Date)
        let difference = Calendar.current.dateComponents(components, from: from as Date, to: now as Date)
        
        // logic what to show: seconds, minuts, hours, days or weeks
        if difference.second! <= 0 {
            dateLbl.text = "now"
        }
        if difference.second! > 0 && difference.minute == 0 {
            dateLbl.text = "\(difference.second!) s."
        }
        if difference.minute! > 0 && difference.hour == 0 {
            dateLbl.text = "\(difference.minute!) m."
        }
        if difference.hour! > 0 && difference.day == 0 {
            dateLbl.text = "\(difference.hour!) h."
        }
        if difference.day! > 0 && difference.weekOfMonth == 0 {
            dateLbl.text = "\(difference.day!) d."
        }
        if difference.weekOfMonth! > 0 {
           dateLbl.text = "\(difference.weekOfMonth!) w."
        }
        
       
        
        
        
    
      //  self.dateLbl.text = notification.date
        
        
        downloadAvatar(image: notification.avatar!, completion:  { (data) in
            self.avatar.image = UIImage(data: data as Data)
          //  self.avatar.layer.cornerRadius = 30.0
          //  self.avatar.clipsToBounds = true
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
   
    @IBAction func fullNameBtn_click(sender: AnyObject) {
        
        
        let contactID_Post_Profile = self.notification.uid
        
     print("Segue Agosto 1xxxxx: contactID_Post_Profile \(contactID_Post_Profile)")
        
        if(self.delegate2 != nil){ //Just to be safe.
            
            self.delegate2!.ContactIDNotificationSegueFromCell(contactID: contactID_Post_Profile! as AnyObject)
            
        }

        
        
    }
    
    

}
