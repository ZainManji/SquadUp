//
//  FirstPageViewController.swift
//  FreshAir
//
//  Created by Zain Manji on 11/19/15.
//  Copyright © 2015 Zeen Labs. All rights reserved.
//

import UIKit

class FirstPageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageViewController:UIPageViewController!
    var pageTitles: NSArray!
    var pageImages: NSArray!
    var index: Int = 0
    
    var viewBackgroundImages:NSArray!
    var backgroundImageView:UIImageView!

    @IBOutlet var getStartedButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewBackgroundImages = NSArray(objects: UIImage(named: "suwu.jpg")!, UIImage(named: "scenery.jpg")!, UIImage(named: "party1black.png")!)
        
        backgroundImageView = UIImageView(frame: view.bounds)
        backgroundImageView.image = self.viewBackgroundImages[self.index] as? UIImage
        self.view.addSubview(backgroundImageView)
        self.view.bringSubviewToFront(self.getStartedButton)

        self.getStartedButton.hidden = false
        
        self.pageTitles = NSArray(objects: "Easily create an event.", "Seamlessly invite people to your event.", "Quickly check out your upcoming events.")
        self.pageImages = NSArray(objects: "suwu.jpg", "scenery.jpg", "party1.png")
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        let startVC = self.viewControllerAtIndex(0) as ContentViewController
        
        let viewControllers = NSArray(object: startVC)
    
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)

        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.size.height - 50)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func restartAction(sender: AnyObject) {
        self.index = 0
        
        let startVC = self.viewControllerAtIndex(0) as ContentViewController
        let viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }
    
    
    @IBAction func nextAction(sender: AnyObject) {
        
        if (self.index == self.pageTitles.count - 1) {
            self.performSegueWithIdentifier("tutorialToHome", sender: self)
        } else {
            self.index += 1
            let nextVC = self.viewControllerAtIndex(self.index) as ContentViewController
            let viewControllers = NSArray(object: nextVC)
            
            self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
            
            let pageContentViewController:ContentViewController = self.pageViewController.viewControllers![0] as! ContentViewController
            let index = pageContentViewController.pageIndex
            self.index = index
            
            if (self.index == self.pageTitles.count - 1) {
                self.getStartedButton.hidden = false
                self.getStartedButton.setTitle("Get Started", forState: UIControlState.Normal)
            } else {
                self.getStartedButton.setTitle("Next", forState: UIControlState.Normal)
                self.getStartedButton.hidden = false
            }
        }

        
    }

    
    func viewControllerAtIndex(index: Int) -> ContentViewController {
        if (self.pageTitles.count == 0 || index >= self.pageTitles.count) {
            return ContentViewController()
        }
        
        let vc:ContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ContentViewController") as! ContentViewController
        
        vc.imageFile = self.pageImages[index] as! String
        vc.titleText = self.pageTitles[index] as! String
        vc.pageIndex = index
        
        return vc
        
    }
    
    
    
    // Mark: page view controller delegate
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController:ContentViewController = self.pageViewController.viewControllers![0] as! ContentViewController
        let index = pageContentViewController.pageIndex
        self.index = index
        
        if (self.index == self.pageTitles.count - 1) {
            self.getStartedButton.hidden = false
            self.getStartedButton.setTitle("Get Started", forState: UIControlState.Normal)
        } else {
            self.getStartedButton.setTitle("Next", forState: UIControlState.Normal)
            self.getStartedButton.hidden = false
        }
        backgroundImageView.image = self.viewBackgroundImages[self.index] as? UIImage
    }
    
    // Mark : page view controller datasource
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        if (index == 0 || index == NSNotFound) {
            return nil
        }
        
        index--
        
        return self.viewControllerAtIndex(index)
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        if (index == NSNotFound) {
            return nil
        }
        
        index++
        
        if (index == self.pageTitles.count) {
            return nil
        }
        
        return self.viewControllerAtIndex(index)
        
    }
    
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.index
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
