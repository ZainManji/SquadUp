//
//  PhoneNumberViewController.swift
//  Squad Up
//
//  Created by Zain Manji on 8/22/15.
//  Copyright (c) 2015 Zeen Labs. All rights reserved.
//

import UIKit
import MessageUI


class PhoneNumberViewController: UIViewController {

    @IBOutlet var phoneNumberField: UITextField!
    var squadUser:PFUser?
    
    @IBOutlet var continueButton: UIButton!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismiss keyboard if user taps away from text fields.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)

        self.phoneNumberField.keyboardType = UIKeyboardType.NumberPad;
        self.squadUser = PFUser.currentUser()
        
        self.continueButton.backgroundColor = UIColor(red: 51.0/255.0, green: 205.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        self.continueButton.layer.borderWidth = 1
        self.continueButton.layer.borderColor = UIColor(red: 51.0/255.0, green: 205.0/255.0, blue: 153.0/255.0, alpha: 1.0).CGColor
        self.continueButton.frame =  CGRectMake(2, 74, 140, 26)
        self.continueButton.setTitle("Submit new phone number", forState: UIControlState.Normal)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func continuePhoneProcess(sender: AnyObject) {
        self.saveUserPhoneNumber()
    }
    
    func saveUserPhoneNumber() {
        let num:String = self.phoneNumberField.text!
        let number = num
        let numberArray = number.characters.map { String($0) }
        let numbersOnly = numberArray.filter { Int($0) != nil }
        let numbers = Array(Array(numbersOnly.reverse())[0...9].reverse()).joinWithSeparator("")
        print(numbers)
        
        self.squadUser?["phoneNumber"] = numbers
        self.squadUser!.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("Saved user phone number")
                let homeViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SquadUpHome") as? MasterTableViewController
                self.navigationController?.pushViewController(homeViewController!, animated: false)
            } else {
                // There was a problem, check error.description
                print(error?.description)
            }
        }

    }
    
    
    // Dismiss Keyboard.
    func DismissKeyboard(){
        // Causes the view (or one of its embedded text fields) to resign the first responder status.
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
