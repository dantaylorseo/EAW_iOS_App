//
//  DataModel.swift
//  iOSNewsApp
//
//  Created by Dan Taylor on 26/01/2016.
//  Copyright © 2016 Dan Taylor. All rights reserved.
//

import Foundation
import Parse
import SwiftyJSON

class StoriesDataModel {
    
    // MARK: - Actions, Oulets, Variables & Constants
    var stories = [Stories]()
    var storiesUrl = Settings().jsonStoriesUrl
    
    let center = NSNotificationCenter.defaultCenter()
    
    var itemCount = 0
    var loop = 0
    
    // MARK: - init
    init() {
        let appBuild = NSUserDefaults.standardUserDefaults().stringForKey("appBuild")
        if appBuild !=  NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            self.deleteData()
            print("Deleting data...")
            NSUserDefaults.standardUserDefaults().setValue(NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String, forKey: "appBuild")
        } else {
            self.loadStories()
        }
        
    }
    
    // MARK: - Check for remote data and load stories
    func loadStories() {
        /*self.getLocalData()
        if Reach().checkOnline() {
            let modified = CheckDownload(url: self.storiesUrl)
            modified.check() { (isModified) in
                if isModified == true {
                    print("getting remote")
                    self.getRemoteData()
                } else {
                    self.getLocalData()
                    print("No data to fetch")
                }
            }
        } else {
            self.getLocalData()
        }
*/
    }
    
    // MARK: - Local Data
    func getLocalData() {
        stories.removeAll(keepCapacity: false)
        var i = 0
        let query = PFQuery(className: "Stories")
        query.fromLocalDatastore()
        query.orderByDescending("date")
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error) -> Void in
            if objects!.count == 0 {
                if Reach().checkOnline() {
                    self.getRemoteData()
                }
            } else {
                for object in objects! {
                    let story = Stories()
                    story.title = object.objectForKey("title") as! String
                    story.date = object.objectForKey("date") as! NSDate
                    story.author = object.objectForKey("author") as! String
                    story.site = object.objectForKey("site") as! String
                    story.category = object.objectForKey("category") as! String
                    story.link = object.objectForKey("link") as! String
                    story.content = object.objectForKey("content") as! String
                    story.desc = object.objectForKey("desc") as! String
                    story.image = object.objectForKey("image") as? String
                    story.thumb = object.objectForKey("thumb") as? String
                    self.stories.append(story)
                    i += 1
                    print("Loading story \(i) of \(objects!.count)")
                    if i == objects!.count {
                        self.center.postNotification(NSNotification(name: "ReloadAllStories", object: self))
                    }
                }
                
            }
        }
    }
    
    // MARK: - Remote Data
    func getRemoteData() {
        let request = NSMutableURLRequest(URL: NSURL(string: Settings().jsonStoriesUrl)!)
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        let session = NSURLSession(configuration: configuration)
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                self.center.postNotification(NSNotification(name: "LoadingAllStories", object: self))
                let json = JSON(data: data!)
                if let items = json.array {
                    self.itemCount = items.count
                    self.loop = 0
                    for item in items {
                        let story = Stories()
                        
                        let dateFormatter = NSDateFormatter()
                        
                        dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss Z"
                        dateFormatter.locale = NSLocale(localeIdentifier: "en-GB")
                        let date = dateFormatter.dateFromString(item["pubDate"].string!)
                        
                        story.title     = item["title"].string
                        story.date      = date
                        story.author    = item["author"].string
                        story.site      = item["feedtitle"].string
                        story.category  = item["category"].string
                        story.link      = item["link"].string
                        story.content   = item["content"].string
                        story.desc      = item["description"].string
                        story.image     = item["image"].string
                        story.thumb     = item["thumbnail"].string
                        
                        
                        self.findOrInsertStory(story)
                        
                    }
                }
            })
            
        }
        task.resume()
        
    }
    
    func findOrInsertStory(story: Stories) {
        let query = PFQuery(className: "Stories")
        query.fromLocalDatastore()
        query.whereKey("link", equalTo:story.link)
        query.countObjectsInBackgroundWithBlock { (count, error) -> Void in
            self.loop += 1
            if count == 0 {
                let saveStory = PFObject(className: "Stories")
                saveStory["title"] = story.title
                saveStory["date"] = story.date
                saveStory["author"] = story.author
                saveStory["site"] = story.site
                saveStory["category"] = story.category
                saveStory["link"] = story.link
                saveStory["content"] = story.content
                saveStory["desc"] = story.desc
                if story.image != nil {
                    saveStory["image"] = story.image
                } else {
                    saveStory["image"] = ""
                }
                if story.thumb != nil {
                    saveStory["thumb"] = story.thumb
                } else {
                    saveStory["thumb"] = ""
                }
                
                saveStory.pinInBackground()
            }
            
            //print("Saved or skipped \(self.loop) of \(self.itemCount)")
            if self.loop == self.itemCount {
                self.center.postNotification(NSNotification(name: "FinishedRemote", object: self))
            }
        }
        
    }

    // MARK: - Delete Data
    func deleteData() {
        let query = PFQuery(className: "Stories")
        query.fromLocalDatastore()
        query.findObjectsInBackgroundWithBlock{
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                print("Objects to delete: \(objects!.count)")
                if let objects = objects {
                    PFObject.unpinAllInBackground(objects, block: { (success, error) -> Void in
                        if success {
                            self.loadStories()
                            //self.center.postNotification(NSNotification(name: "ReloadAllStories", object: self))
                        }
                    })
                }
            }
        }
    }
    
}