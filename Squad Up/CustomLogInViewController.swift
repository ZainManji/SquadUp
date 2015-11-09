//
//  CustomLogInViewController.swift
//  Squad Up
//
//  Created by Zain Manji on 8/18/15.
//  Copyright (c) 2015 Zeen Labs. All rights reserved.
//

import UIKit
import Parse

class CustomLogInViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var webViewBG: UIWebView!
    @IBOutlet var filter: UIView!
    @IBOutlet var logInButton: UIButton!
    @IBOutlet var facebookLogInButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    
    let permissions = ["public_profile", "email", "user_friends"]
    var squadUser:PFUser?
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Customize/Hide status bar and nav bar
        self.navigationItem.setHidesBackButton(true, animated: false)

        self.navigationController!.navigationBarHidden = true
        self.navigationController!.interactivePopGestureRecognizer!.enabled = false;

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "suwu.jpg")!)
        
        // Customize/Hide status bar and nav bar
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.navigationController!.navigationBar.hidden = true


        
        // Customize buttons
        self.logInButton.backgroundColor = UIColor(red: 51.0/255.0, green: 205.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        self.logInButton.layer.borderWidth = 1
        self.logInButton.layer.borderColor = UIColor(red: 51.0/255.0, green: 205.0/255.0, blue: 153.0/255.0, alpha: 1.0).CGColor
        self.logInButton.frame =  CGRectMake(2, 74, 140, 26)
        self.logInButton.setImage(UIImage(named:"user_icon_20px.png"), forState: UIControlState.Normal)
        self.logInButton.imageEdgeInsets = UIEdgeInsets(top: 5,left: 7,bottom: 5,right: 25)
        self.logInButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: 25,bottom: 0,right: 5)
        self.logInButton.setTitle("Log in with Username", forState: UIControlState.Normal)
        self.logInButton.hidden = true
        self.logInButton.enabled = false
        
        
        
        self.facebookLogInButton.backgroundColor = UIColor(red: 59.0/255.0, green: 89.0/255.0, blue: 152.0/255.0, alpha: 1.0)
        self.facebookLogInButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.facebookLogInButton.layer.borderWidth = 1
        self.facebookLogInButton.layer.borderColor = UIColor(red: 59.0/255.0, green: 89.0/255.0, blue: 152.0/255.0, alpha: 1.0).CGColor
        self.facebookLogInButton.frame =  CGRectMake(2, 74, 140, 26)
        self.facebookLogInButton.setImage(UIImage(named:"f_icon.png"), forState: UIControlState.Normal)
        self.facebookLogInButton.imageEdgeInsets = UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 25)
        self.facebookLogInButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: 25,bottom: 0,right: 5)
        self.facebookLogInButton.setTitle("Log in with Facebook", forState: UIControlState.Normal)

        
        
        
        self.signUpButton.backgroundColor = UIColor(red: 59.0/255.0, green: 89.0/255.0, blue: 152.0/255.0, alpha: 0.0)
        self.signUpButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.signUpButton.layer.borderWidth = 1
        self.signUpButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.signUpButton.frame =  CGRectMake(2, 74, 140, 26)
        //self.signUpButton.setImage(UIImage(named:"f_icon.png"), forState: UIControlState.Normal)
        //self.signUpButton.imageEdgeInsets = UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 25)
        self.signUpButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: 15,bottom: 0,right: 5)
        self.signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
        self.signUpButton.hidden = true
        self.signUpButton.enabled = false
        
        // Add check to dismiss keyboard if tapping outside of text fields.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Transition to log in screen if user tapped "log in".
    @IBAction func logInAction(sender: AnyObject) {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(true, forKey: "loggedOut")
        userDefaults.synchronize()
        self.performSegueWithIdentifier("LogInScreen", sender: self)
    }
    
    
    // Log in with User facebook account if they choose to do so.
    @IBAction func facebookLogInAction(sender: AnyObject) {
        PFFacebookUtils.logInInBackgroundWithReadPermissions(self.permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                self.squadUser = user
                
                // If user is new to Squad Up and signed up through Facebook
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                    
                    // Create the user's own user events object
                    let userEvents = PFObject(className:"UserEvents")
                    let newEventsHolder:NSMutableDictionary = NSMutableDictionary()
                    newEventsHolder[user.objectId!] = NSMutableArray()
                    userEvents["events"] = newEventsHolder
                    userEvents.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            // The object has been saved.
                            user["events"] = userEvents
                            user.save()
                        } else {
                            // There was a problem, check error.description
                            print(error?.description)
                        }
                    }
                    
                    // Get all information needed from user here and save it to db. Email, First Name, Last Name.
                    

                    self.getFacebookInfo("me")
                    self.getFacebookFriends()
                    
                    // Take user to their home page.
                    let homeViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SquadUpHome") as? MasterTableViewController
                    self.navigationController?.pushViewController(homeViewController!, animated: false)
                } else {
                    print("User logged in through Facebook!")
                    self.getFacebookFriends()

                    // Take user to their home page.
                    let homeViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SquadUpHome") as? MasterTableViewController
                    self.navigationController?.pushViewController(homeViewController!, animated: false)
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        }
    }
    
    
    // Get Facebook info for given facebook id
    func getFacebookInfo(id: String) {
        let fbRequest = FBSDKGraphRequest(graphPath:"/" + id, parameters: ["fields":"email,name,id"])
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            var resultDict = result as! NSMutableDictionary
            
            if error == nil {
                print(result)
                self.squadUser?.email = result.objectForKey("email") as? String
                self.squadUser?["name"] = result.objectForKey("name") as? String
                self.squadUser?["facebookID"] = result.objectForKey("id") as? String
                self.squadUser!.save()
                print("Saved user's facebook info")
//                
//                
//                
//                // Transition to phone screen to ask for their information.
//                let phoneViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PhoneScreen") as? PhoneNumberViewController
//                self.navigationController?.pushViewController(phoneViewController!, animated: false)
            } else {
                print("Error Getting Facebook Info \(error)");
            }
        }
    }
    
    func sendNewUserNotification(result:NSMutableDictionary) {
        let data:NSMutableArray = result.objectForKey("data") as! NSMutableArray
        
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        let facebookContacts:NSMutableDictionary? = userDefaults.objectForKey("facebookContacts") as? NSMutableDictionary
        //
        var copy:NSMutableDictionary = NSMutableDictionary()
        
        for var i = 0; i < data.count; i++ {
            let valueDict : NSMutableDictionary = data[i] as! NSMutableDictionary
            let id = valueDict.objectForKey("id") as! String
            copy.setObject(valueDict.objectForKey("id") as! String, forKey: id)
        }
        //
        print("GOT HERE!!!")
        
        
        let friends:[AnyObject] = copy.allKeys
        print(friends)
        
        let pushQuery = PFInstallation.query()
        pushQuery?.whereKey("userId", containedIn: friends)
        let push = PFPush()
        push.setQuery(pushQuery)
        let newUserName:String = self.squadUser?["name"] as! String
        push.setMessage("Your Facebook friend, " + newUserName + ", just joined Squad Up!")
        push.sendPushInBackground()
        print("finsihed here")
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
                self.sendNewUserNotification(result as! NSMutableDictionary)
            } else {
                print("Error Getting Friends \(error)");
            }
        }
    }
    
    
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
    
    
    // Dismiss Keyboard
    func DismissKeyboard(){
        // Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    // If user chooses to Sign Up, transition to Sign Up Screen
    @IBAction func signUpAction(sender: AnyObject) {
        self.performSegueWithIdentifier("SignUp", sender: self)
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
