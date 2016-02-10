//
//  AddViewController.swift
//  Squad Up
//
//  Created by Zain Manji on 8/17/15.
//  Copyright (c) 2015 Zeen Labs. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps


class AddViewController: UIViewController, UISearchBarDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var eventNameTextField: UITextField!
    @IBOutlet var eventTimeTextField: UITextField!
    @IBOutlet var eventEndTimeTextField: UITextField!
    @IBOutlet var eventLocationTextField: UITextField!
    var date:NSDate = NSDate()
    var endDate:NSDate = NSDate()
    var datePickerView:UIDatePicker = UIDatePicker()
    var endDatePickerView:UIDatePicker = UIDatePicker()
    
    @IBOutlet var locationTableView: UITableView!
    var locationSearchResults:[String]!
    
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    var user:PFUser?
    
    @IBOutlet var helperLabel: UILabel!
    
    // Variables for editing an event which will be populated from previous controller
    var editingEventObject:PFObject!
    var editingEvent:Bool!
    @IBOutlet var cancelEventButton: UIButton!
    @IBOutlet var shuffleEventButton: UIButton!
    
    // Variables for editing an event to be filled in
    var eventDataSet:NSMutableDictionary!
    var eventSuggestions:NSArray!
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController!.interactivePopGestureRecognizer!.enabled = true;
        self.locationTableView.hidden = true
        self.locationTableView.frame = CGRect(x: 0, y: 55, width: self.view.bounds.width, height: 150)
        self.locationTableView.reloadData()
        
        self.user = PFUser.currentUser()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customzie location suggestions
        self.locationSearchResults = Array()
        self.locationTableView.frame = CGRect(x: 0, y: 55, width: self.view.bounds.width, height: 150)
        
        let tblView =  UIView(frame: CGRectZero)
        self.locationTableView.tableFooterView = tblView
        self.locationTableView.tableFooterView!.hidden = true
        self.locationTableView.backgroundColor = UIColor.clearColor()
        
        self.eventNameTextField.delegate = self
        self.eventTimeTextField.delegate = self
        self.eventEndTimeTextField.delegate = self
        self.eventLocationTextField.delegate = self
        self.eventLocationTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        self.view.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
        
        // Customize Back button.
        let myBackButton:UIButton = UIButton(type: UIButtonType.Custom)
        myBackButton.addTarget(self, action: "popDisplay:", forControlEvents: UIControlEvents.TouchUpInside)
        myBackButton.setTitle("Back", forState: UIControlState.Normal)
        myBackButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myBackButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        myBackButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
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
        dateFormatter.dateFormat = "EEE, MMM d @ h:mm a"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let endDateFormatter = NSDateFormatter()
        endDateFormatter.dateFormat = "EEE, MMM d @ h:mm a"
        endDateFormatter.timeZone = NSTimeZone.localTimeZone()
        
        eventTimeTextField.text = "From: " + dateFormatter.stringFromDate(datePickerView.date)
        date = datePickerView.date
        
        eventEndTimeTextField.text = "To: " + endDateFormatter.stringFromDate(endDatePickerView.date.dateByAddingTimeInterval(60*30))
        endDate = endDatePickerView.date.dateByAddingTimeInterval(60*30)
    
        // Check if we are editing an existing event
        if (self.editingEvent == nil) {
            self.title = "Create Event"
            self.editingEvent = false
            self.cancelEventButton.enabled = false
            self.cancelEventButton.hidden = true
            self.helperLabel.hidden = false
        }
        if (self.editingEvent == true) {
            self.title = "Edit Event"
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
            self.cancelEventButton.enabled = true
            self.cancelEventButton.hidden = false
            self.helperLabel.hidden = true
        }
        
        self.helperLabel.textColor = UIColor(red: 94.0/256.0, green: 111.0/256.0, blue: 123.0/256.0, alpha: 1.0)
        
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
        
        locationTableView.delegate = self
        locationTableView.dataSource = self
        
        
        let query = PFQuery(className: "ShuffledActivities")
        
        if let shuffledActivity = query.getObjectWithId("gaRLdeuz0J") {
            self.eventSuggestions = shuffledActivity["eventSuggestions"] as! NSArray
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.locationTableView.frame = CGRect(x: 0, y: 55, width: self.view.bounds.width, height: 150)
        
        // Add borders to cancel event button
        let cancelBorder = CALayer()
        let cancelWidth = CGFloat(1.0)
        cancelBorder.borderColor = UIColor(red: 235.0/256.0, green: 235.0/256.0, blue: 235.0/256.0, alpha: 1.0).CGColor
        cancelBorder.frame = CGRect(x: 0, y: cancelEventButton.frame.size.height - cancelWidth, width:  cancelEventButton.frame.size.width, height: cancelEventButton.frame.size.height)
        cancelBorder.borderWidth = cancelWidth
        
        cancelEventButton.layer.addSublayer(cancelBorder)
        cancelEventButton.layer.masksToBounds = true
        cancelEventButton.backgroundColor = UIColor.whiteColor()
        
        // Add border to event name text field
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor(red: 235.0/256.0, green: 235.0/256.0, blue: 235.0/256.0, alpha: 1.0).CGColor
        border.frame = CGRect(x: 0, y: eventNameTextField.frame.size.height - width, width:  eventNameTextField.frame.size.width, height: eventNameTextField.frame.size.height)
        border.borderWidth = width
        
        eventNameTextField.layer.addSublayer(border)
        eventNameTextField.layer.masksToBounds = true
        eventNameTextField.backgroundColor = UIColor.whiteColor()

        // Add border to time text field
        let border3 = CALayer()
        let width3 = CGFloat(1.0)
        border3.borderColor = UIColor(red: 235.0/256.0, green: 235.0/256.0, blue: 235.0/256.0, alpha: 1.0).CGColor
        border3.frame = CGRect(x: 0, y: 0, width:  eventNameTextField.frame.size.width, height: 1)
        border3.borderWidth = width3
        
        eventTimeTextField.layer.addSublayer(border3)
        eventTimeTextField.layer.masksToBounds = true
        eventTimeTextField.backgroundColor = UIColor.whiteColor()
        
        // Add border to time border
        let border4 = CALayer()
        let width4 = CGFloat(1.0)
        border4.borderColor = UIColor(red: 235.0/256.0, green: 235.0/256.0, blue: 235.0/256.0, alpha: 1.0).CGColor
        border4.frame = CGRect(x: 0, y: 0, width:  eventNameTextField.frame.size.width, height: 1)
        border4.borderWidth = width4
        
        eventEndTimeTextField.layer.addSublayer(border4)
        eventEndTimeTextField.layer.masksToBounds = true
        eventEndTimeTextField.backgroundColor = UIColor.whiteColor()
        
        // Add border to location text field
        let border5 = CALayer()
        let width5 = CGFloat(1.0)
        border5.borderColor = UIColor(red: 235.0/256.0, green: 235.0/256.0, blue: 235.0/256.0, alpha: 1.0).CGColor
        border5.frame = CGRect(x: 0, y: 0, width:  eventNameTextField.frame.size.width, height: 1)
        border5.borderWidth = width5
        
        eventLocationTextField.layer.addSublayer(border5)
        eventLocationTextField.layer.masksToBounds = true
        eventLocationTextField.backgroundColor = UIColor.whiteColor()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func shuffleEventAction(sender: AnyObject) {
        print("Button pressed")
        let length = self.eventSuggestions.count
        let randomNum = Int(arc4random_uniform(UInt32(length)))
        
        self.eventNameTextField.text = self.eventSuggestions[randomNum] as? String
    }
    
    
    
    @IBAction func cancelEventAction(sender: AnyObject) {
        
        let cancelAlert = UIAlertController(title: "Cancel Event?", message: "Are you sure you want to cancel the event for the squad?", preferredStyle: UIAlertControllerStyle.Alert)
        
        cancelAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            
            let eventItem:NSMutableDictionary = self.editingEventObject!["dataSet"] as! NSMutableDictionary
            eventItem["eventCancelled"] = true
            self.editingEventObject!["dataSet"] = eventItem
            self.editingEventObject?.save()
            
            var users:[AnyObject] = []
            if let goingPeople:NSMutableDictionary = eventItem["goingPeople"] as? NSMutableDictionary {
                goingPeople.removeObjectForKey(self.user!.objectId!)
                users = goingPeople.allKeys
            }
            
            if let invitedPeople:NSMutableDictionary = eventItem["invitedPeopleWithApp"] as? NSMutableDictionary {
                invitedPeople.removeObjectForKey(self.user!.objectId!)
                users = users + invitedPeople.allKeys
            }
            
            // Send push notification to people who are going/invited to event
            let pushQuery = PFInstallation.query()
            pushQuery?.whereKey("userId", containedIn: users)
            let push = PFPush()
            push.setQuery(pushQuery)
            let eventName:String = eventItem.objectForKey("eventName") as! String
            push.setMessage("The event, " + eventName + " has been cancelled!")
            push.sendPushInBackground()
            
            let switchViewController = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - 3]
            self.navigationController?.popToViewController(switchViewController, animated: true)
        }))
        
        
        // Cancel action
        cancelAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
            print("User pressed cancel on the alert.")
        }))
        
        presentViewController(cancelAlert, animated: true, completion: nil)
    }
    

    @IBAction func inviteButtonTapped(sender: AnyObject) {
        let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()

        // Check if user has entered any event title, if not, make sure they do.
        if (self.eventNameTextField!.text!.stringByTrimmingCharactersInSet(whitespaceSet) == "") {
            let alert = UIAlertController(title:"Missing Event Title", message: "Please enter a title for your event.", preferredStyle:   UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title:"OK", style: .Default, handler: { action in
                self.dismissViewControllerAnimated(true, completion:nil)
            
            }))
            self.presentViewController(alert, animated:true, completion:nil)
        } else {
            self.performSegueWithIdentifier("Invite", sender: self)
        }
    }

    
    // Go back to the previous page
    func popDisplay(sender:UIBarButtonItem){
        let cancelAlert = UIAlertController(title: "Discard Event?", message: "If you go back now, your event will be discarded.", preferredStyle: UIAlertControllerStyle.Alert)
        
        cancelAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            self.navigationController!.popViewControllerAnimated(true)
        }))
        
        // Cancel action
        cancelAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
            print("User pressed cancel on the alert.")
        }))
        
        if (!self.editingEvent) {
            if (self.eventNameTextField.text != "") {
                presentViewController(cancelAlert, animated: true, completion: nil)
            } else {
                self.navigationController!.popViewControllerAnimated(true)
            }
        } else {
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
    
    
    // Update the start date picker UI when it is changed by user.
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, MMM d @ h:mm a"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        eventTimeTextField.text = "From: " + dateFormatter.stringFromDate(sender.date)
        date = sender.date
        endDatePickerView.minimumDate = date.dateByAddingTimeInterval(60*30)
        
        // Check if start date is Today, or Tomorrow, or in the Future and add to respective list
        if (date.compare(endDate) == NSComparisonResult.OrderedDescending) {
            eventEndTimeTextField.text = "To: " + dateFormatter.stringFromDate(endDatePickerView.minimumDate!)
            endDate = endDatePickerView.minimumDate!
        } else {
            let interval = endDate.timeIntervalSinceDate(date)
            if (interval < 60*30) {
                eventEndTimeTextField.text = "To: " + dateFormatter.stringFromDate(endDatePickerView.minimumDate!)
                endDate = endDatePickerView.minimumDate!
            }
        }
    }
    
    // Update the end date picker UI when it is changed by the user.
    func endDatePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, MMM d @ h:mm a"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        eventEndTimeTextField.text = "To: " + dateFormatter.stringFromDate(sender.date)
        endDate = sender.date
    }
    
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        print("Began editing")
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        print("Ended editing")
    
        // Reshow the event title, starttime, endtime, cancel button,text at the bottom
        self.eventNameTextField.hidden = false
        self.eventTimeTextField.hidden = false
        self.eventEndTimeTextField.hidden = false
        self.shuffleEventButton.hidden = false
        
        if (self.editingEvent == true) {
            self.cancelEventButton.hidden = false
            self.helperLabel.hidden = true
        } else {
            self.helperLabel.hidden = false
        }
        
        self.locationSearchResults.removeAll()
        self.locationTableView.hidden = true
    }
    
    func textFieldDidChange(textField: UITextField) {
        print("Text changed")
        
        // Hide the event title, starttime, endtime, cancel button,text at bottom
        self.navigationItem.leftBarButtonItem?.enabled = false
        
        self.eventNameTextField.hidden = true
        self.eventTimeTextField.hidden = true
        self.eventEndTimeTextField.hidden = true
        self.shuffleEventButton.hidden = true
        
        if (self.editingEvent == true) {
            self.cancelEventButton.hidden = true
        }
        
        self.helperLabel.hidden = true
        self.locationTableView.hidden = false
        animateViewMoving(true)
        
        self.locationTableView.frame = CGRect(x: 0, y: 55, width: self.view.bounds.width, height: 175)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let placesClient = GMSPlacesClient()
        placesClient.autocompleteQuery(self.eventLocationTextField.text!, bounds: nil, filter: nil) { (results, error:NSError?) -> Void in
            self.locationSearchResults.removeAll()
            if results == nil {
                return
            }
            for result in results!{
                if let result = result as? GMSAutocompletePrediction{
                    self.locationSearchResults.append(result.attributedFullText.string)
                }
            }
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.locationTableView.reloadData()
    }
    
    
    
    func animateViewMoving (up:Bool){
        let movementDuration:NSTimeInterval = 0.39
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.eventLocationTextField.frame.origin.y = 0
        UIView.commitAnimations()
        
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locationSearchResults.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("locationSuggestion", forIndexPath: indexPath) as! locationTableViewCell
        
        cell.locationLabel.text = self.locationSearchResults[indexPath.row]
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let cell = self.locationTableView.cellForRowAtIndexPath(indexPath) as! locationTableViewCell
        
        self.eventLocationTextField.text = cell.locationLabel.text
        self.eventNameTextField.hidden = false
        self.eventTimeTextField.hidden = false
        self.eventEndTimeTextField.hidden = false
        self.shuffleEventButton.hidden = false
        
        if (self.editingEvent == true) {
            self.cancelEventButton.hidden = false
            self.helperLabel.hidden = true
        } else {
            self.helperLabel.hidden = false
        }
        
        self.locationSearchResults.removeAll()
        self.locationTableView.hidden = true
        self.locationSearchResults.removeAll()
        self.eventLocationTextField.resignFirstResponder()
        self.navigationItem.leftBarButtonItem?.enabled = true
    }

    

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.navigationItem.leftBarButtonItem?.enabled = true
        return true
    }
    
    
    // Called when the user click on the view (outside the UITextField).
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        self.navigationItem.leftBarButtonItem?.enabled = true
    }

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if (segue.identifier == "Invite") {
            // Get Data
            let dataSet:NSMutableDictionary = NSMutableDictionary()
            dataSet.setObject(eventNameTextField.text!, forKey: "eventName")
            dataSet.setObject(eventTimeTextField.text!.substringWithRange(Range<String.Index>(start: eventTimeTextField.text!.startIndex.advancedBy(6), end: eventTimeTextField.text!.endIndex)), forKey: "eventTime")
            dataSet.setObject(eventEndTimeTextField.text!.substringWithRange(Range<String.Index>(start: eventEndTimeTextField.text!.startIndex.advancedBy(4), end: eventEndTimeTextField.text!.endIndex)), forKey: "eventEndTime")
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
