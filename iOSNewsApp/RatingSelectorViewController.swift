//
//  RatingSelectorViewController.swift
//  EvertonNewsApp
//
//  Created by Dan Taylor on 24/01/2016.
//  Copyright © 2016 Dan Taylor. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class RatingSelectorViewController: PFQueryTableViewController {
    
    var passedFixture: PFObject!
    
    @IBAction func saveRatings(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeTeam = passedFixture?.objectForKey("fixtureHome") as! String
        let awayTeam = passedFixture?.objectForKey("fixtureAway") as! String
        
        let fixtureName = "\(homeTeam) v \(awayTeam)"
        
        self.title = fixtureName
        self.navigationController!.navigationBar.barTintColor = UIColor(hex: Settings().barTint)
        
    }
    
    override func queryForTable() -> PFQuery {
        
        let query = PFQuery(className: "PlayerFixtures")
        query.whereKey("fixture", equalTo: passedFixture)
        query.includeKey("player")
        
        return query
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! RatingsCell
        
        let player = object?.objectForKey("player")
        
        let number = player?.objectForKey("playerNumber") as! Int
        let position = player?.objectForKey("playerPosition") as! String
        
        cell.playerName!.text = player?.objectForKey("playerName") as? String
        cell.subTitle!.text = "Squad Number: \(number) | Position: \(position)"
        
        return cell
        
    }
    
}
