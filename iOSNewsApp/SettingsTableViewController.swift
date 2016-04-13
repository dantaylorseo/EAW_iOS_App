//
//  SettingsTableViewController.swift
//  EvertonNewsApp
//
//  Created by Dan Taylor on 18/01/2016.
//  Copyright © 2016 Dan Taylor. All rights reserved.
//

import UIKit
import Parse
import StoreKit

class SettingsTableViewController: UITableViewController, SKProductsRequestDelegate {
    
    let currentInstallation = PFInstallation.currentInstallation()
    let productId = Settings().productId
    var menuShown = false
    
    @IBOutlet weak var premiumLabel: UILabel!
    @IBOutlet weak var transferSwitch: UISwitch!
    @IBOutlet weak var newsSwitch: UISwitch!
    @IBOutlet weak var updateFeedsSwitch: UISwitch!
    @IBOutlet weak var premiumCell: UITableViewCell!
    @IBOutlet weak var restoreButton: UIBarButtonItem!
    
    @IBAction func notifyTransferNews(sender: AnyObject) {
        
        if transferSwitch.on {
            currentInstallation.addUniqueObject("transferNews", forKey: "channels")
            currentInstallation.saveEventually()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "transferNews")
            NSUserDefaults.standardUserDefaults().synchronize()
        } else {
            currentInstallation.removeObject("transferNews", forKey: "channels")
            currentInstallation.saveEventually()
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "transferNews")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
    }
    
    @IBAction func notifyScores(sender: AnyObject) {
        
        if newsSwitch.on {
            currentInstallation.addUniqueObject("scores", forKey: "channels")
            currentInstallation.saveEventually()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "scores")
            NSUserDefaults.standardUserDefaults().synchronize()
        } else {
            currentInstallation.removeObject("scores", forKey: "channels")
            currentInstallation.saveEventually()
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "scores")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
    }
    
    @IBAction func autoUpdateFeeds(sender: AnyObject) {
        
        if updateFeedsSwitch.on {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "autoUpdate")
            NSUserDefaults.standardUserDefaults().synchronize()
        } else {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "autoUpdate")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let menuItem = UIBarButtonItem(title: NSString(string: "\u{2630}") as String, style: .Plain, target: self, action: #selector(SettingsTableViewController.menuButtonPress(_:)))
        self.navigationItem.leftBarButtonItem = menuItem
        
        PFPurchase.addObserverForProduct(Settings().productId) { (transaction: SKPaymentTransaction!) -> Void in
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setBool(true, forKey: "premium")
            userDefaults.synchronize()
            
            self.premiumLabel?.text = "You are a premium member"
            self.premiumCell?.accessoryType = .None
            self.restoreButton.enabled = false
            
            let alert = UIAlertController(title: "Success", message: "You are a premium member", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let productID:NSSet = NSSet(object: self.productId);
        let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>);
        productsRequest.delegate = self;
        productsRequest.start()
        
        let transferSwitchVal = NSUserDefaults.standardUserDefaults().boolForKey("transferNews")
        let newsSwitchVal = NSUserDefaults.standardUserDefaults().boolForKey("scores")
        let updateSwitchVal = NSUserDefaults.standardUserDefaults().boolForKey("autoUpdate")
        
        transferSwitch.setOn(transferSwitchVal, animated: false)
        newsSwitch.setOn(newsSwitchVal, animated: false)
        updateFeedsSwitch.setOn(updateSwitchVal, animated: false)
        
        if NSUserDefaults.standardUserDefaults().boolForKey("premium") {
            self.premiumLabel.text = "You are a premium member"
            self.premiumCell.accessoryType = .None
            
            self.restoreButton.enabled = false
        }
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Settings")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        GAI.sharedInstance().dispatch()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func buyPremium(indexPath: NSIndexPath) {
        PFPurchase.buyProduct("evertonNewsPremium") {
            (error: NSError?) -> Void in
            if error == nil {
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                self.premiumLabel.text = "You are a premium member"
                self.premiumCell.accessoryType = .None
            }
        }
    }
    
    @IBAction func restore(sender: AnyObject) {
        if !NSUserDefaults.standardUserDefaults().boolForKey("premium") {
            PFPurchase.restore()
        }
    }
    
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        let count : Int = response.products.count
        if (count>0) {
            let validProduct: SKProduct = response.products[0] as SKProduct
            if (validProduct.productIdentifier == self.productId) {
                if !NSUserDefaults.standardUserDefaults().boolForKey("premium") {
                    let formatter = NSNumberFormatter()
                    formatter.numberStyle = .CurrencyStyle
                    formatter.locale = validProduct.priceLocale
                    let price = formatter.stringFromNumber(validProduct.price)!
                    self.premiumLabel.text = "Upgrade to premium (\(price))"
                }
            }
        } else {
            print("nothing")
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section != 2 {
            return nil
        } else if indexPath.section == 2 && indexPath.row == 0 {
            if !NSUserDefaults.standardUserDefaults().boolForKey("premium") {
                self.buyPremium(indexPath)
                return indexPath
            }
            return nil
        } else {
            return indexPath
        }
    }

}
