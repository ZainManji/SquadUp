//
//  CustomSignUpViewController.swift
//  Squad Up
//
//  Created by Zain Manji on 8/18/15.
//  Copyright (c) 2015 Zeen Labs. All rights reserved.
//

import UIKit
import Parse

class CustomSignUpViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var userNameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Customize nav bar.
        self.navigationController!.navigationBar.hidden = false
        self.navigationController!.navigationBarHidden = false
        self.navigationController!.interactivePopGestureRecognizer!.enabled = true;

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "suwu.jpg")!)
        self.view.backgroundColor = UIColor(red: 51.0/255.0, green: 205.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        
        // Dismiss keyboard if user taps away from text fields.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        // Customize nav bar.
        self.navigationController!.navigationBar.hidden = false
        self.navigationController!.navigationBarHidden = false
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 255.0/255.0, green: 67.0/255.0, blue: 6.0/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.translucent = true
        self.navigationController!.navigationBar.clipsToBounds = true
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        
        self.actInd.center = self.view.center
        self.actInd.hidesWhenStopped = true
        self.actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(self.actInd)
        
        // Customize back button.
        let myBackButton:UIButton = UIButton(type: UIButtonType.Custom)
        myBackButton.addTarget(self, action: "popDisplay:", forControlEvents: UIControlEvents.TouchUpInside)
        myBackButton.setTitle("Back", forState: UIControlState.Normal)
        myBackButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        myBackButton.sizeToFit()
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        self.navigationController!.interactivePopGestureRecognizer!.delegate = self;
        
        
        
        // Customize buttons
        self.signUpButton.backgroundColor = UIColor(red: 240.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        self.signUpButton.layer.borderWidth = 1
        self.signUpButton.layer.borderColor = UIColor(red: 240.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0).CGColor
        self.signUpButton.frame =  CGRectMake(2, 74, 140, 26)
        //self.logInButton.setImage(UIImage(named:"user_icon_20px.png"), forState: UIControlState.Normal)
        //self.logInButton.imageEdgeInsets = UIEdgeInsets(top: 5,left: 7,bottom: 5,right: 25)
        //self.logInButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: 25,bottom: 0,right: 5)
        self.signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        let border = CALayer()
//        let width = CGFloat(2.0)
//        border.borderColor = UIColor.whiteColor().CGColor
//        border.frame = CGRect(x: 0, y: emailField.frame.size.height - width, width:  emailField.frame.size.width, height: emailField.frame.size.height)
//        
//        border.borderWidth = width
//        emailField.layer.addSublayer(border)
//        emailField.layer.masksToBounds = true
        
        self.emailField.layer.borderWidth = 1
        self.emailField.layer.borderColor = UIColor.whiteColor().CGColor
        
        
//        let nameBorder = CALayer()
//        let nameWidth = CGFloat(2.0)
//        nameBorder.borderColor = UIColor.whiteColor().CGColor
//        nameBorder.frame = CGRect(x: 0, y: userNameField.frame.size.height - nameWidth, width:  userNameField.frame.size.width, height: userNameField.frame.size.height)
//        
//        nameBorder.borderWidth = nameWidth
//        userNameField.layer.addSublayer(nameBorder)
//        userNameField.layer.masksToBounds = true
        
        self.userNameField.layer.borderWidth = 1
        self.userNameField.layer.borderColor = UIColor.whiteColor().CGColor
        
        
//        let passwordBorder = CALayer()
//        let passwordWidth = CGFloat(2.0)
//        passwordBorder.borderColor = UIColor.whiteColor().CGColor
//        passwordBorder.frame = CGRect(x: 0, y: passwordField.frame.size.height - passwordWidth, width:  passwordField.frame.size.width, height: passwordField.frame.size.height)
//        
//        passwordBorder.borderWidth = passwordWidth
//        passwordField.layer.addSublayer(passwordBorder)
//        passwordField.layer.masksToBounds = true
        
        self.passwordField.layer.borderWidth = 1
        self.passwordField.layer.borderColor = UIColor.whiteColor().CGColor
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Sign up if user enters details and taps sign up.
    @IBAction func signUpAction(sender: AnyObject) {
        
        let username = self.userNameField.text
        let password = self.passwordField.text
        let email = self.emailField.text
        
        if (username!.utf16.count <= 4 || password!.utf16.count <= 6) {
            let alert = UIAlertView(title: "Invalid", message: "Username must be greater than 4 characters and Password must be greater than 6 characters.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        } else if (email!.utf16.count < 2) {
            let alert = UIAlertView(title: "Invalid", message: "Please enter a valid email.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        } else {
            self.actInd.startAnimating()
            
            // Create the initial data in the backend for the newuser.
            let newUser = PFUser()
            newUser.username = username
            newUser.password = password
            newUser.email = email
            newUser["name"] = username
            
            newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
                self.actInd.stopAnimating()
                
                if (error != nil) {
                    let alert = UIAlertView(title: "Error", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                } else {
                    print("Signed up")
                    
                    // Create the user's own user events list.
                    let userEvents = PFObject(className:"UserEvents")
                    let newEventsHolder:NSMutableDictionary = NSMutableDictionary()
                    newEventsHolder[newUser.objectId!] = NSMutableArray()
                    userEvents["events"] = newEventsHolder
                    
                    userEvents.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            // The object has been saved.
                            newUser["events"] = userEvents
                        } else {
                            // There was a problem, check error.description
                            print(error?.description)
                        }
                    }

                    // Transition to the phone information page.
                    self.performSegueWithIdentifier("signUpPhoneSegue", sender: self)
                }
            })
        }
    }
    
    
    // Dismiss Keyboard.
    func DismissKeyboard(){
        // Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    // Pop display.
    func popDisplay(sender:UIBarButtonItem){
        self.navigationController!.popViewControllerAnimated(true)
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
