//
//  ViewStoryViewController.swift
//  EvertonNewsApp
//
//  Created by Dan Taylor on 08/01/2016.
//  Copyright © 2016 Dan Taylor. All rights reserved.
//

import UIKit
import CoreData

class ViewStoryViewController: UIViewController, UIWebViewDelegate {
    
    var story:Stories!
    
    
    @IBOutlet weak var showShare: UIBarButtonItem!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    @IBOutlet weak var storyContent: UIWebView!
    @IBAction func shareButtonClicked(sender: AnyObject) {
        
        let textToShare = story.title
        
        if let myWebsite = NSURL(string: story.link)
        {
            let objectsToShare = [textToShare, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.barButtonItem = self.showShare
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        storyContent.scrollView.bounces = false;
        storyContent.scrollView.contentInset = UIEdgeInsetsZero
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        loading.hidden = false
        loading.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        loading.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !NSUserDefaults.standardUserDefaults().boolForKey("premium") {
            self.canDisplayBannerAds = true
        } else {
            self.canDisplayBannerAds = false
        }
        
        if story == nil {
            let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            
            let fetchRequest = NSFetchRequest(entityName: "Stories")
            let sortDescriptor1 = NSSortDescriptor(key: "date", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor1]
            
            let allStories = (try! managedContext.executeFetchRequest(fetchRequest)) as! [Stories]
            story = allStories.first! as Stories
        }
        storyContent.delegate = self
        if story != nil {
            print("view stories");
            let tracker = GAI.sharedInstance().defaultTracker
            tracker.set(kGAIScreenName, value: story.title)
            
            let builder = GAIDictionaryBuilder.createScreenView()
            tracker.send(builder.build() as [NSObject : AnyObject])
            GAI.sharedInstance().dispatch()
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "d MMM yyyy"
            let newdate = formatter.stringFromDate(story.date!)
            
            var storyHTML = "<html><head><link rel=\"stylesheet\" href=\"style.css\"><script src=\"https://platform.twitter.com/widgets.js\" type=\"text/javascript\"></script></head><body>"
            if story.image != nil {
                storyHTML = storyHTML + "<img src=\"\(story.image!)\" class=\"img-responsive\">"
            }
            storyHTML = storyHTML + "<div id=\"content\"><small>Posted by \(story.author) in \(story.category) on \(newdate)</small>"
            storyHTML = storyHTML + "<h1>\(story.title)</h1>"
            storyHTML = storyHTML + "\(story.content)</div>"
            storyHTML = storyHTML + "</body></html>"
            
            let cssFile = NSBundle.mainBundle().pathForResource("style", ofType: "css")
            let bundleURL = NSURL(fileURLWithPath: cssFile!)
            
            if Reach().checkOnline() {
                storyContent.loadRequest(NSURLRequest(URL: NSURL(string: story.link)!))
            } else {
                storyContent.loadHTMLString(storyHTML, baseURL: bundleURL)
            }
            title = story.title
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        self.navigationItem.leftItemsSupplementBackButton = true
        
        self.splitViewController?.preferredDisplayMode = .AllVisible
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("premium") {
            self.canDisplayBannerAds = true
        }
        
    }
    
}

extension UISplitViewController {
    func toggleMasterView() {
        var nextDisplayMode: UISplitViewControllerDisplayMode
        switch(self.preferredDisplayMode){
        case .PrimaryHidden:
            nextDisplayMode = .AllVisible
        default:
            nextDisplayMode = .PrimaryHidden
        }
        UIView.animateWithDuration(0.5) { () -> Void in
            self.preferredDisplayMode = nextDisplayMode
        }
    }
}
