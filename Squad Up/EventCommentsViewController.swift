//
//  EventCommentsViewController.swift
//  Squad Up
//
//  Created by Zain Manji on 9/12/15.
//  Copyright (c) 2015 Zeen Labs. All rights reserved.
//

import UIKit

class EventCommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet var addCommentField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    var commentList = [String]()
    var newRefreshControl:UIRefreshControl!
    var user:PFUser?
    var eventId:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get User
        self.user = PFUser.currentUser()
        
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
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    func scrollTableToBottom() {
        var yOffset:CGFloat = 0;
        
        if (self.tableView.contentSize.height > self.tableView.bounds.size.height) {
            yOffset = self.tableView.contentSize.height - self.tableView.bounds.size.height;
        }
        
        self.tableView.setContentOffset(CGPointMake(0, yOffset), animated: false)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            comment["eventId"] = self.eventId
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
        query.whereKey("eventId", equalTo: self.eventId!)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
