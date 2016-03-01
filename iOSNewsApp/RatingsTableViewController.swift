//
//  RatingsTableViewController.swift
//  EvertonNewsApp
//
//  Created by Dan Taylor on 24/01/2016.
//  Copyright © 2016 Dan Taylor. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class RatingsTableViewController: PFQueryTableViewController {
    
    var menuShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let menuItem = UIBarButtonItem(title: NSString(string: "\u{2630}") as String, style: .Plain, target: self, action: "menuButtonPress:")
        self.navigationItem.leftBarButtonItem = menuItem
    }
    
    func menuButtonPress(sender: AnyObject) {
        let center = NSNotificationCenter.defaultCenter()
        if menuShown {
            center.postNotification(NSNotification(name: "hideMenu", object: self))
            menuShown = false
        } else {
            center.postNotification(NSNotification(name: "showMenu", object: self))
            menuShown = true
        }
    }
    
   override func queryForTable() -> PFQuery {
        let query = PFQuery(className: "Fixtures")
        query.orderByDescending("fixtureDate")
    
        return query
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! PFTableViewCell
        
        let homeTeam = object?.objectForKey("fixtureHome") as! String
        let awayTeam = object?.objectForKey("fixtureAway") as! String
        
        let fixtureName = "\(homeTeam) v \(awayTeam)"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let date = dateFormatter.stringFromDate(object?.objectForKey("fixtureDate") as! NSDate)
        
        cell.textLabel!.text = fixtureName
        cell.detailTextLabel!.text = date
        
        return cell
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showRatingSelector" {
            
            let indexPath = self.tableView.indexPathForSelectedRow
            let detailNC = segue.destinationViewController as! UINavigationController
            let detailVC = detailNC.viewControllers.first as! RatingSelectorViewController
            let object = self.objectAtIndexPath(indexPath)
            detailVC.passedFixture = object
            self.tableView.deselectRowAtIndexPath(indexPath!, animated: true)
            
        }
    }
    
    
}
