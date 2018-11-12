//
//  Videos+CoreDataProperties.swift
//  TravelChronicle
//
//  Created by M Aslam on 2017-09-27.
//  Copyright © 2017 M Aslam. All rights reserved.
//
//

import Foundation
import CoreData


extension Videos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Videos> {
        return NSFetchRequest<Videos>(entityName: "Videos")
    }

    @NSManaged public var destinationName: String?
    @NSManaged public var destinationVideoURL: String?

}
