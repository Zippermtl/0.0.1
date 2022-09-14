//
//  Events.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/3/21.
//

import Foundation
import MapKit

protocol EventAnnotationDelegate : AnyObject {
    func selectEvent(for annotationView : EventAnnotationViewProtocol)
}

protocol EventAnnotationViewProtocol {
    
}

class EventAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var event: Event
    var viewFor: EventAnnotationView?

    init(event: Event){
        self.event = event
        coordinate = event.coordinates.coordinate
        super.init()
    }
    
    
    public func overlaps(annotation: EventAnnotation) -> Bool {
        guard let myView = viewFor,
              let otherView = annotation.viewFor
        else {
            return false
        }
        
        if myView.frame.contains(otherView.frame) {
            return true
        }
        return false

    }

}


class EventAnnotationView: MKAnnotationView, EventAnnotationViewProtocol {
    var view_length: CGFloat = 40
    var dot_length: CGFloat = 12
    weak var delegate: EventAnnotationDelegate?
    var isDot = false
    
    private var eventImage: UIButton
    private var dotView: UIView
    private var ringColor: UIColor = .black
    
    override var annotation: MKAnnotation? {
        didSet {
            self.clusteringIdentifier = EventClusterAnnotationView.identifier
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        if let eventAnnotation = annotation as? EventAnnotation {
            self.ringColor = eventAnnotation.event.getType().color
            print("event type = ", eventAnnotation.event.getType())
        }
        self.ringColor = .white
        self.eventImage = UIButton()
        self.dotView = UIView()
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.clusteringIdentifier = EventClusterAnnotationView.identifier
        initConfig()
    }
    
    init(annotation: MKAnnotation?, reuseIdentifier: String?, ringColor c: UIColor = .white, view_length v : CGFloat = 40, dot_length d : CGFloat = 12) {
        self.ringColor = c
        self.view_length = v
        self.dot_length = d
        self.eventImage = UIButton()
        self.dotView = UIView()
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        initConfig()
    }
    
    private func initConfig(){
        eventImage.addTarget(self, action: #selector(didTapEventImage), for: .touchUpInside)

        configureSubviews()
        addSubviews()
        configureSubviewLayout()
        
        clusteringIdentifier = EventClusterAnnotationView.identifier
        isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configureSubviews() {
        eventImage.backgroundColor = .zipLightGray
        frame = CGRect(x: 0, y: 0, width: view_length, height: view_length)
        layer.anchorPoint = CGPoint(x:0 , y: 0)
        
        centerOffset = CGPoint(x: -view_length/2, y: -view_length/2)
        dotView.backgroundColor = ringColor
        
        dotView.layer.masksToBounds = true
        dotView.layer.cornerRadius = dot_length/2
        dotView.layer.borderWidth = 1
        dotView.layer.borderColor = UIColor.white.cgColor

    
        eventImage.layer.masksToBounds = true
        eventImage.layer.cornerRadius = view_length/2
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
        eventImage.frame = bounds

        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        dotView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        dotView.widthAnchor.constraint(equalToConstant: dot_length).isActive = true
        dotView.heightAnchor.constraint(equalTo: dotView.widthAnchor).isActive = true
    }
    
    
    public func configure(event: Event) {
        if let eventAnnotation = annotation as? EventAnnotation {
            self.ringColor = eventAnnotation.event.getType().color
            print("event type = ", eventAnnotation.event.getType())
        }
        
        if let url = event.imageUrl {
            
            eventImage.sd_setImage(with: url, for: .normal, completed: nil)
        } else {
            let imageName = event.getType() == .Promoter ? "defaultPromoterEventProfilePic" : "defaultEventProfilePic"
            eventImage.setImage(UIImage(named: imageName), for: .normal)
        }
        dotView.backgroundColor = ringColor
        dotView.isHidden = true
        eventImage.layer.borderColor = ringColor.cgColor
        eventImage.layer.borderWidth = 2
    }
    
    public func updateImage(_ url: URL) {
        eventImage.sd_setImage(with: url, for: .normal, completed: nil)
    }
    
    public func updateSize(scale: CGFloat){
        eventImage.isHidden = false
        dotView.isHidden = true
        transform = CGAffineTransform(scaleX: scale, y: scale)
        centerOffset = CGPoint(x: -(view_length)*scale, y: -(view_length/2)*scale)
    }
    
    public func makeDot(){
        eventImage.isHidden = true
        dotView.isHidden = false
        isDot = true
        transform = CGAffineTransform(scaleX: 1, y: 1)
//        centerOffset = CGPoint(x: -view_length/2, y: -view_length/2)
        layer.shadowColor = UIColor.clear.cgColor
    }
    
    public func makeEvent() {
        isDot = false
        eventImage.isHidden = false
        dotView.isHidden = true
        layer.shadowColor = UIColor.black.cgColor

    }
    
    @objc private func didTapEventImage() {
        delegate?.selectEvent(for: self)
    }
    
    
}


class PromoterEventAnnotationView: EventAnnotationView {
    static let identifier = "promoter"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier, ringColor: .zipYellow, view_length: 60, dot_length: 16)
        clusteringIdentifier = EventClusterAnnotationView.identifier

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class UserEventAnnotationView: EventAnnotationView {
    static let identifier = "pubic"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier, ringColor: .zipBlue, view_length: 40, dot_length: 12)
        clusteringIdentifier = EventClusterAnnotationView.identifier
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
