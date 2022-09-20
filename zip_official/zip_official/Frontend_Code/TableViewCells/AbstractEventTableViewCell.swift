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
    let distanceLabel: UILabel
    let dateLabel: UILabel
    let timeLabel: UILabel
    
    let distanceIcon: UIImageView
    let dateIcon : UIImageView
    let timeIcon : UIImageView
    
    let participantsIcon : UIImageView
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.bgView = UIView()
        self.eventImage = UIImageView()
        self.titleLabel = UILabel.zipTextNotiBold()
        self.participantsLabel = UILabel.zipTextDetail()
        self.distanceLabel = UILabel.zipTextDetail()
        self.timeLabel = UILabel.zipTextDetail()
        self.dateLabel = UILabel.zipTextDetail()
        
        let distanceConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .light, scale: .large)
        let timeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .small)
        let dateConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .light, scale: .small)
        let distanceImage = UIImage(named: "zip.mappin")?.withConfiguration(distanceConfig).withRenderingMode(.alwaysOriginal).withTintColor(.zipVeryLightGray)
        let timeImage = UIImage(systemName: "clock")?.withConfiguration(timeConfig).withRenderingMode(.alwaysOriginal).withTintColor(.zipVeryLightGray)
        let dateImage = UIImage(systemName: "calendar")?.withConfiguration(dateConfig).withRenderingMode(.alwaysOriginal).withTintColor(.zipVeryLightGray)
        self.timeIcon = UIImageView(image: timeImage)
        self.distanceIcon = UIImageView(image: distanceImage)
        self.dateIcon = UIImageView(image: dateImage)


        let image = UIImage(systemName: "person.3.fill", withConfiguration: timeConfig)?.withRenderingMode(.alwaysOriginal).withTintColor(.zipVeryLightGray)
        self.participantsIcon = UIImageView(image: image)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        eventImage.backgroundColor = .zipLightGray
        eventImage.isUserInteractionEnabled = true

        
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
        eventImage.layer.borderWidth = 2
        
        if let rEvent = event as? RecurringEvent {
            eventImage.layer.borderColor = rEvent.category.color.cgColor
        } else {
            eventImage.layer.borderColor = event.getType().color.cgColor
        }
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
        dateLabel.text =  " " + dateFormatter.string(from: event.startTime)
        
        dateFormatter.dateFormat = "h:mm a"
        timeLabel.text = " " + dateFormatter.string(from: event.startTime)
        
        distanceLabel.text = event.getDistanceString()
        participantsLabel.text = event.usersGoing.count.description
        
        participantsLabel.textAlignment = .right
        
        participantsLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    //MARK: - Add Subviews
    private func addSubviews(){
        contentView.addSubview(bgView)

        bgView.addSubview(eventImage)
        bgView.addSubview(titleLabel)
        
        bgView.addSubview(distanceIcon)
        bgView.addSubview(timeIcon)
        bgView.addSubview(dateIcon)
        
        bgView.addSubview(distanceLabel)
        bgView.addSubview(dateLabel)
        bgView.addSubview(timeLabel)
        
        bgView.addSubview(participantsIcon)
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
        titleLabel.rightAnchor.constraint(equalTo: participantsIcon.leftAnchor, constant: -5).isActive = true

        distanceIcon.translatesAutoresizingMaskIntoConstraints = false
        distanceIcon.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2).isActive = true
        distanceIcon.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true

        dateIcon.translatesAutoresizingMaskIntoConstraints = false
        dateIcon.topAnchor.constraint(equalTo: distanceIcon.bottomAnchor).isActive = true
        dateIcon.centerXAnchor.constraint(equalTo: distanceIcon.centerXAnchor).isActive = true

        timeIcon.translatesAutoresizingMaskIntoConstraints = false
        timeIcon.topAnchor.constraint(equalTo: dateIcon.bottomAnchor).isActive = true
        timeIcon.centerXAnchor.constraint(equalTo: dateIcon.centerXAnchor).isActive = true
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.centerYAnchor.constraint(equalTo: timeIcon.centerYAnchor).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: timeIcon.rightAnchor,constant: 3).isActive = true
        
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.centerYAnchor.constraint(equalTo: distanceIcon.centerYAnchor).isActive = true
        distanceLabel.leftAnchor.constraint(equalTo: timeLabel.leftAnchor).isActive = true
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.centerYAnchor.constraint(equalTo: dateIcon.centerYAnchor).isActive = true
        dateLabel.leftAnchor.constraint(equalTo: timeLabel.leftAnchor).isActive = true
        
        participantsLabel.translatesAutoresizingMaskIntoConstraints = false
        participantsLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
        participantsLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
        
        participantsIcon.translatesAutoresizingMaskIntoConstraints = false
        participantsIcon.centerYAnchor.constraint(equalTo: participantsLabel.centerYAnchor).isActive = true
        participantsIcon.rightAnchor.constraint(equalTo: participantsLabel.leftAnchor, constant: -2).isActive = true

        eventImage.translatesAutoresizingMaskIntoConstraints = false
        eventImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        eventImage.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5).isActive = true
        eventImage.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 10).isActive = true
        eventImage.widthAnchor.constraint(equalTo: eventImage.heightAnchor).isActive = true
        
        eventImage.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

