//
//  Note+CoreDataProperties.swift
//  LifeTravel
//
//  Created by JiuZhiJiao on 4/11/20.
//  Copyright © 2020 JiuZhiJiao. All rights reserved.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var content: String?
    @NSManaged public var date: String?
    @NSManaged public var photo: Data?
    @NSManaged public var location: String?
    @NSManaged public var lat: Double
    @NSManaged public var long: Double

}
