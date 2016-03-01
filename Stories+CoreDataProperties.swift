//
//  Stories+CoreDataProperties.swift
//  iOSNewsApp
//
//  Created by Dan Taylor on 27/01/2016.
//  Copyright © 2016 Dan Taylor. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Stories {

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

}
