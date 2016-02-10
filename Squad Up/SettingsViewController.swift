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
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.footerView.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
        self.tableView.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
        
        self.user = PFUser.currentUser()

        // Customize back button.
        let myBackButton:UIButton = UIButton(type: UIButtonType.Custom)
        myBackButton.addTarget(self, action: "popDisplay:", forControlEvents: UIControlEvents.TouchUpInside)
        myBackButton.setTitle("Back", forState: UIControlState.Normal)
        myBackButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myBackButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        myBackButton.sizeToFit()
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        self.navigationController!.interactivePopGestureRecognizer!.enabled = true;
        self.navigationController!.interactivePopGestureRecognizer!.delegate = self;
        
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
        return 25
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Account"
        } else if (section == 1) {
            return "Support"
        }
        return ""
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)!.backgroundColor = UIColor(red: 235.0/256.0, green: 235.0/256.0, blue: 235.0/256.0, alpha: 1.0)
    }
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)!.backgroundColor = UIColor.whiteColor()
    }
    
    
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        header.contentView.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
        header.textLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 14)!
        //header.textLabel!.textColor = UIColor(red: 28.0/255.0, green: 50.0/255.0, blue: 115.0/255.0, alpha: 1.0)
        header.textLabel!.textColor = UIColor(red: 107.0/256.0, green: 107.0/256.0, blue: 107.0/256.0, alpha: 1.0)
        header.alpha = 1.0
        header.textLabel?.textAlignment = NSTextAlignment.Center
    }
    
    
    // Handle when user selects a row/user to invite
    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section == 0) {
            self.logOutAction()
        } else if (indexPath.section == 1) {
            table.cellForRowAtIndexPath(indexPath)!.backgroundColor = UIColor.whiteColor()
            self.performSegueWithIdentifier("FeedbackSegue", sender: self)
        }
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
