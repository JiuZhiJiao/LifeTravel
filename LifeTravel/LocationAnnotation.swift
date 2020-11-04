//
//  LocationAnnotation.swift
//  LifeTravel
//
//  Created by JiuZhiJiao on 4/11/20.
//  Copyright © 2020 JiuZhiJiao. All rights reserved.
//

import UIKit
import MapKit

class LocationAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    // title: location name
    var title: String?
    // subtitle: date
    var subtitle: String?
    var note: Note?
    
    init(note: Note) {
        self.title = note.location ?? "No Name"
        self.subtitle = note.date ?? "No Date"
        self.note = note
        coordinate = CLLocationCoordinate2D(latitude: note.lat, longitude: note.long)
    }
    
}
