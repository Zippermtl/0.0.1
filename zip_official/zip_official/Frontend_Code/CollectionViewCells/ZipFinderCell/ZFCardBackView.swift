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
        label.font = .zipTitle
        label.numberOfLines = 1
        label.text = "A"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private var lastNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle
        label.numberOfLines = 1
        label.text = "A"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private var ageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle
        label.text = "A"
        return label
    }()
    
    private var distanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(26)
        label.text = "A"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private var usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(26)
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
    
    private var birthdayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.sizeToFit()
        label.text = "@"
        return label
    }()
    
    
    //MARK: - Subviews
    private var scrollView = UIScrollView()
    private var profilePicture = UIImageView()
    private var userInfoView = UIView()
    private var reportPopUp = DropDown()
    private var bottomOfScroll = UIView()
    private var reportButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "report"), for: .normal)
        btn.addTarget(self, action: #selector(didTapReportButton), for: .touchUpInside)
        return btn
    }()
    
    let schoolImage = UIImageView(image: UIImage(named: "school"))
    let birthdayImage = UIImageView(image: UIImage(named: "birthday"))
    
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
    
    
    public func configure(user: User, cellColor: UIColor, loc: CLLocation){
        backgroundColor = .clear
        layer.cornerRadius = 20
        self.user = user
        self.cellColor = cellColor
        self.userLoc = loc
        
        profilePicture = UIImageView(image: user.pictures[0])
        
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
//        scrollView.updateContentView(10)
        if countLayout < 4 {
            countLayout = countLayout + 1
            scrollView.contentSize = CGSize(width: frame.width,
                                            height: bottomOfScroll.frame.maxY - usernameLabel.frame.maxY + 20)
        }

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

        ageLabel.text = String(user.age)
        
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
        birthdayLabel.text = dateFormatter.string(from: user.birthday)
        
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

        let sliderHolderImg = UIImageView(image: UIImage(named: "sliderHolder"))
        slideView.sliderHolderView.addSubview(sliderHolderImg)
        sliderHolderImg.translatesAutoresizingMaskIntoConstraints = false
        sliderHolderImg.topAnchor.constraint(equalTo: slideView.sliderHolderView.topAnchor).isActive = true
        sliderHolderImg.leftAnchor.constraint(equalTo: slideView.sliderHolderView.leftAnchor).isActive = true
        sliderHolderImg.bottomAnchor.constraint(equalTo: slideView.sliderHolderView.bottomAnchor).isActive = true
        sliderHolderImg.rightAnchor.constraint(equalTo: slideView.sliderHolderView.rightAnchor).isActive = true
        
        slideView.thumbnailViewStartingDistance = -10
        slideView.sliderHolderView.backgroundColor = cellColor.withAlphaComponent(0.1)
        slideView.slidingColor = UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1)
        
        let requestedLabel = UILabel()
        requestedLabel.text = "REQUESTED"
        requestedLabel.font = .zipTitle
        requestedLabel.textColor = cellColor
        
        slideView.draggedView.addSubview(requestedLabel)
        requestedLabel.translatesAutoresizingMaskIntoConstraints = false
        requestedLabel.centerYAnchor.constraint(equalTo: slideView.centerYAnchor).isActive = true
        requestedLabel.centerXAnchor.constraint(equalTo: slideView.centerXAnchor).isActive = true

        let xButton = UIButton(frame: .zero)
        xButton.setImage(UIImage(named: "redX"), for: .normal)
        
        slideView.draggedView.addSubview(xButton)
        xButton.translatesAutoresizingMaskIntoConstraints = false
        xButton.centerYAnchor.constraint(equalTo: requestedLabel.centerYAnchor).isActive = true

//        xButton.topAnchor.constraint(equalTo: requestedLabel.topAnchor).isActive = true
//        xButton.bottomAnchor.constraint(equalTo: requestedLabel.bottomAnchor).isActive = true

        xButton.leftAnchor.constraint(equalTo: requestedLabel.rightAnchor).isActive = true
        xButton.heightAnchor.constraint(equalToConstant: requestedLabel.intrinsicContentSize.height).isActive = true
        xButton.widthAnchor.constraint(equalTo: xButton.heightAnchor).isActive = true
        
        let sliderTap = UITapGestureRecognizer(target: self, action: #selector(unrequestUser))
        slideView.addGestureRecognizer(sliderTap)
        
        let xTap = UITapGestureRecognizer(target: self, action: #selector(unrequestUser))
        xButton.addGestureRecognizer(xTap)
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
        addSubview(scrollView)
        
        scrollView.addSubview(profilePicture)
        
        scrollView.addSubview(userInfoView)
        userInfoView.addSubview(firstNameLabel)
        userInfoView.addSubview(lastNameLabel)
        userInfoView.addSubview(ageLabel)
        userInfoView.addSubview(distanceLabel)
        
        scrollView.addSubview(bioLabel)
        scrollView.addSubview(schoolImage)
        scrollView.addSubview(schoolLabel)
        scrollView.addSubview(interestsLabel)
        scrollView.addSubview(birthdayImage)
        scrollView.addSubview(birthdayLabel)
        addSubview(bottomOfScroll)
        
        
        addSubview(slideView)
    }

    
    //MARK: - Add Constraints
    private func configureSubviewLayout(){
        let buffer = CGFloat(10.0)
        let heightBuffer = CGFloat(20.0)

        // Username label
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: topAnchor, constant: buffer).isActive = true

        
        //Report Button
        reportButton.translatesAutoresizingMaskIntoConstraints = false
        reportButton.heightAnchor.constraint(equalToConstant: usernameLabel.intrinsicContentSize.height*1.5).isActive = true
        reportButton.widthAnchor.constraint(equalTo: reportButton.heightAnchor).isActive = true
        reportButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -buffer).isActive = true
        reportButton.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor).isActive = true
        
        //ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: buffer).isActive = true
        scrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: slideView.topAnchor).isActive = true

        // Profile Picture
        let pictureHeight = firstNameLabel.intrinsicContentSize.height*2 + ageLabel.intrinsicContentSize.height*2 + buffer
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        profilePicture.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        profilePicture.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        profilePicture.heightAnchor.constraint(equalToConstant: pictureHeight).isActive = true
        profilePicture.widthAnchor.constraint(equalTo: profilePicture.heightAnchor).isActive = true

        // User Info View
        userInfoView.translatesAutoresizingMaskIntoConstraints = false
        userInfoView.leftAnchor.constraint(equalTo: profilePicture.rightAnchor, constant: buffer).isActive = true
        userInfoView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        userInfoView.centerYAnchor.constraint(equalTo: profilePicture.centerYAnchor).isActive = true
        userInfoView.bottomAnchor.constraint(equalTo: distanceLabel.bottomAnchor).isActive = true
        
        // First Name Label
        firstNameLabel.translatesAutoresizingMaskIntoConstraints = false
        firstNameLabel.leftAnchor.constraint(equalTo: userInfoView.leftAnchor).isActive = true
        firstNameLabel.rightAnchor.constraint(equalTo: userInfoView.rightAnchor).isActive = true
        firstNameLabel.topAnchor.constraint(equalTo: userInfoView.topAnchor).isActive = true
        
        // Last Name Label
        lastNameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastNameLabel.leftAnchor.constraint(equalTo: userInfoView.leftAnchor).isActive = true
        lastNameLabel.rightAnchor.constraint(equalTo: userInfoView.rightAnchor).isActive = true
        lastNameLabel.topAnchor.constraint(equalTo: firstNameLabel.bottomAnchor).isActive = true
        
        // Age Label
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.leftAnchor.constraint(equalTo: userInfoView.leftAnchor).isActive = true
        ageLabel.rightAnchor.constraint(equalTo: userInfoView.rightAnchor).isActive = true
        ageLabel.topAnchor.constraint(equalTo: lastNameLabel.bottomAnchor).isActive = true
        
        // Distance Label
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.leftAnchor.constraint(equalTo: userInfoView.leftAnchor).isActive = true
        distanceLabel.rightAnchor.constraint(equalTo: userInfoView.rightAnchor).isActive = true
        distanceLabel.topAnchor.constraint(equalTo: ageLabel.bottomAnchor).isActive = true

        // Bio Label
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.topAnchor.constraint(equalTo: profilePicture.bottomAnchor, constant: buffer).isActive = true
        bioLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: buffer).isActive = true
        bioLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -buffer).isActive = true
        
        // School Label
        schoolImage.translatesAutoresizingMaskIntoConstraints = false
        schoolImage.leftAnchor.constraint(equalTo: leftAnchor, constant: buffer).isActive = true
        schoolImage.centerYAnchor.constraint(equalTo: schoolLabel.centerYAnchor).isActive = true
        schoolImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        schoolImage.widthAnchor.constraint(equalTo: schoolImage.heightAnchor).isActive = true

        schoolLabel.translatesAutoresizingMaskIntoConstraints = false
        schoolLabel.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: heightBuffer).isActive = true
        schoolLabel.leftAnchor.constraint(equalTo: schoolImage.rightAnchor, constant: buffer).isActive = true
        schoolLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -buffer).isActive = true
        
        // Interest Label
        interestsLabel.translatesAutoresizingMaskIntoConstraints = false
        interestsLabel.topAnchor.constraint(equalTo: schoolLabel.bottomAnchor, constant: heightBuffer).isActive = true
        interestsLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: buffer).isActive = true
        interestsLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -buffer).isActive = true
        
        // Birthday Label
        birthdayImage.translatesAutoresizingMaskIntoConstraints = false
        birthdayImage.leftAnchor.constraint(equalTo: leftAnchor, constant: buffer).isActive = true
        birthdayImage.centerYAnchor.constraint(equalTo: birthdayLabel.centerYAnchor).isActive = true
        birthdayImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        birthdayImage.widthAnchor.constraint(equalTo: birthdayImage.heightAnchor).isActive = true
        
        birthdayLabel.translatesAutoresizingMaskIntoConstraints = false
        birthdayLabel.topAnchor.constraint(equalTo: interestsLabel.bottomAnchor, constant: heightBuffer).isActive = true
        birthdayLabel.leftAnchor.constraint(equalTo: birthdayImage.rightAnchor, constant: buffer).isActive = true
        birthdayLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: buffer).isActive = true

        bottomOfScroll.translatesAutoresizingMaskIntoConstraints = false
        bottomOfScroll.bottomAnchor.constraint(equalTo: birthdayLabel.bottomAnchor).isActive = true
        bottomOfScroll.topAnchor.constraint(equalTo: birthdayLabel.topAnchor).isActive = true
        bottomOfScroll.leftAnchor.constraint(equalTo: birthdayLabel.leftAnchor).isActive = true
        bottomOfScroll.rightAnchor.constraint(equalTo: birthdayLabel.rightAnchor).isActive = true

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
