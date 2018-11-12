//
//  Destinations+CoreDataProperties.swift
//  TravelChronicle
//
//  Created by M Aslam on 2017-09-27.
//  Copyright © 2017 M Aslam. All rights reserved.
//
//

import Foundation
import CoreData


extension Destinations {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Destinations> {
        return NSFetchRequest<Destinations>(entityName: "Destinations")
    }

    @NSManaged public var destinationLatitude: Double
    @NSManaged public var destinationLongitude: Double
    @NSManaged public var destinationName: String
    @NSManaged public var destinationNotes: String
    @NSManaged public var destinationShow: Bool
    @NSManaged public var destinationType: String

}
