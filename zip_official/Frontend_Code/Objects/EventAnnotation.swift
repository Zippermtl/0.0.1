//
//  Events.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/3/21.
//

import Foundation
import MapKit



class EventAnnotation: NSObject, MKAnnotation {

    static let identifier = "event"
    var coordinate: CLLocationCoordinate2D
    var event: Event
    let title: String?
    let subtitle: String?
    
    
    init(
        event: Event,
        coordinate: CLLocationCoordinate2D
    ){
        self.event = event
        self.coordinate = coordinate
        self.title = event.title
        self.subtitle = event.description
        super.init()
    }
}
