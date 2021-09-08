//
//  MyZipsTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/26/21.
//

import UIKit
import CoreLocation
import MapKit



class MyZipsTableViewCell: UITableViewCell {
    static let identifier = "myZipUser"
    
    //MARK: - User Data
    var user = User()
    
    var pictureView = UIImageView()
    var outlineView = UIView()
    var infoView = UIView()
    
    let distanceImage = UIImageView(image: UIImage(named: "distanceToWhite")!)

    
    private var firstNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(22)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .left
        label.sizeToFit()
        label.text = "A"
        return label
    }()
    
    private var lastNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(22)
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
        label.font = .zipBodyBold
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "km"
        
        label.sizeToFit()
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    //MARK: - Configure
    public func configure(_ user: User){
        backgroundColor = .clear

        self.user = user
        pictureView = UIImageView(image: user.pictures[0])

        configureBackground()
        configureLabels()
        addSubviews()
        configureSubviewLayout()
    }
    
    //MARK: - Background Config
    private func configureBackground(){
        contentView.addSubview(outlineView)
        outlineView.frame = CGRect(x: 10, y: 10, width: contentView.frame.width-20, height: contentView.frame.height-20)
        outlineView.layer.cornerRadius = 15
        outlineView.backgroundColor = .zipLightGray
        
//        outlineView.layer.borderWidth = 0
//        outlineView.layer.borderColor =  UIColor.zipBlue.cgColor
    }
    
    
    //MARK: - Label Config
    private func configureLabels(){
        let name = user.name.components(separatedBy: " ")
        firstNameLabel.text = name[0]
        lastNameLabel.text = name[1]
        
        
        if user.distance < 2 {
            distanceLabel.textColor = .zipBlue
            distanceImage.image = distanceImage.image?.withTintColor(.zipBlue)
            
        } else if user.distance < 5 {
            distanceLabel.textColor = .zipGreen
            distanceImage.image = distanceImage.image?.withTintColor(.zipGreen)
            
        } else if user.distance < 10 {
            distanceLabel.textColor = .zipPink
            distanceImage.image = distanceImage.image?.withTintColor(.zipPink)
            
        }

        distanceLabel.text = String(user.distance) + " km"

    }
    
    //MARK: -Add Subviews
    private func addSubviews(){
        outlineView.addSubview(pictureView)
        outlineView.addSubview(firstNameLabel)
        outlineView.addSubview(lastNameLabel)
        outlineView.addSubview(distanceLabel)

        outlineView.addSubview(distanceImage)

    }

    //MARK: - Layout Subviews
    private func configureSubviewLayout(){
        pictureView.translatesAutoresizingMaskIntoConstraints = false
        pictureView.leftAnchor.constraint(equalTo: outlineView.leftAnchor, constant: 10).isActive = true
        pictureView.topAnchor.constraint(equalTo: outlineView.topAnchor, constant: 5).isActive = true
        pictureView.bottomAnchor.constraint(equalTo: outlineView.bottomAnchor, constant: -5).isActive = true
        pictureView.widthAnchor.constraint(equalTo: pictureView.heightAnchor).isActive = true

        firstNameLabel.translatesAutoresizingMaskIntoConstraints = false
        firstNameLabel.leftAnchor.constraint(equalTo: pictureView.rightAnchor, constant: 10).isActive = true
        firstNameLabel.bottomAnchor.constraint(equalTo: outlineView.centerYAnchor).isActive = true
        
        lastNameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastNameLabel.leftAnchor.constraint(equalTo: pictureView.rightAnchor, constant: 10).isActive = true
        lastNameLabel.topAnchor.constraint(equalTo: outlineView.centerYAnchor).isActive = true
        
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.rightAnchor.constraint(equalTo: outlineView.rightAnchor, constant: -10).isActive = true
        distanceLabel.centerYAnchor.constraint(equalTo: outlineView.centerYAnchor).isActive = true

        distanceImage.translatesAutoresizingMaskIntoConstraints = false
        distanceImage.rightAnchor.constraint(equalTo: distanceLabel.leftAnchor).isActive = true
        distanceImage.heightAnchor.constraint(equalToConstant: distanceLabel.intrinsicContentSize.height*1.3).isActive = true
        distanceImage.widthAnchor.constraint(equalTo: distanceImage.heightAnchor).isActive = true
        distanceImage.centerYAnchor.constraint(equalTo: distanceLabel.centerYAnchor).isActive = true

        
    }
    
    
    
}
