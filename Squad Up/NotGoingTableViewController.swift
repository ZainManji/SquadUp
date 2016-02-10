//
//  NotGoingTableViewController.swift
//  Squad Up
//
//  Created by Zain Manji on 8/24/15.
//  Copyright (c) 2015 Zeen Labs. All rights reserved.
//

import UIKit

class NotGoingTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var footerView: UIView!
    var notGoingPeople:NSMutableDictionary = NSMutableDictionary()
    var sortedKeysArray:NSMutableArray = NSMutableArray()
    var sortedValuesArray:NSMutableArray = NSMutableArray()
    var profilePics:NSMutableDictionary = NSMutableDictionary()
    var friendToFacebookIds:NSMutableDictionary = NSMutableDictionary()

    var tableViewFooter:UIView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if (self.notGoingPeople.count == 0) {
            self.tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height))
            self.tableViewFooter.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
            
            
            let label = UILabel(frame: CGRectMake(0, 0, self.tableView.frame.width, 50))
            label.center = CGPointMake(self.tableView.frame.width / 2, self.tableView.frame.height * 0.2)
            label.textAlignment = NSTextAlignment.Center
            label.text = "0 people are not going"
            label.font = UIFont(name: "HelveticaNeue-Light", size: 26)
            
            self.tableViewFooter.addSubview(label)
            
            
            
            self.tableView.tableHeaderView = self.tableViewFooter
            //self.tableView.scrollEnabled = false
        } else {
            self.tableView.tableHeaderView = nil
            //self.tableView.scrollEnabled = true
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Not Going People"
        
        self.footerView.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
        self.view.backgroundColor = UIColor(red: 230.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)
        
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
        
        for (key, value) in notGoingPeople {
            sortedKeysArray.addObject(key)
            sortedValuesArray.addObject(value)
            
            var profilePicView:UIImageView!
            
            if let fbid = self.friendToFacebookIds.objectForKey(key as! String) as? String {
                let profilePic:UIImage = self.getProfPic(fbid)!
                profilePicView = UIImageView(image: profilePic)
                profilePicView.frame = CGRect(x: 15, y: 13, width: 40, height: 40)
                profilePicView.layer.cornerRadius = profilePicView.frame.size.width / 2
                profilePicView.clipsToBounds = true
                self.profilePics.setObject(profilePicView, forKey: key as! String)
            } else {
                profilePicView = self.getProfPicForName(value as! String)
                self.profilePics.setObject(profilePicView, forKey: key as! String)
            }
        }
    }
    
    func popDisplay(sender:UIBarButtonItem){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func getProfPicForName(username: String) -> UIImageView {
        let contactPic:UIImage = UIImage(named: "greybox.png")!
        let fullNameArr = username.componentsSeparatedByString(" ")
        var initials:String = ""
        for char in fullNameArr[0].characters {
            initials = initials + String(char)
            break
        }
        if (fullNameArr.count > 1) {
            for char in fullNameArr[1].characters {
                initials = initials + String(char)
                break
            }
        }
        let newImage:UIImage = textToImage(initials, inImage: contactPic, atPoint: CGPointMake(35, 45))
        
        
        
        let profilePicView:UIImageView = UIImageView(image: newImage)
        profilePicView.frame = CGRect(x: 15, y: 13, width: 40, height: 40)
        profilePicView.layer.cornerRadius = profilePicView.frame.size.width / 2
        profilePicView.clipsToBounds = true
        
        
        return profilePicView
    }
    
    
    func textToImage(drawText: NSString, inImage: UIImage, atPoint:CGPoint)->UIImage{
        
        // Setup the font specific variables
        let textColor: UIColor = UIColor.whiteColor()
        let textFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 115)!
        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(inImage.size)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
        ]
        
        let size:CGSize = drawText.sizeWithAttributes(textFontAttributes)
        
        
        //Put the image into a rectangle as large as the original image.
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        
        // Creating a point within the space that is as bit as the image.
        //let rect: CGRect = CGRectMake(0 + , atPoint.y, inImage.size.width, inImage.size.height)
        
        let textRect:CGRect = CGRectMake(CGFloat(0.0) + CGFloat(floorf(Float(inImage.size.width - size.width) / Float(2.0))),
            CGFloat(Float(0) + floorf(Float(inImage.size.height - size.height) / Float(2.0))),
            size.width,
            size.height);
        
        //Now Draw the text into an image.
        drawText.drawInRect(textRect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
    }
    
    
    // get fb profile pic
    func getProfPic(fid: String) -> UIImage? {
        
        let url = NSURL(string: "https://graph.facebook.com/" + fid + "/picture?type=large")!
        
        let urlRequest = NSURLRequest(URL: url)
        
        do {
            let urlData:NSData = try NSURLConnection.sendSynchronousRequest(urlRequest,
                returningResponse: AutoreleasingUnsafeMutablePointer<NSURLResponse?>())
            let image:UIImage = UIImage(data: urlData)!
            
            return image
            
        } catch {
            print("Error getting profile pic")
        }
        
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.notGoingPeople.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GuestCell", forIndexPath: indexPath) as! GuestListTableViewCell
        
        // Configure the cell.
        
        let userId:String = sortedKeysArray[indexPath.row] as! String
        if (self.profilePics.objectForKey(userId) != nil) {
            
            let pic = self.profilePics.objectForKey(userId) as! UIImageView
            
            cell.notGoingProfilePic.image = pic.image
            //cell.notGoingProfilePic.frame = CGRect(x: 15, y: 30, width: 30, height: 30)
            cell.notGoingProfilePic.layer.cornerRadius = cell.notGoingProfilePic.frame.size.width / 2
            cell.notGoingProfilePic.clipsToBounds = true
        }
        
        cell.notGoingFriendLabel.text = sortedValuesArray[indexPath.row] as? String
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
