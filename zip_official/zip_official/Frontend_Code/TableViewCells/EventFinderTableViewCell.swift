//
//  EventFinderTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/12/21.
//

import UIKit
import MapKit
import CoreLocation

class EventFinderTableViewCell: UITableViewCell {
    static let identifier = "eventCell"
    weak var delegate: UpdateZipRequestsTableDelegate?
    
    
    var event: Event?
    
    //MARK: - Subviews
    private let bgView: UIView
    private let eventImage: UIImageView
    
    // Buttons
    private let goingButton: UIButton
    private let interestedButton: UIButton
    
    //Labels
    private var titleLabel: UILabel
    private let participantsLabel: UILabel
    private var distanceLabel: DistanceLabel
    private var dateLabel: IconLabel
    private var timeLabel: IconLabel
    
    
    @objc private func openEvent(){
        
    }
    
    @objc private func didTapInterestedButton(){
        print("Interested tapped")
        delegate?.deleteEventsRow(interestedButton)
    }
    
    @objc private func didTapGoingButton() {
        print("Going tapped")
        delegate?.deleteEventsRow(goingButton)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.bgView = UIView()
        self.eventImage = UIImageView()
        self.goingButton = UIButton()
        self.interestedButton = UIButton()
        self.titleLabel = UILabel.zipTextNotiBold()
        self.participantsLabel = UILabel.zipTextDetail()
        
        let smallConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold, scale: .small)

        self.distanceLabel = DistanceLabel(labelFont: .zipTextDetail, color: .zipVeryLightGray, config: smallConfig)
        self.timeLabel = IconLabel(iconImage: UIImage(systemName: "clock.fill")?.withConfiguration(smallConfig), labelFont: .zipTextDetail, color: .zipVeryLightGray)
        self.dateLabel = IconLabel(iconImage: UIImage(systemName: "calendar")?.withConfiguration(smallConfig), labelFont: .zipTextDetail, color: .zipVeryLightGray)

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        eventImage.isUserInteractionEnabled = true

        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
        let goingIcon = UIImage(systemName: "checkmark.circle.fill", withConfiguration: largeConfig)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.zipYellow)
        goingButton.setImage(goingIcon, for: .normal)
        
 
        let interestedIcon = UIImage(systemName: "xmark.circle.fill", withConfiguration: largeConfig)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.zipVeryLightGray)
        interestedButton.setImage(interestedIcon, for: .normal)
        
        configureBackground()
        addSubviews()
        configureSubviewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Config
    public func configure(_ event: Event){
        backgroundColor = .clear
        self.event = event
        
        interestedButton.addTarget(self, action: #selector(didTapInterestedButton), for: .touchUpInside)
        goingButton.addTarget(self, action: #selector(didTapGoingButton), for: .touchUpInside)
        
        configureImage()
        configureLabels()
    }
    
    //MARK: - Background Config
    private func configureBackground(){
        contentView.addSubview(bgView)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 5).isActive = true
        bgView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).isActive = true
        bgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true

        bgView.layer.cornerRadius = 10
        bgView.backgroundColor = .zipLightGray
    }
    
    //MARK: - Label Config
    private func configureLabels(){
        guard let event = event else {
            return
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openEvent))
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(tap)
        
        titleLabel.text = event.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        dateLabel.update(string:  " " + dateFormatter.string(from: event.startTime))
        
        dateFormatter.dateFormat = "h:mm a"
        timeLabel.update(string: " " + dateFormatter.string(from: event.startTime))
        
        let eventLoc = CLLocation(latitude: event.coordinates.coordinate.latitude, longitude: event.coordinates.coordinate.longitude)
        distanceLabel.update(location: eventLoc)
        
        
        participantsLabel.text = String(event.usersGoing.count) + "/" + String(event.maxGuests) + "\ngoing"
        
        participantsLabel.textAlignment = .right
        
        participantsLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    }
    
    //MARK: - Image Config
    private func configureImage() {
        guard let event = event else {
            return
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openEvent))
        eventImage.addGestureRecognizer(tap)
        
        eventImage.image = event.image

        eventImage.translatesAutoresizingMaskIntoConstraints = false
        eventImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        eventImage.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5).isActive = true
        eventImage.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 10).isActive = true
        eventImage.widthAnchor.constraint(equalTo: eventImage.heightAnchor).isActive = true
        
        eventImage.layer.masksToBounds = true
        eventImage.layer.cornerRadius = contentView.frame.height/4
        
        eventImage.layer.borderWidth = 2
        eventImage.layer.borderColor = UIColor.zipYellow.cgColor
    }
    
    //MARK: - Add Subviews
    private func addSubviews(){
        bgView.addSubview(eventImage)
        bgView.addSubview(titleLabel)
        
        
        bgView.addSubview(distanceLabel)
        bgView.addSubview(dateLabel)
        bgView.addSubview(timeLabel)
        
       

        bgView.addSubview(participantsLabel)
        bgView.addSubview(goingButton)
        bgView.addSubview(interestedButton)


        
    }
    
    //MARK: - Layout Constraints
    private func configureSubviewLayout(){
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: eventImage.rightAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: participantsLabel.leftAnchor, constant: -5).isActive = true

        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5).isActive = true
        distanceLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor).isActive = true
        dateLabel.leftAnchor.constraint(equalTo: distanceLabel.leftAnchor).isActive = true

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: distanceLabel.leftAnchor).isActive = true
        
        participantsLabel.translatesAutoresizingMaskIntoConstraints = false
        participantsLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
        participantsLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true

        goingButton.translatesAutoresizingMaskIntoConstraints = false
        goingButton.rightAnchor.constraint(equalTo: participantsLabel.rightAnchor).isActive = true
        goingButton.topAnchor.constraint(equalTo: participantsLabel.bottomAnchor, constant: 10).isActive = true
        
        interestedButton.translatesAutoresizingMaskIntoConstraints = false
        interestedButton.topAnchor.constraint(equalTo: goingButton.topAnchor).isActive = true
        interestedButton.rightAnchor.constraint(equalTo: goingButton.leftAnchor, constant: -7).isActive = true

    }
}
