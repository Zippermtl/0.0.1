//
//  ClusterAnnotation.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 9/12/22.
//

import Foundation
import UIKit
import MapKit

class EventClusterAnnotation : MKClusterAnnotation {
    init(eventAnnotations : [EventAnnotation]) {
        super.init(memberAnnotations: eventAnnotations)
    }
}

class HappeningsClusterAnnotation : MKClusterAnnotation {
    init(eventAnnotations : [EventAnnotation]) {
        super.init(memberAnnotations: eventAnnotations)
    }
}

class EventClusterAnnotationView : MKAnnotationView {
    static let identifier = "eventCluster"
   
    override var annotation: MKAnnotation? {
        didSet {
            config()
        }
    }
    
    var countLabel: UILabel
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        countLabel = UILabel.zipSubtitle2()
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        addSubview(countLabel)

        config()
    }
    
    private func config() {
        frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        layer.masksToBounds = true
        layer.cornerRadius = 15
        canShowCallout = false
        clusteringIdentifier = Self.identifier
        displayPriority = .required
        zPriority = .defaultSelected

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 4)
        layer.shadowRadius = 2
        countLabel.textAlignment = .center
        
        guard let annotation = annotation as? MKClusterAnnotation else {
            return
        }
        countLabel.text = annotation.memberAnnotations.count.description
        
        if let eventAnnotations = annotation.memberAnnotations as? [EventAnnotation] {
            for event in eventAnnotations.map({ $0.event }) {
                if event is PromoterEvent {
                    backgroundColor = .zipYellow
                    countLabel.textColor = .black

                    return
                }
            }
            countLabel.textColor = .white
            backgroundColor = .zipBlue
            
        } else {
            countLabel.textColor = .zipGray
            backgroundColor = .black
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        countLabel.frame = bounds
    }
}


class HappeningsClusterAnnotationView : MKAnnotationView {
    static let identifier = "HappenignsCluster"
    var countLabel: UILabel
   
    override var annotation: MKAnnotation? {
        didSet {
            guard let cluster = annotation as? MKClusterAnnotation else { return }
            displayPriority = .defaultHigh
            zPriority = .defaultUnselected
            countLabel.text = cluster.memberAnnotations.count.description
            clusteringIdentifier = Self.identifier
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        countLabel = UILabel.zipSubtitle2()
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        layer.masksToBounds = true
        layer.cornerRadius = 10
        backgroundColor = .zipRed
        addSubview(countLabel)
        canShowCallout = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 4)
        layer.shadowRadius = 2
        countLabel.textAlignment = .center
        countLabel.textColor = .white
        clusteringIdentifier = Self.identifier

        guard let annotation = annotation as? MKClusterAnnotation else {
            return
        }
        countLabel.text = annotation.memberAnnotations.count.description
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        countLabel.frame = bounds
    }
}
