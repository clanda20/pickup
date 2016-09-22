//
//  Extensions.swift
//  pickup
//
//  Created by christian landa on 9/14/16.
//  Copyright © 2016 christian landa. All rights reserved.
// youtube  firebae 3 Episode 6  min 16

import UIKit

let imageCache = NSCache()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String){
        
        self.image = nil 
        
        // check cache for image first
        
        if let cacheImage = imageCache.objectForKey(urlString) as? UIImage{
            self.image = cacheImage
            return
        }
        
        // otherwise fire off a new download 
        
        let url = NSURL(string: urlString)
        NSURLSession.sharedSession().dataTaskWithURL(url!,
            completionHandler:  { (data, response, error) in
            
            //download hit an error so lets return out
            if error != nil {
                print(error)
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if let downloadedImage =  UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString)
                    
                    self.image = downloadedImage
                }
               
            })
        }).resume()
    }
}
