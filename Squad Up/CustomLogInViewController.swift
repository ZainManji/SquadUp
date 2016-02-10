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

    @IBOutlet var facebookLogInButton: UIButton!
    
    let permissions = ["public_profile", "email", "user_friends"]
    var squadUser:PFUser?
    var tempBool:Bool = false
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Customize/Hide status bar and nav bar
        self.navigationItem.setHidesBackButton(true, animated: false)

        //self.navigationController!.navigationBarHidden = true
        //self.navigationController!.interactivePopGestureRecognizer!.enabled = false;
        print("View appeared again")
        self.segueToHome()
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(frame: view.bounds)
        imageView.image = UIImage(named: "party1black.png")
        self.view.addSubview(imageView)

        // Customize/Hide status bar and nav bar
        self.navigationItem.setHidesBackButton(true, animated: false)
        if (self.navigationController?.navigationBar != nil) {
            self.navigationController!.navigationBar.hidden = true
        }

        
        self.facebookLogInButton.backgroundColor = UIColor(red: 59.0/255.0, green: 89.0/255.0, blue: 152.0/255.0, alpha: 1.0)
        self.facebookLogInButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.facebookLogInButton.layer.borderWidth = 1
        self.facebookLogInButton.layer.borderColor = UIColor(red: 59.0/255.0, green: 89.0/255.0, blue: 152.0/255.0, alpha: 1.0).CGColor
        self.facebookLogInButton.frame =  CGRectMake(2, 74, 140, 26)
        self.facebookLogInButton.setImage(UIImage(named:"f_icon.png"), forState: UIControlState.Normal)
        self.facebookLogInButton.imageEdgeInsets = UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 25)
        self.facebookLogInButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: 25,bottom: 0,right: 5)
        self.facebookLogInButton.setTitle("Log in with Facebook", forState: UIControlState.Normal)
        self.view.addSubview(self.facebookLogInButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                            user["events"] = userEvents
                            user.save()
                        } else {
                            print(error?.description)
                        }
                    }
                    
                    // Add user to the current installation object for push notifications
                    let currentInstallation = PFInstallation.currentInstallation()
                    currentInstallation["userId"] = user.objectId
                    currentInstallation.saveInBackground()
                    
                    self.getFacebookInfo("me")
                    self.getFacebookFriends()
                    
                    self.performSegueWithIdentifier("goToTutorial", sender: self)
                } else {
                    // Add user to the current installation object for push notifications
                    let currentInstallation = PFInstallation.currentInstallation()
                    currentInstallation["userId"] = user.objectId
                    currentInstallation.saveInBackground()
                    
                    print("User logged in through Facebook!!")
                    //self.getFacebookFriends()

                    // Take user to their home page.
                    // Transition to home screen if user is already logged in
                    let homeViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SquadUpHomeNav") as? MasterTableViewController
//                    self.navigationController?.pushViewController(homeViewController!, animated: false)
                    //self.performSegueWithIdentifier("signUp", sender: self)
                    self.tempBool = true
                    self.segueToHome()
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
            
            
        }
        
        
    }
    
    func segueToHome() {
        if (self.tempBool) {
            print("HERE!!!!")
            
            self.performSegueWithIdentifier("signUp", sender: self)
        }
    }
    

    
    
    // Get Facebook info for given facebook id
    func getFacebookInfo(id: String) {
        let fbRequest = FBSDKGraphRequest(graphPath:"/" + id, parameters: ["fields":"email,name,id"])
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            if error == nil {
                print(result)
                self.squadUser?.email = result.objectForKey("email") as? String
                self.squadUser?["name"] = result.objectForKey("name") as? String
                self.squadUser?["facebookID"] = result.objectForKey("id") as? String
                self.squadUser!.save()
                print("Saved user's facebook info")

            } else {
                print("Error Getting Facebook Info \(error)");
            }
        }
    }

    
    // Get User's Facebook friends
    func getFacebookFriends() {
        
        let fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: nil)
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            let resultDict = result as! NSMutableDictionary
            let data:NSArray = resultDict.objectForKey("data") as! NSArray
            
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
    
    
    func getFacebookName(id: String) {
        let fbRequest = FBSDKGraphRequest(graphPath:"/" + id, parameters: nil)
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
