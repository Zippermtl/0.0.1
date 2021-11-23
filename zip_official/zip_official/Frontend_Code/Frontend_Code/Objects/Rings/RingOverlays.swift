//
//  RingOverlays.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/23/21.
//

import Foundation
import MapKit

class RingOverlay: NSObject, MKOverlay {
    let coordinate: CLLocationCoordinate2D
    let boundingMapRect: MKMapRect
    let title: String?
    
    init(ring: Ring){
        boundingMapRect = ring.overlayBoundingMapRect
        coordinate = ring.midCoordinate
        title = ring.title
    }
   
   
}

