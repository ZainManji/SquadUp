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
import DGElasticPullToRefresh

class MasterTableViewController: UITableViewController {
    
    @IBOutlet var footerView: UIView!
    var friendsWithApp:NSMutableDictionary = NSMutableDictionary()
    var friendsWithoutApp:NSMutableDictionary = NSMutableDictionary()
    var indexApp:NSMutableDictionary = NSMutableDictionary()
    var indexWithoutApp:NSMutableDictionary = NSMutableDictionary()
    var appCount = 0
    var withoutAppCount = 0
    var events:NSMutableArray = NSMutableArray()
    
    var inProgressEvents:NSMutableArray = NSMutableArray()
    var todayEvents:NSMutableArray = NSMutableArray()
    var tomorrowEvents:NSMutableArray = NSMutableArray()
    var futureEvents:NSMutableArray = NSMutableArray()
    var numSections = 0
    
    var name = String()
    var user:PFUser?
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
    var newRefreshControl:UIRefreshControl!
    var tableViewFooter:UIView!
    
    var connectedToInternet:Bool?
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // Customize nav bar
        self.navigationController!.navigationBar.hidden = false
        self.navigationController!.navigationBarHidden = false
        self.navigationController!.navigationBar.translucent = false
        
        // Customize Settings Button
        let myBackButton:UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        myBackButton.setImage(UIImage(named: "settingswhitenew.png"), forState: UIControlState.Normal)
        myBackButton.addTarget(self, action: "goToSettings:", forControlEvents: UIControlEvents.TouchUpInside)
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        self.navigationController!.interactivePopGestureRecognizer!.enabled = false;
        
        // Get user
        self.user = PFUser.currentUser()
        
        self.connectedToInternet = Reachability.isConnectedToNetwork()
        
        // Check if user is connected to the internet.
        if (self.connectedToInternet == true) {
            
            // Fetch the events for the user.
            self.user?.fetchIfNeeded()

            self.actInd.startAnimating()
            
            if let userEvents:PFObject = self.user?["events"] as? PFObject {
                
                userEvents.fetchIfNeeded()
                let eventsDict:NSMutableDictionary = userEvents["events"] as! NSMutableDictionary
                let events:NSMutableArray = eventsDict[self.user!.objectId!] as! NSMutableArray
                
                // Keep reference to the event objects to the class
                self.events = events
                
                // Remove the events which have expired
                self.removeExpiredEvents()
                
                // Organize the events into their respective sections
                self.organizeEvents()
            }
            self.actInd.stopAnimating()
            
        }
        
        // Show the empty state view if the user has no events
        if (self.events.count == 0) {
            
            self.tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height))
            
            let label = UILabel(frame: CGRectMake(0, 0, self.tableView.frame.width, 50))
            label.center = CGPointMake(self.tableView.frame.width / 2, self.tableView.frame.height * 0.35)
            label.textAlignment = NSTextAlignment.Center
            
            // If user is not connected to internet, show no internet connection empty state, else normal
            // empty state
            if (self.connectedToInternet == false) {
                label.text = "No internet connection :("
                label.textColor = UIColor(red: 43.0/256.0, green: 69.0/256.0, blue: 86.0/256.0, alpha: 1.0)
                label.font = UIFont(name: "HelveticaNeue-Light", size: 26)
                
                self.tableViewFooter.addSubview(label)
            } else {
                label.text = "No upcoming events."
                label.textColor = UIColor(red: 43.0/256.0, green: 69.0/256.0, blue: 86.0/256.0, alpha: 1.0)
                label.font = UIFont(name: "HelveticaNeue-Light", size: 26)
                
                let secondLabel = UILabel(frame: CGRectMake(0, 0, self.tableView.frame.width - 40, 150))
                secondLabel.center = CGPointMake(self.tableView.frame.width / 2, (self.tableView.frame.height * 0.35) + 65)
                secondLabel.textAlignment = NSTextAlignment.Center
                secondLabel.text = "\nHow about a game night tonight, or maybe a coffee date tomorrow? \n\nTap the '+' button above to create a quick informal event!"
                secondLabel.textColor = UIColor(red: 94.0/256.0, green: 111.0/256.0, blue: 123.0/256.0, alpha: 1.0)
                secondLabel.numberOfLines = 0
                secondLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
                secondLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15)
                
                self.tableViewFooter.addSubview(label)
                self.tableViewFooter.addSubview(secondLabel)
            }
            self.tableView.tableHeaderView = self.tableViewFooter
        } else {
            self.tableView.tableHeaderView = nil
        }
        
        // Reload the tableview data
        self.tableView.reloadData()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title for view
        self.title = "Squad Up"
        
        // Set view background color
        self.view.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
        
        // Customize the table view footer view
        let border3 = CALayer()
        let width3 = CGFloat(2.0)
        border3.borderColor = UIColor(red: 235.0/256.0, green: 235.0/256.0, blue: 235.0/256.0, alpha: 1.0).CGColor
        border3.frame = CGRect(x: 0, y: 0, width: self.footerView.frame.size.width, height: 1)
        border3.borderWidth = width3
        self.footerView.layer.addSublayer(border3)
        self.footerView.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
        
        // Set color of table view separator colors
        self.tableView.separatorColor = UIColor(red: 235.0/256.0, green: 235.0/256.0, blue: 235.0/256.0, alpha: 1.0)

//        // Add a refresh to the page
//        self.newRefreshControl = UIRefreshControl()
//        self.newRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh events")
//        self.newRefreshControl.addTarget(self, action: "refreshPage:", forControlEvents: UIControlEvents.ValueChanged)
//        self.tableView.addSubview(newRefreshControl)
        
        // Customize nav bar.
        self.navigationController!.navigationBar.hidden = false
        self.navigationController!.navigationBarHidden = false
        self.navigationController!.navigationBar.translucent = false
        self.navigationController!.navigationBar.clipsToBounds = false

        // Customize activity indicator
        self.actInd.center = self.view.center
        self.actInd.hidesWhenStopped = true
        self.actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        //self.actInd.layer.zPosition = 1
        view.addSubview(self.actInd)

        // Check if there is an already cached version of the friend lists
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        if let appFriends = userDefaults.objectForKey("friendsWithApp") as? NSMutableDictionary {
            self.friendsWithApp = appFriends
            self.friendsWithoutApp = userDefaults.objectForKey("friendsWithoutApp") as! NSMutableDictionary
            self.indexApp = userDefaults.objectForKey("indexApp") as! NSMutableDictionary
            self.indexWithoutApp = userDefaults.objectForKey("indexWithoutApp") as! NSMutableDictionary
            
            userDefaults.setObject(true, forKey: "fetchedPeople")
            userDefaults.synchronize()
        } else {
            userDefaults.setObject(false, forKey: "fetchedPeople")
            userDefaults.synchronize()
        }
        
        // Initialize tableView
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
            // Do not forget to call dg_stopLoading() at the end
            //self?.coolRefreshPage()
            self!.actInd.startAnimating()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            self!.refreshEvents()
            if (self!.events.count == 0) {
                print(UIScreen.mainScreen().bounds.width)
                self!.tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self!.tableView.frame.width, height: self!.tableView.frame.height))
                self!.tableViewFooter.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
                
                let label = UILabel(frame: CGRectMake(0, 0, self!.tableView.frame.width, 50))
                label.center = CGPointMake(self!.tableView.frame.width / 2, self!.tableView.frame.height * 0.35)
                label.textAlignment = NSTextAlignment.Center
                
                // If user is not connected to internet, show no internet connection empty state, else
                // normal empty state
                if (self!.connectedToInternet == false) {
                    label.text = "No internet connection :("
                    label.textColor = UIColor(red: 43.0/256.0, green: 69.0/256.0, blue: 86.0/256.0, alpha: 1.0)
                    label.font = UIFont(name: "HelveticaNeue-Light", size: 26)
                    
                    self!.tableViewFooter.addSubview(label)
                } else {
                    label.text = "No upcoming events."
                    label.textColor = UIColor(red: 43.0/256.0, green: 69.0/256.0, blue: 86.0/256.0, alpha: 1.0)
                    label.font = UIFont(name: "HelveticaNeue-Light", size: 26)
                    
                    let secondLabel = UILabel(frame: CGRectMake(0, 0, self!.tableView.frame.width - 40, 150))
                    secondLabel.center = CGPointMake(self!.tableView.frame.width / 2, (self!.tableView.frame.height * 0.35) + 65)
                    secondLabel.textAlignment = NSTextAlignment.Center
                    secondLabel.text = "\nHow about a game night tonight, or maybe a coffee date tomorrow? \n\nTap the '+' button above to create a quick informal event!"
                    secondLabel.textColor = UIColor(red: 94.0/256.0, green: 111.0/256.0, blue: 123.0/256.0, alpha: 1.0)
                    secondLabel.numberOfLines = 0
                    secondLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
                    secondLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15)
                    
                    self!.tableViewFooter.addSubview(label)
                    self!.tableViewFooter.addSubview(secondLabel)
                }
                self!.tableView.tableHeaderView = self!.tableViewFooter
            } else {
                self!.tableView.tableHeaderView = nil
            }
            
            self!.tableView.reloadData()
            //self!.newRefreshControl.endRefreshing()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self!.actInd.stopAnimating()
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
    }
    
    
//    deinit {
//        tableView.dg_removePullToRefresh()
//    }
    
    func coolRefreshPage() {
        self.refreshEvents()
        if (self.events.count == 0) {
            print(UIScreen.mainScreen().bounds.width)
            self.tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height))
            self.tableViewFooter.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
            
            let label = UILabel(frame: CGRectMake(0, 0, self.tableView.frame.width, 50))
            label.center = CGPointMake(self.tableView.frame.width / 2, self.tableView.frame.height * 0.35)
            label.textAlignment = NSTextAlignment.Center
            
            // If user is not connected to internet, show no internet connection empty state, else
            // normal empty state
            if (self.connectedToInternet == false) {
                label.text = "No internet connection :("
                label.textColor = UIColor(red: 43.0/256.0, green: 69.0/256.0, blue: 86.0/256.0, alpha: 1.0)
                label.font = UIFont(name: "HelveticaNeue-Light", size: 26)
                
                self.tableViewFooter.addSubview(label)
            } else {
                label.text = "No upcoming events."
                label.textColor = UIColor(red: 43.0/256.0, green: 69.0/256.0, blue: 86.0/256.0, alpha: 1.0)
                label.font = UIFont(name: "HelveticaNeue-Light", size: 26)
                
                let secondLabel = UILabel(frame: CGRectMake(0, 0, self.tableView.frame.width - 40, 150))
                secondLabel.center = CGPointMake(self.tableView.frame.width / 2, (self.tableView.frame.height * 0.35) + 65)
                secondLabel.textAlignment = NSTextAlignment.Center
                secondLabel.text = "\nHow about a game night tonight, or maybe a coffee date tomorrow? \n\nTap the '+' button above to create a quick informal event!"
                secondLabel.textColor = UIColor(red: 94.0/256.0, green: 111.0/256.0, blue: 123.0/256.0, alpha: 1.0)
                secondLabel.numberOfLines = 0
                secondLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
                secondLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15)
                
                self.tableViewFooter.addSubview(label)
                self.tableViewFooter.addSubview(secondLabel)
            }
            self.tableView.tableHeaderView = self.tableViewFooter
        } else {
            self.tableView.tableHeaderView = nil
        }
        
        self.tableView.reloadData()
        self.newRefreshControl.endRefreshing()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    // Refresh the page
    func refreshPage() { //sender:AnyObject) {
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        
        dispatch_async(backgroundQueue, {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            self.refreshEvents()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (self.events.count == 0) {
                    self.tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height))
                    self.tableViewFooter.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
                    
                    let label = UILabel(frame: CGRectMake(0, 0, self.tableView.frame.width, 50))
                    label.center = CGPointMake(self.tableView.frame.width / 2, self.tableView.frame.height * 0.35)
                    label.textAlignment = NSTextAlignment.Center
                    
                    // If user is not connected to internet, show no internet connection empty state, else
                    // normal empty state
                    if (self.connectedToInternet == false) {
                        label.text = "No internet connection :("
                        label.textColor = UIColor(red: 43.0/256.0, green: 69.0/256.0, blue: 86.0/256.0, alpha: 1.0)
                        label.font = UIFont(name: "HelveticaNeue-Light", size: 26)
                        
                        self.tableViewFooter.addSubview(label)
                    } else {
                        label.text = "No upcoming events."
                        label.textColor = UIColor(red: 43.0/256.0, green: 69.0/256.0, blue: 86.0/256.0, alpha: 1.0)
                        label.font = UIFont(name: "HelveticaNeue-Light", size: 26)
                        
                        let secondLabel = UILabel(frame: CGRectMake(0, 0, self.tableView.frame.width - 40, 150))
                        secondLabel.center = CGPointMake(self.tableView.frame.width / 2, (self.tableView.frame.height * 0.35) + 65)
                        secondLabel.textAlignment = NSTextAlignment.Center
                        secondLabel.text = "\nHow about a game night tonight, or maybe a coffee date tomorrow? \n\nTap the '+' button above to create a quick informal event!"
                        secondLabel.textColor = UIColor(red: 94.0/256.0, green: 111.0/256.0, blue: 123.0/256.0, alpha: 1.0)
                        secondLabel.numberOfLines = 0
                        secondLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
                        secondLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15)
                        
                        self.tableViewFooter.addSubview(label)
                        self.tableViewFooter.addSubview(secondLabel)
                    }
                    self.tableView.tableHeaderView = self.tableViewFooter
                } else {
                    self.tableView.tableHeaderView = nil
                }
                
                self.tableView.reloadData()
                self.newRefreshControl.endRefreshing()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
        })
    }
    
    
    
    // Refresh the events
    func refreshEvents() {
        if let userEvents:PFObject = self.user?["events"] as? PFObject {
            userEvents.fetchIfNeeded()
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
        return 4
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return self.inProgressEvents.count
        } else if (section == 1) {
            return self.todayEvents.count
        } else if (section == 2) {
            return self.tomorrowEvents.count
        } else if (section == 3) {
            return self.futureEvents.count
        }
        return self.events.count
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        if (section == 0 && self.inProgressEvents.count > 0) {
            return "In Progress"
        } else if (section == 1 && self.todayEvents.count > 0) {
            return "Today"
        } else if (section == 2 && self.tomorrowEvents.count > 0) {
            return "Tomorrow"
        } else if (section == 3 && self.futureEvents.count > 0) {
            return "Future"
        }
        
        return ""
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EventsTableViewCell
        
        var eventObject:PFObject?
        
        self.actInd.stopAnimating()
        
        if (indexPath.section == 0) {
            eventObject = self.inProgressEvents.objectAtIndex(indexPath.row) as? PFObject
            cell.eventTime.textColor = UIColor(red: 30.0/256.0, green: 156.0/256.0, blue: 64.0/256.0, alpha: 1.0)
        } else if (indexPath.section == 1) {
            eventObject = self.todayEvents.objectAtIndex(indexPath.row) as? PFObject
        } else if (indexPath.section == 2) {
            eventObject = self.tomorrowEvents.objectAtIndex(indexPath.row) as? PFObject
        } else {
            eventObject = self.futureEvents.objectAtIndex(indexPath.row) as? PFObject
        }
        
        // Get respective event for row/cell.
        eventObject!.fetchIfNeeded()

        let eventItem:NSMutableDictionary = eventObject!["dataSet"] as! NSMutableDictionary
        let goingPeople:NSMutableDictionary = eventItem["goingPeople"] as! NSMutableDictionary
        let notGoingPeople:NSMutableDictionary = eventItem["notGoingPeople"] as! NSMutableDictionary
        
        // Generate the string which says how many people are going to the event.
        var numGoingMessage:String = ""
        if (goingPeople.count == 1) {
            numGoingMessage = String(goingPeople.count) + " person is going"
        } else {
            numGoingMessage = String(goingPeople.count) + " people are going"
        }
        
        // Identify whether the user is going or not going to the event.
        let userId:String = self.user!.objectId!
        if let _ = goingPeople[userId] as? String {
            cell.goingButton.selected = true
            cell.responseImage.image = UIImage(named: "happymonkey.png")
        } else {
            cell.goingButton.selected = false
        }
        
        if let _ = notGoingPeople[userId] as? String {
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
        if (indexPath.section == 0) {
            cell.eventTime!.text = "Now"
        } else {
            // Create the date format for the starting date and ending date
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE, MMM d @ h:mm a"
            dateFormatter.timeZone = NSTimeZone.localTimeZone()
            cell.eventTime!.text = dateFormatter.stringFromDate(eventItem["date"] as! NSDate)
            //cell.eventTime!.text = eventItem.objectForKey("eventTime") as? String ?? "[No Time]"
        }
        
        // Check if the event has been cancelled
        let cancelledEventBool: Bool = eventItem.objectForKey("eventCancelled") as! Bool
        
        if (cancelledEventBool) {
            cell.eventTime.textColor = UIColor.redColor()
        }

        cell.cancelledLabel!.hidden = !cancelledEventBool
        cell.responseImage.hidden = cancelledEventBool
        cell.goingButton.hidden = cancelledEventBool
        cell.goingButton.enabled = !cancelledEventBool
        cell.notGoingButton.hidden = cancelledEventBool
        cell.notGoingButton.enabled = !cancelledEventBool
        cell.numPeopleGoing!.text = numGoingMessage
        cell.goingButton.tintColor = UIColor(red:27.0/255.0, green: 69.0/255.0, blue: 191.0/255.0, alpha: 1.0)
        cell.notGoingButton.tintColor = UIColor(red:27.0/255.0, green: 69.0/255.0, blue: 191.0/255.0, alpha: 1.0)
        
        // Customize appearance of cell
        cell.backgroundColor = UIColor(red: 256.0/256.0, green: 256.0/256.0, blue: 256.0/256.0, alpha: 1.0)
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        
        // Add borders to cell
        let border2 = CALayer()
        let width2 = CGFloat(2.0)
        border2.borderColor = UIColor(red: 235.0/256.0, green: 235.0/256.0, blue: 235.0/256.0, alpha: 1.0).CGColor
        border2.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: 1)
        border2.borderWidth = width2
        
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
            print(eventItem)
            let endDate:NSDate = eventItem["endDate"] as! NSDate
            
            //var dateComparisionResult:NSComparisonResult = NSDate().compare(endDate)
            
            if endDate.timeIntervalSinceNow.isSignMinus {
                //myDate is earlier than Now (date and time)
                print("Removing event!:")
                print(endDate)
                print(eventItem["eventName"] as! String)
            } else {
                print("Not removing event")
                //myDate is equal or after than Now (date and time)
                newEventList.addObject(eventObject)
            }
            
        }
        
        self.events = newEventList
        
        // Get events for current user
        if let userEvents:PFObject = self.user?["events"] as? PFObject {
            userEvents.fetchIfNeeded()
            let eventsDict:NSMutableDictionary = userEvents["events"] as! NSMutableDictionary
            eventsDict[self.user!.objectId!] = self.events
            userEvents["events"] = eventsDict
            userEvents.save()
        }
    }
    
    
    // Organize the events into their respective sections
    func organizeEvents() {
        self.inProgressEvents = NSMutableArray()
        self.todayEvents = NSMutableArray()
        self.tomorrowEvents = NSMutableArray()
        self.futureEvents = NSMutableArray()
        
        for eventObject in self.events {
            eventObject.fetchIfNeeded()
            let eventItem:NSMutableDictionary = eventObject["dataSet"] as! NSMutableDictionary
            let startDate:NSDate = eventItem["date"] as! NSDate
            
            // Check if start date is Today, or Tomorrow, or in the Future and add to respective list
            let cal = NSCalendar.currentCalendar()

            if (cal.isDateInYesterday(startDate)){
                self.inProgressEvents.addObject(eventObject)
            } else if (cal.isDateInToday(startDate)) {
                if startDate.timeIntervalSinceNow.isSignMinus {
                    self.inProgressEvents.addObject(eventObject)
                } else if startDate.timeIntervalSinceNow.isZero {
                    self.inProgressEvents.addObject(eventObject)
                } else {
                    self.todayEvents.addObject(eventObject)
                }
            } else if (cal.isDateInTomorrow(startDate)) {
                self.tomorrowEvents.addObject(eventObject)
            } else {
                self.futureEvents.addObject(eventObject)
            }
        }
    }
    
    

    @IBAction func goingButtonAction(sender: UIButton) {
        let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)
        let indexSection = indexPath?.section

        if indexPath != nil {
            
            // Get respective event for row/cell.
            let eventObject:PFObject?
            if (indexSection == 0) {
                eventObject = self.inProgressEvents.objectAtIndex(indexPath!.row) as? PFObject
            } else if (indexSection == 1) {
                eventObject = self.todayEvents.objectAtIndex(indexPath!.row) as? PFObject
            } else if (indexSection == 2) {
                eventObject = self.tomorrowEvents.objectAtIndex(indexPath!.row) as? PFObject
            } else {
                eventObject = self.futureEvents.objectAtIndex(indexPath!.row) as? PFObject
            }
            
            //eventObject!.fetch()
            eventObject!.fetchIfNeeded()
            let eventItem:NSMutableDictionary = eventObject!["dataSet"] as! NSMutableDictionary
            let eventName:String = eventItem["eventName"] as! String
                    
            if let objectId:String = self.user!.objectId {
                let userName:String = self.user?["name"] as! String
                        
                if let _:NSMutableDictionary = eventItem["goingPeople"] as? NSMutableDictionary {
                    // Add user to going list
                    eventObject!.objectForKey("dataSet")?.objectForKey("goingPeople")?.setObject(userName, forKey: objectId)
                }
                
                if let notGoingPeople:NSMutableDictionary = eventItem["notGoingPeople"] as? NSMutableDictionary {
                    if let _:String = notGoingPeople[objectId] as? String {
                        // user in not going list, remove them
                        eventObject!.objectForKey("dataSet")?.objectForKey("notGoingPeople")?.removeObjectForKey(objectId)
                        if (objectId != eventObject!.objectForKey("dataSet")?.objectForKey("eventCreator") as! String) {
                            self.sendUserEventResponseNotification(true, eventObject: eventObject!, userName: userName, eventName: eventName)
                        }
                    }
                }
                
                if let invitedPeople:NSMutableDictionary = eventItem["invitedPeople"] as? NSMutableDictionary {
                    if let _:String = invitedPeople[objectId] as? String {
                        // user in invited list, remove them
                        eventObject!.objectForKey("dataSet")?.objectForKey("invitedPeople")?.removeObjectForKey(objectId)
                        self.sendUserEventResponseNotification(true, eventObject: eventObject!, userName: userName, eventName: eventName)
                    }
                }
            }
                    
            eventObject!.save()//InBackground()
            
            if (indexSection == 0) {
                self.inProgressEvents[indexPath!.row] = eventObject!
            } else if (indexSection == 1) {
                self.todayEvents[indexPath!.row] = eventObject!
            } else if (indexSection == 2) {
                self.tomorrowEvents[indexPath!.row] = eventObject!
            } else {
                self.futureEvents[indexPath!.row] = eventObject!
            }
            
            let events:NSMutableArray = NSMutableArray()
            for event in self.inProgressEvents {
                events.addObject(event)
            }
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
            let eventObject:PFObject?
            if (indexSection == 0) {
                eventObject = self.inProgressEvents.objectAtIndex(indexPath!.row) as? PFObject
            } else if (indexSection == 1) {
                eventObject = self.todayEvents.objectAtIndex(indexPath!.row) as? PFObject
            } else if (indexSection == 2) {
                eventObject = self.tomorrowEvents.objectAtIndex(indexPath!.row) as? PFObject
            } else {
                eventObject = self.futureEvents.objectAtIndex(indexPath!.row) as? PFObject
            }
            
            //eventObject!.fetch()
            eventObject!.fetchIfNeeded()
            let eventItem:NSMutableDictionary = eventObject!["dataSet"] as! NSMutableDictionary
            let eventName:String = eventItem["eventName"] as! String
            
            if let objectId:String = self.user!.objectId {
                let userName:String = self.user?["name"] as! String
                
                if let goingPeople:NSMutableDictionary = eventItem["goingPeople"] as? NSMutableDictionary {
                    if let _:String = goingPeople[objectId] as? String {
                        // user in not going list, remove them
                        eventObject!.objectForKey("dataSet")?.objectForKey("goingPeople")?.removeObjectForKey(objectId)
                        if (objectId != eventObject!.objectForKey("dataSet")?.objectForKey("eventCreator") as! String) {
                            self.sendUserEventResponseNotification(false, eventObject: eventObject!, userName: userName, eventName: eventName)
                        }
                        
                    }
                }
                
                if let _:NSMutableDictionary = eventItem["notGoingPeople"] as? NSMutableDictionary {
                    // Add user to not going list
                    eventObject!.objectForKey("dataSet")?.objectForKey("notGoingPeople")?.setObject(userName, forKey: objectId)
                }
                
                if let invitedPeople:NSMutableDictionary = eventItem["invitedPeople"] as? NSMutableDictionary {
                    if let _:String = invitedPeople[objectId] as? String {
                        // user in invited list, remove them
                        invitedPeople.removeObjectForKey(objectId)
                        self.sendUserEventResponseNotification(false, eventObject: eventObject!, userName: userName, eventName: eventName)
                    }
                }
            }

            eventObject!.save()//InBackground()
            
            if (indexSection == 0) {
                self.inProgressEvents[indexPath!.row] = eventObject!
            } else if (indexSection == 1) {
                self.todayEvents[indexPath!.row] = eventObject!
            } else if (indexSection == 2) {
                self.tomorrowEvents[indexPath!.row] = eventObject!
            } else {
                self.futureEvents[indexPath!.row] = eventObject!
            }
            
            let events:NSMutableArray = NSMutableArray()
            for event in self.inProgressEvents {
                events.addObject(event)
            }
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
        
        

        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView

        header.contentView.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
        header.textLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 14)!
        //header.textLabel!.textColor = UIColor(red: 28.0/255.0, green: 50.0/255.0, blue: 115.0/255.0, alpha: 1.0)
        header.textLabel!.textColor = UIColor(red: 107.0/256.0, green: 107.0/256.0, blue: 107.0/256.0, alpha: 1.0)
        header.alpha = 1.0
        header.textLabel?.textAlignment = NSTextAlignment.Center
        
//        if (section == 0) {
//            header.textLabel!.textColor = UIColor(red: 30.0/256.0, green: 156.0/256.0, blue: 64.0/256.0, alpha: 1.0)
//        }
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "showDetail") {
            let selectedIndexPath:NSIndexPath = self.tableView.indexPathForSelectedRow!
            let detailViewController:EventDetailsViewController = segue.destinationViewController as! EventDetailsViewController
            
            var eventObject:PFObject?
            if (selectedIndexPath.section == 0) {
                eventObject = self.inProgressEvents.objectAtIndex(selectedIndexPath.row) as? PFObject
            } else if (selectedIndexPath.section == 1) {
                eventObject = self.todayEvents.objectAtIndex(selectedIndexPath.row) as? PFObject
            } else if (selectedIndexPath.section == 2) {
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




    


