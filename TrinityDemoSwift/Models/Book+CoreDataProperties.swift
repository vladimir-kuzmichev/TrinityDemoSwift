//
//  Book+CoreDataProperties.swift
//  
//
//  Created by Vladimir Kuzmichev on 09.06.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Book {

    @NSManaged var author: String?
    @NSManaged var desc: String?
    @NSManaged var itemId: String?
    @NSManaged var thumbnailUrl: String?
    @NSManaged var title: String?

}
