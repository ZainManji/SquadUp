//
//  LogInScreenViewController.swift
//  Squad Up
//
//  Created by Zain Manji on 8/22/15.
//  Copyright (c) 2015 Zeen Labs. All rights reserved.
//

import UIKit

class LogInScreenViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var logInButton: UIButton!
    @IBOutlet var userNameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    var tField: UITextField!
    
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Customize nav bar
        self.navigationController!.interactivePopGestureRecognizer!.enabled = true;

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "scenery.jpg")!)
        //self.view.backgroundColor = UIColor(red: 230.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        
        self.actInd.center = self.view.center
        self.actInd.hidesWhenStopped = true
        self.actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(self.actInd)
        
        //
        // Customize nav bar.
        self.navigationController!.navigationBar.hidden = false
        self.navigationController!.navigationBarHidden = false
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 255.0/255.0, green: 67.0/255.0, blue: 6.0/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.translucent = true
        self.navigationController!.navigationBar.clipsToBounds = true
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        

        
        // Customize back button
        let myBackButton:UIButton = UIButton(type: UIButtonType.Custom)
        myBackButton.addTarget(self, action: "popDisplay:", forControlEvents: UIControlEvents.TouchUpInside)
        myBackButton.setTitle("Back", forState: UIControlState.Normal)
        myBackButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        myBackButton.sizeToFit()
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        self.navigationController!.interactivePopGestureRecognizer!.delegate = self;
        
        // Dismiss keyboard if user taps away from text fields.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        
        // Customize buttons
        self.logInButton.backgroundColor = UIColor(red: 51.0/255.0, green: 205.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        self.logInButton.layer.borderWidth = 1
        self.logInButton.layer.borderColor = UIColor(red: 51.0/255.0, green: 205.0/255.0, blue: 153.0/255.0, alpha: 1.0).CGColor
        self.logInButton.frame =  CGRectMake(2, 74, 140, 26)
        //self.logInButton.setImage(UIImage(named:"user_icon_20px.png"), forState: UIControlState.Normal)
        //self.logInButton.imageEdgeInsets = UIEdgeInsets(top: 5,left: 7,bottom: 5,right: 25)
        //self.logInButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: 25,bottom: 0,right: 5)
        self.logInButton.setTitle("Log in", forState: UIControlState.Normal)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        let border = CALayer()
//        let width = CGFloat(2.0)
//        border.borderColor = UIColor.whiteColor().CGColor
//        //border.frame = CGRect(x: 0, y: userNameField.frame.size.height - width, width:  userNameField.frame.size.width, height: userNameField.frame.size.height)
//        
//        border.borderWidth = width
//        userNameField.layer.addSublayer(border)
//        userNameField.layer.masksToBounds = true
//        userNameField.bo
        self.userNameField.layer.borderWidth = 1
        self.userNameField.layer.borderColor = UIColor.whiteColor().CGColor
        
        
//        let passwordBorder = CALayer()
//        let passwordWidth = CGFloat(2.0)
//        passwordBorder.borderColor = UIColor.whiteColor().CGColor
//        //passwordBorder.frame = CGRect(x: 0, y: userNameField.frame.size.height - passwordWidth, width:  userNameField.frame.size.width, height: userNameField.frame.size.height)
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
    
    
    // Log in if user enters details and taps log in.
    @IBAction func logInAction(sender: AnyObject) {
        
        var username = self.userNameField.text
        var password = self.passwordField.text
        
        // Check if username and password are valid
        if (username!.utf16.count <= 4 || password!.utf16.count <= 6) {
            var alert = UIAlertView(title: "Invalid", message: "Username must be greater than 4 characters and Password must be greater than 6 characters.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        } else {
            self.actInd.startAnimating()
            PFUser.logInWithUsernameInBackground(username!, password: password!, block: { (user, error) -> Void in
                self.actInd.stopAnimating()
                
                if (user != nil) {
                    print("User logged in w/o Facebook")
                    let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    userDefaults.setObject(true, forKey: "loggedOut")
                    userDefaults.synchronize()

                    // Transition to Home screen.
                    let homeViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SquadUpHome") as? MasterTableViewController
                    self.navigationController?.pushViewController(homeViewController!, animated: false)
                } else {
                    let alert = UIAlertView(title: "Error", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
            })
        }
    }
    
    
    // Forgot password (TO DO).
    @IBAction func passwordForgottenAction(sender: AnyObject) {
        let alert = UIAlertController(title: "Enter email to reset password", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
            print("Resetting password for user")
            PFUser.requestPasswordResetForEmailInBackground(self.tField.text!)
        }))
        self.presentViewController(alert, animated: true, completion: {

        })
    }

    
    func configurationTextField(textField: UITextField!) {
        textField.placeholder = "Email address"
        tField = textField
    }
    
    func handleCancel(alertView: UIAlertAction!) {
        print("User cancelled forgotten password alert.")
    }
    
    
    func popDisplay(sender:UIBarButtonItem){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    // Dismiss Keyboard.
    func DismissKeyboard(){
        view.endEditing(true)
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
