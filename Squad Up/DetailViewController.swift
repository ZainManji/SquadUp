//
//  DetailViewController.swift
//  Squad Up
//
//  Created by Zain Manji on 8/17/15.
//  Copyright (c) 2015 Zeen Labs. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    
    @IBOutlet var eventNameLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var endTimeLabel: UILabel!
    @IBOutlet var locationButton: UIButton!
    
    
    @IBOutlet var goingButton: UIButton!
    @IBOutlet var notGoingButton: UIButton!
    @IBOutlet var invitedPeopleButton: UIButton!
    
    var eventData:NSMutableDictionary = NSMutableDictionary();
    var eventObjectID:String = ""
    var eventObject:PFObject?

    var user:PFUser?
    
    //for comments section
    @IBOutlet var addCommentField: UITextField! {
        didSet{addCommentField.delegate = self}
    }
    @IBOutlet var tableView: UITableView!
    
    var commentList = [String]()
    var newRefreshControl:UIRefreshControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        // Get User
        self.user = PFUser.currentUser()
        
        let eventCreator:String = eventData["eventCreator"] as! String
        
        if (self.user?.objectId == eventCreator) {
            self.navigationItem.rightBarButtonItem?.enabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        
        self.navigationController!.navigationBar.hidden = false
        
        // Customize back button
        let myBackButton:UIButton = UIButton(type: UIButtonType.Custom)
        myBackButton.addTarget(self, action: "popDisplay:", forControlEvents: UIControlEvents.TouchUpInside)
        myBackButton.setTitle("Back", forState: UIControlState.Normal)
        myBackButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        myBackButton.sizeToFit()
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem

        
        // Fill in text fields with data.
        eventNameLabel.text = eventData.objectForKey("eventName") as? String
        
        let startTime:String = eventData.objectForKey("eventTime") as! String
        let endTime:String = eventData.objectForKey("eventEndTime") as! String
        timeLabel.text = startTime
        endTimeLabel.text = endTime

        var location:String = eventData.objectForKey("eventLocation") as! String
        if (location.isEmpty) {
            location = "To be determined"
        }
        locationButton.setTitle(location, forState: UIControlState.Normal)
        
        if let invitedPeople:NSMutableDictionary = eventData["invitedPeople"] as? NSMutableDictionary {
            invitedPeopleButton.setTitle(String(invitedPeople.count) + "\nInvited", forState: .Normal)
        }
        
        if let goingPeople:NSMutableDictionary = eventData["goingPeople"] as? NSMutableDictionary {
            goingButton.setTitle(String(goingPeople.count) + "\nGoing", forState: .Normal)
        }
        
        if let notGoingPeople:NSMutableDictionary = eventData["notGoingPeople"] as? NSMutableDictionary {
            notGoingButton.setTitle(String(notGoingPeople.count) + "\nNot Going", forState: .Normal)
        }
        
        
        
        //for comments section
        
        // Dismiss keyboard if user taps elsewhere.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CommentCell")
        
        // Get comment list from Parse for event id - getCommentList
        self.getCommentsList()
        
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
    

    // Actually should be called event blast invited people
    @IBAction func deleteItem(sender: AnyObject) {
        
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
    
    @IBAction func checkCommentsSection(sender: UIButton) {
        self.performSegueWithIdentifier("CommentSegue", sender: self)
    }
    
    func popDisplay(sender:UIBarButtonItem){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
        } else if (segue.identifier == "CommentSegue") {
            let commentView:EventCommentsViewController = segue.destinationViewController as! EventCommentsViewController
            commentView.eventId = eventObject?.objectId
        }
    }
    
    
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    //for comments
    func scrollTableToBottom() {
        var yOffset:CGFloat = 0;
        
        if (self.tableView.contentSize.height > self.tableView.bounds.size.height) {
            yOffset = self.tableView.contentSize.height - self.tableView.bounds.size.height;
        }
        
        self.tableView.setContentOffset(CGPointMake(0, yOffset), animated: false)
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
            comment.save()
            
            self.refreshComments()
        }
        
        if error != "" {
            let alert = UIAlertController(title:"Error In Form", message: error, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title:"OK", style: .Default, handler: { action in
                self.dismissViewControllerAnimated(true, completion:nil)
                
            }))
            
            self.presentViewController(alert, animated:true, completion:nil)
        }
        
        addCommentField.text = ""
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) 
        
        cell.textLabel!.text = self.commentList[indexPath.row]
        return cell
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
        query.orderByAscending("createdAt")
        let eventComments = query.findObjects() as! [PFObject]
        
        self.commentList = [String]()
        
        for comment in eventComments {
            let str = comment["comment"] as! String
            self.commentList.append(str)
        }
    }
    
    
    func refreshComments() {
        self.getCommentsList()
        self.tableView.reloadData()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        print("EDIT")
        animateViewMoving(true, moveValue: 300)
    }
    func textFieldDidEndEditing(textField: UITextField) {
        animateViewMoving(false, moveValue: 300)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.addCommentField.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
}
