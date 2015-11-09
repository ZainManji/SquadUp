//
//  MasterTableViewController.swift
//  Squad Up
//
//  Created by Zain Manji on 8/17/15.
//  Copyright (c) 2015 Zeen Labs. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI

class MasterTableViewController: UITableViewController {
    
    @IBOutlet var footerView: UIView!
    var friendsWithApp:NSMutableDictionary = NSMutableDictionary()
    var friendsWithoutApp:NSMutableDictionary = NSMutableDictionary()
    var indexApp:NSMutableDictionary = NSMutableDictionary()
    var indexWithoutApp:NSMutableDictionary = NSMutableDictionary()
    var appCount = 0
    var withoutAppCount = 0
    var fetchedPeople:Bool = false
    var events:NSMutableArray = NSMutableArray()
    
    var todayEvents:NSMutableArray = NSMutableArray()
    var tomorrowEvents:NSMutableArray = NSMutableArray()
    var futureEvents:NSMutableArray = NSMutableArray()
    var numSections = 0
    
    var name = String()
    var user:PFUser?
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
    var newRefreshControl:UIRefreshControl!
    
    
    var tableViewFooter:UIView!
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        // Customize nav bar
        self.navigationController!.navigationBar.hidden = false
        self.navigationController!.navigationBarHidden = false
        self.navigationController!.navigationBar.translucent = false

        
        // Customize Settings Button
        let settingsImage = UIImage(named: "settingswhite.png") as UIImage!
        let myBackButton:UIButton = UIButton(type: UIButtonType.Custom)
        myBackButton.addTarget(self, action: "goToSettings:", forControlEvents: UIControlEvents.TouchUpInside)
        myBackButton.setImage(settingsImage, forState: UIControlState.Normal)
        myBackButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        myBackButton.sizeToFit()
        
        
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        self.navigationController!.interactivePopGestureRecognizer!.enabled = false;
        
        // Fetch the events for the user.
        if let userEvents:PFObject = self.user?["events"] as? PFObject {
            userEvents.fetch()
            let eventsDict:NSMutableDictionary = userEvents["events"] as! NSMutableDictionary
            let events:NSMutableArray = eventsDict[self.user!.objectId!] as! NSMutableArray
            self.events = events
            self.removeExpiredEvents()
            self.organizeEvents()
        }
        
        self.tableView.reloadData()
        
        if (self.events.count == 0) {
            
            
            self.tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height))
            self.tableViewFooter.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
            
            
            let label = UILabel(frame: CGRectMake(0, 0, self.tableView.frame.width, 50))
            label.center = CGPointMake(self.tableView.frame.width / 2, self.tableView.frame.height * 0.2)
            label.textAlignment = NSTextAlignment.Center
            label.text = "No events yet"
            label.font = UIFont(name: "Avenir", size: 26)
            
            self.tableViewFooter.addSubview(label)
            
            let secondLabel = UILabel(frame: CGRectMake(0, 0, self.tableView.frame.width, 50))
            secondLabel.center = CGPointMake(self.tableView.frame.width / 2, (self.tableView.frame.height * 0.2) + 40 )
            secondLabel.textAlignment = NSTextAlignment.Center
            secondLabel.text = "Tap the '+' button to create an event"
            secondLabel.font = UIFont(name: "Avenir", size: 18)
            
            self.tableViewFooter.addSubview(secondLabel)
        
            
            self.tableView.tableHeaderView = self.tableViewFooter
            //self.tableView.scrollEnabled = false
        } else {
            self.tableView.tableHeaderView = nil
            //self.tableView.scrollEnabled = true
        }
        
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.view.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
        
        
        let border3 = CALayer()
        let width3 = CGFloat(2.0)
        border3.borderColor = UIColor(red: 187.0/256.0, green: 187.0/256.0, blue: 187.0/256.0, alpha: 1.0).CGColor
        border3.frame = CGRect(x: 0, y: 0, width: self.footerView.frame.size.width, height: 1)
        
        border3.borderWidth = width3
        self.footerView.layer.addSublayer(border3)
        self.footerView.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        
        self.tableView.separatorColor = UIColor(red: 187.0/256.0, green: 187.0/256.0, blue: 187.0/256.0, alpha: 1.0)

        

        // Add a refresh to the page
        self.newRefreshControl = UIRefreshControl()
        self.newRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.newRefreshControl.addTarget(self, action: "refreshPage:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(newRefreshControl)
        
        // Customize nav bar.
        self.navigationController!.navigationBar.hidden = false
        self.navigationController!.navigationBarHidden = false
        self.navigationController!.navigationBar.translucent = false
        self.navigationController!.navigationBar.clipsToBounds = false

        
        
        self.actInd.center = self.view.center
        self.actInd.hidesWhenStopped = true
        self.actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(self.actInd)
        
        // Get user
        self.user = PFUser.currentUser()
        
        // Add user to the current installation object for push notifications
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation["userId"] = self.user?.objectId
        currentInstallation.saveInBackground()
        
        //let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        //let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        
        self.fetchedPeople = false
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()

        
        // Check if there is an already cached version of the friend lists
        if let appFriends = userDefaults.objectForKey("friendsWithApp") as? NSMutableDictionary {
            self.friendsWithApp = appFriends
            self.friendsWithoutApp = userDefaults.objectForKey("friendsWithoutApp") as! NSMutableDictionary
            self.indexApp = userDefaults.objectForKey("indexApp") as! NSMutableDictionary
            self.indexWithoutApp = userDefaults.objectForKey("indexWithoutApp") as! NSMutableDictionary
            
            self.fetchedPeople = true
            userDefaults.setObject(true, forKey: "fetchedPeople")
            userDefaults.synchronize()
        } else {
            self.fetchedPeople = false
            userDefaults.setObject(false, forKey: "fetchedPeople")
            userDefaults.synchronize()
        }
        
//        UINavigationBar.appearance().translucent = true
        //UINavigationBar.appearance().barTintColor = UIColor(red: 46.0/255.0, green: 14.0/255.0, blue: 74.0/255.0, alpha: 1.0)
        //UINavigationBar.appearance().tintColor = UIColor.whiteColor()
    }
    
    
    // Refresh the page
    func refreshPage(sender:AnyObject) {
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        
        dispatch_async(backgroundQueue, {
            print("This is run on the background queue")
            self.refreshEvents()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("This is run on the main queue, after the previous code in outer block")
                self.tableView.reloadData()
                self.newRefreshControl.endRefreshing()
            })
        })
    }
    
    // Refresh the events
    func refreshEvents() {
        if let userEvents:PFObject = self.user?["events"] as? PFObject {
            userEvents.fetch()
            let query = PFQuery(className: "UserEvents")
            
            if let userEventObject = query.getObjectWithId(userEvents.objectId!) {
                let eventsDict:NSMutableDictionary = userEventObject["events"] as! NSMutableDictionary
                let events:NSMutableArray = eventsDict[self.user!.objectId!] as! NSMutableArray
                self.events = events
                self.removeExpiredEvents()
                self.organizeEvents()
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 3 //self.numSections
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            return self.todayEvents.count
        } else if (section == 1) {
            return self.tomorrowEvents.count
        } else if (section == 2) {
            return self.futureEvents.count
        }
        
        return self.events.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        // do not display empty `Section`s
        if (section == 0 && self.todayEvents.count > 0) {
            return "Today"
        } else if (section == 1 && self.tomorrowEvents.count > 0) {
            return "Tomorrow"
        } else if (section == 2 && self.futureEvents.count > 0) {
            return "Future"
        }
        
        return ""
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EventsTableViewCell
        
        var eventObject:PFObject?
        if (indexPath.section == 0) {
            eventObject = self.todayEvents.objectAtIndex(indexPath.row) as? PFObject
        } else if (indexPath.section == 1) {
            eventObject = self.tomorrowEvents.objectAtIndex(indexPath.row) as? PFObject
        } else {
            eventObject = self.futureEvents.objectAtIndex(indexPath.row) as? PFObject
        }
        
        // Get respective event for row/cell.
        //var eventObject:PFObject = self.events.objectAtIndex(indexPath.row) as! PFObject
        eventObject!.fetchIfNeeded()

        let eventItem:NSMutableDictionary = eventObject!["dataSet"] as! NSMutableDictionary
        let goingPeople:NSMutableDictionary = eventItem["goingPeople"] as! NSMutableDictionary
        let notGoingPeople:NSMutableDictionary = eventItem["notGoingPeople"] as! NSMutableDictionary
        
        // Generate the string which says how many people are going to the event.
        var numGoingMessage:String = ""
        if (goingPeople.count == 1) {
            numGoingMessage = String(goingPeople.count) + " friend is going"
        } else {
            numGoingMessage = String(goingPeople.count) + " friends are going"
        }
        
        // Identify whether the user is going or not going to the event.
        let userId:String = self.user!.objectId!
        if let goingId = goingPeople[userId] as? String {
            cell.goingButton.selected = true
            cell.responseImage.image = UIImage(named: "happymonkey.png")
        } else {
            cell.goingButton.selected = false
        }
        
        if let notGoingId = notGoingPeople[userId] as? String {
            cell.notGoingButton.selected = true
            cell.responseImage.image = UIImage(named: "pensive emoji.png")
        } else {
            cell.notGoingButton.selected = false
        }
        
        if (cell.notGoingButton.selected == false && cell.goingButton.selected == false) {
            cell.responseImage.image = UIImage(named: "point.png")
        }
        
        
        // Configure the cell.
        cell.eventName!.text = eventItem.objectForKey("eventName") as? String ?? "[No Title]"
        cell.eventTime!.text = eventItem.objectForKey("eventTime") as? String ?? "[No Time]"
        cell.numPeopleGoing!.text = numGoingMessage

        let cancelledEventBool: Bool = eventItem.objectForKey("eventCancelled") as! Bool

        cell.cancelledLabel!.hidden = !cancelledEventBool
        
        cell.responseImage.hidden = cancelledEventBool
        cell.goingButton.hidden = cancelledEventBool
        cell.goingButton.enabled = !cancelledEventBool
        cell.notGoingButton.hidden = cancelledEventBool
        cell.notGoingButton.enabled = !cancelledEventBool
        
        // Customize appearance of cell
        cell.backgroundColor = UIColor.whiteColor()
        cell.alpha = 0.1
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        
        cell.goingButton.layer.cornerRadius = 5
        cell.goingButton.layer.borderWidth = 1
        cell.goingButton.layer.borderColor = UIColor.grayColor().CGColor
        
        cell.notGoingButton.layer.cornerRadius = 5
        cell.notGoingButton.layer.borderWidth = 1
        cell.notGoingButton.layer.borderColor = UIColor.grayColor().CGColor
        
        // testing borders
//        let border = CALayer()
//        let width = CGFloat(2.0)
//        border.borderColor = UIColor(red: 187.0/256.0, green: 187.0/256.0, blue: 187.0/256.0, alpha: 1.0).CGColor
//        border.frame = CGRect(x: 0, y: cell.frame.size.height - width, width:  cell.frame.size.width, height: cell.frame.size.height)
//        
//        border.borderWidth = width
        
        let border2 = CALayer()
        let width2 = CGFloat(2.0)
        border2.borderColor = UIColor(red: 187.0/256.0, green: 187.0/256.0, blue: 187.0/256.0, alpha: 1.0).CGColor
        border2.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: 1)
        
        border2.borderWidth = width2
        
        //cell.layer.addSublayer(border)
        cell.layer.addSublayer(border2)

        return cell
    }
    
    // Navigate to the settings page.
    func goToSettings(sender:UIBarButtonItem){
        self.performSegueWithIdentifier("settingsSegue", sender: self)
    }
    
    
    
    // Remove the events which have already ended.
    func removeExpiredEvents() {
        let newEventList:NSMutableArray = NSMutableArray()

        for eventObject in self.events {
            eventObject.fetchIfNeeded()
            let eventItem:NSMutableDictionary = eventObject["dataSet"] as! NSMutableDictionary
            let endDate:NSDate = eventItem["endDate"] as! NSDate
            
            if endDate.timeIntervalSinceNow.isSignMinus {
                //myDate is earlier than Now (date and time)
            } else {
                //myDate is equal or after than Now (date and time)
                newEventList.addObject(eventObject)
            }
        }
        
        self.events = newEventList
        
        // Get events for current user
        if let userEvents:PFObject = self.user?["events"] as? PFObject {
            userEvents.fetch()
            let eventsDict:NSMutableDictionary = userEvents["events"] as! NSMutableDictionary
            eventsDict[self.user!.objectId!] = self.events
            userEvents["events"] = eventsDict
            userEvents.save()
        }
    }
    
    
    
    func organizeEvents() {
        self.todayEvents = NSMutableArray()
        self.tomorrowEvents = NSMutableArray()
        self.futureEvents = NSMutableArray()
        self.numSections = 0
        
        for eventObject in self.events {
            eventObject.fetchIfNeeded()
            let eventItem:NSMutableDictionary = eventObject["dataSet"] as! NSMutableDictionary
            let startDate:NSDate = eventItem["date"] as! NSDate
            
            // Check if start date is Today, or Tomorrow, or in the Future and add to respective list
            let cal = NSCalendar.currentCalendar()

            if (cal.isDateInToday(startDate)) {
                self.todayEvents.addObject(eventObject)
            } else if (cal.isDateInTomorrow(startDate)) {
                self.tomorrowEvents.addObject(eventObject)
            } else {
                self.futureEvents.addObject(eventObject)
            }
        }
        
        if (self.todayEvents.count > 0) {
            self.numSections++
        }
        
        if (self.tomorrowEvents.count > 0) {
            self.numSections++
        }
        
        if (self.futureEvents.count > 0) {
            self.numSections++
        }
        
//        print("ORGANIZED")
//        print(self.todayEvents)
//        print(self.tomorrowEvents)
//        print(self.futureEvents)
    }
    
    

    @IBAction func goingButtonAction(sender: UIButton) {
        let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)
        let indexSection = indexPath?.section

        
        if indexPath != nil {
            
            // Get respective event for row/cell.
            //let eventObject:PFObject = self.events.objectAtIndex(indexPath!.row) as! PFObject
            let eventObject:PFObject?
            if (indexSection == 0) {
                eventObject = self.todayEvents.objectAtIndex(indexPath!.row) as? PFObject
            } else if (indexSection == 1) {
                eventObject = self.tomorrowEvents.objectAtIndex(indexPath!.row) as? PFObject
            } else {
                eventObject = self.futureEvents.objectAtIndex(indexPath!.row) as? PFObject
            }
            
            eventObject!.fetch()
            eventObject!.fetchIfNeeded()
            let eventItem:NSMutableDictionary = eventObject!["dataSet"] as! NSMutableDictionary
            let eventName:String = eventItem["eventName"] as! String
                    
            if let objectId:String = self.user!.objectId {
                let userName:String = self.user?["name"] as! String
                        
                if let goingPeople:NSMutableDictionary = eventItem["goingPeople"] as? NSMutableDictionary {
                    // Add user to going list
                    eventObject!.objectForKey("dataSet")?.objectForKey("goingPeople")?.setObject(userName, forKey: objectId)
                }
                
                if let notGoingPeople:NSMutableDictionary = eventItem["notGoingPeople"] as? NSMutableDictionary {
                    if let member:String = notGoingPeople[objectId] as? String {
                        // user in not going list, remove them
                        eventObject!.objectForKey("dataSet")?.objectForKey("notGoingPeople")?.removeObjectForKey(objectId)
                        if (objectId != eventObject!.objectForKey("dataSet")?.objectForKey("eventCreator") as! String) {
                            self.sendUserEventResponseNotification(true, eventObject: eventObject!, userName: userName, eventName: eventName)
                        }
                    }
                            
                }
                
                if let invitedPeople:NSMutableDictionary = eventItem["invitedPeople"] as? NSMutableDictionary {
                    if let member:String = invitedPeople[objectId] as? String {
                        // user in invited list, remove them
                        eventObject!.objectForKey("dataSet")?.objectForKey("invitedPeople")?.removeObjectForKey(objectId)
                        self.sendUserEventResponseNotification(true, eventObject: eventObject!, userName: userName, eventName: eventName)
                    }
                }
            }
                    
            eventObject!.saveInBackground()
            
            if (indexSection == 0) {
                self.todayEvents[indexPath!.row] = eventObject!
            } else if (indexSection == 1) {
                self.tomorrowEvents[indexPath!.row] = eventObject!
            } else {
                self.futureEvents[indexPath!.row] = eventObject!
            }
            
            let events:NSMutableArray = NSMutableArray()
            for event in self.todayEvents {
                events.addObject(event)
            }
            for event in self.tomorrowEvents {
                events.addObject(event)
            }
            for event in self.futureEvents {
                events.addObject(event)
            }
            self.events = events
            
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func notGoingButtonAction(sender: UIButton) {
        let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)
        let indexSection = indexPath?.section
        
        if indexPath != nil {
            
            // Get respective event for row/cell.
            //let eventObject:PFObject = self.events.objectAtIndex(indexPath!.row) as! PFObject
            let eventObject:PFObject?
            if (indexSection == 0) {
                eventObject = self.todayEvents.objectAtIndex(indexPath!.row) as? PFObject
            } else if (indexSection == 1) {
                eventObject = self.tomorrowEvents.objectAtIndex(indexPath!.row) as? PFObject
            } else {
                eventObject = self.futureEvents.objectAtIndex(indexPath!.row) as? PFObject
            }
            
            
            
            
            eventObject!.fetch()
            eventObject!.fetchIfNeeded()
            let eventItem:NSMutableDictionary = eventObject!["dataSet"] as! NSMutableDictionary
            let eventName:String = eventItem["eventName"] as! String
            
            if let objectId:String = self.user!.objectId {
                let userName:String = self.user?["name"] as! String
                
                if let goingPeople:NSMutableDictionary = eventItem["goingPeople"] as? NSMutableDictionary {
                    if let member:String = goingPeople[objectId] as? String {
                        // user in not going list, remove them
                        eventObject!.objectForKey("dataSet")?.objectForKey("goingPeople")?.removeObjectForKey(objectId)
                        if (objectId != eventObject!.objectForKey("dataSet")?.objectForKey("eventCreator") as! String) {
                            self.sendUserEventResponseNotification(false, eventObject: eventObject!, userName: userName, eventName: eventName)
                        }
                        
                    }
                }
                
                if let notGoingPeople:NSMutableDictionary = eventItem["notGoingPeople"] as? NSMutableDictionary {
                    // Add user to not going list
                    eventObject!.objectForKey("dataSet")?.objectForKey("notGoingPeople")?.setObject(userName, forKey: objectId)
                }
                
                if let invitedPeople:NSMutableDictionary = eventItem["invitedPeople"] as? NSMutableDictionary {
                    if let member:String = invitedPeople[objectId] as? String {
                        // user in invited list, remove them
                        invitedPeople.removeObjectForKey(objectId)
                        self.sendUserEventResponseNotification(false, eventObject: eventObject!, userName: userName, eventName: eventName)
                    }
                }
            }

            eventObject!.saveInBackground()
            
            if (indexSection == 0) {
                self.todayEvents[indexPath!.row] = eventObject!
            } else if (indexSection == 1) {
                self.tomorrowEvents[indexPath!.row] = eventObject!
            } else {
                self.futureEvents[indexPath!.row] = eventObject!
            }
            
            let events:NSMutableArray = NSMutableArray()
            for event in self.todayEvents {
                events.addObject(event)
            }
            for event in self.tomorrowEvents {
                events.addObject(event)
            }
            for event in self.futureEvents {
                events.addObject(event)
            }
            self.events = events
            
            //self.events[indexPath!.row] = eventObject!
            self.tableView.reloadData()
        }
    }
    
    
    
    @IBAction func removeEvent(sender: UIButton) {
        return // NOT PRIORITY RIGHT NOW
        let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)
        let indexSection = indexPath?.section
        
        if indexPath != nil {

            let eventObject:PFObject?
            if (indexSection == 0) {
                eventObject = self.todayEvents.objectAtIndex(indexPath!.row) as? PFObject
                self.todayEvents.removeObjectAtIndex(indexPath!.row)
            } else if (indexSection == 1) {
                eventObject = self.tomorrowEvents.objectAtIndex(indexPath!.row) as? PFObject
                self.tomorrowEvents.removeObjectAtIndex(indexPath!.row)
            } else {
                eventObject = self.futureEvents.objectAtIndex(indexPath!.row) as? PFObject
                self.futureEvents.removeObjectAtIndex(indexPath!.row)
            }
            
            eventObject!.fetch()
            eventObject!.fetchIfNeeded()
            
            
            
            let newEventList:NSMutableArray = NSMutableArray()
            
            for event in self.events {
                event.fetchIfNeeded()

                if (event.objectId == eventObject?.objectId) {
                    //want to remove this one
                } else {
                    //myDate is equal or after than Now (date and time)
                    newEventList.addObject(event)
                }
            }
            
            self.events = newEventList
            
            // Get events for current user
            if let userEvents:PFObject = self.user?["events"] as? PFObject {
                userEvents.fetch()
                let eventsDict:NSMutableDictionary = userEvents["events"] as! NSMutableDictionary
                eventsDict[self.user!.objectId!] = self.events
                userEvents["events"] = eventsDict
                userEvents.save()
            }
            
            let events:NSMutableArray = NSMutableArray()
            for event in self.todayEvents {
                events.addObject(event)
            }
            for event in self.tomorrowEvents {
                events.addObject(event)
            }
            for event in self.futureEvents {
                events.addObject(event)
            }
            self.events = events
            

            self.tableView.reloadData()
        }

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
    

    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let border = UIView(frame: CGRectMake(0,0,self.view.bounds.width,1))
        border.backgroundColor = UIColor(red: 187.0/256.0, green: 187.0/256.0, blue: 187.0/256.0, alpha: 1.0)
        


        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
        header.textLabel!.font = UIFont(name: "Avenir", size: 14)!
        header.textLabel!.textColor = UIColor(red: 107.0/256.0, green: 107.0/256.0, blue: 107.0/256.0, alpha: 1.0)
        header.alpha = 1.0 //make the header transparent
        header.addSubview(border)

    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "showDetail") {
            let selectedIndexPath:NSIndexPath = self.tableView.indexPathForSelectedRow!
            let detailViewController:EventDetailsViewController = segue.destinationViewController as! EventDetailsViewController
            
            var eventObject:PFObject?
            if (selectedIndexPath.section == 0) {
                eventObject = self.todayEvents.objectAtIndex(selectedIndexPath.row) as? PFObject
            } else if (selectedIndexPath.section == 1) {
                eventObject = self.tomorrowEvents.objectAtIndex(selectedIndexPath.row) as? PFObject
            } else {
                eventObject = self.futureEvents.objectAtIndex(selectedIndexPath.row) as? PFObject
            }
            
          
            // Get respective event for row/cell.
            eventObject!.fetchIfNeeded()
            let eventItem:NSMutableDictionary = eventObject!["dataSet"] as! NSMutableDictionary
                    
            detailViewController.eventData = eventItem
            detailViewController.eventObject = eventObject
        } 
        
    }
    
    
    
    
}




    


