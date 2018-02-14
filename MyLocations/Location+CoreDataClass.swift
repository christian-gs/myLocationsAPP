//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by Christian on 2/13/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject, MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    public var title: String? {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }
    public var subtitle: String? {
        return category
    }


}
