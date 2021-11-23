//
//  Rings.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/11/21.
//

import Foundation
import MapKit
import SwiftUI

class Ring {
    var title: String?
    var midCoordinate = CLLocationCoordinate2D()
    var overlayBoundingMapRect: MKMapRect
    
    init(title: String = "default", midCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)){
        
        switch title {
        case "ring1":
            overlayBoundingMapRect = Ring.MKMapRectForCoordinateRegion(region: MKCoordinateRegion(center: midCoordinate,
                                                                                                  latitudinalMeters: 4000,
                                                                                                  longitudinalMeters: 4000))
        case "ring2":
            overlayBoundingMapRect = Ring.MKMapRectForCoordinateRegion(region: MKCoordinateRegion(center: midCoordinate,
                                                                                                  latitudinalMeters: 10000,
                                                                                                  longitudinalMeters: 10000))
        case "ring3":
            overlayBoundingMapRect = Ring.MKMapRectForCoordinateRegion(region: MKCoordinateRegion(center: midCoordinate,
                                                                                                  latitudinalMeters: 20000,
                                                                                                  longitudinalMeters: 20000))
        default:
            overlayBoundingMapRect = MKMapRect()
        }
        self.title = title
        self.midCoordinate = midCoordinate
    }


    private static func MKMapRectForCoordinateRegion(region: MKCoordinateRegion) -> MKMapRect {
        let topLeft = CLLocationCoordinate2D(latitude: region.center.latitude + (region.span.latitudeDelta/2), longitude: region.center.longitude - (region.span.longitudeDelta/2))
        let bottomRight = CLLocationCoordinate2D(latitude: region.center.latitude - (region.span.latitudeDelta/2), longitude: region.center.longitude + (region.span.longitudeDelta/2))

        let a = MKMapPoint(topLeft)
        let b = MKMapPoint(bottomRight)

        return MKMapRect(origin: MKMapPoint(x:min(a.x,b.x), y:min(a.y,b.y)), size: MKMapSize(width: abs(a.x-b.x), height: abs(a.y-b.y)))
    }
    
}
