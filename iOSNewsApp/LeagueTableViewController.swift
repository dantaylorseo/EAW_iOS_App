//
//  LeagueTableViewController.swift
//  EvertonNewsApp
//
//  Created by Dan Taylor on 20/01/2016.
//  Copyright © 2016 Dan Taylor. All rights reserved.
//

import UIKit
import SwiftyJSON

class LeagueTableViewController: UITableViewController {
    
    var league = [League]()
    var menuShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuItem = UIBarButtonItem(title: NSString(string: "\u{2630}") as String, style: .Plain, target: self, action: #selector(LeagueTableViewController.menuButtonPress(_:)))
        self.navigationItem.leftBarButtonItem = menuItem
        
        self.getTable()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Table")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        GAI.sharedInstance().dispatch()
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
    
    func getTable() {
        let jsonUrl = Settings().leagueUrl
        
        let request = NSMutableURLRequest(URL: NSURL(string: jsonUrl)!)
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        let session = NSURLSession(configuration: configuration)
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            dispatch_sync(dispatch_get_main_queue(), {
                let json = JSON(data: data!)
                if let items = json["standing"].array {
                    for team in items {
                        let temp = League()
                        temp.position = team["position"].int
                        temp.team = team["teamName"].string
                        temp.played = team["playedGames"].int
                        temp.points = team["points"].int
                        temp.goals = team["goals"].int
                        temp.against = team["goalsAgainst"].int
                        temp.gd = team["goalDifference"].int
                        temp.wins = team["wins"].int
                        temp.draws = team["draws"].int
                        temp.losses = team["losses"].int
                        temp.logo = team["crestURI"].string
                        
                        self.league.append(temp)
                    }
                }
                self.tableView.reloadData()
            })
        }
        task.resume()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return league.count + 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.row == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("LeagueCellHead", forIndexPath: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("LeagueCell", forIndexPath: indexPath)
            let item = league[indexPath.row - 1]
            
            let tpos = cell.viewWithTag(209) as! UILabel
            tpos.text = String(item.position)
            
            let tteam = cell.viewWithTag(200) as! UILabel
            tteam.text = item.team
            
            let tplayed = cell.viewWithTag(201) as! UILabel
            tplayed.text = String(item.played)
            
            let twins = cell.viewWithTag(202) as! UILabel
            twins.text = String(item.wins)
            
            let tdraws = cell.viewWithTag(203) as! UILabel
            tdraws.text = String(item.draws)
            
            let tlosses = cell.viewWithTag(204) as! UILabel
            tlosses.text = String(item.losses)
            
            let tgoals = cell.viewWithTag(205) as! UILabel
            tgoals.text = String(item.goals)
            
            let tagainst = cell.viewWithTag(206) as! UILabel
            tagainst.text = String(item.against)
            
            let tgd = cell.viewWithTag(207) as! UILabel
            tgd.text = String(item.gd)
            
            let tpts = cell.viewWithTag(208) as! UILabel
            tpts.text = String(item.points)
            
            return cell
        }
        
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
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
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
