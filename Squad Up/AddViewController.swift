//
//  AddViewController.swift
//  Squad Up
//
//  Created by Zain Manji on 8/17/15.
//  Copyright (c) 2015 Zeen Labs. All rights reserved.
//

import UIKit
import MapKit


class AddViewController: UIViewController, UISearchBarDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var eventNameTextField: UITextField!
    @IBOutlet var eventTimeTextField: UITextField!
    @IBOutlet var eventEndTimeTextField: UITextField!
    @IBOutlet var eventLocationTextField: UITextField!
    var date:NSDate = NSDate()
    var endDate:NSDate = NSDate()
    var datePickerView:UIDatePicker = UIDatePicker()
    var endDatePickerView:UIDatePicker = UIDatePicker()
    
    
    
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    
    // Variables for editing an event which will be populated from previous controller
    var editingEventObject:PFObject!
    var editingEvent:Bool!
    
    // Variables for editing an event to be filled in
    var eventDataSet:NSMutableDictionary!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController!.interactivePopGestureRecognizer!.enabled = true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
        
        // Dismiss keyboard if user taps elsewhere.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        // Customize Back button.
        let myBackButton:UIButton = UIButton(type: UIButtonType.Custom)
        myBackButton.addTarget(self, action: "popDisplay:", forControlEvents: UIControlEvents.TouchUpInside)
        myBackButton.setTitle("Back", forState: UIControlState.Normal)
        myBackButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myBackButton.sizeToFit()
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        self.navigationController!.interactivePopGestureRecognizer!.delegate = self;
        self.navigationController!.interactivePopGestureRecognizer!.enabled = true;


        
        // Create the starting date picker view
        datePickerView.minuteInterval = 15
        datePickerView.minimumDate = datePickerView.date
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        eventTimeTextField.inputView = datePickerView
        
        // Create the ending date picker view
        endDatePickerView.minuteInterval = 15
        endDatePickerView.minimumDate = datePickerView.date
        endDatePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        endDatePickerView.addTarget(self, action: Selector("endDatePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        eventEndTimeTextField.inputView = endDatePickerView
        
        // Create the date format for the starting date and ending date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE MMM d @ hh:mm a"
        let endDateFormatter = NSDateFormatter()
        endDateFormatter.dateFormat = "EEE MMM d @ hh:mm a"
        
        eventTimeTextField.text = "From: " + dateFormatter.stringFromDate(datePickerView.date)
        date = datePickerView.date
        
        eventEndTimeTextField.text = "To: " + endDateFormatter.stringFromDate(endDatePickerView.date.dateByAddingTimeInterval(60*15))
        endDate = endDatePickerView.date.dateByAddingTimeInterval(60*15)
    
        if (self.editingEvent == nil) {
            self.editingEvent = false
        }
        if (self.editingEvent == true) {
            self.eventDataSet = NSMutableDictionary()
            self.eventDataSet = self.editingEventObject["dataSet"] as! NSMutableDictionary
            self.eventNameTextField.text = self.eventDataSet["eventName"] as? String
            let timeStr:String = (self.eventDataSet["eventTime"] as? String)!
            let endTimeStr:String = (self.eventDataSet["eventEndTime"] as? String)!
            self.eventTimeTextField.text = "From: " + timeStr
            self.eventEndTimeTextField.text = "To: " + endTimeStr
            self.eventLocationTextField.text = self.eventDataSet["eventLocation"] as? String
            self.date = self.eventDataSet["date"] as! NSDate
            self.endDate = self.eventDataSet["endDate"] as! NSDate
        }
        
        
        
        let paddingView = UIView(frame: CGRectMake(0, 0, 15, eventNameTextField.frame.height))
        eventNameTextField.leftView = paddingView
        eventNameTextField.leftViewMode = UITextFieldViewMode.Always
        
        let paddingView2 = UIView(frame: CGRectMake(0, 0, 15, eventNameTextField.frame.height))

        eventTimeTextField.leftView = paddingView2
        eventTimeTextField.leftViewMode = UITextFieldViewMode.Always
        
        let paddingView3 = UIView(frame: CGRectMake(0, 0, 15, eventNameTextField.frame.height))
        eventEndTimeTextField.leftView = paddingView3
        eventEndTimeTextField.leftViewMode = UITextFieldViewMode.Always
        
        let paddingView4 = UIView(frame: CGRectMake(0, 0, 15, eventNameTextField.frame.height))
        eventLocationTextField.leftView = paddingView4
        eventLocationTextField.leftViewMode = UITextFieldViewMode.Always
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor(red: 187.0/256.0, green: 187.0/256.0, blue: 187.0/256.0, alpha: 1.0).CGColor
        border.frame = CGRect(x: 0, y: eventNameTextField.frame.size.height - width, width:  eventNameTextField.frame.size.width, height: eventNameTextField.frame.size.height)
        
        border.borderWidth = width
        
        let border2 = CALayer()
        let width2 = CGFloat(1.0)
        border2.borderColor = UIColor(red: 187.0/256.0, green: 187.0/256.0, blue: 187.0/256.0, alpha: 1.0).CGColor
        border2.frame = CGRect(x: 0, y: 0, width:  eventNameTextField.frame.size.width, height: 1)
        
        border2.borderWidth = width2
        
        eventNameTextField.layer.addSublayer(border)
        eventNameTextField.layer.addSublayer(border2)
        eventNameTextField.layer.masksToBounds = true
        eventNameTextField.backgroundColor = UIColor.whiteColor()
        


        
        let timeBorder = CALayer()
        let timeWidth = CGFloat(1.0)
        timeBorder.borderColor = UIColor(red: 187.0/256.0, green: 187.0/256.0, blue: 187.0/256.0, alpha: 1.0).CGColor
        timeBorder.frame = CGRect(x: 0, y: eventTimeTextField.frame.size.height - timeWidth, width:  eventTimeTextField.frame.size.width, height: eventTimeTextField.frame.size.height)
        
        timeBorder.borderWidth = timeWidth
        
        let border3 = CALayer()
        let width3 = CGFloat(1.0)
        border3.borderColor = UIColor(red: 187.0/256.0, green: 187.0/256.0, blue: 187.0/256.0, alpha: 1.0).CGColor
        border3.frame = CGRect(x: 0, y: 0, width:  eventNameTextField.frame.size.width, height: 1)
        
        border3.borderWidth = width3
        
        eventTimeTextField.layer.addSublayer(border3)
        //eventTimeTextField.layer.addSublayer(timeBorder)
        eventTimeTextField.layer.masksToBounds = true
        
        eventTimeTextField.backgroundColor = UIColor.whiteColor()
        

        
        
        
        let endTimeBorder = CALayer()
        let endTimeWidth = CGFloat(1.0)
        endTimeBorder.borderColor = UIColor(red: 187.0/256.0, green: 187.0/256.0, blue: 187.0/256.0, alpha: 1.0).CGColor
        endTimeBorder.frame = CGRect(x: 0, y: eventEndTimeTextField.frame.size.height - endTimeWidth, width:  eventEndTimeTextField.frame.size.width, height: eventEndTimeTextField.frame.size.height)
        
        endTimeBorder.borderWidth = endTimeWidth
        
        let border4 = CALayer()
        let width4 = CGFloat(1.0)
        border4.borderColor = UIColor(red: 187.0/256.0, green: 187.0/256.0, blue: 187.0/256.0, alpha: 1.0).CGColor
        border4.frame = CGRect(x: 0, y: 0, width:  eventNameTextField.frame.size.width, height: 1)
        
        border4.borderWidth = width4
        
        eventEndTimeTextField.layer.addSublayer(border4)
        //eventEndTimeTextField.layer.addSublayer(endTimeBorder)
        eventEndTimeTextField.layer.masksToBounds = true
        
        eventEndTimeTextField.backgroundColor = UIColor.whiteColor()
        
        

        
        
        let locationBorder = CALayer()
        let locationWidth = CGFloat(1.0)
        locationBorder.borderColor = UIColor(red: 187.0/256.0, green: 187.0/256.0, blue: 187.0/256.0, alpha: 1.0).CGColor
        locationBorder.frame = CGRect(x: 0, y: eventLocationTextField.frame.size.height - locationWidth, width:  eventLocationTextField.frame.size.width, height: eventLocationTextField.frame.size.height)
        
        locationBorder.borderWidth = locationWidth
        
        let border5 = CALayer()
        let width5 = CGFloat(1.0)
        border5.borderColor = UIColor(red: 187.0/256.0, green: 187.0/256.0, blue: 187.0/256.0, alpha: 1.0).CGColor
        border5.frame = CGRect(x: 0, y: 0, width:  eventNameTextField.frame.size.width, height: 1)
        
        border5.borderWidth = width5
        
        eventLocationTextField.layer.addSublayer(border5)
        eventLocationTextField.layer.addSublayer(locationBorder)
        eventLocationTextField.layer.masksToBounds = true
        
        eventLocationTextField.backgroundColor = UIColor.whiteColor()
        

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func inviteButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("Invite", sender: self)
    }

    
    func popDisplay(sender:UIBarButtonItem){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        view.endEditing(true)
    }
    
    // Update the start date picker UI when it is changed by user.
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE MMM d @ hh:mm a"
        eventTimeTextField.text = "From: " + dateFormatter.stringFromDate(sender.date)
        date = sender.date
        endDatePickerView.minimumDate = date.dateByAddingTimeInterval(60*15)
        
        if (date.compare(endDate) == NSComparisonResult.OrderedDescending) {
            // date is larger than end date
            eventEndTimeTextField.text = "To: " + dateFormatter.stringFromDate(endDatePickerView.minimumDate!)
            endDate = date
        } else {
            let interval = endDate.timeIntervalSinceDate(date)
            if (interval < 60*15) {
                eventEndTimeTextField.text = "To: " + dateFormatter.stringFromDate(endDatePickerView.minimumDate!)
                endDate = date
            }
        }
    }
    
    // Update the end date picker UI when it is changed by the user.
    func endDatePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE MMM d @ hh:mm a"
        eventEndTimeTextField.text = "To: " + dateFormatter.stringFromDate(sender.date)
        endDate = sender.date
    }
    
    
    

    
    
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "Invite") {
            // Get Data
            let dataSet:NSMutableDictionary = NSMutableDictionary()
            dataSet.setObject(eventNameTextField.text!, forKey: "eventName")
            dataSet.setObject(eventTimeTextField.text!, forKey: "eventTime")
            dataSet.setObject(eventEndTimeTextField.text!, forKey: "eventEndTime")
            dataSet.setObject(eventLocationTextField.text!, forKey: "eventLocation")
            dataSet.setObject(date, forKey: "date")
            dataSet.setObject(endDate, forKey: "endDate")
            
            let inviteFriendsViewController:EventInviteFriendsTableViewController = segue.destinationViewController as! EventInviteFriendsTableViewController
            
            inviteFriendsViewController.dataSet = dataSet
            inviteFriendsViewController.editingEvent = self.editingEvent
            inviteFriendsViewController.editingEventObject = self.editingEventObject
            
            
        }
    }
}
