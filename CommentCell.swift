//
//  CommentCell.swift
//  pickup
//
//  Created by christian landa on 6/22/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import Firebase

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var Username2: UILabel!
    
    @IBOutlet weak var commentText: UITextView!
    
    var comment: Comment!
  //  var post: Post!
    
    var value: Int!
    
    var postRefKey: FIRDatabaseReference!
    
    var postKey:String?
    
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCommentCell(comment: Comment){
        self.comment = comment
        
        self.commentText.text = comment.commentDescription
        
        postRefKey = DataService.ds.REF_POSTCOMMENTS.child("postKey")  //added 6-29-16
        
      //  print("PostKey PostCell XX: \(post.postKey)")
        
        
    }
    
}
