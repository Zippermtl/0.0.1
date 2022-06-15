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
    func openZips(_ user: User)
    func messageUser(_ user: User)
    func inviteUser(_ user: User)
}

class ZFCardBackView: UIView {
    weak var delegate: ZFCardBackDelegate?
    //User
    private var user: User?
    var userLoc: CLLocation

    private var dropDownTitles: [String]
    
    //MARK: - Labels
    private var firstNameLabel: UILabel
    private var lastNameLabel: UILabel
    private var ageLabel: UILabel
    private var distanceLabel: DistanceLabel
    private var usernameLabel: UILabel
    private var bioLabel: UILabel
    private var schoolLabel: UILabel
    private var interestsLabel: UILabel
    private var joinedDateLabel: UILabel
    
    
    private let zipsButton: IconButton
    private let messageButton: IconButton
    private let inviteButton: IconButton

    
    //MARK: - Subviews
    private var profilePicture: UIImageView
    private var reportPopUp: DropDown
    private var reportButton: UIButton
    
    let schoolImage: UIImageView
    let interestsImage: UIImageView
    
    private var slideView: MTSlideToOpenView
    
    
    init() {
        zipsButton = IconButton.zipsIcon()
        inviteButton = IconButton.inviteIcon()
        messageButton = IconButton.messageIcon()
        firstNameLabel = UILabel.zipHeader()
        lastNameLabel = UILabel.zipSubtitle()
        usernameLabel = UILabel.zipHeader()
        ageLabel = UILabel.zipSubtitle2()
        bioLabel = UILabel.zipTextFill()
        schoolLabel = UILabel.zipTextFill()
        joinedDateLabel = UILabel.zipTextDetail()
        interestsLabel = UILabel.zipTextFill()
        distanceLabel = DistanceLabel()
        
        schoolImage = UIImageView(image: UIImage(systemName: "graduationcap.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white))
        interestsImage = UIImageView(image: UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white))
        profilePicture = UIImageView()
        
        slideView = MTSlideToOpenView(frame: CGRect(x: 0, y: 0, width: 317, height: 56))
        
        reportPopUp = DropDown()
            
        reportButton = UIButton()
        userLoc = CLLocation()
        dropDownTitles = []
        
        super.init(frame: .zero)
        layer.cornerRadius = 20
        
        zipsButton.setIconDimension(width: 60)
        messageButton.setIconDimension(width: 60)
        inviteButton.setIconDimension(width: 60)
        
        reportButton.setImage(UIImage(named: "report"), for: .normal)
        reportButton.addTarget(self, action: #selector(didTapReportButton), for: .touchUpInside)
         
        if AppDelegate.userDefaults.bool(forKey: "hasHomeButton"){
            usernameLabel.font = .zipBody.withSize(18)
            firstNameLabel.font = .zipTitle.withSize(20)
            lastNameLabel.font = .zipTitle.withSize(20)
            ageLabel.font = .zipTitle.withSize(20)
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
        
       
        
        interestsLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        interestsImage.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        interestsLabel.numberOfLines = 2
        interestsLabel.lineBreakMode = .byWordWrapping
        
        addSubviews()
        configureSubviewLayout()
        configureSlider()
        configureDropDown()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapZipsButton(){
        
    }
    
    @objc private func didTapMessageButton() {
        
    }
    
    @objc private func didTapInviteButton(){
        
    }
    
    //MARK: - Button Actions
    @objc private func didTapReportButton(){
        reportPopUp.show()
        print("report tapped")
    }
    
    @objc private func openProfile(){
        guard let user = user else {
            return
        }
        delegate?.openProfile(user)
    }
    
    @objc private func unrequestUser(){
        slideView.resetStateWithAnimation(true)
    }
    
    
    public func configure(user: User){
        print("SUBVIEW COUNT = \(subviews.count)")
        
        
        backgroundColor = .clear
        self.user = user
        
        profilePicture.sd_setImage(with: user.getProfilePicUrl(), completed: nil)
        usernameLabel.text = "@" + user.username
        firstNameLabel.text = user.firstName
        lastNameLabel.text = user.lastName
        ageLabel.text = "\(user.age) years old"
        bioLabel.text = user.bio
        distanceLabel.update(distance: user.distance)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        
        if user.school != nil {
            schoolLabel.text = user.school!
        }
        
        if user.interests.count != 0 {
            interestsLabel.text = "Interests: " + user.interests.map{$0.description}.joined(separator: ", ")
        }

    }
    
    //MARK: - Configure Slider
    private func configureSlider(){
        slideView.thumnailImageView.image = UIImage(named: "zipperSlider")
        slideView.thumnailImageView.backgroundColor = .clear
        slideView.thumbnailViewStartingDistance = -10
        slideView.backgroundColor = .zipGray
        
//        slideView.
        slideView.sliderViewTopDistance = 11
        slideView.sliderCornerRadius = 15
        slideView.delegate = self
        slideView.sliderTextLabel.text = ""
        slideView.textLabel.text = ""
        
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
        guard let user = user else {
            return
        }
        
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
    public func addSubviews(){
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
    func configureSubviewLayout(){
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
        zipsButton.widthAnchor.constraint(equalToConstant:  60).isActive = true
        
        messageButton.translatesAutoresizingMaskIntoConstraints = false
        messageButton.topAnchor.constraint(equalTo: zipsButton.bottomAnchor, constant: 30).isActive = true
        messageButton.rightAnchor.constraint(equalTo: zipsButton.rightAnchor).isActive = true
        messageButton.widthAnchor.constraint(equalTo: zipsButton.widthAnchor).isActive = true
        
        inviteButton.translatesAutoresizingMaskIntoConstraints = false
        inviteButton.topAnchor.constraint(equalTo: messageButton.bottomAnchor, constant: 30).isActive = true
        inviteButton.rightAnchor.constraint(equalTo: zipsButton.rightAnchor).isActive = true
        inviteButton.widthAnchor.constraint(equalTo: zipsButton.widthAnchor).isActive = true
        
        
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
        interestsImage.widthAnchor.constraint(equalTo: interestsImage.heightAnchor).isActive = true
        
        
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
