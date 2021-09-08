//
//  ZipListTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/26/21.
//

import UIKit
import CoreLocation



class ZipListTableViewCell: UITableViewCell {

    static let zippedIdentifier = "zippedListUser"
    static let notZippedIdentifier = "notZippedListUser"

    //MARK: - User Data
    let userLoc = CLLocation(latitude: MapViewController.userLoc.latitude, longitude: MapViewController.userLoc.longitude)
    var user = User()
    var pictureView = UIImageView()
    var outlineView = UIView()
    var infoView = UIView()
    
    let distanceImage = UIImageView(image: UIImage(named: "distanceToWhite")!)

    
    private var firstNameLabel: UILabel = {
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
    
    private var lastNameLabel: UILabel = {
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
    
    var addButton = UIButton()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    //MARK: - Button Actions
    @objc private func didTapAddButton(_ sender: UIButton){
        print("add tapped for user \(user.name)")
    }
    
    //MARK: - Configure
    public func configure(_ user: User){
        backgroundColor = .clear

        self.user = user
        pictureView = UIImageView(image: user.pictures[0])

        configureBackground()
        configureLabels()
        configureButtons()
        addSubviews()
        configureSubviewLayout()
    }
    
    //MARK: - prepare for Reuse
    override func prepareForReuse() {
        firstNameLabel.text = ""
        lastNameLabel.text = ""
        distanceLabel.text = ""
        addButton.isHidden = true
    }
    
    //MARK: - Background Config
    private func configureBackground(){
        contentView.addSubview(outlineView)
        outlineView.frame = CGRect(x: 10, y: 10, width: contentView.frame.width-20, height: contentView.frame.height-20)
        outlineView.layer.cornerRadius = 10
        outlineView.backgroundColor = .zipLightGray
        
        
        if user.zipped {
            outlineView.layer.borderWidth = 3
            outlineView.layer.borderColor =  UIColor.zipBlue.cgColor
        } else {
            outlineView.layer.borderWidth = 0
        }
        
    }
    
    
    //MARK: - Label Config
    private func configureLabels(){
        let name = user.name.components(separatedBy: " ")

        firstNameLabel.text = name[0]
        lastNameLabel.text = name[1]
        
        let distance = Double(round(10*(userLoc.distance(from: user.location))/1000))/10
        
        
        if distance < 2 {
            distanceLabel.textColor = .zipBlue
            distanceImage.image = distanceImage.image?.withTintColor(.zipBlue)
            
        } else if distance < 5 {
            distanceLabel.textColor = .zipGreen
            distanceImage.image = distanceImage.image?.withTintColor(.zipGreen)
            
        } else if distance < 10 {
            distanceLabel.textColor = .zipPink
            distanceImage.image = distanceImage.image?.withTintColor(.zipPink)
        }

        distanceLabel.text = String(distance) + " km"

        
    }
    
    private func configureButtons(){
        addButton.setBackgroundImage(UIImage(named: "add"), for: .normal)
        addButton.addTarget(self, action: #selector(didTapAddButton(_:)), for: .touchUpInside)
    }
    
    //MARK: -Add Subviews
    private func addSubviews(){
        outlineView.addSubview(pictureView)
        outlineView.addSubview(firstNameLabel)
        outlineView.addSubview(lastNameLabel)
        outlineView.addSubview(distanceLabel)
        outlineView.addSubview(distanceImage)
        
        outlineView.addSubview(addButton)
        
        if user.zipped {
            addButton.isHidden = true
        } else {
            addButton.isHidden = false
        }
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
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.rightAnchor.constraint(equalTo: outlineView.rightAnchor, constant: -10).isActive = true
        addButton.centerYAnchor.constraint(equalTo: distanceLabel.centerYAnchor).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: distanceLabel.intrinsicContentSize.height*1.5).isActive = true
        addButton.widthAnchor.constraint(equalTo: addButton.heightAnchor).isActive = true

        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.centerYAnchor.constraint(equalTo: outlineView.centerYAnchor).isActive = true
        distanceImage.translatesAutoresizingMaskIntoConstraints = false
        distanceImage.centerYAnchor.constraint(equalTo: distanceLabel.centerYAnchor).isActive = true
        distanceImage.rightAnchor.constraint(equalTo: distanceLabel.leftAnchor).isActive = true
        distanceImage.heightAnchor.constraint(equalToConstant: distanceLabel.intrinsicContentSize.height).isActive = true
        distanceImage.widthAnchor.constraint(equalTo: distanceImage.heightAnchor).isActive = true

        
        

        
        
        
        if user.zipped {
            distanceLabel.rightAnchor.constraint(equalTo: outlineView.rightAnchor, constant: -10).isActive = true
        } else {
            distanceLabel.rightAnchor.constraint(equalTo: addButton.leftAnchor, constant: 0).isActive = true
        }
        
        

        
    }
    
    
    
}

