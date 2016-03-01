//
//  MainNavigationController.swift
//  EvertonNewsApp
//
//  Created by Dan Taylor on 20/01/2016.
//  Copyright © 2016 Dan Taylor. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
    
    private var mainSelectedObserver: NSObjectProtocol?
    private var fixturesSelectedObserver: NSObjectProtocol?
    private var settingsSelectedObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.barTintColor = UIColor(hex: Settings().barTint)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    private func addObservers() {
        let center = NSNotificationCenter.defaultCenter()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        mainSelectedObserver = center.addObserverForName(MenuTableViewController.Notifications.MainSelected, object: nil, queue: nil) { (notification: NSNotification) in
            let mvc = storyboard.instantiateViewControllerWithIdentifier("allStories")
            self.setViewControllers([mvc], animated: true)
            center.postNotification(NSNotification(name: "hideMenu", object: self))
        }
        
        fixturesSelectedObserver = center.addObserverForName(MenuTableViewController.Notifications.FixturesSelected, object: nil, queue: nil) { (notification: NSNotification) in
            let rvc = storyboard.instantiateViewControllerWithIdentifier("fixturesViewController")
            self.setViewControllers([rvc], animated: true)
            center.postNotification(NSNotification(name: "hideMenu", object: self))
        }
        
        settingsSelectedObserver = center.addObserverForName(MenuTableViewController.Notifications.SettingsSelected, object: nil, queue: nil) { (notification: NSNotification) in
            let gvc = storyboard.instantiateViewControllerWithIdentifier("SettingsViewController")
            self.setViewControllers([gvc], animated: true)
            center.postNotification(NSNotification(name: "hideMenu", object: self))
        }
        
        settingsSelectedObserver = center.addObserverForName(MenuTableViewController.Notifications.LeagueSelected, object: nil, queue: nil) { (notification: NSNotification) in
            let gvc = storyboard.instantiateViewControllerWithIdentifier("LeagueViewController")
            self.setViewControllers([gvc], animated: true)
            center.postNotification(NSNotification(name: "hideMenu", object: self))
        }
        
        settingsSelectedObserver = center.addObserverForName(MenuTableViewController.Notifications.RatingsSelected, object: nil, queue: nil) { (notification: NSNotification) in
            let gvc = storyboard.instantiateViewControllerWithIdentifier("RatingsTableViewController")
            self.setViewControllers([gvc], animated: true)
            center.postNotification(NSNotification(name: "hideMenu", object: self))
        }
        
        
    }
    
    private func removeObservers(){
        let center = NSNotificationCenter.defaultCenter()
        
        if mainSelectedObserver !=  nil {
            center.removeObserver(mainSelectedObserver!)
        }
        if fixturesSelectedObserver != nil {
            center.removeObserver(fixturesSelectedObserver!)
        }
        if settingsSelectedObserver != nil {
            center.removeObserver(settingsSelectedObserver!)
        }
    }
    
}

