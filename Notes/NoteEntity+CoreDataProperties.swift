//
//  NoteEntity+CoreDataProperties.swift
//  Notes
//
//  Created by Алексей Лопух on 12.10.2017.
//  Copyright © 2017 Алексей Лопух. All rights reserved.
//
//

import Foundation
import CoreData


extension NoteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteEntity> {
        return NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
    }

    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var date: String?
    @NSManaged public var uid: String?

}
