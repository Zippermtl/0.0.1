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
    let userLoc = CLLocation(latitude: ZipperTabBarViewController.userLoc.latitude, longitude: ZipperTabBarViewController.userLoc.longitude)
    var user = User()
    
    //MARK: - Subviews
    var pictureView = UIView()
    var outlineView = UIView()
    var contentContainer = UIView()
    var infoView = UIView()
    
    let distanceImage = UIImageView(image: UIImage(named: "distanceToWhite")!)

    //MARK: - Labels
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(18)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .left
        label.sizeToFit()
        label.text = "A"
        return label
    }()
    
    private var distanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        label.sizeToFit()
        return label
    }()
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        label.sizeToFit()
        return label
    }()
    
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
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
    public func configure(_ event: Event){
        backgroundColor = .clear
        
        self.event = event

        generateTestData()
        
        configureBackground()
        configureImage()
        configureLabels()
        addSubviews()
        configureSubviewLayout()
    }
    
    //MARK: - Background Config
    private func configureBackground(){
        contentView.addSubview(outlineView)
        outlineView.addSubview(contentContainer)
        
        outlineView.frame = CGRect(x: 10, y: 10, width: contentView.frame.width-20, height: contentView.frame.height-20)

        outlineView.layer.cornerRadius = 10
        outlineView.backgroundColor = .zipEventYellow
        
        contentContainer.frame = CGRect(x: 5, y: 5, width: outlineView.frame.width-10, height: outlineView.frame.height-10)
        contentContainer.layer.cornerRadius = 10
        contentContainer.backgroundColor = UIColor(red: 71/255, green: 71/255, blue: 71/255, alpha: 1)
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
        let distance = Double(round(10*(userLoc.distance(from: user.location))/1000))/10
//
//        if distance < 2 {
//            distanceLabel.textColor = .zipBlue
//            distanceImage.image = distanceImage.image?.withTintColor(.zipBlue)
//
//        } else if distance < 5 {
//            distanceLabel.textColor = .zipGreen
//            distanceImage.image = distanceImage.image?.withTintColor(.zipGreen)
//
//        } else if distance < 10 {
//            distanceLabel.textColor = .zipPink
//            distanceImage.image = distanceImage.image?.withTintColor(.zipPink)
//        }
        
        distanceLabel.text = String(distance) + " km"
        
//        let distance = userLoc.distance(from: event.location)
//        switch distance {
//        case < 2000: distanceLabel.textColor = .zipBlue
//        case < 5000: distanceLabel.textColor = .zipGreen
//        case < 10000: distanceLabel.textColor = .zipPink
//        default: distanceLabel.textColor = .white
//        }
        
        switch event.type {
        case "innerCircle": outlineView.backgroundColor = .zipEventBlue
        case "promoter": outlineView.backgroundColor = .zipEventYellow
        default: outlineView.backgroundColor = .zipLightGray
        }
        
        
    }
    
    //MARK: - Image Config
    private func configureImage() {
        let pic = UIImageView(image: event.image)
        let size = contentView.frame.height/2
        pic.frame = CGRect(x: 0, y: 0, width: size, height: size)

        pic.layer.masksToBounds = true
        pic.layer.cornerRadius = size/2

        pictureView.addSubview(pic)
    }
    
    //MARK: - Add Subviews
    private func addSubviews(){
        contentContainer.addSubview(pictureView)
        
        contentContainer.addSubview(titleLabel)
        
        contentContainer.addSubview(infoView)
        infoView.addSubview(distanceLabel)
        infoView.addSubview(dateLabel)
        infoView.addSubview(timeLabel)
    }
    
    //MARK: - Layout Constraints
    private func configureSubviewLayout(){
        let size = contentView.frame.height/2
        let buffer = CGFloat(5)

        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoView.rightAnchor.constraint(equalTo: contentContainer.rightAnchor).isActive = true
        infoView.topAnchor.constraint(equalTo: contentContainer.topAnchor).isActive = true
        infoView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor).isActive = true
        infoView.widthAnchor.constraint(equalToConstant: contentView.frame.width/4).isActive = true
        
        pictureView.translatesAutoresizingMaskIntoConstraints = false
        pictureView.heightAnchor.constraint(equalToConstant: size).isActive = true
        pictureView.widthAnchor.constraint(equalTo: pictureView.heightAnchor).isActive = true
        pictureView.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor).isActive = true
        pictureView.leftAnchor.constraint(equalTo: contentContainer.leftAnchor, constant: size/4).isActive = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: pictureView.rightAnchor, constant: size/4).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: infoView.leftAnchor).isActive = true
        titleLabel.heightAnchor.constraint(lessThanOrEqualTo: contentContainer.heightAnchor).isActive = true

        let dateImage = UIImageView(image: UIImage(named: "calendar")!)
        let timeImage = UIImageView(image: UIImage(named: "clock")!)
        
        

        infoView.addSubview(distanceImage)
        infoView.addSubview(dateImage)
        infoView.addSubview(timeImage)

        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor).isActive = true
        distanceLabel.rightAnchor.constraint(equalTo: contentContainer.rightAnchor, constant: -buffer).isActive = true
        distanceLabel.widthAnchor.constraint(lessThanOrEqualTo: infoView.widthAnchor).isActive = true
        
        distanceImage.translatesAutoresizingMaskIntoConstraints = false
        distanceImage.topAnchor.constraint(equalTo: distanceLabel.topAnchor).isActive = true
        distanceImage.rightAnchor.constraint(equalTo: distanceLabel.leftAnchor, constant: -buffer).isActive = true
        distanceImage.bottomAnchor.constraint(equalTo: distanceLabel.bottomAnchor).isActive = true
        distanceImage.heightAnchor.constraint(equalToConstant: distanceLabel.intrinsicContentSize.height*1.3).isActive = true
        distanceImage.widthAnchor.constraint(equalTo: distanceImage.heightAnchor).isActive = true
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        dateLabel.rightAnchor.constraint(equalTo: contentContainer.rightAnchor, constant: -buffer).isActive = true
        dateLabel.widthAnchor.constraint(lessThanOrEqualTo: infoView.widthAnchor).isActive = true
        
        dateImage.translatesAutoresizingMaskIntoConstraints = false
        dateImage.topAnchor.constraint(equalTo: dateLabel.topAnchor).isActive = true
        dateImage.rightAnchor.constraint(equalTo: dateLabel.leftAnchor, constant: -buffer).isActive = true
        dateImage.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor).isActive = true
        dateImage.heightAnchor.constraint(equalTo: distanceImage.heightAnchor).isActive = true
        dateImage.widthAnchor.constraint(equalTo: dateImage.heightAnchor).isActive = true
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: contentContainer.rightAnchor, constant: -buffer).isActive = true
        timeLabel.widthAnchor.constraint(lessThanOrEqualTo: infoView.widthAnchor).isActive = true

        timeImage.translatesAutoresizingMaskIntoConstraints = false
        timeImage.topAnchor.constraint(equalTo: timeLabel.topAnchor).isActive = true
        timeImage.rightAnchor.constraint(equalTo: timeLabel.leftAnchor, constant: -buffer).isActive = true
        timeImage.bottomAnchor.constraint(equalTo: timeLabel.bottomAnchor).isActive = true
        timeImage.heightAnchor.constraint(equalTo: distanceImage.heightAnchor).isActive = true
        timeImage.widthAnchor.constraint(equalTo: timeImage.heightAnchor).isActive = true
    }
}



//MARK: - Generate Test Data
extension EventFinderTableViewCell {
    func generateTestData(){
        var yiannipics = [UIImage]()
        var interests = [Interests]()
        
        interests.append(.chess)
        interests.append(.coding)
        interests.append(.skiing)
        interests.append(.wine)
        interests.append(.workingOut)


        yiannipics.append(UIImage(named: "yianni1")!)
        yiannipics.append(UIImage(named: "yianni2")!)
        yiannipics.append(UIImage(named: "yianni3")!)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let yianniBirthday = formatter.date(from: "2001/12/06")!
        
        user = User(email: "zavalyia@gmail.com",
                    username: "yianni_zav",
                    firstName: "Yianni",
                    lastName: "Zavaliagkos",
//                    name: "Yianni Zavaliagkos",
                    birthday: yianniBirthday,
                    location: CLLocation(latitude: 51.5013, longitude: -0.2070),
                    pictures: yiannipics,
                    bio: "Yianni Zavaliagkos. Second Year at Mcgill. Add my snap and follow my insta @Yianni_Zav. I run this shit. Remember my name when I pass Zuckerberg on Forbes",
                    school: "McGill University",
                    interests: interests)
    }

}
