//
//  ImageShowVC.swift
//  pickup
//
//  Created by christian landa on 8/7/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseMessaging
import FirebaseStorage


class ImageShowVC: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var imageShowView: UIImageView!
    @IBOutlet weak var scrollImg: UIScrollView!
    
   var postKey_Segue: String?
 
     var activeUserInfo: NSDictionary?
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        setZoomScale()

        
        var scrollImg: UIScrollView = UIScrollView()
        self.scrollImg.delegate = self
      
        scrollImg.backgroundColor = UIColor(red: 90, green: 90, blue: 90, alpha: 0.90)
         scrollImg.alwaysBounceVertical = false
        scrollImg.alwaysBounceHorizontal = false
        scrollImg.showsVerticalScrollIndicator = true
         scrollImg.flashScrollIndicators()
        scrollImg.contentSize = imageShowView.bounds.size
        
        
        scrollImg = UIScrollView(frame: view.bounds)
        scrollImg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollImg.contentOffset = CGPoint(x: 0, y: 0)
        
        
        DataService.ds.REF_POSTS.child(postKey_Segue!).observe(.value, with: { (snapshot)  in
            
            let item = snapshot as DataSnapshot
            print("SNAP-Itemxxxxxxxxxxx: \(item)")
            
            
            
            if let dict = item.value as? [String : AnyObject]{
                let imageUrl = dict["imageUrl"] as! String
                //    image = avatar
                
                self.activeUserInfo = dict as NSDictionary?
                
                self.title = " \((self.activeUserInfo!["fullName"]! as AnyObject).uppercased!)'s Post"
                
                self.downloadAvatar(image: imageUrl, completion: { (data) in
                    
                    self.imageShowView.image = UIImage(data: data as Data)
                    
                })
            }
            
        }, withCancel: {(error) -> Void in
                
        })
    }
    
    
    
    // downloading profile image from Facebook
    
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
       // FirebaseFanout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
   // func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
      
        return self.imageShowView
    }
    
    override func viewWillLayoutSubviews() {   // activated when phone change side
        setZoomScale()
    }
   
    func setZoomScale() {
        
        var minZoom = min(self.view.bounds.size.width / self.imageShowView.image!.size.width, self.view.bounds.size.height / self.imageShowView.image!.size.height);
        
        if (minZoom > 1) {
            minZoom = 1;
        }
        
        scrollImg.minimumZoomScale = minZoom//min(widthScale, heightScale)
        scrollImg.zoomScale = minZoom
        scrollImg.maximumZoomScale = 2.0
    }
}
