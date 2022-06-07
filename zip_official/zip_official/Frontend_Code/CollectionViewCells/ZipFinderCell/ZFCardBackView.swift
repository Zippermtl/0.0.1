//
//  ZFCardBackViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/28/21.
//

import Foundation
import UIKit
import MapKit
import MTSlideToOpen
import DropDown

protocol ZFCardBackDelegate: AnyObject {
    func openProfile(_ user: User)
}

class ZFCardBackView: UIView {
    var cellColor = UIColor.zipBlue.withAlphaComponent(1)
    weak var delegate: ZFCardBackDelegate?
    //User
    private var user = User()
    var userLoc = CLLocation()

    private var dropDownTitles: [String] = []
    
    //MARK: - Labels
    private var firstNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBodyBold
        label.numberOfLines = 1
        label.text = "A"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private var lastNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBodyBold
        label.numberOfLines = 1
        label.text = "A"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private var ageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBodyBold
        label.text = "A"
        return label
    }()
    
    private var distanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBodyBold
        label.text = "A"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private var usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(20)
        label.sizeToFit()
        label.text = "@"
        return label
    }()
    
    private var bioLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.sizeToFit()
        label.text = "@"
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    private var schoolLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.sizeToFit()
        label.text = "@"
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    private var interestsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.sizeToFit()
        label.text = "@"
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    private var joinedDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .zipVeryLightGray
        label.font = .zipBody.withSize(16)
        label.sizeToFit()
        label.text = "Joined Zipper on January 1st, 2022"
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    
    private let zipsButton: UIButton = {
        let btn = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .large) //
        let img = UIImage(systemName: "person.3", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        btn.setImage(img, for: .normal)
        btn.backgroundColor = .zipLightGray
        btn.layer.masksToBounds = true
        return btn
    }()
    
    private let messageButton: UIButton = {
        let btn = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .large) //, withConfiguration: config
        let img = UIImage(systemName: "message", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        btn.setImage(img, for: .normal)
        btn.backgroundColor = .zipLightGray
        btn.layer.masksToBounds = true
        return btn
    }()
    
    private let inviteButton: UIButton = {
        let btn = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .large) //, withConfiguration: config
        let img = UIImage(systemName: "paperplane", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        btn.setImage(img, for: .normal)
        btn.backgroundColor = .zipLightGray
        btn.layer.masksToBounds = true
        return btn
    }()

    
    
    //MARK: - Subviews
    private var profilePicture = UIImageView()
    private var reportPopUp = DropDown()
    private var reportButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "report"), for: .normal)
        btn.addTarget(self, action: #selector(didTapReportButton), for: .touchUpInside)
        return btn
    }()
    
    let schoolImage = UIImageView(image: UIImage(systemName: "graduationcap.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white))
    let interestsImage = UIImageView(image: UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white))
    
    private var slideView: MTSlideToOpenView = {
        let slider = MTSlideToOpenView(frame: CGRect(x: 0, y: 0, width: 317, height: 56))
        slider.thumnailImageView.image = UIImage(named: "zipperSlider")
        slider.thumnailImageView.backgroundColor = .clear
        slider.backgroundColor = .zipGray
        return slider
    }()
    
    //MARK: - Button Actions
    @objc private func didTapReportButton(){
        reportPopUp.show()
        print("report tapped")
    }
    
    @objc private func openProfile(){
        delegate?.openProfile(user)
    }
    
    @objc private func unrequestUser(){
        slideView.resetStateWithAnimation(true)
    }
    
    
    public func configure(user: User, cellColor: UIColor, loc: CLLocation, url: URL){
        backgroundColor = .clear
        layer.cornerRadius = 20
        self.user = user
        self.cellColor = cellColor
        self.userLoc = loc
        
        profilePicture.sd_setImage(with: url, completed: nil)
        
        configureLabels()
        configureDropDown()
        configureSlider()
        addSubviews()
        configureSubviewLayout()
        layoutSubviews()
    }
    
    private var countLayout = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }



   
    
    //MARK: - Configure Labels
    private func configureLabels(){
        
        if AppDelegate.userDefaults.bool(forKey: "hasHomeButton"){
            usernameLabel.font = .zipBody.withSize(18)
            firstNameLabel.font = .zipTitle.withSize(20)
            lastNameLabel.font = .zipTitle.withSize(20)
            ageLabel.font = .zipTitle.withSize(20)
            distanceLabel.font =  .zipTitle.withSize(16)
        }
        
        usernameLabel.text = "@" + user.username
//        let name = user.name.components(separatedBy: " ")
//
//        firstNameLabel.text = name[0]
//        lastNameLabel.text = name[1]
        
        firstNameLabel.text = user.firstName
        lastNameLabel.text = user.lastName

        ageLabel.text = "\(user.age) years old"
        var distance = Double(round(10*(userLoc.distance(from: user.location))/1000))/10
        var unit = "km"
        if NSLocale.current.regionCode == "US" {
            distance = round(10*distance/1.6)/10
            unit = "miles"
        }
        
        if distance > 10 {
            let intDistance = Int(distance)
            if distance <= 1 {
                if unit == "miles" {
                    unit = "mile"
                }
                distanceLabel.text = "<1 \(unit) away"
            } else if distance >= 500 {
                distanceLabel.text = ">500 \(unit) away"
            } else {
                distanceLabel.text = String(intDistance) + " \(unit) away"
            }
            distanceLabel.textColor = cellColor
        } else {
            if distance <= 1 {
                if unit == "miles" {
                    unit = "mile"
                }
                distanceLabel.text = "<1 \(unit) away"
            } else if distance >= 500 {
                distanceLabel.text = ">500 \(unit) away"
            } else {
                distanceLabel.text = String(distance) + " \(unit) away"
            }
            distanceLabel.textColor = cellColor
        }
        
        
        
        
        
        bioLabel.text = user.bio
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        
        if user.school != nil {
            schoolLabel.text = user.school!
        }
        
        if user.interests.count != 0 {
            interestsLabel.text = "Interests: " + user.interests.map{$0.description}.joined(separator: ", ")
        }
        
        
        let usernameTap = UITapGestureRecognizer(target: self, action: #selector(openProfile))
        usernameLabel.isUserInteractionEnabled = true
        usernameLabel.addGestureRecognizer(usernameTap)
        
        let firstNameTap = UITapGestureRecognizer(target: self, action: #selector(openProfile))
        firstNameLabel.isUserInteractionEnabled = true
        firstNameLabel.addGestureRecognizer(firstNameTap)
        
        let lastNameTap = UITapGestureRecognizer(target: self, action: #selector(openProfile))
        lastNameLabel.isUserInteractionEnabled = true
        lastNameLabel.addGestureRecognizer(lastNameTap)
    }
    
    //MARK: - Configure Slider
    private func configureSlider(){
        slideView.sliderViewTopDistance = 6
        slideView.sliderCornerRadius = 15
        slideView.delegate = self
        slideView.sliderTextLabel.text = ""
        
        slideView.backgroundColor = .clear


//        slideView.thumbnailViewStartingDistance = -10
        slideView.sliderHolderView.backgroundColor = .zipBlue.withAlphaComponent(0.5) //.zipBlue.withAlphaComponent(0.1)
        slideView.slidingColor = .zipGray//UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1)
        
        let requestedLabel = UILabel()
        requestedLabel.text = "REQUESTED"
        requestedLabel.font = .zipTitle
        requestedLabel.textColor = .zipBlue
        requestedLabel.textAlignment = .center
        requestedLabel.backgroundColor = UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1)
        requestedLabel.layer.cornerRadius = 8
        requestedLabel.layer.masksToBounds = true
        
        
        slideView.draggedView.addSubview(requestedLabel)
        
        requestedLabel.translatesAutoresizingMaskIntoConstraints = false
        requestedLabel.centerYAnchor.constraint(equalTo: slideView.centerYAnchor).isActive = true
        requestedLabel.centerXAnchor.constraint(equalTo: slideView.centerXAnchor).isActive = true
        requestedLabel.leftAnchor.constraint(equalTo: slideView.leftAnchor).isActive = true
        requestedLabel.rightAnchor.constraint(equalTo: slideView.rightAnchor).isActive = true


        let sliderTap = UITapGestureRecognizer(target: self, action: #selector(unrequestUser))
        slideView.addGestureRecognizer(sliderTap)

    }
    
    //MARK: - Configure Drop Down
    private func configureDropDown(){
//        let name = user.name.components(separatedBy: " ")
//        dropDownTitles = ["Report \(name[0])",
//                          "Block \(name[0])",
//                          "Don't show me \(name[0])"]
        
        dropDownTitles = ["Report \(user.firstName)",
                          "Block \(user.firstName)",
                          "Don't show me \(user.firstName)"]
        
        reportPopUp.dataSource = dropDownTitles
        reportPopUp.anchorView = reportButton
        
        reportPopUp.selectionAction = { index, title in
            print("index \(index) and \(title)")
        }
        reportPopUp.setEdgeInsets()
        reportPopUp.direction = .bottom
    }
    
    //MARK: - Configure Table
   
    
    //MARK: - Add Subviews
    private func addSubviews(){
        //Card FrontView
        addSubview(usernameLabel)
        addSubview(reportButton)
        
        addSubview(profilePicture)
        
        addSubview(firstNameLabel)
        addSubview(lastNameLabel)
        addSubview(ageLabel)
        addSubview(distanceLabel)
        
        
        addSubview(bioLabel)
        addSubview(schoolImage)
        addSubview(schoolLabel)
        addSubview(interestsImage)
        addSubview(interestsLabel)
        addSubview(joinedDateLabel)
        
        
        addSubview(zipsButton)
        addSubview(inviteButton)
        addSubview(messageButton)

        addSubview(slideView)
    }

    
    //MARK: - Add Constraints
    private func configureSubviewLayout(){
        let buffer = CGFloat(10.0)

        // Username label
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: topAnchor, constant: buffer).isActive = true

        
        //Report Button
        reportButton.translatesAutoresizingMaskIntoConstraints = false
        reportButton.heightAnchor.constraint(equalToConstant: usernameLabel.intrinsicContentSize.height*1.5).isActive = true
        reportButton.widthAnchor.constraint(equalTo: reportButton.heightAnchor).isActive = true
        reportButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -buffer).isActive = true
        reportButton.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor).isActive = true
        
        // Age label
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor).isActive = true
        ageLabel.leftAnchor.constraint(equalTo: usernameLabel.leftAnchor).isActive = true


        // Profile Picture
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        profilePicture.leftAnchor.constraint(equalTo: usernameLabel.leftAnchor).isActive = true
        profilePicture.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 5).isActive = true
        profilePicture.heightAnchor.constraint(equalToConstant: 80).isActive = true
        profilePicture.widthAnchor.constraint(equalTo: profilePicture.heightAnchor).isActive = true
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.cornerRadius = 40
        
        // First Name Label
        firstNameLabel.translatesAutoresizingMaskIntoConstraints = false
        firstNameLabel.leftAnchor.constraint(equalTo: profilePicture.rightAnchor, constant: 5).isActive = true
        firstNameLabel.bottomAnchor.constraint(equalTo: lastNameLabel.topAnchor).isActive = true
        
        // Last Name Label
        lastNameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastNameLabel.leftAnchor.constraint(equalTo: firstNameLabel.leftAnchor).isActive = true
        lastNameLabel.centerYAnchor.constraint(equalTo: profilePicture.centerYAnchor).isActive = true
        
        // Age Label
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.leftAnchor.constraint(equalTo: firstNameLabel.leftAnchor).isActive = true
        distanceLabel.topAnchor.constraint(equalTo: lastNameLabel.bottomAnchor).isActive = true

        // Right buttons
        zipsButton.translatesAutoresizingMaskIntoConstraints = false
        zipsButton.topAnchor.constraint(equalTo: firstNameLabel.topAnchor).isActive = true
        zipsButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        zipsButton.heightAnchor.constraint(equalToConstant:  60).isActive = true
        zipsButton.widthAnchor.constraint(equalTo: zipsButton.heightAnchor).isActive = true
        
        messageButton.translatesAutoresizingMaskIntoConstraints = false
        messageButton.topAnchor.constraint(equalTo: zipsButton.bottomAnchor, constant: 30).isActive = true
        messageButton.rightAnchor.constraint(equalTo: zipsButton.rightAnchor).isActive = true
        messageButton.heightAnchor.constraint(equalTo: zipsButton.heightAnchor).isActive = true
        messageButton.widthAnchor.constraint(equalTo: messageButton.heightAnchor).isActive = true
        
        inviteButton.translatesAutoresizingMaskIntoConstraints = false
        inviteButton.topAnchor.constraint(equalTo: messageButton.bottomAnchor, constant: 30).isActive = true
        inviteButton.rightAnchor.constraint(equalTo: zipsButton.rightAnchor).isActive = true
        inviteButton.heightAnchor.constraint(equalTo: zipsButton.heightAnchor).isActive = true
        inviteButton.widthAnchor.constraint(equalTo: inviteButton.heightAnchor).isActive = true
        
        
        zipsButton.layer.cornerRadius = 30
        inviteButton.layer.cornerRadius = 30
        messageButton.layer.cornerRadius = 30

        
        // School Label
        schoolImage.translatesAutoresizingMaskIntoConstraints = false
        schoolImage.leftAnchor.constraint(equalTo: usernameLabel.leftAnchor).isActive = true
        schoolImage.topAnchor.constraint(equalTo: profilePicture.bottomAnchor, constant: 30).isActive = true
        
        schoolLabel.translatesAutoresizingMaskIntoConstraints = false
        schoolLabel.centerYAnchor.constraint(equalTo: schoolImage.centerYAnchor).isActive = true
        schoolLabel.leftAnchor.constraint(equalTo: schoolImage.rightAnchor, constant: buffer).isActive = true
        schoolLabel.rightAnchor.constraint(equalTo: zipsButton.leftAnchor, constant: -10).isActive = true

        
        // Interest Label
        interestsImage.translatesAutoresizingMaskIntoConstraints = false
        interestsImage.leftAnchor.constraint(equalTo: usernameLabel.leftAnchor).isActive = true
        interestsImage.topAnchor.constraint(equalTo: schoolImage.bottomAnchor, constant: 30).isActive = true
        
        interestsLabel.translatesAutoresizingMaskIntoConstraints = false
        interestsLabel.centerYAnchor.constraint(equalTo: interestsImage.centerYAnchor).isActive = true
        interestsLabel.leftAnchor.constraint(equalTo: interestsImage.rightAnchor, constant: buffer).isActive = true
        interestsLabel.rightAnchor.constraint(equalTo: zipsButton.leftAnchor, constant: -10).isActive = true

        joinedDateLabel.translatesAutoresizingMaskIntoConstraints = false
        joinedDateLabel.leftAnchor.constraint(equalTo: interestsImage.leftAnchor).isActive = true
        joinedDateLabel.rightAnchor.constraint(equalTo: interestsLabel.rightAnchor).isActive = true
        joinedDateLabel.bottomAnchor.constraint(equalTo: inviteButton.bottomAnchor).isActive = true
        
        
        // Bio Label
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.topAnchor.constraint(equalTo: inviteButton.bottomAnchor, constant: 20).isActive = true
        bioLabel.leftAnchor.constraint(equalTo: usernameLabel.leftAnchor).isActive = true
        bioLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -buffer).isActive = true
        
        
        // SlideView
        slideView.translatesAutoresizingMaskIntoConstraints = false
        slideView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -buffer).isActive = true
        slideView.leftAnchor.constraint(equalTo: leftAnchor, constant: buffer).isActive = true
        slideView.rightAnchor.constraint(equalTo: rightAnchor, constant: -buffer).isActive = true
        slideView.heightAnchor.constraint(equalToConstant: 50).isActive = true
  
    }

}

//MARK: - Slider Delegate
extension ZFCardBackView: MTSlideToOpenDelegate {
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        print("should zip here")
    }
    
}
