//
//  MenuTableViewController.swift
//  EvertonNewsApp
//
//  Created by Dan Taylor on 20/01/2016.
//  Copyright © 2016 Dan Taylor. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    @IBOutlet var menuTableView: UITableView! {
        didSet{
            menuTableView.delegate = self
            menuTableView.bounces = false
        }
    }
    
    struct Notifications {
        static let MainSelected = "MainSelected"
        static let FixturesSelected = "FixturesSelected"
        static let SettingsSelected = "SettingsSelected"
        static let LeagueSelected = "LeagueSelected"
        static let RatingsSelected = "RatingsSelected"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let center = NSNotificationCenter.defaultCenter()
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                center.postNotification(NSNotification(name: Notifications.MainSelected, object: self))
            case 1:
                center.postNotification(NSNotification(name: Notifications.FixturesSelected, object: self))
            case 2:
                center.postNotification(NSNotification(name: Notifications.LeagueSelected, object: self))
            default:
                print("Unrecognized menu index")
                return
            }
        }
        
        /*if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                center.postNotification(NSNotification(name: Notifications.RatingsSelected, object: self))
            case 1:
                center.postNotification(NSNotification(name: Notifications.FixturesSelected, object: self))
            case 2:
                center.postNotification(NSNotification(name: Notifications.LeagueSelected, object: self))
            default:
                print("Unrecognized menu index")
                return
            }
        }*/
        
        if indexPath.section == 1 && indexPath.row == 0 {
            center.postNotification(NSNotification(name: Notifications.SettingsSelected, object: self))
        }
        
    }

}
