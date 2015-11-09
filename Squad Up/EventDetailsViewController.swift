//
//  EventDetailsViewController.swift
//  Squad Up
//
//  Created by Zain Manji on 9/23/15.
//  Copyright (c) 2015 Zeen Labs. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AddressBook

class EventDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate {
    

    
    // For Details Section
    
    var eventNameString: String!
    var eventCreatorString: String!
    var timeString: String!
    var endTimeString: String!
    var locationString: String!
    var coords: CLLocationCoordinate2D?
    
    var goingString: String!
    var notGoingString: String!
    var invitedPeopleString: String!
    
    var eventData:NSMutableDictionary = NSMutableDictionary();
    var eventObjectID:String = ""
    var eventObject:PFObject?
    
    var user:PFUser?
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
    
    var profilePicMap:NSMutableDictionary = NSMutableDictionary()
    
    
    // For Comments Section
    @IBOutlet var footerView: UIView!
    @IBOutlet var addCommentField: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var commentButton: UIButton!

    
    var commentList = [PFObject]()
    var newRefreshControl:UIRefreshControl!
    
    
    var keyboardFrame:NSValue!
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        eventObject?.fetch()
        eventData = eventObject!["dataSet"] as! NSMutableDictionary
        self.initializePage()
        self.tableView.reloadData()
        self.navigationController!.interactivePopGestureRecognizer!.enabled = true;
    }
    
    func initializePage() {
        self.user = PFUser.currentUser()
        
        self.actInd.center = self.view.center
        self.actInd.hidesWhenStopped = true
        self.actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(self.actInd)
        
        let eventCreator:String = eventData["eventCreator"] as! String
        
        self.addCommentField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        self.commentButton.enabled = false
        self.commentButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        
        
        self.navigationController!.navigationBar.hidden = false
        
        // Customize back button
        let myBackButton:UIButton = UIButton(type: UIButtonType.Custom)
        myBackButton.addTarget(self, action: "popDisplay:", forControlEvents: UIControlEvents.TouchUpInside)
        myBackButton.setTitle("Back", forState: UIControlState.Normal)
        myBackButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myBackButton.sizeToFit()
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        self.navigationController!.interactivePopGestureRecognizer!.delegate = self;
        
        // Customize blast button
        let blastButton:UIButton = UIButton(type: UIButtonType.Custom)
        blastButton.addTarget(self, action: "blastPeople:", forControlEvents: UIControlEvents.TouchUpInside)
        blastButton.setTitle("Blast", forState: UIControlState.Normal)
        blastButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        blastButton.setTitleColor(UIColor.greenColor(), forState: UIControlState.Highlighted)
        blastButton.sizeToFit()
        
        if (self.user?.objectId == eventCreator) {
            blastButton.enabled = true
            let customBlastButton:UIBarButtonItem = UIBarButtonItem(customView: blastButton)
            self.navigationItem.rightBarButtonItem  = customBlastButton
        } else {
            blastButton.enabled = false
            blastButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            let customBlastButton:UIBarButtonItem = UIBarButtonItem(customView: blastButton)
            self.navigationItem.rightBarButtonItem  = customBlastButton
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        
        
        
        
        
        // Fill in text fields with data.
        eventNameString = eventData.objectForKey("eventName") as? String
        eventCreatorString = eventData.objectForKey("eventCreatorName") as? String
        timeString = eventData.objectForKey("eventTime") as! String
        endTimeString = eventData.objectForKey("eventEndTime") as! String
        
        
        locationString = eventData.objectForKey("eventLocation") as! String
        if (locationString.isEmpty) {
            locationString = "Location to be determined"
        }
        
        if let invitedPeople:NSMutableDictionary = eventData["invitedPeople"] as? NSMutableDictionary {
            invitedPeopleString = String(invitedPeople.count) + "\nInvited"
        }
        
        if let goingPeople:NSMutableDictionary = eventData["goingPeople"] as? NSMutableDictionary {
            goingString = String(goingPeople.count) + "\nGoing"
        }
        
        if let notGoingPeople:NSMutableDictionary = eventData["notGoingPeople"] as? NSMutableDictionary {
            notGoingString = String(notGoingPeople.count) + "\nNot Going"
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializePage()
        
        // Create top border for comment button section
        let upperBorder:CALayer = CALayer();
        upperBorder.backgroundColor = UIColor.redColor().CGColor;
        upperBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.footerView.frame), 1.0);
        self.footerView.layer.addSublayer(upperBorder)
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)



        
        
        
        // For Comments Section
        
        // Dismiss keyboard if user taps elsewhere.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        
        dispatch_async(backgroundQueue, {
            print("This is run on the background queue")
            self.actInd.startAnimating()
            self.getCommentsList()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.actInd.stopAnimating()
                self.tableView.reloadData()
            })
        })
        
        // Get comment list from Parse for event id - getCommentList
        //self.getCommentsList()
        
        self.addCommentField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        self.newRefreshControl = UIRefreshControl()
        self.newRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.newRefreshControl.addTarget(self, action: "refreshPage:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(newRefreshControl)
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openLocationInMaps(sender: UIButton) {
        let geoCoder = CLGeocoder()
        
        let addressString = locationString
        
        geoCoder.geocodeAddressString(addressString, completionHandler:
            {(placemarks: [CLPlacemark]?, error: NSError?) in
                
                if error != nil {
                    print("Geocode failed with error: \(error!.localizedDescription)")
                } else if placemarks!.count > 0 {
                    let placemark = placemarks![0]
                    let location = placemark.location
                    self.coords = location!.coordinate
                    
                    self.showMap()
                    
                }
        })
    }
    
    
    func showMap() {
        let addressDict =
        [kABPersonAddressStreetKey as String: locationString]

        
        let place = MKPlacemark(coordinate: coords!,
            addressDictionary: addressDict)
        
        let mapItem = MKMapItem(placemark: place)
        
        let options = [MKLaunchOptionsDirectionsModeKey:
        MKLaunchOptionsDirectionsModeDriving]
        
        mapItem.openInMapsWithLaunchOptions(options)
    }
    
    
    // Cancel event
    @IBAction func cancelEvent(sender: AnyObject) {
        let alert = UIAlertController(title:"Cancel squad event?", message: "Are you sure you want to cancel the squad event?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title:"Yes", style: .Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion:nil)
        }))
        
        let eventItem:NSMutableDictionary = eventObject!["dataSet"] as! NSMutableDictionary
        eventItem["eventCancelled"] = true
        self.eventObject!["dataSet"] = eventItem
        self.eventObject?.save()
        
        
        var users:[AnyObject] = []
        if let goingPeople:NSMutableDictionary = eventData["goingPeople"] as? NSMutableDictionary {
            goingPeople.removeObjectForKey(self.user!.objectId!)
            users = goingPeople.allKeys
        }
        
        if let invitedPeople:NSMutableDictionary = eventData["invitedPeopleWithApp"] as? NSMutableDictionary {
            invitedPeople.removeObjectForKey(self.user!.objectId!)
            users = users + invitedPeople.allKeys
        }
        
        
        // Send push notification to people who are going/invited to event
        let pushQuery = PFInstallation.query()
        pushQuery?.whereKey("userId", containedIn: users)
        let push = PFPush()
        push.setQuery(pushQuery)
        push.setMessage("The event, " + eventNameString + " has been cancelled!")
        push.sendPushInBackground()
        
        
        self.popDisplay(sender)
        
        // Need to notify going/invited people that event has been cancelled
        self.tableView.reloadData()
        
    }
    
    
    @IBAction func goingButtonAction(sender: UIButton) {
        
        eventObject!.fetch()
        eventObject!.fetchIfNeeded()
        
        if let objectId:String = self.user!.objectId {
            let userName:String = self.user?["name"] as! String
            
            if let goingPeople:NSMutableDictionary = eventData["goingPeople"] as? NSMutableDictionary {
                // Add user to going list
                eventObject!.objectForKey("dataSet")?.objectForKey("goingPeople")?.setObject(userName, forKey: objectId)
            }
            
            if let notGoingPeople:NSMutableDictionary = eventData["notGoingPeople"] as? NSMutableDictionary {
                if let member:String = notGoingPeople[objectId] as? String {
                    // user in not going list, remove them
                    eventObject!.objectForKey("dataSet")?.objectForKey("notGoingPeople")?.removeObjectForKey(objectId)
                    if (objectId != eventObject!.objectForKey("dataSet")?.objectForKey("eventCreator") as! String) {
                        self.sendUserEventResponseNotification(true, eventObject: eventObject!, userName: userName, eventName: eventNameString)
                    }
                }
                
            }
            
            if let invitedPeople:NSMutableDictionary = eventData["invitedPeople"] as? NSMutableDictionary {
                if let member:String = invitedPeople[objectId] as? String {
                    // user in invited list, remove them
                    eventObject!.objectForKey("dataSet")?.objectForKey("invitedPeople")?.removeObjectForKey(objectId)
                    self.sendUserEventResponseNotification(true, eventObject: eventObject!, userName: userName, eventName: eventNameString)
                }
            }
        }
        
        eventObject!.saveInBackground()
        eventData = eventObject!["dataSet"] as! NSMutableDictionary
        
        self.tableView.reloadData()
        
    }

    
    
    
    
    @IBAction func notGoingButtonAction(sender: AnyObject) {
        
        eventObject!.fetch()
        eventObject!.fetchIfNeeded()
        
        if let objectId:String = self.user!.objectId {
            let userName:String = self.user?["name"] as! String
            
            if let goingPeople:NSMutableDictionary = eventData["goingPeople"] as? NSMutableDictionary {
                if let member:String = goingPeople[objectId] as? String {
                    // user in not going list, remove them
                    eventObject!.objectForKey("dataSet")?.objectForKey("goingPeople")?.removeObjectForKey(objectId)
                    if (objectId != eventObject!.objectForKey("dataSet")?.objectForKey("eventCreator") as! String) {
                        self.sendUserEventResponseNotification(false, eventObject: eventObject!, userName: userName, eventName: eventNameString)
                    }
                }
            }
            
            if let notGoingPeople:NSMutableDictionary = eventData["notGoingPeople"] as? NSMutableDictionary {
                // Add user to not going list
                eventObject!.objectForKey("dataSet")?.objectForKey("notGoingPeople")?.setObject(userName, forKey: objectId)
            }
            
            if let invitedPeople:NSMutableDictionary = eventData["invitedPeople"] as? NSMutableDictionary {
                if let member:String = invitedPeople[objectId] as? String {
                    // user in invited list, remove them
                    invitedPeople.removeObjectForKey(objectId)
                    self.sendUserEventResponseNotification(false, eventObject: eventObject!, userName: userName, eventName: eventNameString)
                }
            }
        }
        
        eventObject!.saveInBackground()
        eventData = eventObject!["dataSet"] as! NSMutableDictionary
        tableView.reloadData()
    }
    
    
    // Send response notification to the author when someone responds not going/going
    func sendUserEventResponseNotification(going: Bool, eventObject: PFObject, userName: String, eventName: String) {
        let authorChannel = eventObject["eventAuthorChannel"] as! String
        var inviteResponse = ""
        
        if (going) {
            inviteResponse = "going"
        } else {
            inviteResponse = "not going"
        }
        
        PFCloud.callFunctionInBackground("sendPushNotifications",
            withParameters: ["channel": authorChannel, "inviteResponse": inviteResponse, "squadMemberName": userName, "eventName": eventName]) {
                (response: AnyObject?, error: NSError?) -> Void in
                if (error != nil){
                    print("Error sending push notification to author")
                    print(error)
                } else {
                    print("Push notification sent to author")
                }
        }
    }
    
    
    
    
    
    
    // BLAST FUNCTION
    // Actually should be called event blast invited people
    @IBAction func blastPeople(sender: UIBarButtonItem) {
        
        let username:String = self.user?["name"] as! String
        let eventName:String = eventData["eventName"] as! String
        
        if let invitedPeople:NSMutableDictionary = eventData["invitedPeople"] as? NSMutableDictionary {
            let users:[AnyObject] = invitedPeople.allKeys
            
            // Send push notification to people who were just invited to event
            let pushQuery = PFInstallation.query()
            pushQuery?.whereKey("userId", containedIn: users)
            let push = PFPush()
            push.setQuery(pushQuery)
            push.setMessage(username + " is reminding you to respond to " + eventName)
            push.sendPushInBackground()
        }
        
        let alert = UIAlertController(title:"Blasted!", message: "Sent a reminder to respond to those who haven't.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title:"Cool", style: .Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion:nil)
            
        }))
        
        self.presentViewController(alert, animated:true, completion:nil)
    }
    
    
    
    @IBAction func checkPeopleGoing(sender: UIButton) {
        self.performSegueWithIdentifier("goingSegue", sender: self)
    }
    
    @IBAction func checkPeopleNotGoing(sender: UIButton) {
        self.performSegueWithIdentifier("notGoingSegue", sender: self)
    }
    
    @IBAction func checkPeopleInvited(sender: UIButton) {
        self.performSegueWithIdentifier("invitedPeopleSegue", sender: self)
    }
    
    
    func popDisplay(sender:AnyObject){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    
    func textFieldDidChange(textField: UITextField) {
        print("fieldchanged")
        
        
        if self.addCommentField.text == "" {
            self.commentButton.enabled = false
            self.commentButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        } else {
            self.commentButton.enabled = true
            self.commentButton.setTitleColor(UIColor.greenColor(), forState: UIControlState.Normal)
        }
        
    }
    
    @IBAction func addCommentButton(sender: AnyObject) {
        self.view.endEditing(true)
        var error = ""
        
        if addCommentField.text == "" {
            error = "Please enter a comment!"
        } else {
            
            // Create a comment object with event id, the comment, creation time, user name
            // Save it to parse
            // Refresh the table
            // Create the new event and save it to db
            let comment = PFObject(className:"CommentActivity")
            comment["comment"] = self.addCommentField.text
            comment["userId"] = self.user?.objectId
            comment["eventId"] = eventObject?.objectId
            comment["username"] = self.user?["name"]
            comment["facebookId"] = self.user?["facebookID"]
            comment.save()
            
            self.refreshComments()
        }
        
        if error != "" {
            let alert = UIAlertController(title:"Empty ", message: error, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title:"OK", style: .Default, handler: { action in
                self.dismissViewControllerAnimated(true, completion:nil)
                
            }))
            
            self.presentViewController(alert, animated:true, completion:nil)
        }
        
        addCommentField.text = ""
        self.commentButton.enabled = false
        self.commentButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
    }
    
    // Calls this function when the tap is recognized.
    func DismissKeyboard(){
        view.endEditing(true)
    }
    
    
    func refreshPage(sender:AnyObject) {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        
        dispatch_async(backgroundQueue, {
            print("This is run on the background queue")
            self.refreshComments()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("This is run on the main queue, after the previous code in outer block")
                self.tableView.reloadData()
                self.newRefreshControl.endRefreshing()
            })
        })
    }
    
    func getCommentsList() {
        let query = PFQuery(className: "CommentActivity")
        query.whereKey("eventId", equalTo: eventObject!.objectId!)
        query.orderByDescending("createdAt")
        let eventComments = query.findObjects() as! [PFObject]
        
        self.commentList = eventComments
        
        self.profilePicMap = NSMutableDictionary()
        
        for comment in self.commentList {
            if (self.profilePicMap.objectForKey(comment["userId"]!) != nil) {
                continue
            }
            let fbid = comment["facebookId"] as! String
            let profilePic:UIImage = self.getProfPic(fbid)!
            let profilePicView:UIImageView = UIImageView(image: profilePic)
            profilePicView.frame = CGRect(x: 15, y: 30, width: 30, height: 30)
            profilePicView.layer.cornerRadius = profilePicView.frame.size.width / 2
            profilePicView.clipsToBounds = true
            self.profilePicMap.setObject(profilePicView, forKey: comment["userId"] as! String)
        }
        self.tableView.reloadData()
    }
    
    
    func refreshComments() {
        self.getCommentsList()
        self.tableView.reloadData()
    }
    
    
    // get fb profile pic
    func getProfPic(fid: String) -> UIImage? {
        
        let url = NSURL(string: "https://graph.facebook.com/" + fid + "/picture?type=large")!
        
        let urlRequest = NSURLRequest(URL: url)
        
        do {
            let urlData:NSData = try NSURLConnection.sendSynchronousRequest(urlRequest,
                returningResponse: AutoreleasingUnsafeMutablePointer<NSURLResponse?>())
            let image:UIImage = UIImage(data: urlData)!
            
            return image
            
        } catch let error as NSError {
            print("CAUGHT ERROR")
        }
        
        return nil
        
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if (section == 0) {
            return 1
        } else if (section == 1) {
            return 1
        } else {
            return self.commentList.count
        }
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let invitedPeople:NSMutableDictionary = eventData["invitedPeople"] as? NSMutableDictionary {
            invitedPeopleString = String(invitedPeople.count) + "\nInvited"
        }
        
        if let goingPeople:NSMutableDictionary = eventData["goingPeople"] as? NSMutableDictionary {
            goingString = String(goingPeople.count) + "\nGoing"
        }
        
        if let notGoingPeople:NSMutableDictionary = eventData["notGoingPeople"] as? NSMutableDictionary {
            notGoingString = String(notGoingPeople.count) + "\nNot Going"
        }
        
        
        if (indexPath.section == 0) {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("EventDetailsCell", forIndexPath: indexPath) as! EventDetailsTableViewCell
            
            cell.eventNameLabel.text = eventNameString
            
            cell.goingButton.setTitle(goingString, forState: UIControlState.Normal)
            cell.goingButton.titleLabel?.textAlignment = NSTextAlignment.Center
            
            cell.notGoingButton.setTitle(notGoingString, forState: UIControlState.Normal)
            cell.notGoingButton.titleLabel?.textAlignment = NSTextAlignment.Center
            
            cell.invitedPeopleButton.setTitle(invitedPeopleString, forState: UIControlState.Normal)
            cell.invitedPeopleButton.titleLabel?.textAlignment = NSTextAlignment.Center
            
            cell.eventCreatorLabel.text = "Hosted by " + eventCreatorString
            
            
            
            
            // Moved from repsonse table view cell
            
            var isUserGoing:Bool!
            var isUserNotGoing:Bool!
            if let member:String = eventData["goingPeople"]?.objectForKey((self.user?.objectId)!) as? String {
                isUserGoing = true
            } else {
                isUserGoing = false
            }
            
            if let member:String = eventData["notGoingPeople"]?.objectForKey((self.user?.objectId)!) as? String {
                isUserNotGoing = true
            } else {
                isUserNotGoing = false
            }
            
            cell.goingResponseButton.highlighted = isUserGoing
            cell.notGoingResponseButton.highlighted = isUserNotGoing
            cell.goingResponseButton.selected = isUserGoing
            cell.notGoingResponseButton.selected = isUserNotGoing
            
            // Customize appearance of cell
            cell.backgroundColor = UIColor.whiteColor()
            cell.alpha = 0.1
            cell.separatorInset = UIEdgeInsetsZero
            cell.preservesSuperviewLayoutMargins = false
            
            
            
            return cell
        } else if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCellWithIdentifier("ResponseCell", forIndexPath: indexPath) as! ResponseTableViewCell
            
            // Toggle the going/not going button highlight, check if user.objectID in going or notgoing list
            let isUserAuthor:Bool = self.user?.objectId == self.eventObject?.objectForKey("dataSet")?.objectForKey("eventCreator") as? String
            
            
            
            
            let eventCancelled:Bool = (self.eventObject?.objectForKey("dataSet")?.objectForKey("eventCancelled") as! Bool)
            
            cell.cancelEventButton.hidden = !isUserAuthor && eventCancelled
            cell.cancelEventButton.enabled = isUserAuthor && !eventCancelled
            cell.editEventButton.hidden = !isUserAuthor && eventCancelled
            cell.editEventButton.enabled = isUserAuthor && !eventCancelled
            
            
            
            
            // Moved from event details to here.
            
            cell.timeLabel.text = timeString
            cell.endTimeLabel.text = endTimeString
            cell.locationButton.setTitle(locationString, forState: UIControlState.Normal)
            
            // Customize appearance of cell
            cell.backgroundColor = UIColor.whiteColor()
            cell.alpha = 0.1
            cell.separatorInset = UIEdgeInsetsZero
            cell.preservesSuperviewLayoutMargins = false
            
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentsTableViewCell
            let commentObject:PFObject = self.commentList[indexPath.row]
            
            cell.message.text = commentObject["comment"] as? String
            cell.username.text = commentObject["username"] as? String
            let date:NSDate = commentObject.createdAt!
            
            let currentDate:NSDate = NSDate()
            let minutesFromNow:Double = currentDate.timeIntervalSinceDate(date) / 60.0
            
            if (minutesFromNow < 60.0) {
                cell.time.text = String(stringInterpolationSegment: Int(minutesFromNow)) + "m ago"
            } else if (minutesFromNow >= 60.0) {
                cell.time.text = String(stringInterpolationSegment: Int(minutesFromNow/60.0)) + "h ago"
            } else if (minutesFromNow >= 1440.0) {
                cell.time.text = String(stringInterpolationSegment: Int(minutesFromNow/1440.0)) + "d ago"
            }
            
            
            
            // Customize appearance of cell
            cell.backgroundColor = UIColor.whiteColor()
            cell.alpha = 0.1
            cell.separatorInset = UIEdgeInsetsZero
            cell.preservesSuperviewLayoutMargins = false

            
            if (self.profilePicMap.objectForKey(commentObject["userId"]!) != nil) {

                
                let pic = self.profilePicMap.objectForKey(commentObject["userId"]!) as! UIImageView

                cell.profilePic.image = pic.image
                cell.profilePic.frame = CGRect(x: 15, y: 30, width: 30, height: 30)
                cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2
                cell.profilePic.clipsToBounds = true
            }
            
            
            return cell
        }

    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return 175
        } else if (indexPath.section == 1) {
            return 115
        } else {
            return 90
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 1) {
            return 30
        } else if (section == 2) {
            return 30
        } else {
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // do not display empty `Section`s
        if (section == 0) {
            return ""
        } else if (section == 1) {
            return "Event details"
        } else if (section == 2) {
            if (self.commentList.count == 1) {
                return String(self.commentList.count) + " comment"
            } else {
                return String(self.commentList.count) + " comments"
            }
        }
        
        return ""
    }
    
    
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let border = UIView(frame: CGRectMake(0,0,self.view.bounds.width,1))
        border.backgroundColor = UIColor(red: 187.0/256.0, green: 187.0/256.0, blue: 187.0/256.0, alpha: 1.0)
        
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
        header.textLabel!.font = UIFont(name: "Futura", size: 14)!
        header.textLabel!.textColor = UIColor(red: 107.0/256.0, green: 107.0/256.0, blue: 107.0/256.0, alpha: 1.0)
        header.alpha = 1.0 //make the header transparent
        header.addSubview(border)
    }

    
    // MARK: - Navigation

    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "goingSegue") {
            // Get Data
            if let goingPeople:NSMutableDictionary = eventData["goingPeople"] as? NSMutableDictionary {
                let goingPeopleView:GoingPeopleTableViewController = segue.destinationViewController as! GoingPeopleTableViewController
                goingPeopleView.goingPeople = goingPeople
            }
        } else if (segue.identifier == "notGoingSegue") {
            // Get Data
            if let notGoingPeople:NSMutableDictionary = eventData["notGoingPeople"] as? NSMutableDictionary {
                let notGoingPeopleView:NotGoingTableViewController = segue.destinationViewController as! NotGoingTableViewController
                notGoingPeopleView.notGoingPeople = notGoingPeople
            }
        } else if (segue.identifier == "invitedPeopleSegue") {
            // Get Data
            if let invitedPeople:NSMutableDictionary = eventData["invitedPeople"] as? NSMutableDictionary {
                let invitedPeopleView:InvitedPeopleTableViewController = segue.destinationViewController as! InvitedPeopleTableViewController
                invitedPeopleView.invitedPeople = invitedPeople
            }
        } else if (segue.identifier == "EditEvent") {
            let editEventView:AddViewController = segue.destinationViewController as! AddViewController
            editEventView.editingEvent = true
            editEventView.editingEventObject = self.eventObject
        }
    }
    
    
    
    @IBAction func editEvent(sender: AnyObject) {
        self.performSegueWithIdentifier("EditEvent", sender: self)
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if let userInfo = sender.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                self.keyboardFrame = keyboardHeight
                self.animateViewMoving(true, moveValue: keyboardHeight.CGRectValue().size.height)
            }
        }
    }
    
    
    
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //let frame = (notification.userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        //animateViewMoving(true, moveValue: 225)
    }
    func textFieldDidEndEditing(textField: UITextField) {
        animateViewMoving(false, moveValue: keyboardFrame.CGRectValue().size.height)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }

}
