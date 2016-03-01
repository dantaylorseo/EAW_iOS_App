//
//  StoriesCDModel.swift
//  iOSNewsApp
//
//  Created by Dan Taylor on 27/01/2016.
//  Copyright © 2016 Dan Taylor. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

class StoriesCDModel {

    var stories:[Stories]!
    var storiesUrl = Settings().jsonStoriesUrl
    
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    let center = NSNotificationCenter.defaultCenter()
    
    var itemCount = 0
    var loop = 0

    
    init() {
        let appBuild = NSUserDefaults.standardUserDefaults().stringForKey("appBuild")
        if appBuild !=  NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            self.deleteData()
            print("Deleting data...")
            NSUserDefaults.standardUserDefaults().setValue(NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String, forKey: "appBuild")
        }
        self.getRemoteData()
    }
    
    // MARK: - Check for remote data and load stories
    func loadStories() {
        
        self.getLocalData()
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
    }
    
    func getLocalData() {
        let fetchRequest = NSFetchRequest(entityName: "Stories")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var fetchResults:[Stories]!
        do {
            fetchResults = try self.managedContext.executeFetchRequest(fetchRequest) as! [Stories]
            self.stories = fetchResults
            if fetchResults.count > 0 {
                self.center.postNotification(NSNotification(name: "ReloadAllStories", object: self))
            } else {
                if Reach().checkOnline() {
                    self.getRemoteData()
                }
            }
        } catch {
            print("Error fetching Stories")
        }
    }
    
    func getRemoteData() {
        let request = NSMutableURLRequest(URL: NSURL(string: Settings().jsonStoriesUrl)!)
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        let session = NSURLSession(configuration: configuration)
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            if data != nil {
                dispatch_async(dispatch_get_main_queue(), {
                        let json = JSON(data: data!)
                        if let items = json.array {
                            self.itemCount = items.count
                            self.loop = 0
                            for item in items {
                                
                                let dateFormatter = NSDateFormatter()
                                
                                dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss Z"
                                dateFormatter.locale = NSLocale(localeIdentifier: "en-GB")
                                let date = dateFormatter.dateFromString(item["pubDate"].string!)
                                
                                let fetchRequest = NSFetchRequest(entityName: "Stories")
                                let predicate = NSPredicate(format: "link == %@", item["link"].string!)
                                fetchRequest.predicate = predicate
                                var fetchResults = [NSObject]()
                                do{
                                    fetchResults = try self.managedContext.executeFetchRequest(fetchRequest) as! [Stories]
                                    if fetchResults.count > 0 {
                                        //print("Should Skip")
                                    } else {
                                        let entity =  NSEntityDescription.entityForName("Stories", inManagedObjectContext:self.managedContext)
                                        
                                        let story = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.managedContext)
                                        
                                        story.setValue(item["title"].string, forKey: "title")
                                        story.setValue(date, forKey: "date")
                                        story.setValue(item["author"].string, forKey: "author")
                                        story.setValue(item["feedtitle"].string, forKey: "site")
                                        story.setValue(item["category"].string, forKey: "category")
                                        story.setValue(item["link"].string, forKey: "link")
                                        story.setValue(item["content"].string, forKey: "content")
                                        story.setValue(item["description"].string, forKey: "desc")
                                        story.setValue(item["image"].string, forKey: "image")
                                        story.setValue(item["thumbnail"].string, forKey: "thumb")
                                        
                                        do {
                                            try self.managedContext.save()
                                            print("Inserted")
                                        } catch let error as NSError  {
                                            print("Could not save \(error), \(error.userInfo)")
                                        }
                                    }
                                    
                                } catch {
                                    print("Error")
                                }
                            }
                        }
                        self.center.postNotification(NSNotification(name: "ReloadAllStories", object: self))
                    })
            
            }
        }
        task.resume()
    }
    
    func deleteData() {
        let fetchRequest = NSFetchRequest(entityName: "Stories")
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:Stories = managedObject as! Stories
                managedContext.deleteObject(managedObjectData)
            }
            if Reach().checkOnline() {
                self.getRemoteData()
            }
        } catch let error as NSError {
            print("Delete all data in Stories error : \(error) \(error.userInfo)")
        }
    }
    
}