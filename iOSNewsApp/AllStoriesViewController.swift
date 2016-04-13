//
//  ViewController.swift
//  EvertonNewsApp
//
//  Created by Dan Taylor on 08/01/2016.
//  Copyright © 2016 Dan Taylor. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Haneke
import iAd
import StoreKit
import CoreData


class AllStoriesViewController: UITableViewController, NSURLSessionDelegate {
    
    // MARK: - Actions, Oulets, Variables & Constants
    //var dataModel = StoriesDataModel()
    var dataModel = StoriesCDModel()
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var refreshing = false
    var rowCount = 0
    
    var dateFormatter2: NSDateFormatter!
    
    var menuShown = false
    
    var messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    
    // MARK: - View (Did|Will|Load) & Memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occurred")
        }
        
        let menuItem = UIBarButtonItem(title: NSString(string: "\u{2630}") as String, style: .Plain, target: self, action: #selector(AllStoriesViewController.menuButtonPress(_:)))
        self.navigationItem.leftBarButtonItem = menuItem
        
        NSTimer.scheduledTimerWithTimeInterval( 1 * 60 , target: self, selector: #selector(AllStoriesViewController.autoUpdate), userInfo: nil, repeats: true)
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("premium") {
            self.canDisplayBannerAds = true
        }
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "logo-trans-3")
        imageView.image = image
        navigationItem.titleView = imageView
                
        self.refreshControl?.addTarget(self, action: #selector(AllStoriesViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.tableView.reloadData()
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("premium") {
            self.canDisplayBannerAds = true
        } else {
            self.canDisplayBannerAds = false
        }
        
        let center = NSNotificationCenter.defaultCenter()
        
        center.addObserverForName("ReloadAllStories", object: nil, queue: nil) { (notification: NSNotification) in
            dispatch_async(dispatch_get_main_queue(), {
                if self.refreshing {
                    self.refreshControl?.endRefreshing()
                    self.refreshing = false
                }
                print("Reloading")
            })
        }
        
        print("all stories");
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "All Stories")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        GAI.sharedInstance().dispatch()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest()
        
        let entity = NSEntityDescription.entityForName("Stories", inManagedObjectContext: self.managedContext)
        fetchRequest.entity = entity
        
        let sortDescriptor1 = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor1]
        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedContext,
            sectionNameKeyPath: nil,
            cacheName: "Stories")
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
        
    }()
    
    // MARK: - Menu buttoin function
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
    
    // MARK: - Auto Update & Refresh Functions
    func autoUpdate() {
        if NSUserDefaults.standardUserDefaults().boolForKey("autoUpdate") {
            print("Updating")
            dataModel.getRemoteData()
        }
    }
    
    func refresh(sender:AnyObject) {
        refreshing = true
        dataModel.getRemoteData()
    }
    
    // MARK: - TableView Data
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row != 0 {
            return 70
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let item = fetchedResultsController.objectAtIndexPath(indexPath) as! Stories
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "d MMM yyyy @ HH:mm"
        let newdate = formatter.stringFromDate(item.date!)
        let subTitle = "\(item.site) - \(newdate)"
        
        if fetchedResultsController.indexPathForObject(item)!.row == -1 {
            
            print("Top")
            let cell = tableView.dequeueReusableCellWithIdentifier("TopCell", forIndexPath: indexPath)
            cell.accessoryType = .None
            
            let encTitle = item.title
            
            let title = cell.viewWithTag(11) as! UILabel
            title.text = encTitle.stringByDecodingHTMLEntities
            
            let cellSub = cell.viewWithTag(12) as! UILabel
            cellSub.text = subTitle
            
            let imageCont = cell.viewWithTag(10) as! UIImageView
            
            if(item.image != "" ) {
                
                let cache = Shared.imageCache
                
                let URL = NSURL(string: item.image!)!
                cache.fetch(URL: URL).onSuccess { image in
                    imageCont.image = image
                }
                
            }
            self.rowCount += 1
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            
            if fetchedResultsController.indexPathForObject(item)!.row % 2 == 0 {
                print("hey")
                cell.backgroundColor = UIColor.clearColor()
            } else {
                cell.backgroundColor = UIColor.whiteColor()
            }
            
            cell.textLabel!.text = item.title
            cell.detailTextLabel!.text = subTitle
            
            let image = UIImage(named: "logo-150")
            let newImage = self.resizeImage(image!, toTheSize: CGSizeMake(50, 50))
            cell.imageView?.image = newImage
            if(item.thumb != "" ) {
                
                let cache = Shared.imageCache
                
                let URL = NSURL(string: item.thumb!)!
                cache.fetch(URL: URL).onSuccess { image in
                    let newImage = self.resizeImage(image, toTheSize: CGSizeMake(50, 50))
                    cell.imageView?.image = newImage
                }
                
            }
            self.rowCount += 1
            return cell
        }
        
    }
    
    // MARK: - Image Resizing
    func resizeImage(image:UIImage, toTheSize size:CGSize)->UIImage{
        let scale = CGFloat(max(size.width/image.size.width,
            size.height/image.size.height))
        let width:CGFloat  = image.size.width * scale
        let height:CGFloat = image.size.height * scale;
        
        let rr:CGRect = CGRectMake( 0, 0, width, height);
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        image.drawInRect(rr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage
    }
    
    // MARK: - Progress Bar
    func progressBarDisplayer(msg:String, _ indicator:Bool ) {
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
        strLabel.text = msg
        strLabel.textColor = UIColor.whiteColor()
        messageFrame = UIView(frame: CGRect(x: view.frame.midX - 100, y: view.frame.midY - 75 , width: 200, height: 50))
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
        if indicator {
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.startAnimating()
            messageFrame.addSubview(activityIndicator)
        }
        messageFrame.addSubview(strLabel)
        self.view.addSubview(messageFrame)
    }

    // MARK: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowStory" {
            let controller = segue.destinationViewController as! ViewStoryViewController
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                controller.story = fetchedResultsController.objectAtIndexPath(indexPath) as! Stories
            }
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
            
            //let backItem = UIBarButtonItem()
            //backItem.title = ""
            //navigationItem.backBarButtonItem = backItem
        }
        
        if segue.identifier == "ShowStoryiPad" {
            let navController = segue.destinationViewController as! UINavigationController
            let controller = navController.viewControllers.first as! ViewStoryViewController
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                controller.story = fetchedResultsController.objectAtIndexPath(indexPath) as! Stories
            }
            
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
            //let backItem = UIBarButtonItem()
            //backItem.title = ""
            //navigationItem.backBarButtonItem = backItem
        }
    }

}

extension AllStoriesViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        case .Delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .Update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            let item = controller.objectAtIndexPath(indexPath!) as! Stories
            //self.configureCell(item, indexPath: indexPath!)
            dump(item)
        case .Move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        case .Delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        case .Update:
            print("*** NSFetchedResultsChangeUpdate (section)")
            
        case .Move:
            print("*** NSFetchedResultsChangeMove (section)")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
        
    }
}

