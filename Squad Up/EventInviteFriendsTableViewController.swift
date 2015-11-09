//
//  EventInviteFriendsTableViewController.swift
//  Squad Up
//
//  Created by Zain Manji on 8/19/15.
//  Copyright (c) 2015 Zeen Labs. All rights reserved.
//

import UIKit
import EventKit
import MessageUI
import Contacts

class EventInviteFriendsTableViewController: UITableViewController,  MFMessageComposeViewControllerDelegate, UISearchBarDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet var searchBar: UISearchBar!
    
    let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
    
    var dataSet:NSMutableDictionary = NSMutableDictionary()
    var invitedPeople:NSMutableDictionary = NSMutableDictionary()
    var invitedPeopleWithApp:NSMutableDictionary = NSMutableDictionary()
    var invitedPeopleWithoutApp:NSMutableDictionary = NSMutableDictionary()
    var goingPeople:NSMutableDictionary = NSMutableDictionary()
    var notGoingPeople:NSMutableDictionary = NSMutableDictionary()
    
    var friendToFacebookID:NSMutableDictionary = NSMutableDictionary()
    var friendsWithApp:NSMutableDictionary = NSMutableDictionary()
    var indexApp:NSMutableDictionary = NSMutableDictionary()
    var friendsWithoutApp:NSMutableDictionary = NSMutableDictionary()
    var indexWithoutApp:NSMutableDictionary = NSMutableDictionary()
    
    var appCount = 0
    var withoutAppCount = 0
    
    var filteredFriendsWithApp = [Friend]()
    var filteredFriendsWithoutApp = [Friend]()
    var friendsWithAppArray = [Friend]()
    var friendsWithoutAppArray = [Friend]()
    
    var friendObjectsAppIndex:NSMutableDictionary = NSMutableDictionary()
    var friendObjectsWithoutAppIndex:NSMutableDictionary = NSMutableDictionary()
    
    var searchActive : Bool = false
    
    let eventStore = EKEventStore()
    var squadUpReminderCalendar: EKCalendar?
    
    var user:PFUser?
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
    var newRefreshControl:UIRefreshControl!
    var viewLoaded: Bool = false
    
    var tableViewFooter:UIView!
    var footerCollectionView: UICollectionView!
    
    var profilePicDict:NSMutableDictionary = NSMutableDictionary()
    
    
    
    
    // Variables populated from a controller when editing an event
    var editingEvent:Bool!
    var editingEventObject:PFObject!
    
    // Variables to be populated when editing an event
    var prevEventDataSet:NSMutableDictionary!
    var prevInvitedPeople:NSMutableDictionary!
    var prevGoingPeople:NSMutableDictionary!
    var prevNotGoingPeople:NSMutableDictionary!
    var prevInvitedPeopleWithApp:NSMutableDictionary!
    var prevInvitedPeopleWithoutApp:NSMutableDictionary!
    
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        

        
        // Customize back button
        let myBackButton:UIButton = UIButton(type: UIButtonType.Custom)
        myBackButton.addTarget(self, action: "popDisplay:", forControlEvents: UIControlEvents.TouchUpInside)
        myBackButton.setTitle("Back", forState: UIControlState.Normal)
        myBackButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myBackButton.sizeToFit()
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        
        
        self.tableView.reloadData()
        self.footerCollectionView.reloadData()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.tableViewFooter.frame = CGRect(x: 0, y: self.tableView.frame.height - 45.0 + self.tableView.contentOffset.y, width: self.tableView.frame.width, height: 45)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self

        self.newRefreshControl = UIRefreshControl()
        self.newRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.newRefreshControl.addTarget(self, action: "refreshPage:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(newRefreshControl)
        
        self.verifyUserEventAuthorization()
        
        

        // Footer
        
        // Create top border for comment button section
        let upperBorder:CALayer = CALayer();
        upperBorder.backgroundColor = UIColor.redColor().CGColor;
        upperBorder.frame = CGRectMake(0, 0, self.tableView.frame.width, 1.0);
        
        
//        let inviteButton = UIButton(type: UIButtonType.System) as UIButton
//        inviteButton.frame = CGRectMake(self.tableView.frame.width - 50, 0, 50, 50)
//        inviteButton.backgroundColor = UIColor.whiteColor()
//        inviteButton.setTitle("Invite", forState: UIControlState.Normal)
//        inviteButton.titleLabel!.font = UIFont(name: "Avenir", size: 17)
//        inviteButton.addTarget(self, action: "sendInvitesAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 25, height: 25)
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        self.footerCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 45), collectionViewLayout: layout)
        self.footerCollectionView.dataSource = self
        self.footerCollectionView.delegate = self
        self.footerCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.footerCollectionView.backgroundColor = UIColor.whiteColor()
        
        
        self.tableViewFooter = UIView(frame: CGRect(x: 0, y: self.tableView.frame.height - 45.0, width: self.tableView.frame.width, height: 45))        
        
        //self.tableViewFooter.addSubview(inviteButton)
        self.tableViewFooter.addSubview(self.footerCollectionView)
        self.tableViewFooter.layer.addSublayer(upperBorder)
        self.tableView.addSubview(self.tableViewFooter)
        
        

        
        // Customize back button
        let myBackButton:UIButton = UIButton(type: UIButtonType.Custom)
        myBackButton.addTarget(self, action: "popDisplay:", forControlEvents: UIControlEvents.TouchUpInside)
        myBackButton.setTitle("Back", forState: UIControlState.Normal)
        myBackButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myBackButton.sizeToFit()
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        
        self.actInd.center = self.view.center
        self.actInd.hidesWhenStopped = true
        self.actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(self.actInd)
        
        self.tableView.allowsMultipleSelection = false
        self.clearsSelectionOnViewWillAppear = false;
        
        // Get User
        self.user = PFUser.currentUser()
        
        // Add user to going list.
        let userName:String = self.user?["name"] as! String
        self.goingPeople.setObject(userName, forKey: self.user!.objectId!)
        
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()

        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        var fetchedPeople:Bool = userDefaults.objectForKey("fetchedPeople") as! Bool
        let loggedOutBool:Bool = userDefaults.objectForKey("loggedOut") as! Bool
        self.tableView.userInteractionEnabled = false
        
        dispatch_async(backgroundQueue, {
            print("This is run on the background queue")
            
            if (!fetchedPeople || loggedOutBool) {
                print("Getting user objects for contacts since it's the first time accessing this page ever.")
                self.actInd.startAnimating()
                self.getUserObjectsForContacts()
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("This is run on the main queue, after the previous code in outer block")
                
                self.actInd.stopAnimating()
                fetchedPeople = true
                userDefaults.setObject(true, forKey: "fetchedPeople")
                userDefaults.setObject(false, forKey: "loggedOut")
                userDefaults.synchronize()
                
                self.resetFilteredFriendsArray()
                self.tableView.userInteractionEnabled = true
                //self.viewLoaded = true
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()

            })
        })
        
        
        // 
        if (self.editingEvent == nil) {
            self.editingEvent = false
        }
        if (self.editingEvent == true) {
            self.prevEventDataSet = self.editingEventObject["dataSet"] as! NSMutableDictionary
            self.prevInvitedPeople = self.prevEventDataSet["invitedPeople"] as! NSMutableDictionary
            self.prevGoingPeople = self.prevEventDataSet["goingPeople"] as! NSMutableDictionary
            self.prevNotGoingPeople = self.prevEventDataSet["notGoingPeople"] as! NSMutableDictionary
            self.prevInvitedPeopleWithApp = self.prevEventDataSet["invitedPeopleWithApp"] as! NSMutableDictionary
            self.prevInvitedPeopleWithoutApp = self.prevEventDataSet["invitedPeopleWithoutApp"] as! NSMutableDictionary
            
            self.invitedPeople = self.prevInvitedPeople.mutableCopy() as! NSMutableDictionary
            self.goingPeople = self.prevGoingPeople.mutableCopy() as! NSMutableDictionary
            self.notGoingPeople = self.prevNotGoingPeople.mutableCopy() as! NSMutableDictionary
            self.invitedPeopleWithApp = self.prevInvitedPeople.mutableCopy() as! NSMutableDictionary
            self.invitedPeopleWithoutApp = self.prevInvitedPeopleWithoutApp.mutableCopy() as! NSMutableDictionary
        } else {
            self.prevEventDataSet = NSMutableDictionary()
            self.prevInvitedPeople = NSMutableDictionary()
            self.prevGoingPeople = NSMutableDictionary()
            self.prevNotGoingPeople = NSMutableDictionary()
            self.prevInvitedPeopleWithApp = NSMutableDictionary()
            self.prevInvitedPeopleWithoutApp = NSMutableDictionary()
        }
        
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.invitedPeople.allKeys.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        
        var index = -1
        let friendId:String = self.invitedPeople.allKeys[indexPath.item] as! String
        print(invitedPeople)
        
        if (self.friendObjectsAppIndex.objectForKey(friendId) != nil) {
            print(friendId)
            index = self.friendObjectsAppIndex.objectForKey(friendId) as! Int
            cell.backgroundView = UIView()
            let temp:UIImageView = UIImageView(image: self.friendsWithAppArray[index].profilePicView.image)
            temp.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            temp.layer.cornerRadius = temp.frame.size.width / 2
            temp.clipsToBounds = true
            cell.backgroundView!.addSubview(temp)
        } else if (self.friendObjectsWithoutAppIndex.objectForKey(friendId) != nil) {
            index = self.friendObjectsWithoutAppIndex.objectForKey(friendId) as! Int
            cell.backgroundView = UIView()
            let temp:UIImageView = UIImageView(image: self.friendsWithoutAppArray[index].profilePicView.image)
            temp.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            temp.layer.cornerRadius = temp.frame.size.width / 2
            temp.clipsToBounds = true
            cell.backgroundView!.addSubview(temp)
        }
        
        
    
        return cell
    }
    
    
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {

        self.tableViewFooter.frame = CGRect(x: 0, y: self.tableView.frame.height - 45.0 + self.tableView.contentOffset.y, width: self.tableView.frame.width, height: 45)
    }

    
    
    func resetFilteredFriendsArray() {
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.grayColor()
        self.viewLoaded = false
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        // Get the friends who have the app
        let appFriends = userDefaults.objectForKey("friendsWithApp") as? NSMutableDictionary
        if (appFriends == nil) {
            self.friendsWithApp = NSMutableDictionary()
        } else {
            self.friendsWithApp = appFriends!.mutableCopy() as! NSMutableDictionary
        }
        
        let facebookIDs = userDefaults.objectForKey("friendToFacebookID") as? NSMutableDictionary
        if (facebookIDs == nil) {
            self.friendToFacebookID = NSMutableDictionary()
        } else {
            self.friendToFacebookID = facebookIDs!.mutableCopy() as! NSMutableDictionary
        }
        
        
        // Get the friends who don't have the app
        let noAppFriends = userDefaults.objectForKey("friendsWithoutApp") as? NSMutableDictionary
        if (noAppFriends == nil) {
            self.friendsWithoutApp = NSMutableDictionary()
        } else {
            self.friendsWithoutApp = noAppFriends!.mutableCopy() as! NSMutableDictionary
        }
        
        // Get the index for people who have the app
        let appIndex = userDefaults.objectForKey("indexApp") as? NSMutableDictionary
        if (appIndex == nil) {
            self.indexApp = NSMutableDictionary()
        } else {
            self.indexApp = appIndex!.mutableCopy() as! NSMutableDictionary
        }
        
        // Get the index for people who don't have the app
        let noAppIndex = userDefaults.objectForKey("indexWithoutApp") as? NSMutableDictionary
        if (noAppIndex == nil) {
            self.indexWithoutApp = NSMutableDictionary()
        } else {
            self.indexWithoutApp = noAppIndex!.mutableCopy() as! NSMutableDictionary
        }
        
        var friendsNoApp = [Friend]()
        var friendsApp = [Friend]()
        
        var count = 0
        for (id, value) in self.friendsWithApp {
            
            var profilePicView:UIImageView!
            
            if let fbid = self.friendToFacebookID.objectForKey(id as! String) as? String {
                let profilePic:UIImage = self.getProfPic(fbid)!
                profilePicView = UIImageView(image: profilePic)
                profilePicView.frame = CGRect(x: 15, y: 15, width: 40, height: 40)
                profilePicView.layer.cornerRadius = profilePicView.frame.size.width / 2
                profilePicView.clipsToBounds = true
            } else {
                profilePicView = self.getProfPicForName(value as! String)
            }

            
            self.friendObjectsAppIndex.setObject(count, forKey: id as! String)
            friendsApp.append(Friend(name: value as! String, objectId: id as! String, invited: false, index: count, profilePicView: profilePicView)) // Add the friends profilePicImageView here
            count++
        }
        
        count = 0
        for (id, value) in self.friendsWithoutApp {
            
            let username:String = value as! String
            let profilePicView:UIImageView = self.getProfPicForName(username)
            
            self.friendObjectsWithoutAppIndex.setObject(count, forKey: id as! String)
            friendsNoApp.append(Friend(name: value as! String, objectId: id as! String, invited: false, index: count, profilePicView: profilePicView)) // Add the friends profilePicImageView here
            count++
        }
        
        self.friendsWithAppArray = friendsApp
        self.friendsWithoutAppArray = friendsNoApp
        
        self.filteredFriendsWithApp = self.friendsWithAppArray
        self.filteredFriendsWithoutApp = self.friendsWithoutAppArray
        self.viewLoaded = true
        
        self.tableView.reloadData()
        self.footerCollectionView.reloadData()
        
    }
    

    func DismissKeyboard(){
        view.endEditing(true)
    }
    
    
    func getProfPicForName(username: String) -> UIImageView {
        let contactPic:UIImage = UIImage(named: "greybox.png")!
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
        let newImage:UIImage = textToImage(initials, inImage: contactPic, atPoint: CGPointMake(35, 45))
        let profilePicView:UIImageView = UIImageView(image: newImage)
        profilePicView.frame = CGRect(x: 15, y: 15, width: 40, height: 40)
        profilePicView.layer.cornerRadius = profilePicView.frame.size.width / 2
        profilePicView.clipsToBounds = true
        return profilePicView
    }
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        self.DismissKeyboard()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        self.DismissKeyboard()
        self.tableView.reloadData()
        self.footerCollectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    
    // Search for friends which match the given text.
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewLoaded = false
        // Search for friends with app who match the given text
        self.filteredFriendsWithApp = self.friendsWithAppArray.filter({ (friend: Friend) -> Bool in
            let stringMatch = friend.name.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return stringMatch != nil
        })
        
        // Search for friends without app who match the given text
        self.filteredFriendsWithoutApp = self.friendsWithoutAppArray.filter({ (friend2: Friend) -> Bool in
            let stringMatch = friend2.name.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return stringMatch != nil
        })
        
        if(self.filteredFriendsWithApp.count == 0){
            //
        } else if (self.filteredFriendsWithoutApp.count == 0) {
            //
        } else {
            searchActive = true;
        }
        
        if (searchText.isEmpty) {
            self.filteredFriendsWithApp = self.friendsWithAppArray
            self.filteredFriendsWithoutApp = self.friendsWithoutAppArray
        }
        
        self.viewLoaded = true
        self.tableView.reloadData()
        self.footerCollectionView.reloadData()
    }

    
    // Refresh the page - load the friends again
    func refreshPage(sender:AnyObject) {
        self.viewLoaded = false

        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        var fetchedPeople:Bool = userDefaults.objectForKey("fetchedPeople") as! Bool
        self.tableView.userInteractionEnabled = false
        
        dispatch_async(backgroundQueue, {
            print("This is run on the background queue")
            self.getUserObjectsForContacts()
            self.tableView.userInteractionEnabled = false
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("This is run on the main queue, after the previous code in outer block")

                fetchedPeople = true
                userDefaults.setObject(true, forKey: "fetchedPeople")
                userDefaults.setObject(false, forKey: "loggedOut")
                userDefaults.synchronize()

                self.resetFilteredFriendsArray()
                self.tableView.userInteractionEnabled = true
                //self.viewLoaded = true
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()

                self.viewLoaded = true
                
                
                
                self.newRefreshControl.endRefreshing()
            })
        })
    }
    
    
    // Send invites to those the user has invited
    @IBAction func sendInvitesAction(sender: AnyObject) {
        
        let prevWithoutApp = self.getPrevWithoutApp(self.invitedPeopleWithoutApp)
        let users:[String] = prevWithoutApp.allKeys as! [String]
        
        if (users.count > 0) {
            let eventName:String = self.dataSet["eventName"] as! String
            let eventEndDate:NSDate = self.dataSet["endDate"] as! NSDate
            let eventStartDate:NSDate = self.dataSet["date"] as! NSDate
            let eventLocation:String = self.dataSet["eventLocation"] as! String
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
            dateFormatter.timeStyle = .MediumStyle
            let startDateString = dateFormatter.stringFromDate(eventStartDate)
            let endDateString = dateFormatter.stringFromDate(eventEndDate)
            
            // Send text message to those who don't have the app and who you have invited.
            let messageVC = MFMessageComposeViewController()
            messageVC.body = "Squad up!! \n\nReach, '" + eventName + "' from " + startDateString + " to " + endDateString + " @ " + eventLocation + ".";
            messageVC.recipients = users
            messageVC.messageComposeDelegate = self;
            
            self.presentViewController(messageVC, animated: true, completion: nil)
        } else {
            self.createEvent()
        }
    }
    
    
    // Actions to perform on outcome of message compose view controller.
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResultCancelled.rawValue:
            print("Message was cancelled")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultFailed.rawValue:
            print("Message failed")
            self.dismissViewControllerAnimated(true, completion: nil)
            self.createEvent()
        case MessageComposeResultSent.rawValue:
            print("Message was sent")
            self.dismissViewControllerAnimated(true, completion: nil)
            self.createEvent()
        default:
            break;
        }
    }
    
    
    // Create an event.
    func createEvent() {
        // Get the data related for the event
        self.dataSet.setObject(self.invitedPeople, forKey: "invitedPeople")
        self.dataSet.setObject(self.goingPeople, forKey: "goingPeople")
        self.dataSet.setObject(self.notGoingPeople, forKey: "notGoingPeople")
        self.dataSet.setObject(self.invitedPeopleWithApp, forKey: "invitedPeopleWithApp")
        self.dataSet.setObject(self.invitedPeopleWithoutApp, forKey: "invitedPeopleWithoutApp")
        self.dataSet.setObject(self.user!.objectId!, forKey: "eventCreator")
        self.dataSet.setObject(self.user!["name"] as! String, forKey: "eventCreatorName")
        self.dataSet.setObject(false, forKey: "eventCancelled")
        
        var event:PFObject!
        if (self.editingEvent == true) {
            event = self.editingEventObject
        } else {
            event = PFObject(className:"Event")
        }
        // Create the new event and save it to db
        //let event = PFObject(className:"Event")
        event["dataSet"] = self.dataSet
        let success = event.save()
        
        let eventName:String = self.dataSet["eventName"] as! String
        //var eventEndDate:NSDate = self.dataSet["endDate"] as! NSDate
        let eventStartDate:NSDate = self.dataSet["date"] as! NSDate
        
        if (success) {
            // The object has been saved.
            print("New event saved.")
            
            if (self.editingEvent == false) { // User already has the event
                // Get events for current user and add the new event to the user's list of events
                if let userEventsObject:PFObject = self.user?["events"] as? PFObject {
                    let eventsDict:NSMutableDictionary = userEventsObject["events"] as! NSMutableDictionary
                    
                    let userEvents:NSMutableArray = eventsDict[self.user!.objectId!] as! NSMutableArray
                    let newMutableList:NSMutableArray = NSMutableArray();
                    
                    let eventStartDate:NSDate = self.dataSet["date"] as! NSDate
                    var added = false
                    
                    // Insert the new event in the correct order in the list of user events, by date.
                    for dict:AnyObject in userEvents {
                        let eventObject:PFObject = dict as! PFObject
                        
                        let eventItem:NSMutableDictionary = eventObject["dataSet"] as! NSMutableDictionary
                        let startDate:NSDate = eventItem["date"] as! NSDate
                        
                        let compareResult = startDate.compare(eventStartDate)
                        
                        if (compareResult == NSComparisonResult.OrderedDescending && !added) {
                            // event start date is earlier than other start date
                            newMutableList.addObject(event)
                            newMutableList.addObject(eventObject)
                            added = true
                        } else {
                            newMutableList.addObject(eventObject)
                        }
                    }
                    
                    if (!added) {
                        newMutableList.addObject(event)
                    }
                    
                    
                    eventsDict[self.user!.objectId!] = newMutableList
                    userEventsObject["events"] = eventsDict
                    let userEventsSuccess:Bool = userEventsObject.save()
                    
                    if (!userEventsSuccess) {
                        userEventsObject.saveEventually()
                    }
                    
                    //Set up channels for event
                    let eventAuthorChannelKey:String = event.objectId! + "Author"
                    //var eventReminderChannelKey:String = event.objectId! + "Reminder"
                    event["eventAuthorChannel"] = eventAuthorChannelKey
                    event.saveInBackground()

                    // Add channel to push notification installation
                    let currentInstallation = PFInstallation.currentInstallation()
                    currentInstallation.addUniqueObject(eventAuthorChannelKey, forKey: "channels")
                    currentInstallation.saveInBackground()
                }
            }
            
            let qualityOfServiceClass = QOS_CLASS_BACKGROUND
            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            
            dispatch_async(backgroundQueue, {
                print("This is run on the background queue")
                
                // Add events for users who have been invited and have the app and subcsribe them to appropriate channels for push notifs.
                self.addEventsForInvitedUsers(event)
                
                
                //let users:[AnyObject] = self.invitedPeopleWithApp.allKeys
                
                // Separate people into those who have already been invited (and going/invited) and those who are new
                let newInvitees:NSMutableDictionary = self.getNewInvitees(self.invitedPeopleWithApp)
                let newInviteeUsers:[AnyObject] = newInvitees.allKeys
                let prevGoing:NSMutableDictionary = self.prevGoingPeople.mutableCopy() as! NSMutableDictionary
                prevGoing.removeObjectForKey(self.user!.objectId!)
                let goingUsers:[AnyObject] = prevGoing.allKeys
                let prevInvitees:NSMutableDictionary = self.getPrevInvited(self.invitedPeopleWithApp)
                let prevInviteeUsers:[AnyObject] = prevInvitees.allKeys
                let prevPeople:[AnyObject] = prevInviteeUsers + goingUsers
                
                // For those already invited (going/invited) send "edited event notif"
                // For those who are new, send invited notif and scheduled notif
                
                // Send push notification to people who were just invited to event
                let pushQuery = PFInstallation.query()
                pushQuery?.whereKey("userId", containedIn: newInviteeUsers)
                let push = PFPush()
                push.setQuery(pushQuery)
                push.setMessage("You've been invited to: " + eventName)
                push.sendPushInBackground()

                let secondPushQuery = PFInstallation.query()
                secondPushQuery?.whereKey("userId", containedIn: prevPeople)
                let secondPush = PFPush()
                secondPush.setQuery(secondPushQuery)
                secondPush.setMessage(self.user!["name"] as! String + " has made changes to the event: " + eventName)
                secondPush.sendPushInBackground()
                
                
                // Create and send scheduled notification to users when the event is about to start
                self.sendScheduledNotificationForEvent(event, eventName: eventName, eventStartDate: eventStartDate)

                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //print("This is run on the main queue, after the previous code in outer block")
                    //print("Added events for invited users in background")
                })
            })
            
            
            dispatch_async(backgroundQueue, {
                //print("This is run on the background queue")
                
                // Add events for users who have been invited and have the app.
                self.checkUserEventAuthorization()
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //print("This is run on the main queue, after the previous code in outer block")
                    //print("Checked user event authorization in background")
                })
            })
            
            let switchViewController = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - 3] 
            self.navigationController?.popToViewController(switchViewController, animated: true)
        } else {
            print("Error occurred.")
            event.saveEventually()
        }
    }
    
    
    func getNewInvitees(list:NSMutableDictionary) -> NSMutableDictionary {
        var result:NSMutableDictionary = NSMutableDictionary()
        for (id, value) in list {
            if (!self.checkIfPreviouslyInvited(id as! String)) {
                result.setObject(value, forKey: id as! String)
            }
        }
        
        return result
    }
    
    func getPrevInvited(list:NSMutableDictionary) -> NSMutableDictionary {
        var result:NSMutableDictionary = NSMutableDictionary()
        for (id, value) in list {
            if (id as! String == (self.user?.objectId)!) {
                continue
            }
            if let member:String = self.prevGoingPeople[id as! String] as? String {
                result.setObject(value, forKey: id as! String)
            }
            if let member:String = self.prevInvitedPeopleWithApp[id as! String] as? String {
                result.setObject(value, forKey: id as! String)
            }
        }
        return result
    }
    
    func getPrevWithoutApp(list:NSMutableDictionary) -> NSMutableDictionary {
        var result:NSMutableDictionary = NSMutableDictionary()
        for (id, value) in list {
            if let member:String = self.prevInvitedPeopleWithoutApp[id as! String] as? String {
                //
            } else {
                result.setObject(value, forKey: id as! String)
            }
        }
        return result
    }
    
    
    
    // Create and send scheduled notification for event starting to users.
    func sendScheduledNotificationForEvent(eventObject: PFObject, eventName: String, eventStartDate: NSDate) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        let dateString = dateFormatter.stringFromDate(eventStartDate)
        
        let tempDateFormatter = NSDateFormatter()
        tempDateFormatter.timeStyle = NSDateFormatterStyle.LongStyle
        let timeString = tempDateFormatter.stringFromDate(eventStartDate)
        let pushDate = dateString + ", " + timeString
        
        let users:[AnyObject] = self.invitedPeopleWithApp.allKeys
        
        PFCloud.callFunctionInBackground("sendPushNotifications",
            withParameters: ["pushDate": pushDate, "users": users, "eventName": eventName]) {
                (response: AnyObject?, error: NSError?) -> Void in
                if (error != nil){
                    print("Error sending push notification to author")
                    print(error)
                } else {
                    print("Push notification sent to author")
                }
        }
    }
    
    
    
    func addEventsForInvitedUsers(event: PFObject) {
        
        // Iterate through self.invitedPeopleWithApp, get their user object, add event to list.
        for (objectId, value) in self.invitedPeopleWithApp {
            
            if (self.editingEvent == true) {
                if (self.checkIfPreviouslyInvited(objectId as! String)) {
                    continue
                }
            }
            
            let query = PFUser.query()
            query!.whereKey("objectId", equalTo:objectId)
            
            query!.findObjectsInBackgroundWithBlock {
                (appUsers: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    if let appUsers = appUsers as? [PFUser] {
                        if (appUsers.isEmpty) {
                            print("No users with objectId: " + (objectId as! String))
                        } else {
                            var appUser:PFUser = appUsers[0]
                            self.addEventForUser(appUser, event: event)
                        }
                    }
                } else {
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }
    }
    
    
    
    func addEventForUser(user: PFUser, event: PFObject) {
        user.fetch()
        event.fetchIfNeeded()
        print("USER!")
        print(user["name"])
        print(user["events"])
        
        if let userEventsObject:PFObject = user["events"] as? PFObject {
            print("GOT IN HERE!!!!")
            userEventsObject.fetch()
            
            let eventsDict:NSMutableDictionary = userEventsObject["events"] as! NSMutableDictionary
            let userEvents:NSMutableArray = eventsDict[user.objectId!] as! NSMutableArray
            let newMutableList:NSMutableArray = NSMutableArray();
            let eventDataSet:NSMutableDictionary = event["dataSet"] as! NSMutableDictionary
            let eventStartDate:NSDate = eventDataSet["date"] as! NSDate
            var added = false
            
            // Add event in the correct order in the user's events list, by date.
            for dict:AnyObject in userEvents {
                let eventObject:PFObject = dict as! PFObject
                eventObject.fetchIfNeeded()
                let eventItem:NSMutableDictionary = eventObject["dataSet"] as! NSMutableDictionary
                let startDate:NSDate = eventItem["date"] as! NSDate
                
                let compareResult = startDate.compare(eventStartDate)
                
                if (compareResult == NSComparisonResult.OrderedDescending && !added) {
                    // event start date is earlier than other start date
                    newMutableList.addObject(event)
                    newMutableList.addObject(eventObject)
                    added = true
                } else {
                    newMutableList.addObject(eventObject)
                }
            }
            
            if (!added) {
                newMutableList.addObject(event)
            }
            
            eventsDict[user.objectId!] = newMutableList
            userEventsObject["events"] = eventsDict
            let success:Bool = userEventsObject.save()
            
            if (!success) {
                print("NOT SUCCESS....!")
                //userEventsObject.save()
                userEventsObject.saveEventually()
            }

        }
    }
    
    
    
    func popDisplay(sender:UIBarButtonItem){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    
    
    func verifyUserEventAuthorization() {
        switch EKEventStore.authorizationStatusForEntityType(EKEntityType.Event) {
        case .Authorized:
            // Insert Event
            print("Authorized user event")
        case .Denied:
            print("Access Denied")
        case .NotDetermined:
            self.eventStore.requestAccessToEntityType(EKEntityType.Event, completion:
                { [weak self](granted: Bool, error: NSError?) -> Void in
                    if granted {
                        // Insert Event
                        print("Access granted")
                    }
                    else {
                        print("Access Denied")
                    }
                })
        case .Restricted:
            print("Access Denied")
        }
    }
    
    
    func checkUserEventAuthorization() {
        switch EKEventStore.authorizationStatusForEntityType(EKEntityType.Event) {
        case .Authorized:
            // Insert Event
            self.retrieveSquadCalendar()
            if (self.squadUpReminderCalendar != nil) {
                self.insertEvent()
            }
            print("Authorized checkuservent")
        case .Denied:
            print("Access Denied")
        case .NotDetermined:
            self.eventStore.requestAccessToEntityType(EKEntityType.Event, completion:
                { [weak self](granted: Bool, error: NSError?) -> Void in
                    if granted {
                        // Insert Event
                        print("Access granted")
                    }
                    else {
                        print("Access Denied")
                    }
                })
        case .Restricted:
            print("Access Denied")
        }
    }
    
    
    func retrieveSquadCalendar() {
        let calendars = self.eventStore.calendarsForEntityType(EKEntityType.Event)
        
        if(self.squadUpReminderCalendar == nil) {
            for calendar in calendars {
                if calendar.title == "Squad Up Calendar" {
                    self.squadUpReminderCalendar = (calendar )
                    break
                }
            }
            
            if (self.squadUpReminderCalendar == nil) {
                self.squadUpReminderCalendar = EKCalendar(forEntityType: EKEntityType.Event, eventStore: self.eventStore)
                self.squadUpReminderCalendar!.title = "Squad Up Calendar"
                self.squadUpReminderCalendar!.source = self.eventStore.defaultCalendarForNewEvents.source
                let error: NSError?
                let result: Bool
                
                do {
                    try self.eventStore.saveCalendar(self.squadUpReminderCalendar!, commit: true)
                    result = true
                } catch let error1 as NSError {
                    error = error1
                    result = false
                }
                
                if (result == true) {
                    print("Squad Up Calendar saved")
                }
                else {
                    print("Saving calendar failed with error")
                }
            }
        }
    }
    
    
    func insertEvent() {
        let startDate = dataSet.objectForKey("date") as! NSDate
        let endDate = dataSet.objectForKey("date") as! NSDate

        let event = EKEvent(eventStore: self.eventStore)
        event.calendar = self.squadUpReminderCalendar!
                
        event.title = dataSet.objectForKey("eventName") as! String
        event.startDate = startDate
        event.endDate = endDate
                
        var error: NSError?
        let result: Bool
        do {
            try self.eventStore.saveEvent(event, span: .ThisEvent)
            result = true
        } catch let error1 as NSError {
            error = error1
            result = false
        }
                
        if result == false {
            if let theError = error {
                print("An error occured \(theError)")
            }
        } else {
            print("Squad Event created!")
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        
        if (searchActive) {
            return 2
        }
        
        return 2
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if (section == 0) {
            if (self.searchActive) {
                return self.filteredFriendsWithApp.count
            }
            return self.friendsWithApp.count
        } else if (section == 1) {
            if (self.searchActive) {
                return self.filteredFriendsWithoutApp.count
            }
            return self.friendsWithoutApp.count
        }
        return 0
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
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        
        
        if (indexPath.section == 0) {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("SquadFriendCell", forIndexPath: indexPath) as! SquadInviteFriendsTableViewCell
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            
            var phoneContact:String = ""
            var phoneNumber:String = ""
            
            if (self.viewLoaded || false) {
                let friend:Friend = self.filteredFriendsWithApp[indexPath.row]
                phoneContact = friend.name
                cell.userInteractionEnabled = true
                cell.friendName.textColor = UIColor.blackColor()
                
                if (self.editingEvent == true) {
                    if (self.checkIfPreviouslyInvited(friend.objectId)) {
                        cell.userInteractionEnabled = false
                        cell.friendName.textColor = UIColor.redColor()
                    }
                }
                cell.objectId = friend.objectId
                cell.friend = friend
                
                
                if (self.invitedPeople.objectForKey(friend.objectId) != nil) {
                    
                    cell.invited = true
                    cell.invitedSymbol.hidden = false
                } else {
                    cell.invited = friend.invited
                    cell.invitedSymbol.hidden = !(cell.invited!)
                }
                
                
                
                cell.addSubview(friend.profilePicView)
                
                
            }
            
            // Configure the cell.
            cell.friendName.text = phoneContact
            
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! InviteFriendsTableViewCell
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            
            var phoneContact:String = ""
            var phoneNumber:String = ""
            
            
            
            if (self.viewLoaded || false) {
                let friend:Friend = self.filteredFriendsWithoutApp[indexPath.row]
                phoneContact = friend.name
                phoneNumber = self.formatPhoneNumber(friend.objectId)
                
                cell.userInteractionEnabled = true
                cell.friendName.textColor = UIColor.blackColor()
                
                if (self.editingEvent == true) {
                    if (self.checkIfPreviouslyInvited(friend.objectId)) {
                        cell.userInteractionEnabled = false
                        cell.friendName.textColor = UIColor.redColor()
                    }
                }
                
                cell.objectId = friend.objectId
                cell.friend = friend
                
                if (self.invitedPeople.objectForKey(friend.objectId) != nil) {
                    cell.invited = true
                    cell.invitedSymbol.hidden = false
                } else {
                    cell.invited = friend.invited
                    cell.invitedSymbol.hidden = !(cell.invited!)
                }
                
                cell.addSubview(friend.profilePicView)
            }
            // Configure the cell.
            cell.friendName.text = phoneContact
            cell.phoneNumber.text = phoneNumber
            
            return cell
        }
        
        
    }
    
    
    func formatPhoneNumber(phoneNumber: String) -> String {
        let stringts: NSMutableString = NSMutableString.init(string: phoneNumber)
        stringts.insertString("(", atIndex: 0)
        stringts.insertString(")", atIndex: 4)
        stringts.insertString("-", atIndex: 5)
        stringts.insertString("-", atIndex: 9)
        
        return stringts as String
    }
    
    
    func textToImage(drawText: NSString, inImage: UIImage, atPoint:CGPoint)->UIImage{
        
        // Setup the font specific variables
        let textColor: UIColor = UIColor.whiteColor()
        let textFont: UIFont = UIFont(name: "Helvetica Bold", size: 115)!
        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(inImage.size)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
        ]
        
        //Put the image into a rectangle as large as the original image.
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        
        // Creating a point within the space that is as bit as the image.
        let rect: CGRect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width, inImage.size.height)
        
        //Now Draw the text into an image.
        drawText.drawInRect(rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
    }
    
    
    
    
    /* section headers
    appear above each `UITableView` section */
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
            // do not display empty `Section`s
        if (section == 0) {
            return "Squad Up Crew"
        } else if (section == 1) {
            return "Phone Contacts"
        }
        
        return ""
    }
    
    
    // Get contacts from user's address book.
    func promptForAddressBookRequestAccess() {
        self.viewLoaded = false
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(NSMutableDictionary(), forKey: "phoneContacts")
        userDefaults.synchronize()

        if #available(iOS 9.0, *) {
            do {
                let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let containerId = CNContactStore().defaultContainerIdentifier()
                let predicate: NSPredicate = CNContact.predicateForContactsInContainerWithIdentifier(containerId)
                let cnContacts = try CNContactStore().unifiedContactsMatchingPredicate(predicate, keysToFetch: keysToFetch)
                let contacts = NSMutableDictionary()
                
                
                for contact:CNContact in cnContacts {
                    if (contact.isKeyAvailable(CNContactPhoneNumbersKey)) {
                        for number:CNLabeledValue in contact.phoneNumbers {
                            if (number.label != "_$!<Mobile>!$_" && number.label != "iPhone" && number.label != "_$!<Home>!$_" && number.label != "_$!<Other>!$_") {
                                continue
                            } else {
                                let username:String = contact.givenName + " " + contact.familyName
                                
                                let phoneNumber:CNPhoneNumber = number.value as! CNPhoneNumber
                                let value:String = phoneNumber.stringValue
                                let number = value
                                let numberArray = number.characters.map { String($0) }
                                let numbersOnly = numberArray.filter { Int($0) != nil }
                                let numbers = Array(Array(numbersOnly.reverse())[0...9].reverse()).joinWithSeparator("")

                                contacts.setObject(username, forKey: numbers)
                                
                            }
                        }
                    }

                }
                userDefaults.setObject(contacts, forKey: "phoneContacts")
                userDefaults.synchronize()
                
            } catch let error1 as NSError {
                //
                print("ERROR")
                print(error1.description)
            }
            
        } else {
            // Fallback on earlier versions
            
            
            ABAddressBookRequestAccessWithCompletion(self.addressBookRef) {
                (granted: Bool, error: CFError!) in
                dispatch_async(dispatch_get_main_queue()) {
                    if !granted {
                        print("Address Book Request Access Just denied")
                    } else {
                        print("Address Book Request Access Just authorized")
                        
                        if let people = ABAddressBookCopyArrayOfAllPeople(self.addressBookRef)?.takeRetainedValue() as? NSMutableArray {
                            
                            let contacts = NSMutableDictionary()
                            
                            // Iterate through each person in contact list.
                            for person in people {
                                let numbers:ABMultiValue = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()
                                for ix in 0 ..< ABMultiValueGetCount(numbers) {
                                    if let copyLabel = ABMultiValueCopyLabelAtIndex(numbers,ix) {
                                        if let label = copyLabel.takeRetainedValue() as? String {
                                            
                                            if (label != "_$!<Mobile>!$_" && label != "iPhone" && label != "_$!<Home>!$_" && label != "_$!<Other>!$_") {
                                                continue
                                            } else {
                                                
                                                var userName:String?
                                                if let name = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeRetainedValue() as? String {
                                                    let lastname2 = ABRecordCopyValue(person, kABPersonLastNameProperty)
                                                    if (lastname2 != nil) {
                                                        let lastname = lastname2.takeRetainedValue() as? String
                                                        userName = name + " " + lastname!
                                                    } else {
                                                        userName = name + ""
                                                    }
                                                }
                                                
                                                if let value = ABMultiValueCopyValueAtIndex(numbers,ix).takeRetainedValue() as? String {
                                                    if (userName != "") {
                                                        let number = value
                                                        let numberArray = number.characters.map { String($0) }
                                                        let numbersOnly = numberArray.filter { Int($0) != nil }
                                                        let numbers = Array(Array(numbersOnly.reverse())[0...9].reverse()).joinWithSeparator("")
                                                        contacts.setObject(userName!, forKey: numbers)
                                                    } else {
                                                        contacts.setObject(value, forKey: value)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            userDefaults.setObject(contacts, forKey: "phoneContacts")
                            userDefaults.synchronize()
                        }
                    }
                }
            }
        }
        
        
        //self.viewLoaded = true
        self.tableView.reloadData()
        self.footerCollectionView.reloadData()
    }
    
    
    // Get User's Facebook friends
    func getFacebookFriends() {
        let fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: nil)
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            let resultDict = result as! NSMutableDictionary
            let data:NSMutableArray = resultDict.objectForKey("data") as! NSMutableArray
            
            for var i = 0; i < data.count; i++ {
                let valueDict : NSMutableDictionary = data[i] as! NSMutableDictionary
                let id = valueDict.objectForKey("id") as! String
                self.getFacebookName(String(id))
            }
            
            if error == nil {
                print("Friends are : \(result)")
            } else {
                print("Error Getting Friends \(error)");
            }
        }
    }
    
    
    // Get facebook name for the given facebook id
    func getFacebookName(id: String) {
        let fbRequest = FBSDKGraphRequest(graphPath:"/" + id, parameters: nil)
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            var resultDict = result as! NSMutableDictionary
            
            if error == nil {
                let str = result.objectForKey("name") as! String
                let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                let facebookContacts:NSMutableDictionary? = userDefaults.objectForKey("facebookContacts") as? NSMutableDictionary
                var copy:NSMutableDictionary = NSMutableDictionary()
                
                if (facebookContacts == nil) {
                    copy = NSMutableDictionary()
                } else {
                    copy = facebookContacts!.mutableCopy() as! NSMutableDictionary
                    copy.setObject(str, forKey: id)
                }
                
                userDefaults.setObject(copy, forKey: "facebookContacts")
                userDefaults.synchronize()
            } else {
                print("Error Getting Friends \(error)");
            }
        }
    }


    func getUserObjectsForContacts() {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.friendsWithApp = NSMutableDictionary()
        self.indexApp = NSMutableDictionary()
        self.friendsWithoutApp = NSMutableDictionary()
        self.indexWithoutApp = NSMutableDictionary()
        
        if (self.user != nil) {
            if PFFacebookUtils.isLinkedWithUser(self.user!) {
                print("User is linked with Facebook")
                self.getFacebookFriends()
            } else {
                print("User is not linked with Facebook")
                let emptyDict:NSMutableDictionary = NSMutableDictionary()
                userDefaults.setObject(emptyDict, forKey: "facebookContacts")
            }
        }
        
        // Get phone contacts
        self.promptForAddressBookRequestAccess()
        
        let phoneContacts:NSMutableDictionary = userDefaults.objectForKey("phoneContacts") as! NSMutableDictionary
   
        // Get facebook contacts for user
        var facebookContacts:NSMutableDictionary = NSMutableDictionary()
        
        if let facebookFriendList:NSMutableDictionary = userDefaults.objectForKey("facebookContacts") as? NSMutableDictionary {
            facebookContacts = facebookFriendList
        }
        
        // Create the index and friends list for facebook people who have the app
        for (fbid, friendName) in facebookContacts {
            let name = friendName as! String
            let query = PFUser.query()
            query!.whereKey("facebookID", equalTo:fbid)
            var appUsers = query!.findObjects() as! [PFUser]
            
            if (appUsers.isEmpty) {
                print("No users with that facebookid")
            } else {
                let appUser:PFUser = appUsers[0]
                self.friendsWithApp.setObject(name, forKey: appUser.objectId!)
                self.friendToFacebookID.setObject(fbid, forKey: appUser.objectId!)
                self.indexApp.setObject(appUser.objectId!, forKey: String(self.appCount))
                self.appCount++
            }
        }
        
        // Create the index and friends list for people who are not on fb and who have or may not have the app
        for (key, value) in phoneContacts {
//            let query = PFUser.query()
//            query!.whereKey("phoneNumber", equalTo:key)
//            var appUsers = query!.findObjects() as! [PFUser]
//            print("KEY")
//            print(key)

            if (true) { // || appUsers.isEmpty) {
                self.friendsWithoutApp.setObject(value as! String, forKey: key as! String)
                self.indexWithoutApp.setObject(key as! String, forKey: String(self.withoutAppCount))
                self.withoutAppCount++
            }
//            } else {
//                let appUser:PFUser = appUsers[0]
//                if let phoneNumber = appUser["phoneNumber"] as? String {
//                    
//                    if (phoneNumber == key as! String) {
//                        let userName:String = appUser["name"] as! String
//                        let currentUserName:String = self.user?["name"]! as! String
//                        let objectId:String = appUser.objectId!
//                        
//                        if (userName != currentUserName) {
//                            if PFFacebookUtils.isLinkedWithUser(appUser) {
//                                let fbID:String = appUser["facebookID"] as! String
//                                
//                                
//                                if let checkName:String = facebookContacts.objectForKey(fbID) as? String {
//                                    // User is already in facebook friends list so no need to add them again to friends with app list
//                                } else {
//                                    // User is not in facebook friends list so add them to friends with app list
//                                    self.friendsWithApp.setObject(userName, forKey: objectId)
//                                    self.indexApp.setObject(objectId, forKey: String(self.appCount))
//                                    self.appCount++
//                                }
//                            } else {
//                                // Add phone number and user to friendsWithApp list
//                                self.friendsWithApp.setObject(userName, forKey: objectId)
//                                self.indexApp.setObject(objectId, forKey: String(self.appCount))
//                                self.appCount++
//                            }
//                        }
//                    } else {
//                        // phone number is not a user
//                    }
//                }
//                
//            }
        }

        userDefaults.setObject(self.friendToFacebookID, forKey: "friendToFacebookID")
        userDefaults.setObject(self.friendsWithApp, forKey: "friendsWithApp")
        userDefaults.setObject(self.friendsWithoutApp, forKey: "friendsWithoutApp")
        userDefaults.setObject(self.indexApp, forKey: "indexApp")
        userDefaults.setObject(self.indexWithoutApp, forKey: "indexWithoutApp")
        userDefaults.synchronize()
        self.resetFilteredFriendsArray()
    }
    
    
    
    func checkIfPreviouslyInvited(friendID:String) -> Bool {
        print(friendID)
        if let member:String = self.prevGoingPeople[friendID] as? String {
            print("1")
            return true
        }
        if let member:String = self.prevInvitedPeople[friendID] as? String {
            print("2")
            return true
        }
        if let member:String = self.prevInvitedPeopleWithApp[friendID] as? String {
            print("3")
            return true
        }
        if let member:String = self.prevInvitedPeopleWithoutApp[friendID] as? String {
            print("4")
            return true
        }
        if let member:String = self.prevNotGoingPeople[friendID] as? String {
            print("5")
            return true
        }
        
        return false
    }
    
    
    
    // Handle when user selects a row/user to invite
    override func tableView(table: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.DismissKeyboard()
        
        
        
        
        
        
        
        
        let indexSection = indexPath.section
        
        
        
        if (indexSection == 0) {
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! SquadInviteFriendsTableViewCell
            
            // Check if the friend was part of editing event
            if (self.editingEvent == true) {
                let previouslyInvited:Bool = self.checkIfPreviouslyInvited(cell.objectId)
                
                if (previouslyInvited) {
                    return
                }
            }
            
            let phoneContact:String =  cell.friendName.text!
            var friendID:String = cell.objectId
            let friend:Friend = cell.friend!
            let toggle: Bool = !(cell.invited!)
            let prevCellInvited: Bool = cell.invited!
            
            cell.invited = toggle
            cell.invitedSymbol.hidden = !(cell.invited!)
            
            
            if (!prevCellInvited) {
                self.invitedPeopleWithApp.setObject(phoneContact, forKey: friendID)
                self.invitedPeople.setObject(phoneContact, forKey: friendID)
            } else {
                // remove from list
                self.invitedPeopleWithApp.removeObjectForKey(friendID)
                self.invitedPeople.removeObjectForKey(friendID)
            }
            
            // toggle friend.invited boolean and set in list again
            let toggledFriend:Friend = Friend(name: friend.name, objectId: friend.objectId, invited: toggle, index: friend.index, profilePicView: friend.profilePicView)
            self.friendsWithAppArray[friend.index] = toggledFriend
            self.filteredFriendsWithApp[indexPath.row] = toggledFriend
            
            if (friendID == "") {
                friendID = phoneContact + ""
            }
        } else {
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! InviteFriendsTableViewCell
            
            // Check if the friend was part of editing event
            if (self.editingEvent == true) {
                let previouslyInvited:Bool = self.checkIfPreviouslyInvited(cell.objectId)
                
                if (previouslyInvited) {
                    return
                }
            }
            
            let phoneContact:String =  cell.friendName.text!
            var friendID:String = cell.objectId
            let friend:Friend = cell.friend!
            let toggle: Bool = !(cell.invited!)
            let prevCellInvited: Bool = cell.invited!
            
            cell.invited = toggle
            cell.invitedSymbol.hidden = !(cell.invited!)
            
            
            if (!prevCellInvited) {
                self.invitedPeopleWithoutApp.setObject(phoneContact, forKey: friendID)
                self.invitedPeople.setObject(phoneContact, forKey: friendID)
            } else {
                // remove from list
                self.invitedPeopleWithoutApp.removeObjectForKey(friendID)
                self.invitedPeople.removeObjectForKey(friendID)
            }
            
            // toggle friend.invited boolean and set in list again
            let toggledFriend:Friend = Friend(name: friend.name, objectId: friend.objectId, invited: toggle, index: friend.index, profilePicView: friend.profilePicView)
            self.friendsWithoutAppArray[friend.index] = toggledFriend
            self.filteredFriendsWithoutApp[indexPath.row] = toggledFriend
            
            
            if (friendID == "") {
                friendID = phoneContact + ""
            }
        }
        
        
        self.footerCollectionView.reloadData()
        
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
