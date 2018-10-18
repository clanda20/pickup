//
//  PlayVideoVC.swift
//  pickup
//
//  Created by christian landa on 9/18/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class PlayVideoVC: UIViewController {
    
    
    var videoUrl_segue: String!   // From FeedVC through Segue

    let avPlayerViewController = AVPlayerViewController()
    var avPlayer:AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let movieUrl = NSURL(string: videoUrl_segue)


        if let url = movieUrl {
            
            self.avPlayer = AVPlayer(url: url as URL)
            self.avPlayerViewController.player = self.avPlayer
        }
    
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
       
        
    }

    @IBAction func playButtonTapped(sender: AnyObject) {
        
        self.present(self.avPlayerViewController, animated: true) { 
            self.avPlayerViewController.player?.play()
        }
    }
}
