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
import DGElasticPullToRefresh

extension UIScrollView {
    func dg_stopScrollingAnimation() {}
}

class EventDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate {
    

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // For Details Section
    
    var keyboardShown:Bool = false
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
    
    var blastImage:UIImage?
    
    
    // For Comments Section
    @IBOutlet var footerView: UIView!
    @IBOutlet var addCommentField: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var commentButton: UIButton!

    
    var commentList = [PFObject]()
    var newRefreshControl:UIRefreshControl!
    
    
    var keyboardFrame:NSValue!
    var viewAppeared:Bool = true
    
    
    override func viewDidAppear(animated: Bool) {
        //self.DismissKeyboard()
        self.viewAppeared = true
        self.addCommentField.resignFirstResponder()
        self.viewAppeared = false
        //self.view.frame = CGRectOffset(self.view.frame, 0,  0)
        super.viewDidAppear(animated)
        eventObject?.fetchIfNeeded()
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
        myBackButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        myBackButton.sizeToFit()
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        self.navigationController!.interactivePopGestureRecognizer!.delegate = self;
        
        
        // Customize edit button
        let editButton:UIButton = UIButton(type: UIButtonType.Custom)
        editButton.addTarget(self, action: "editEvent:", forControlEvents: UIControlEvents.TouchUpInside)
        editButton.setTitle("Edit", forState: UIControlState.Normal)
        editButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        editButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        editButton.sizeToFit()
        
        // Customize blast button
        let blastButton:UIButton = UIButton(type: UIButtonType.Custom)
        blastButton.addTarget(self, action: "blastPeople:", forControlEvents: UIControlEvents.TouchUpInside)
        blastButton.setTitle("Blast", forState: UIControlState.Normal)
        blastButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        blastButton.setTitleColor(UIColor.greenColor(), forState: UIControlState.Highlighted)
        blastButton.sizeToFit()
        
        let eventCancelled:Bool = (self.eventObject?.objectForKey("dataSet")?.objectForKey("eventCancelled") as! Bool)
        
        
        if (self.user?.objectId == eventCreator) {
            editButton.enabled = true
            editButton.hidden = false
            
            blastButton.enabled = true
            blastButton.hidden = false
            
            let customEditButton:UIBarButtonItem = UIBarButtonItem(customView: editButton)
            self.navigationItem.rightBarButtonItem  = customEditButton
        } else if (eventCancelled) {
            editButton.enabled = false
            editButton.hidden = true
            
            blastButton.enabled = false
            blastButton.hidden = true
            
            let customEditButton:UIBarButtonItem = UIBarButtonItem(customView: editButton)
            self.navigationItem.rightBarButtonItem  = customEditButton
            self.navigationItem.rightBarButtonItem?.enabled = false
        } else {
            editButton.enabled = false
            editButton.hidden = true
            
            blastButton.enabled = false
            blastButton.hidden = true
            
            let customEditButton:UIBarButtonItem = UIBarButtonItem(customView: editButton)
            self.navigationItem.rightBarButtonItem  = customEditButton
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
        
        self.view.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
        
        
        
        self.addCommentField.delegate = self
        self.initializePage()
        
        self.title = eventNameString
        
        // Create top border for comment button section
        let upperBorder:CALayer = CALayer();
        upperBorder.backgroundColor = UIColor(red: 28.0/255.0, green: 50.0/255.0, blue: 115.0/255.0, alpha: 1.0).CGColor;
        upperBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.footerView.frame), 1.0);
        self.footerView.layer.addSublayer(upperBorder)
        
        
        
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

        

        
        
        
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
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = 350
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
//        self.newRefreshControl = UIRefreshControl()
//        self.newRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
//        self.newRefreshControl.addTarget(self, action: "refreshPage:", forControlEvents: UIControlEvents.ValueChanged)
//        self.tableView.addSubview(newRefreshControl)
        
        // Initialize tableView
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        self.tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
            // Do not forget to call dg_stopLoading() at the end
            print("Refreshing pull")
            
            self!.getCommentsList()
            self!.tableView.reloadData()
            //self!.tableView.reloadData()
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        self.tableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
        self.tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)

    }
    
    deinit {
        self.tableView.dg_removePullToRefresh()
    }
    
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.Down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.Left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.Up:
                print("Swiped up")
            default:
                break
            }
        }
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
    
    
//    // Cancel event
//    @IBAction func cancelEvent(sender: AnyObject) {
//        let cancelAlert = UIAlertController(title: "Cancel Event?", message: "Are you sure you want to cancel the event for the squad?", preferredStyle: UIAlertControllerStyle.Alert)
//        
//        cancelAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
//            
//            let eventItem:NSMutableDictionary = self.eventObject!["dataSet"] as! NSMutableDictionary
//            eventItem["eventCancelled"] = true
//            self.eventObject!["dataSet"] = eventItem
//            self.eventObject?.save()
//            
//            
//            var users:[AnyObject] = []
//            if let goingPeople:NSMutableDictionary = self.eventData["goingPeople"] as? NSMutableDictionary {
//                goingPeople.removeObjectForKey(self.user!.objectId!)
//                users = goingPeople.allKeys
//            }
//            
//            if let invitedPeople:NSMutableDictionary = self.eventData["invitedPeopleWithApp"] as? NSMutableDictionary {
//                invitedPeople.removeObjectForKey(self.user!.objectId!)
//                users = users + invitedPeople.allKeys
//            }
//            
//            
//            // Send push notification to people who are going/invited to event
//            let pushQuery = PFInstallation.query()
//            pushQuery?.whereKey("userId", containedIn: users)
//            let push = PFPush()
//            push.setQuery(pushQuery)
//            push.setMessage("The event, " + self.eventNameString + " has been cancelled!")
//            push.sendPushInBackground()
//            
//            
//            self.popDisplay(sender)
//            
//            // Need to notify going/invited people that event has been cancelled
//            self.tableView.reloadData()
//        }))
//        
//        
//        // Cancel action
//        cancelAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
//            print("User pressed cancel on the alert.")
//        }))
//        
//        presentViewController(cancelAlert, animated: true, completion: nil)
//        
//    }
    
    
    @IBAction func goingButtonAction(sender: UIButton) {
        
        //eventObject!.fetch()
        eventObject!.fetchIfNeeded()
        
        if let objectId:String = self.user!.objectId {
            let userName:String = self.user?["name"] as! String
            
            if let _:NSMutableDictionary = eventData["goingPeople"] as? NSMutableDictionary {
                // Add user to going list
                eventObject!.objectForKey("dataSet")?.objectForKey("goingPeople")?.setObject(userName, forKey: objectId)
            }
            
            if let notGoingPeople:NSMutableDictionary = eventData["notGoingPeople"] as? NSMutableDictionary {
                if let _:String = notGoingPeople[objectId] as? String {
                    // user in not going list, remove them
                    eventObject!.objectForKey("dataSet")?.objectForKey("notGoingPeople")?.removeObjectForKey(objectId)
                    if (objectId != eventObject!.objectForKey("dataSet")?.objectForKey("eventCreator") as! String) {
                        self.sendUserEventResponseNotification(true, eventObject: eventObject!, userName: userName, eventName: eventNameString)
                    }
                }
                
            }
            
            if let invitedPeople:NSMutableDictionary = eventData["invitedPeople"] as? NSMutableDictionary {
                if let _:String = invitedPeople[objectId] as? String {
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
        
        //eventObject!.fetch()
        eventObject!.fetchIfNeeded()
        
        if let objectId:String = self.user!.objectId {
            let userName:String = self.user?["name"] as! String
            
            if let goingPeople:NSMutableDictionary = eventData["goingPeople"] as? NSMutableDictionary {
                if let _:String = goingPeople[objectId] as? String {
                    // user in not going list, remove them
                    eventObject!.objectForKey("dataSet")?.objectForKey("goingPeople")?.removeObjectForKey(objectId)
                    if (objectId != eventObject!.objectForKey("dataSet")?.objectForKey("eventCreator") as! String) {
                        self.sendUserEventResponseNotification(false, eventObject: eventObject!, userName: userName, eventName: eventNameString)
                    }
                }
            }
            
            if let _:NSMutableDictionary = eventData["notGoingPeople"] as? NSMutableDictionary {
                // Add user to not going list
                eventObject!.objectForKey("dataSet")?.objectForKey("notGoingPeople")?.setObject(userName, forKey: objectId)
            }
            
            if let invitedPeople:NSMutableDictionary = eventData["invitedPeople"] as? NSMutableDictionary {
                if let _:String = invitedPeople[objectId] as? String {
                    // user in invited list, remove them
                    eventObject!.objectForKey("dataSet")?.objectForKey("invitedPeople")?.removeObjectForKey(objectId)
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
    @IBAction func blastPeople(sender: AnyObject) {
        
        let blastAlert = UIAlertController(title: "Send reminder?", message: "Would you like to send an event reminder to friends who haven't responded yet?", preferredStyle: UIAlertControllerStyle.Alert)
        
        
        blastAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            
        
            let username:String = self.user?["name"] as! String
            let eventName:String = self.eventData["eventName"] as! String
            
            if let invitedPeople:NSMutableDictionary = self.eventData["invitedPeople"] as? NSMutableDictionary {
                let users:[AnyObject] = invitedPeople.allKeys
                
                // Send push notification to people who were just invited to event
                let pushQuery = PFInstallation.query()
                pushQuery?.whereKey("userId", containedIn: users)
                let push = PFPush()
                push.setQuery(pushQuery)
                push.setMessage(username + " is reminding you to respond to " + eventName)
                push.sendPushInBackground()
            }
            
            let alert = UIAlertController(title:"Reminded!", message: "Sent an event reminder to friends who haven't responded yet!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title:"Cool", style: .Default, handler: { action in
                self.dismissViewControllerAnimated(true, completion:nil)
                
            }))
            
            self.presentViewController(alert, animated:true, completion:nil)
        }))
        
        // Cancel action
        blastAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
            print("User pressed no on the alert.")
        }))
        
        self.presentViewController(blastAlert, animated:true, completion:nil)
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
        
        if self.addCommentField.text == "" {
            self.commentButton.enabled = false
            self.commentButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        } else {
            self.commentButton.enabled = true
            self.commentButton.setTitleColor(UIColor.greenColor(), forState: UIControlState.Normal)
        }
        
    }
    
    @IBAction func addCommentButton(sender: AnyObject) {
        //self.view.endEditing(true)
        var error = ""
        
        if addCommentField.text == "" {
            error = "Please enter a comment!"
        } else {
            eventObject?.fetchIfNeeded()
            eventData = eventObject!["dataSet"] as! NSMutableDictionary
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
            
            let users:NSMutableDictionary = self.eventData["invitedPeopleWithApp"] as! NSMutableDictionary
            //Filter users. Only those that are invited and going with app get notifications
            let usersArr:[AnyObject] = users.allKeys
            var resultArr:[AnyObject] = self.filterCommentReceivers(usersArr as! [String])
            
            if (self.user?.objectId != self.eventData["eventCreator"] as? String) {
                resultArr.append(self.eventData["eventCreator"] as! String)
            }
 
            
            
            let name:String = (self.user?["name"])! as! String
            // Send push notification to people who were just invited to event
            let pushQuery = PFInstallation.query()
            pushQuery?.whereKey("userId", containedIn: resultArr)
            let push = PFPush()
            push.setQuery(pushQuery)
            push.setMessage(name + " said: " + self.addCommentField.text!)
            push.sendPushInBackground()
            
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
    
    
    func filterCommentReceivers(usersArr: [String]) -> [AnyObject] {
        var resultArr:[AnyObject] = []
        let invitedPeople:NSMutableDictionary = (eventData["invitedPeople"] as? NSMutableDictionary)!
        let goingPeople:NSMutableDictionary = (eventData["goingPeople"] as? NSMutableDictionary)!

        for user in usersArr {
            if (user == self.user?.objectId) {
                continue
            } else if (invitedPeople.objectForKey(user) != nil) {
                resultArr.append(user)
            } else if (goingPeople.objectForKey(user) != nil) {
                resultArr.append(user)
            }
        }
        
        return resultArr
    }
    
    // Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //animateViewMoving(false, moveValue: keyboardFrame.CGRectValue().size.height)
        self.addCommentField.resignFirstResponder()
        //view.endEditing(true)
        //animateViewMoving(false, moveValue: keyboardFrame.CGRectValue().size.height)
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
    
    
    func getProfPicForName(username: String, box: String) -> UIImageView {
        let contactPic:UIImage = UIImage(named: box)!
        let fullNameArr = username.componentsSeparatedByString(" ")
        var initials:String = ""
        for char in fullNameArr[0].characters {
            initials = initials + String(char)
            break
        }
        if (fullNameArr.count > 1) {
            for char in fullNameArr[1].characters {
                initials = initials + String(char)
                break
            }
        }
        let newImage:UIImage = textToImage(initials, inImage: contactPic, atPoint: CGPointMake(40, 40))
        
        
        
        let profilePicView:UIImageView = UIImageView(image: newImage)
        profilePicView.frame = CGRect(x: 15, y: 13, width: 40, height: 40)
        profilePicView.layer.cornerRadius = profilePicView.frame.size.width / 2
        profilePicView.clipsToBounds = true
        
        
        return profilePicView
    }
    
    
    func textToImage(drawText: NSString, inImage: UIImage, atPoint:CGPoint)->UIImage{
        
        // Setup the font specific variables
        let textColor: UIColor = UIColor.whiteColor()
        let textFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 115)!
        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(inImage.size)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
        ]
        
        let size:CGSize = drawText.sizeWithAttributes(textFontAttributes)
        
        
        //Put the image into a rectangle as large as the original image.
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        
        // Creating a point within the space that is as bit as the image.
        //let rect: CGRect = CGRectMake(0 + , atPoint.y, inImage.size.width, inImage.size.height)
        
        let textRect:CGRect = CGRectMake(CGFloat(0.0) + CGFloat(floorf(Float(inImage.size.width - size.width) / Float(2.0))),
            CGFloat(Float(0) + floorf(Float(inImage.size.height - size.height) / Float(2.0))),
            size.width,
            size.height);
        
        //Now Draw the text into an image.
        drawText.drawInRect(textRect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
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
            
        } catch {
            print("Error getting profile pic")
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
            invitedPeopleString = String(invitedPeople.count)// + "\nInvited"
        }
        
        if let goingPeople:NSMutableDictionary = eventData["goingPeople"] as? NSMutableDictionary {
            goingString = String(goingPeople.count) //+ "\nGoing"
        }
        
        if let notGoingPeople:NSMutableDictionary = eventData["notGoingPeople"] as? NSMutableDictionary {
            notGoingString = String(notGoingPeople.count) //+ "\nNot Going"
        }
        
        
        if (indexPath.section == 0) {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("EventDetailsCell", forIndexPath: indexPath) as! EventDetailsTableViewCell
            
            
            cell.eventNameLabel.text = eventNameString
        
            
        
            
            
            let goingButtonView:UIImageView = self.getProfPicForName(goingString, box: "greenbox.png")
            cell.numGoingImage.image = goingButtonView.image
            cell.numGoingImage.layer.cornerRadius = cell.numGoingImage.frame.size.width / 2
            cell.numGoingImage.clipsToBounds = true
            
            let goingButton:UIButton = UIButton.init(frame: CGRectMake(cell.numGoingImage.frame.origin.x, cell.numGoingImage.frame.origin.y, cell.numGoingImage.frame.size.width, cell.numGoingImage.frame.size.height))
            goingButton.backgroundColor = UIColor.clearColor();
            goingButton.showsTouchWhenHighlighted = true;
            goingButton.addTarget(self, action: "checkPeopleGoing:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.addSubview(goingButton)
            
//            cell.notGoingButton.setTitle(notGoingString, forState: UIControlState.Normal)
//            cell.notGoingButton.titleLabel?.textAlignment = NSTextAlignment.Center
            
            let notGoingButtonView:UIImageView = self.getProfPicForName(notGoingString, box: "redbox.png")
            cell.numNotGoingImage.image = notGoingButtonView.image
            cell.numNotGoingImage.layer.cornerRadius = cell.numNotGoingImage.frame.size.width / 2
            cell.numNotGoingImage.clipsToBounds = true
            
            let notGoingButton:UIButton = UIButton.init(frame: CGRectMake(cell.numNotGoingImage.frame.origin.x, cell.numNotGoingImage.frame.origin.y, cell.numNotGoingImage.frame.size.width, cell.numNotGoingImage.frame.size.height))
            notGoingButton.backgroundColor = UIColor.clearColor();
            notGoingButton.showsTouchWhenHighlighted = true;
            notGoingButton.addTarget(self, action: "checkPeopleNotGoing:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.addSubview(notGoingButton)
            
//            cell.invitedPeopleButton.setTitle(invitedPeopleString, forState: UIControlState.Normal)
//            cell.invitedPeopleButton.titleLabel?.textAlignment = NSTextAlignment.Center
            
            let invitedButtonView:UIImageView = self.getProfPicForName(invitedPeopleString, box: "orangebox.png")
            cell.numInvitedImage.image = invitedButtonView.image
            cell.numInvitedImage.layer.cornerRadius = cell.numInvitedImage.frame.size.width / 2
            cell.numInvitedImage.clipsToBounds = true
            
            let invitedButton:UIButton = UIButton.init(frame: CGRectMake(cell.numInvitedImage.frame.origin.x, cell.numInvitedImage.frame.origin.y, cell.numInvitedImage.frame.size.width, cell.numInvitedImage.frame.size.height))
            invitedButton.backgroundColor = UIColor.clearColor();
            invitedButton.showsTouchWhenHighlighted = true;
            invitedButton.addTarget(self, action: "checkPeopleInvited:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.addSubview(invitedButton)
            
            cell.eventCreatorLabel.text = "Created by " + eventCreatorString
            
            
            
            
            // Moved from repsonse table view cell
            
            var isUserGoing:Bool!
            var isUserNotGoing:Bool!
            if let _:String = eventData["goingPeople"]?.objectForKey((self.user?.objectId)!) as? String {
                isUserGoing = true
            } else {
                isUserGoing = false
            }
            
            if let _:String = eventData["notGoingPeople"]?.objectForKey((self.user?.objectId)!) as? String {
                isUserNotGoing = true
            } else {
                isUserNotGoing = false
            }
            
            cell.goingResponseButton.highlighted = isUserGoing
            cell.notGoingResponseButton.highlighted = isUserNotGoing
            cell.goingResponseButton.selected = isUserGoing
            cell.notGoingResponseButton.selected = isUserNotGoing
            
            cell.goingResponseButton.tintColor = UIColor(red:27.0/255.0, green: 69.0/255.0, blue: 191.0/255.0, alpha: 1.0)
            cell.notGoingResponseButton.tintColor = UIColor(red:27.0/255.0, green: 69.0/255.0, blue: 191.0/255.0, alpha: 1.0)
            
            // Customize appearance of cell
            cell.backgroundColor = UIColor(red: 256.0/256.0, green: 256.0/256.0, blue: 256.0/256.0, alpha: 0.1)//UIColor.whiteColor()
            //cell.alpha = 0.1
            cell.separatorInset = UIEdgeInsetsZero
            cell.preservesSuperviewLayoutMargins = false
            
            
            let eventCancelled:Bool = (self.eventObject?.objectForKey("dataSet")?.objectForKey("eventCancelled") as! Bool)
            
            let eventCreator:String = eventData["eventCreator"] as! String
            
            cell.cancelledLabel.hidden = !eventCancelled
            cell.goingResponseButton.hidden = eventCancelled
            cell.notGoingResponseButton.hidden = eventCancelled
            
            
            if (self.user?.objectId == eventCreator) {
                cell.blastButton.hidden = eventCancelled
                cell.blastButton.enabled = !eventCancelled
            } else {
                cell.blastButton.hidden = true
                cell.blastButton.enabled = false
            }
            
            

            
            return cell
        } else if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCellWithIdentifier("ResponseCell", forIndexPath: indexPath) as! ResponseTableViewCell
            
            cell.timeLabel.text = timeString
            cell.endTimeLabel.text = endTimeString
            cell.locationButton.setTitle(locationString, forState: UIControlState.Normal)
            cell.locationButton.tintColor = UIColor(red:27.0/255.0, green: 69.0/255.0, blue: 191.0/255.0, alpha: 1.0)
            
            cell.backgroundColor = UIColor(red: 256.0/256.0, green: 256.0/256.0, blue: 256.0/256.0, alpha: 0.1)
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
                if (Int(minutesFromNow) == 1) {
                    cell.time.text = String(stringInterpolationSegment: Int(minutesFromNow)) + " minute ago"
                } else {
                    cell.time.text = String(stringInterpolationSegment: Int(minutesFromNow)) + " minutes ago"
                }
            } else if (minutesFromNow >= 60.0) {
                if (Int(minutesFromNow/60.0) == 1) {
                    cell.time.text = String(stringInterpolationSegment: Int(minutesFromNow/60.0)) + " hour ago"
                } else {
                    cell.time.text = String(stringInterpolationSegment: Int(minutesFromNow/60.0)) + " hours ago"
                }
            } else if (minutesFromNow >= 1440.0) {
                if (Int(minutesFromNow/1440.0) == 1) {
                    cell.time.text = String(stringInterpolationSegment: Int(minutesFromNow/1440.0)) + " day ago"
                } else {
                    cell.time.text = String(stringInterpolationSegment: Int(minutesFromNow/1440.0)) + " days ago"
                }
            }
            
            
            
            // Customize appearance of cell
            //cell.backgroundColor = UIColor.whiteColor()
            //cell.alpha = 0.1
            
            cell.backgroundColor = UIColor(red: 256.0/256.0, green: 256.0/256.0, blue: 256.0/256.0, alpha: 0.1)
            cell.separatorInset = UIEdgeInsetsZero
            cell.preservesSuperviewLayoutMargins = false

            
            if (self.profilePicMap.objectForKey(commentObject["userId"]!) != nil) {
                
                let pic = self.profilePicMap.objectForKey(commentObject["userId"]!) as! UIImageView

                cell.profilePic.image = pic.image
                //cell.profilePic.frame = CGRect(x: 15, y: 30, width: 30, height: 30)
                cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2
                cell.profilePic.clipsToBounds = true
            }
            
            let border2 = CALayer()
            let width2 = CGFloat(2.0)
            border2.borderColor = UIColor(red: 235.0/256.0, green: 235.0/256.0, blue: 235.0/256.0, alpha: 1.0).CGColor
            border2.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: 1)
            
            border2.borderWidth = width2
            
            cell.layer.addSublayer(border2)

            
            return cell
        }

    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return 225
        } else if (indexPath.section == 1) {
            return 95
        } else {
            return UITableViewAutomaticDimension//100
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
        //let border = UIView(frame: CGRectMake(0,0,self.view.bounds.width,1))
        //border.backgroundColor = UIColor(red: 187.0/256.0, green: 187.0/256.0, blue: 187.0/256.0, alpha: 1.0)
        
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
        header.textLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 14)!
        header.textLabel!.textColor = UIColor(red: 107.0/256.0, green: 107.0/256.0, blue: 107.0/256.0, alpha: 1.0)
        //header.textLabel!.textColor = UIColor(red: 28.0/255.0, green: 50.0/255.0, blue: 115.0/255.0, alpha: 1.0)
        header.alpha = 1.0 //make the header transparent
        header.textLabel?.textAlignment = NSTextAlignment.Center
        //header.addSubview(border)
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
                goingPeopleView.friendToFacebookIds = eventData["friendToFacebookIDs"] as! NSMutableDictionary
            }
        } else if (segue.identifier == "notGoingSegue") {
            // Get Data
            if let notGoingPeople:NSMutableDictionary = eventData["notGoingPeople"] as? NSMutableDictionary {
                let notGoingPeopleView:NotGoingTableViewController = segue.destinationViewController as! NotGoingTableViewController
                notGoingPeopleView.notGoingPeople = notGoingPeople
                notGoingPeopleView.friendToFacebookIds = eventData["friendToFacebookIDs"] as! NSMutableDictionary
            }
        } else if (segue.identifier == "invitedPeopleSegue") {
            // Get Data
            if let invitedPeople:NSMutableDictionary = eventData["invitedPeople"] as? NSMutableDictionary {
                let invitedPeopleView:InvitedPeopleTableViewController = segue.destinationViewController as! InvitedPeopleTableViewController
                invitedPeopleView.invitedPeople = invitedPeople
                invitedPeopleView.friendToFacebookIds = eventData["friendToFacebookIDs"] as! NSMutableDictionary
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
    
    
    func keyboardWillShow(notification:NSNotification) {
        print("Show")
        self.keyboardShown = true
        adjustingHeight(true, notification: notification)
    }
    
    func keyboardWillHide(notification:NSNotification) {
        print("Hide")
        
        if (self.keyboardShown) {
            adjustingHeight(false, notification: notification)
        }
        self.keyboardShown = false
    }
    
    func adjustingHeight(show:Bool, notification:NSNotification) {
        // 1
        var userInfo = notification.userInfo!
        // 2
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        // 3
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        // 4
        let changeInHeight = (CGRectGetHeight(keyboardFrame)) * (show ? 1 : -1)
        //5
        UIView.animateWithDuration(animationDurarion, animations: { () -> Void in
            self.view.frame = CGRectOffset(self.view.frame, 0,  -1 * changeInHeight)
          
        })
        
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //textField.resignFirstResponder()
        //adjustingHeight(false, notification: notification)
        
        //self.navigationItem.leftBarButtonItem?.enabled = true
        return true
    }
    
    
    /**
     * Called when the user click on the view (outside the UITextField).
     */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        //self.view.endEditing(true)
        //self.navigationItem.leftBarButtonItem?.enabled = true
    }
    

    
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //let frame = (notification.userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        //animateViewMoving(true, moveValue: 225)
        //self.animateViewMoving(true, moveValue: keyboardFrame.CGRectValue().size.height)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        //print(self.view.frame.origin.y)
        if (!self.viewAppeared) {
            //animateViewMoving(false, moveValue: keyboardFrame.CGRectValue().size.height)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.39
        let movement:CGFloat = (up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }

}
