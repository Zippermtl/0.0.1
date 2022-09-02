//
//  EventFinderTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/12/21.
//

import UIKit
import MapKit
import CoreLocation

//protocol OpenEventFromCellDelegate: AnyObject {
//    func openEvent()
//}

class AbstractEventTableViewCell: UITableViewCell {
    static let identifier = "abstractEventCell"
    
    var event: Event!
    
    //MARK: - Subviews
    let bgView: UIView
    let eventImage: UIImageView
    var cellHeight = 120
    
    var titleLabel: UILabel
    let participantsLabel: UILabel
    var distanceLabel: DistanceLabel
    var dateLabel: IconLabel
    var timeLabel: IconLabel
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.bgView = UIView()
        self.eventImage = UIImageView()
        self.titleLabel = UILabel.zipTextNotiBold()
        self.participantsLabel = UILabel.zipTextDetail()
        
        let smallConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold, scale: .small)
        self.distanceLabel = DistanceLabel(labelFont: .zipTextDetail, color: .zipVeryLightGray, config: smallConfig)
        self.timeLabel = IconLabel(iconImage: UIImage(systemName: "clock")?.withConfiguration(smallConfig), labelFont: .zipTextDetail, color: .zipVeryLightGray)
        self.dateLabel = IconLabel(iconImage: UIImage(systemName: "calendar")?.withConfiguration(smallConfig), labelFont: .zipTextDetail, color: .zipVeryLightGray)

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        eventImage.backgroundColor = .zipLightGray
        eventImage.isUserInteractionEnabled = true
        
        participantsLabel.numberOfLines = 0
        participantsLabel.lineBreakMode = .byWordWrapping
        
        
        bgView.layer.cornerRadius = 10
        bgView.backgroundColor = .zipLightGray
        
        eventImage.layer.cornerRadius = 30
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
        configureLabels()
        configureImage(event)
    }
    
    public func configureImage(_ event: Event) {
        guard let url = event.imageUrl else {
            let imageName = event.getType() == .Promoter ? "defaultPromoterEventProfilePic" : "defaultEventProfilePic"
            eventImage.image = UIImage(named: imageName)
            return
        }
        eventImage.sd_setImage(with: url, completed: nil)
    }
    

    
    //MARK: - Label Config
    private func configureLabels(){
        guard let event = event else {
            return
        }
        
       
        
        titleLabel.text = event.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        dateLabel.update(string:  " " + dateFormatter.string(from: event.startTime))
        
        dateFormatter.dateFormat = "h:mm a"
        timeLabel.update(string: " " + dateFormatter.string(from: event.startTime))
        
        let eventLoc = CLLocation(latitude: event.coordinates.coordinate.latitude, longitude: event.coordinates.coordinate.longitude)
        distanceLabel.update(location: eventLoc)
        
        
        participantsLabel.text = String(event.usersGoing.count) + "\nparticipants"
        
        participantsLabel.textAlignment = .right
        
        participantsLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    //MARK: - Add Subviews
    private func addSubviews(){
        contentView.addSubview(bgView)

        bgView.addSubview(eventImage)
        bgView.addSubview(titleLabel)
        
        
        bgView.addSubview(distanceLabel)
        bgView.addSubview(dateLabel)
        bgView.addSubview(timeLabel)
        
        bgView.addSubview(participantsLabel)
    }
    
    //MARK: - Layout Constraints
    private func configureSubviewLayout(){
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 5).isActive = true
        bgView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).isActive = true
        bgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: eventImage.topAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: eventImage.rightAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: participantsLabel.leftAnchor, constant: -5).isActive = true

        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2).isActive = true
        distanceLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor).isActive = true
        dateLabel.leftAnchor.constraint(equalTo: distanceLabel.leftAnchor).isActive = true

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: distanceLabel.leftAnchor).isActive = true
        
        participantsLabel.translatesAutoresizingMaskIntoConstraints = false
        participantsLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
        participantsLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true

        eventImage.translatesAutoresizingMaskIntoConstraints = false
        eventImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        eventImage.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5).isActive = true
        eventImage.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 10).isActive = true
        eventImage.widthAnchor.constraint(equalTo: eventImage.heightAnchor).isActive = true
        
        eventImage.layer.masksToBounds = true
        
        eventImage.layer.borderWidth = 2
        eventImage.layer.borderColor = UIColor.zipYellow.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

