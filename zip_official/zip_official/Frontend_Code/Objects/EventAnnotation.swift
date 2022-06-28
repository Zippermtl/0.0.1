//
//  Events.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/3/21.
//

import Foundation
import MapKit



class EventAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var event: Event

    init(event: Event){
        self.event = event
        coordinate = event.coordinates.coordinate
        super.init()
    }
}


class EventAnnotationView: MKAnnotationView {
    static let length: CGFloat = 60
    
    private let containingView: UIView
    private var ring: UIImageView
    private var eventImage: UIImageView
    private var liveLabel: IconLabel
    private var labelBG: UIView
    
    private var ringColor: UIColor
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        self.containingView = UIView()
        self.ring = UIImageView()
        self.ringColor = .white
        ring.image = UIImage(named: "EventAnnotationRing")?.withTintColor(ringColor)
        self.eventImage = UIImageView()
        self.labelBG = UIView()
        self.liveLabel = IconLabel(iconImage: nil, labelFont: .zipBodyBold.withSize(6), color: .white)

        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: EventAnnotationView.length, height: EventAnnotationView.length)
        centerOffset = CGPoint(x: -EventAnnotationView.length/2, y: -EventAnnotationView.length/2)
        
        
        
        addSubviews()
        configureSubviews()
    }
    
    init(annotation: MKAnnotation?, reuseIdentifier: String?, ringColor: UIColor) {
        self.containingView = UIView()
        self.ring = UIImageView()
        self.ringColor = ringColor
        ring.image = UIImage(named: "EventAnnotationRing")?.withTintColor(ringColor)
        self.eventImage = UIImageView()
        self.labelBG = UIView()
        self.liveLabel = IconLabel(iconImage: nil, labelFont: .zipBodyBold.withSize(6), color: .white)
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: EventAnnotationView.length, height: EventAnnotationView.length)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
        
        addSubviews()
        configureSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func addSubviews(){
        addSubview(containingView)
        containingView.addSubview(ring)
        containingView.addSubview(eventImage)
        containingView.addSubview(labelBG)
        containingView.addSubview(liveLabel)
    }
    
    private func configureSubviews(){
        print("configuring")
        containingView.frame = bounds

        ring.translatesAutoresizingMaskIntoConstraints = false
        ring.bottomAnchor.constraint(equalTo: containingView.bottomAnchor).isActive = true
        ring.topAnchor.constraint(equalTo: containingView.topAnchor).isActive = true
        ring.rightAnchor.constraint(equalTo: containingView.rightAnchor).isActive = true
        ring.leftAnchor.constraint(equalTo: containingView.leftAnchor).isActive = true

        eventImage.frame = CGRect(x: 7, y: 7, width: EventAnnotationView.length-14, height: EventAnnotationView.length-14)
        
        labelBG.translatesAutoresizingMaskIntoConstraints = false
        labelBG.bottomAnchor.constraint(equalTo: containingView.bottomAnchor).isActive = true
        labelBG.centerXAnchor.constraint(equalTo: containingView.centerXAnchor).isActive = true
        labelBG.widthAnchor.constraint(equalToConstant: 24).isActive = true
        labelBG.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        labelBG.layer.masksToBounds = true
        labelBG.layer.cornerRadius = 4
        labelBG.backgroundColor = ringColor
        
        liveLabel.translatesAutoresizingMaskIntoConstraints = false
        liveLabel.bottomAnchor.constraint(equalTo: labelBG.bottomAnchor, constant: 2).isActive = true
        liveLabel.centerXAnchor.constraint(equalTo: containingView.centerXAnchor).isActive = true

        liveLabel.numberOfLines = 1
        
        containingView.bringSubviewToFront(liveLabel)

        eventImage.layer.masksToBounds = true
        eventImage.layer.cornerRadius = (EventAnnotationView.length-14)/2
    }
    
    
    public func configure(event: Event) {
        eventImage.sd_setImage(with: event.imageUrl, completed: nil)
        
        if event.startTime < Date() {
            liveLabel.update(string: "LIVE")
            let small = UIImage.SymbolConfiguration(pointSize: 6, weight: .bold, scale: .small)
            liveLabel.setIcon(newIcon: UIImage(systemName: "circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.red).withConfiguration(small))
            liveLabel.sizeToFit()
        }
    }
    
    public func updateSize(scale: CGFloat){
        
        transform = CGAffineTransform(scaleX: scale, y: scale)
        centerOffset = CGPoint(x: -(EventAnnotationView.length/2)*scale, y: -(EventAnnotationView.length/2)*scale)

//        frame = CGRect(x: 0, y: 0, width: EventAnnotationView.length * scale, height: EventAnnotationView.length * scale)
//        containingView.frame = frame
//        eventImage.frame = CGRect(x: 7 * scale, y: 7 * scale, width: (EventAnnotationView.length-14) * scale, height: (EventAnnotationView.length-14) * scale)
//        eventImage.layer.cornerRadius = ((EventAnnotationView.length-14) * scale)/2
////        centerOffset = CGPoint(x: -frame.size.width/2, y: -frame.size.height/2)
//        print("SCALE = \(scale)")
    }
    
}


class PromoterEventAnnotationView: EventAnnotationView {
    static let identifier = "promoter"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier, ringColor: .zipGreen)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class PrivateEventAnnotationView: EventAnnotationView {
    static let identifier = "zips"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier, ringColor: .zipBlue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
