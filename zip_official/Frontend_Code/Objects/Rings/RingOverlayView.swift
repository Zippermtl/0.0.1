//
//  RingOverlayView.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/25/21.
//

import Foundation
import MapKit

class RingOverlayView: MKOverlayRenderer {
    let overlayImage: UIImage
    
    
    init(overlay: MKOverlay, overlayImage: UIImage) {
        self.overlayImage = overlayImage
        super.init(overlay: overlay)
    }
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard let imageReference = overlayImage.cgImage else { return }
        
        let rect = self.rect(for: overlay.boundingMapRect)
//        context.translateBy(x: 0, y: -rect.size.height)
        context.draw(imageReference, in: rect)
        
    }
    
    
}
