//
//  File.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 9/10/22.
//

import Foundation
import UIKit
import MapKit


class RecurringEventAnnotationView: MKAnnotationView, EventAnnotationViewProtocol {
    static let identifier = "happeningsAnnotationView"
    weak var delegate: EventAnnotationDelegate?

    var isVisible = false
    
    private var eventImage: UIImageView
    
    override var annotation: MKAnnotation? {
        didSet {
            self.clusteringIdentifier = HappeningsClusterAnnotationView.identifier
        }
    }
    
    func getEvent() -> Event {
        guard let eventAnnotation = annotation as? EventAnnotation else {
            return Event()
        }
        return eventAnnotation.event
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        self.eventImage = UIImageView()
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        addSubview(eventImage)
        eventImage.frame = bounds
        eventImage.contentMode = .scaleAspectFit
        eventImage.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(openEvent))
        eventImage.addGestureRecognizer(tap)
        clusteringIdentifier = HappeningsClusterAnnotationView.identifier
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 4)
        layer.shadowRadius = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func openEvent() {
        print("tapping")
        delegate?.selectEvent(for: self)
    }
    
    public func configure(event: RecurringEvent) {
        eventImage.image = UIImage(named: event.category.imageName)
    }
    
    public func hide(){
        eventImage.isHidden = true
        isVisible = false
    }
    
    public func show() {
        eventImage.isHidden = false
        isVisible = true
    }
    
}
