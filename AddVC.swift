//
//  AddVC.swift
//  pickup
//
//  Created by christian landa on 8/19/16.
//  Copyright © 2016 christian landa. All rights reserved.
//

import UIKit

class AddVC: UIViewController {
    
    
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var findLbl: UILabel!
    
    @IBOutlet  var saveBtnItem: UIBarButtonItem!
    @IBOutlet  var doneBtnItem: UIBarButtonItem!
    @IBOutlet  var doneLeftBtnItem: UIBarButtonItem!

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var searchBtnText: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true , animated: animated);
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // self.navigationController?.toolbarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil

    }
    @IBAction func chooseDateBtn(sender: AnyObject) {
        
        self.titleLbl.hidden  = true
        self.titleTextField.hidden = true
        self.dateLbl.hidden = true
        self.dateBtn.hidden = true
        self.descriptionLbl.hidden = true
        self.descriptionTextView.hidden = true
        self.findLbl.hidden = true
        self.searchBtnText.hidden = true
        // self.doneDateBtn.hidden = false
        self.datePicker.hidden = false
       // self.navigationItem.rightBarButtonItem = nil
        
        // Later on...
        self.navigationItem.rightBarButtonItem = self.doneBtnItem
 
    }

    @IBAction func doneDateHidden(sender: AnyObject) {
        
        self.titleLbl.hidden  = false
        self.titleTextField.hidden = false
        self.dateLbl.hidden = false
        self.dateBtn.hidden = false
        self.descriptionLbl.hidden = false
        self.descriptionTextView.hidden = false
        self.findLbl.hidden = false
       // self.doneDateBtn.hidden = true
        self.datePicker.hidden = true
        //self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = self.saveBtnItem
        
        
    }
    
    @IBAction func doneItemBtn(sender: AnyObject) {
        
        
        self.titleLbl.hidden  = false
        self.titleTextField.hidden = false
        self.dateLbl.hidden = false
        self.dateBtn.hidden = false
        self.descriptionLbl.hidden = false
        self.descriptionTextView.hidden = false
        self.findLbl.hidden = false
        self.searchBtnText.hidden = false
       // self.doneDateBtn.hidden = true
        self.datePicker.hidden = true
        //self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = self.saveBtnItem
        
    }
    @IBAction func datePickerBtn(sender: AnyObject) {
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy hh:mm a"
        var strDate = dateFormatter.stringFromDate(datePicker.date)
        self.dateBtn.setTitle(strDate, forState: .Normal)
    }
    
    
    @IBAction func searchBtn(sender: AnyObject) {
        self.titleLbl.hidden  = true
        self.titleTextField.hidden = true
        self.dateLbl.hidden = true
        self.dateBtn.hidden = true
        self.descriptionLbl.hidden = true
        self.descriptionTextView.hidden = true
        self.mapView.hidden = true
        self.findLbl.hidden = true
        self.datePicker.hidden = true
        // self.doneDateBtn.hidden = false
        self.datePicker.hidden = true
        self.searchBtnText.hidden = true
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        
        // Later on...
      //  self.navigationItem.rightBarButtonItem = self.doneBtnItem
        self.navigationItem.leftBarButtonItem = self.doneLeftBtnItem

        
        
        
    }
    
    @IBAction func doneLeftBtnItemAction(sender: AnyObject) {
        
        self.titleLbl.hidden  = false
        self.titleTextField.hidden = false
        self.dateLbl.hidden = false
        self.dateBtn.hidden = false
        self.descriptionLbl.hidden = false
        self.descriptionTextView.hidden = false
        self.findLbl.hidden = false
        self.mapView.hidden = false
        self.searchBtnText.hidden = false
        // self.doneDateBtn.hidden = true
        self.datePicker.hidden = true
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = self.saveBtnItem
        
        
    }
    
    
    
    @IBAction func saveBtn(sender: AnyObject) {
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
