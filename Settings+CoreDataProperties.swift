//
//  Settings+CoreDataProperties.swift
//  TravelChronicle
//
//  Created by M Aslam on 2017-09-27.
//  Copyright © 2017 M Aslam. All rights reserved.
//
//

import Foundation
import CoreData


extension Settings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Settings> {
        return NSFetchRequest<Settings>(entityName: "Settings")
    }

    @NSManaged public var showMyDestinations: Bool
    @NSManaged public var showPreloadedDestinations: Bool

}
