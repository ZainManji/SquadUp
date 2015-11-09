//
//  SettingsViewController.swift
//  Squad Up
//
//  Created by Zain Manji on 8/23/15.
//  Copyright (c) 2015 Zeen Labs. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet var tableView: UITableView!
    var user:PFUser?
    
    @IBOutlet var footerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.footerView.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
        self.tableView.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
        
        self.user = PFUser.currentUser()

        // Customize back button.
        let myBackButton:UIButton = UIButton(type: UIButtonType.Custom)
        myBackButton.addTarget(self, action: "popDisplay:", forControlEvents: UIControlEvents.TouchUpInside)
        myBackButton.setTitle("Back", forState: UIControlState.Normal)
        myBackButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        myBackButton.sizeToFit()
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logOutAction() {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(true, forKey: "loggedOut")
        userDefaults.synchronize()
        PFUser.logOut()
        
        let logInViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LogInScreen") as? CustomLogInViewController
        self.navigationController?.pushViewController(logInViewController!, animated: true)
    }


    
    
    func popDisplay(sender:UIBarButtonItem){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell", forIndexPath: indexPath) as! SettingsTableViewCell
        
        
        if (indexPath.section == 0) {
            cell.settingCellLabel.text = "Log out"
        } else if (indexPath.section == 1) {
            cell.settingCellLabel.text = "Submit feedback"
        }
        
        cell.backgroundColor = UIColor.whiteColor()
        return cell
    }

    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Account"
        } else if (section == 1) {
            return "Support"
        }
        return ""
    }
    
    
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let border = UIView(frame: CGRectMake(0,0,self.view.bounds.width,1))
        border.backgroundColor = UIColor(red: 187.0/256.0, green: 187.0/256.0, blue: 187.0/256.0, alpha: 1.0)
        
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
        header.textLabel!.font = UIFont(name: "Avenir", size: 14)!
        header.textLabel!.textColor = UIColor(red: 107.0/256.0, green: 107.0/256.0, blue: 107.0/256.0, alpha: 1.0)
        header.alpha = 1.0 //make the header transparent
        header.addSubview(border)
    }
    
    
    // Handle when user selects a row/user to invite
    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section == 0) {
            self.logOutAction()
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
