//
//  ContainerViewController.swift
//  EvertonNewsApp
//
//  Created by Dan Taylor on 20/01/2016.
//  Copyright © 2016 Dan Taylor. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

    var leftViewController: UIViewController? {
        willSet{
            if self.leftViewController != nil {
                if self.leftViewController!.view != nil {
                    self.leftViewController!.view!.removeFromSuperview()
                }
                self.leftViewController!.removeFromParentViewController()
            }
        }
        
        didSet{
            
            self.view!.addSubview(self.leftViewController!.view)
            self.addChildViewController(self.leftViewController!)
        }
    }
    
    var rightViewController: UIViewController? {
        willSet {
            if self.rightViewController != nil {
                if self.rightViewController!.view != nil {
                    self.rightViewController!.view!.removeFromSuperview()
                }
                self.rightViewController!.removeFromParentViewController()
            }
        }
        
        didSet{
            
            self.view!.addSubview(self.rightViewController!.view)
            self.addChildViewController(self.rightViewController!)
        }
    }
    
    var menuShown: Bool = false
    
    @IBAction func swipeRight(sender: UISwipeGestureRecognizer) {
        showMenu()
        
    }
    @IBAction func swipeLeft(sender: UISwipeGestureRecognizer) {
        hideMenu()
    }
    
    func showMenu() {
        UIView.animateWithDuration(0.3, animations: {
            self.rightViewController!.view.frame = CGRect(x: self.view.frame.origin.x + 235, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height)
            self.rightViewController!.view.layer.shadowOpacity = 0.5
            }, completion: { (Bool) -> Void in
                self.menuShown = true
        })
    }
    
    func hideMenu() {
        UIView.animateWithDuration(0.3, animations: {
            self.rightViewController!.view.frame = CGRect(x: 0, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height)
            self.rightViewController!.view.layer.shadowOpacity = 0.0
            }, completion: { (Bool) -> Void in
                self.menuShown = false
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ContainerViewController.hideMenu), name: "hideMenu", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ContainerViewController.showMenu), name: "showMenu", object: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let mainNavigationController: UINavigationController = storyboard.instantiateViewControllerWithIdentifier("NavigationController") as! UINavigationController
        
        let menuViewController: MenuTableViewController = storyboard.instantiateViewControllerWithIdentifier("MenuViewController")as! MenuTableViewController
        
        self.leftViewController = menuViewController
        self.rightViewController = mainNavigationController
        
        
        self.view!.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin]
        
        self.rightViewController!.view.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin]
        
        self.leftViewController!.view.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin]

    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
}
