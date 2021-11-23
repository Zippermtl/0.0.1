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
    var event = Event()
    var userLoc = CLLocation(latitude: 0, longitude: 0)
    
    //MARK: - Subviews
    private let bgView = UIView()
    private let eventImage = UIImageView()
    
    // Buttons
    private let goingButton: UIButton = {
        let btn = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 100, weight: .bold, scale: .large)
        let img = UIImage(systemName: "checkmark.circle.fill", withConfiguration: largeConfig)?
                        .withRenderingMode(.alwaysOriginal)
                        .withTintColor(.zipVeryLightGray)
        btn.setImage(img, for: .normal)
        return btn
    }()
    
    private let interestedButton: UIButton = {
        let btn = UIButton()
//        btn.layer.masksToBounds = true
//        btn.layer.cornerRadius = 20
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 100, weight: .bold, scale: .large)
        let img = UIImage(systemName: "star.circle.fill", withConfiguration: largeConfig)?
                        .withRenderingMode(.alwaysOriginal)
                        .withTintColor(.zipVeryLightGray)
        btn.setImage(img, for: .normal)
        return btn
    }()
    
    
    //Labels
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(18)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.sizeToFit()
        label.text = "A"
        return label
    }()
    
    private let participantsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .zipVeryLightGray
        label.font = .zipBody.withSize(16)
        label.textAlignment = .right
        label.numberOfLines = 2
        label.sizeToFit()
        return label
    }()
    
    private var distanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .zipVeryLightGray
        label.font = .zipBody.withSize(16)
        label.sizeToFit()
        return label
    }()
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .zipVeryLightGray
        label.font = .zipBody.withSize(16)
        label.sizeToFit()
        return label
    }()
    
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .zipVeryLightGray
        label.font = .zipBody.withSize(16)
        label.sizeToFit()
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Config
    public func configure(_ event: Event, loc: CLLocation){
        backgroundColor = .clear
        self.event = event
        
        guard let coordinates = UserDefaults.standard.object(forKey: "userLoc") as? [Double] else {
            return
        }
        
        userLoc = CLLocation(latitude: coordinates[0], longitude: coordinates[1])
        
        print("userloc = \(userLoc)")
        configureBackground()
        addSubviews()
        configureImage()
        configureLabels()
        configureSubviewLayout()
    }
    
    //MARK: - Background Config
    private func configureBackground(){
        contentView.addSubview(bgView)
        bgView.frame = CGRect(x: 5, y: 5, width: contentView.frame.width-10, height: contentView.frame.height-10)
        bgView.layer.cornerRadius = 10
        bgView.backgroundColor = .zipLightGray
    }
    
    //MARK: - Label Config
    private func configureLabels(){
        titleLabel.text = event.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        dateLabel.text = dateFormatter.string(from: event.startTime)
        
        dateFormatter.dateFormat = "h:mm a"
        timeLabel.text = dateFormatter.string(from: event.startTime)
        
        //MARK: TODO - change to eventLoc
        var distance = Double(round(10*(userLoc.distance(from: event.location))/1000))/10
        var unit = "km"
        if NSLocale.current.regionCode == "US" {
            distance = round(10*distance/1.6)/10
            unit = "miles"
        }
        if distance > 10 {
            distanceLabel.text = String(Int(distance)) + " " + unit
        } else {
            distanceLabel.text = String(distance) + " " + unit

        }

        participantsLabel.text = String(event.usersGoing.count) + "/" + String(event.maxGuests) + "\ngoing"
        
        participantsLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    }
    
    //MARK: - Image Config
    private func configureImage() {
        eventImage.image = event.image
        let size = contentView.frame.height/2
        let y = bgView.frame.height/2 - size/2
        eventImage.frame = CGRect(x: 10,
                                  y: y,
                                  width: size,
                                  height: size)

        eventImage.layer.masksToBounds = true
        eventImage.layer.cornerRadius = size/2
        
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

        let distanceImage = UIImageView(image: UIImage(named: "distanceToWhite")?.withTintColor(.zipVeryLightGray))
        let dateImage = UIImageView(image: UIImage(systemName: "calendar")?.withRenderingMode(.alwaysOriginal).withTintColor(.zipVeryLightGray))
        let timeImage = UIImageView(image: UIImage(systemName: "clock.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.zipVeryLightGray))

        bgView.addSubview(distanceImage)
        bgView.addSubview(dateImage)
        bgView.addSubview(timeImage)
        
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5).isActive = true
        distanceLabel.leftAnchor.constraint(equalTo: distanceImage.rightAnchor, constant: 5).isActive = true

        distanceImage.translatesAutoresizingMaskIntoConstraints = false
        distanceImage.centerYAnchor.constraint(equalTo: distanceLabel.centerYAnchor).isActive = true
        distanceImage.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
        distanceImage.heightAnchor.constraint(equalToConstant: distanceLabel.intrinsicContentSize.height).isActive = true
        distanceImage.widthAnchor.constraint(equalTo: distanceImage.heightAnchor).isActive = true

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor).isActive = true
        dateLabel.leftAnchor.constraint(equalTo: distanceLabel.leftAnchor).isActive = true

        dateImage.translatesAutoresizingMaskIntoConstraints = false
        dateImage.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor).isActive = true
        dateImage.centerXAnchor.constraint(equalTo: distanceImage.centerXAnchor).isActive = true
        dateImage.heightAnchor.constraint(equalTo: distanceImage.heightAnchor).isActive = true
        dateImage.widthAnchor.constraint(equalTo: dateImage.heightAnchor).isActive = true

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: distanceLabel.leftAnchor).isActive = true

        timeImage.translatesAutoresizingMaskIntoConstraints = false
        timeImage.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor).isActive = true
        timeImage.centerXAnchor.constraint(equalTo: distanceImage.centerXAnchor).isActive = true
        timeImage.heightAnchor.constraint(equalTo: distanceImage.heightAnchor).isActive = true
        timeImage.widthAnchor.constraint(equalTo: timeImage.heightAnchor).isActive = true
        
        participantsLabel.translatesAutoresizingMaskIntoConstraints = false
        participantsLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
        participantsLabel.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -5).isActive = true

        goingButton.translatesAutoresizingMaskIntoConstraints = false
        goingButton.rightAnchor.constraint(equalTo: participantsLabel.rightAnchor).isActive = true
        goingButton.topAnchor.constraint(equalTo: participantsLabel.bottomAnchor, constant: 10).isActive = true
        goingButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        goingButton.widthAnchor.constraint(equalTo: goingButton.heightAnchor).isActive = true
        
        interestedButton.translatesAutoresizingMaskIntoConstraints = false
        interestedButton.topAnchor.constraint(equalTo: goingButton.topAnchor).isActive = true
        interestedButton.rightAnchor.constraint(equalTo: goingButton.leftAnchor, constant: -10).isActive = true
        interestedButton.widthAnchor.constraint(equalTo: goingButton.widthAnchor).isActive = true
        interestedButton.heightAnchor.constraint(equalTo: goingButton.heightAnchor).isActive = true

        
        
    }
}
