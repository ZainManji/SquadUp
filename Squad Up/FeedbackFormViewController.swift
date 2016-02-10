//
//  FeedbackFormViewController.swift
//  Squad Up
//
//  Created by Zain Manji on 11/16/15.
//  Copyright © 2015 Zeen Labs. All rights reserved.
//

import UIKit

class FeedbackFormViewController: UIViewController, UIGestureRecognizerDelegate, UITextViewDelegate {

    
    @IBOutlet var feedback: UITextView!
    var user:PFUser?
    var keyboardFrame:NSValue?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Feedback"
        
        self.user = PFUser.currentUser()
        
        self.view.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        self.feedback.delegate = self
        self.feedback.becomeFirstResponder()

        
        // Customize back button.
        let myBackButton:UIButton = UIButton(type: UIButtonType.Custom)
        myBackButton.addTarget(self, action: "popDisplay:", forControlEvents: UIControlEvents.TouchUpInside)
        myBackButton.setTitle("Back", forState: UIControlState.Normal)
        myBackButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myBackButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        myBackButton.sizeToFit()
        
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        
        // Customize edit button
        let sendButton:UIButton = UIButton(type: UIButtonType.Custom)
        sendButton.addTarget(self, action: "sendMessage:", forControlEvents: UIControlEvents.TouchUpInside)
        sendButton.setTitle("Send", forState: UIControlState.Normal)
        sendButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        sendButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        sendButton.sizeToFit()
        
        let rightBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: sendButton)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.grayColor()
        
        self.navigationController!.interactivePopGestureRecognizer!.enabled = true;
        self.navigationController!.interactivePopGestureRecognizer!.delegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func popDisplay(sender:UIBarButtonItem){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func sendMessage(sender:UIBarButtonItem) {
        self.feedback.resignFirstResponder()
        let comment = PFObject(className:"FeedbackActivity")
        comment["feedback"] = self.feedback.text
        comment["userId"] = self.user?.objectId
        comment["username"] = self.user?["name"]
        comment["facebookId"] = self.user?["facebookID"]
        comment.save()
        let alert = UIAlertController(title:"Thanks!", message: "Thanks for the feedback! We really appreciate it!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title:"No problem!", style: .Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion:nil)
            self.popDisplay(sender)
            
        }))
        
        self.presentViewController(alert, animated:true, completion: nil)

    }
    
    
    func keyboardWillShow(sender: NSNotification) {
        if let userInfo = sender.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                self.keyboardFrame = keyboardHeight
            }
        }
    }
    
    
    func textViewDidChange(textView: UITextView) {
        if (self.feedback.text != "") {
            self.navigationItem.rightBarButtonItem?.enabled = true
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        } else {
            self.navigationItem.rightBarButtonItem?.enabled = false
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.grayColor()
        }
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
