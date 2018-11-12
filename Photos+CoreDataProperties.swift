//
//  Photos+CoreDataProperties.swift
//  TravelChronicle
//
//  Created by M Aslam on 2017-09-27.
//  Copyright © 2017 M Aslam. All rights reserved.
//
//

import Foundation
import CoreData


extension Photos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photos> {
        return NSFetchRequest<Photos>(entityName: "Photos")
    }

    @NSManaged public var destinationName: String?
    @NSManaged public var destinationPhoto: NSData?

}
