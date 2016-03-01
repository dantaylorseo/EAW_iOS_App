//
//  FixturesViewController.swift
//  EvertonNewsApp
//
//  Created by Dan Taylor on 20/01/2016.
//  Copyright © 2016 Dan Taylor. All rights reserved.
//

import UIKit
import SwiftyJSON

class FixturesViewController: UITableViewController {

    var menuShown = false
    var fixtures = [Fixtures]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuItem = UIBarButtonItem(title: NSString(string: "\u{2630}") as String, style: .Plain, target: self, action: "menuButtonPress:")
        self.navigationItem.leftBarButtonItem = menuItem
        
        self.getFixtures()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Fixtures")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        GAI.sharedInstance().dispatch()
    }
    
    func getFixtures() {
        let request = NSMutableURLRequest(URL: NSURL(string: Settings().fixturesUrl)!)
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        let session = NSURLSession(configuration: configuration)
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            dispatch_sync(dispatch_get_main_queue(), {
                let json = JSON(data: data!)
                if let items = json.array {
                    for fixture in items {

                        let dateFormatter = NSDateFormatter()
                        
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        dateFormatter.locale = NSLocale(localeIdentifier: "en-GB")
                        let date = dateFormatter.dateFromString(fixture["fixtureDate"].string!)
                        
                        let temp = Fixtures()
                        temp.id = fixture["fixtureID"].string
                        temp.title = fixture["fixtureTitle"].string
                        temp.subtitle = fixture["fixtureSub"].string
                        temp.date = date
                        temp.score = fixture["fixtureScore"].string
                        temp.status = fixture["fixtureStatus"].string
                        
                        self.fixtures.append(temp)
                        
                    }
                }
               self.tableView.reloadData()
            })
        }
        task.resume()
        
        
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fixtures.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FixtureCell", forIndexPath: indexPath)
        
        let item = fixtures[indexPath.row]
        
        let title = cell.viewWithTag(101) as! UILabel
        title.text = item.title
        
        let subtitle = cell.viewWithTag(102) as! UILabel
        subtitle.text = item.subtitle
        
        let score = cell.viewWithTag(103) as! UILabel
        score.text = item.score

        return cell
            
        
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
