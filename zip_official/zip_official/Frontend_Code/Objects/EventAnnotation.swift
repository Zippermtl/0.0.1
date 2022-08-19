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
    static let VIEW_LENGTH: CGFloat = 40
    static let DOT_LENGTH: CGFloat = 12
    
    private var eventImage: UIImageView
    private var dotView: UIView
    private var ringColor: UIColor
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        self.ringColor = .white
        self.eventImage = UIImageView()
        self.dotView = UIView()

        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
       
        configureSubviews()
        addSubviews()
        configureSubviewLayout()
    }
    
    init(annotation: MKAnnotation?, reuseIdentifier: String?, ringColor: UIColor) {
        self.ringColor = ringColor
        self.eventImage = UIImageView()
        self.dotView = UIView()
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        configureSubviews()
        addSubviews()
        configureSubviewLayout()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSubviews() {
        frame = CGRect(x: 0, y: 0, width: EventAnnotationView.VIEW_LENGTH, height: EventAnnotationView.VIEW_LENGTH)
        layer.anchorPoint = CGPoint(x:0 , y: 0)
        
        centerOffset = CGPoint(x: -EventAnnotationView.VIEW_LENGTH/2, y: -EventAnnotationView.VIEW_LENGTH/2)
        dotView.backgroundColor = ringColor
        
        dotView.layer.masksToBounds = true
        dotView.layer.cornerRadius = EventAnnotationView.DOT_LENGTH/2
        dotView.layer.borderWidth = 1
        dotView.layer.borderColor = UIColor.white.cgColor

    
        eventImage.layer.masksToBounds = true
        eventImage.layer.cornerRadius = EventAnnotationView.VIEW_LENGTH/2
        eventImage.layer.borderColor = ringColor.cgColor
        eventImage.layer.borderWidth = 1
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 4)
        layer.shadowRadius = 2
    }
    
    private func addSubviews(){
        addSubview(eventImage)
        addSubview(dotView)
    }
    
    private func configureSubviewLayout(){
        print("configuring")
        eventImage.frame = bounds

        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        dotView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        dotView.widthAnchor.constraint(equalToConstant: EventAnnotationView.DOT_LENGTH).isActive = true
        dotView.heightAnchor.constraint(equalTo: dotView.widthAnchor).isActive = true
    }
    
    
    public func configure(event: Event) {
        eventImage.sd_setImage(with: event.imageUrl, completed: nil)
        dotView.backgroundColor = ringColor
        dotView.isHidden = true
        eventImage.layer.borderColor = ringColor.cgColor
        eventImage.layer.borderWidth = 2
    }
    
    public func updateImage(_ url: URL) {
        eventImage.sd_setImage(with: url, completed: nil)
    }
    
    public func updateSize(scale: CGFloat){
        eventImage.isHidden = false
        dotView.isHidden = true
        transform = CGAffineTransform(scaleX: scale, y: scale)
        centerOffset = CGPoint(x: -(EventAnnotationView.VIEW_LENGTH/2)*scale, y: -(EventAnnotationView.VIEW_LENGTH/2)*scale)
    }
    
    public func makeDot(){
        eventImage.isHidden = true
        dotView.isHidden = false
        transform = CGAffineTransform(scaleX: 1, y: 1)
        centerOffset = CGPoint(x: -EventAnnotationView.VIEW_LENGTH/2, y: -EventAnnotationView.VIEW_LENGTH/2)
        layer.shadowColor = UIColor.clear.cgColor
    }
    
    public func makeEvent() {
        eventImage.isHidden = false
        dotView.isHidden = true
        layer.shadowColor = UIColor.black.cgColor

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
    static let identifier = "private"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier, ringColor: .zipBlue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PublicEventAnnotationView: EventAnnotationView {
    static let identifier = "pubic"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier, ringColor: .zipGreen)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
