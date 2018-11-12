//
//  Sounds+CoreDataProperties.swift
//  TravelChronicle
//
//  Created by M Aslam on 2017-09-27.
//  Copyright © 2017 M Aslam. All rights reserved.
//
//

import Foundation
import CoreData


extension Sounds {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sounds> {
        return NSFetchRequest<Sounds>(entityName: "Sounds")
    }

    @NSManaged public var destinationName: String?
    @NSManaged public var destinationSoundTitle: String?
    @NSManaged public var destinationSoundURL: String?

}
