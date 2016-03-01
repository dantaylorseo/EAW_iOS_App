//
//  Stories.swift
//  EvertonNewsApp
//
//  Created by Dan Taylor on 08/01/2016.
//  Copyright © 2016 Dan Taylor. All rights reserved.
//

import Foundation
import CoreData

class Stories2: NSManagedObject {
    
    @NSManaged var title: String!
    @NSManaged var date: NSDate!
    @NSManaged var author: String!
    @NSManaged var site: String!
    @NSManaged var category: String!
    @NSManaged var link: String!
    @NSManaged var content: String!
    @NSManaged var desc: String!
    @NSManaged var image: String?
    @NSManaged var thumb: String?
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, title: String, date: NSDate, author: String, site: String, category: String, link: String, content: String, desc: String, image: String, thumb: String) -> Stories {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Stories", inManagedObjectContext: moc) as! Stories
        newItem.title = title
        newItem.date = date
        newItem.author = author
        newItem.site = site
        newItem.category = category
        newItem.link = link
        newItem.content = content
        newItem.desc = desc
        newItem.image = image
        newItem.thumb = thumb
        
        return newItem
    }
}
