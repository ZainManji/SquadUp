//
//  LogInViewController.swift
//  Squad Up
//
//  Created by Zain Manji on 8/18/15.
//  Copyright (c) 2015 Zeen Labs. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import AddressBook


class LogInViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    var homeViewController:MasterTableViewController! = MasterTableViewController()
    var customViewController:CustomLogInViewController! = CustomLogInViewController()
    let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()


    override func viewDidLoad() {
        super.viewDidLoad()
        print("inside log in view controller")
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let currentUser = PFUser.currentUser()
        
        // Get Contact List
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        
        switch authorizationStatus {
        case .Denied, .Restricted:
            print("Get Contact List Denied/Restricted")
            
            // Set phone contacts to an empty dictionary since we don't have permission
            let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let contacts:NSMutableDictionary = NSMutableDictionary()
            userDefaults.setObject(contacts, forKey: "phoneContacts")
            userDefaults.synchronize()
        case .Authorized:
            print("Get Contact List Authorized")
            promptForAddressBookRequestAccess()
        case .NotDetermined:
            print("Get Contact List Not Determined")
            promptForAddressBookRequestAccess()
        }
        
        // Reset Facebook Contacts to an empty dictionary so we can refetch
        self.resetFacebookContacts()
        
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            // User is already logged in, do work such as go to next view controller.
            if (currentUser != nil) {
                print("CURRENT USER LOGGED IN WITH FACEBOOK")
                if PFFacebookUtils.isLinkedWithUser(currentUser!) {
                    print("Getting Facebook friends for the user :)")
                    self.getFacebookFriends()
                }
            //}
            
                // Transition to home screen if user is already logged in
                let homeViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SquadUpHome") as? MasterTableViewController
                self.navigationController?.pushViewController(homeViewController!, animated: false)
            }
        } else {
            // Show the signup/login screen
            print("current access token is nULL")
            let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(true, forKey: "loggedOut")
            userDefaults.synchronize()
            let logInViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LogInScreen") as? CustomLogInViewController
            self.navigationController?.pushViewController(logInViewController!, animated: false)
        }


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Get User's Facebook friends
    func getFacebookFriends() {
        let fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: nil)
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            if (result != nil) {
                let resultDict = result as! NSMutableDictionary
                let data:NSArray = resultDict.objectForKey("data") as! NSArray
            
                for var i = 0; i < data.count; i++ {
                    let valueDict : NSMutableDictionary = data[i] as! NSMutableDictionary
                    let id = valueDict.objectForKey("id") as! String
                    self.getFacebookName(String(id))
                }
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
    
    
    
    // Get contacts from user's address book.
    func promptForAddressBookRequestAccess() {
        var err: Unmanaged<CFError>? = nil
        
        ABAddressBookRequestAccessWithCompletion(self.addressBookRef) {
            (granted: Bool, error: CFError!) in
            dispatch_async(dispatch_get_main_queue()) {
                if !granted {
                    print("Address Book Request Access Just denied")
                } else {
                    print("Address Book Request Access Just authorized")
                    
                    if let people = ABAddressBookCopyArrayOfAllPeople(self.addressBookRef)?.takeRetainedValue() as? NSMutableArray {
                        
                        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        let contacts = NSMutableDictionary()
                        
                        // Iterate through each person in contact list.
                        for person in people {
                            let numbers:ABMultiValue = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()
                            for ix in 0 ..< ABMultiValueGetCount(numbers) {
                                if let copyLabel = ABMultiValueCopyLabelAtIndex(numbers,ix) {
                                    if let label = copyLabel.takeRetainedValue() as? String {
                                        
                                        if (label != "_$!<Mobile>!$_" && label != "iPhone" && label != "_$!<Home>!$_" && label != "_$!<Other>!$_" && label != "_$!<Work>!$_") {
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
    
    
    func resetFacebookContacts() {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let copy:NSMutableDictionary = NSMutableDictionary()
        userDefaults.setObject(copy, forKey: "facebookContacts")
        userDefaults.synchronize()
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
