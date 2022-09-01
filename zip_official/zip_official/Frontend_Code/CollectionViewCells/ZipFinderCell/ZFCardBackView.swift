//
//  ZFCardBackViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/28/21.
//

import Foundation
import UIKit
import MapKit

protocol ZFCardBackDelegate: AnyObject {
    func openVC(_ vc: UIViewController)
}

class ZFCardBackView: UIView {
    weak var delegate: ZFCardBackDelegate?
    //User
    private var user: User?
    var frontView: ZFCardFrontView?
    var userLoc: CLLocation

    
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
    private var tapToFlipLabel: UILabel
    private var requestedLabel : UILabel

    
    private let zipsButton: IconButton
    private let messageButton: IconButton
    private let inviteButton: IconButton

    
    //MARK: - Subviews
    private var profilePicture: UIImageView
    
    let schoolImage: UIImageView
    let interestsImage: UIImageView
    
    private var slideView: MTSlideToOpenViewCopy
    
    var canRequest = true
    
    init() {
        zipsButton = IconButton.zipsIcon()
        inviteButton = IconButton.inviteIcon()
        messageButton = IconButton.messageIcon()
        firstNameLabel = UILabel.zipSubtitle()
        lastNameLabel = UILabel.zipSubtitle()
        usernameLabel = UILabel.zipHeader()
        ageLabel = UILabel.zipSubtitle2()
        bioLabel = UILabel.zipTextFill()
        schoolLabel = UILabel.zipTextFill()
        joinedDateLabel = UILabel.zipTextDetail()
        interestsLabel = UILabel.zipTextFill()
        distanceLabel = DistanceLabel()
        tapToFlipLabel = UILabel.zipTextPrompt()
        requestedLabel = UILabel.zipSubtitle2()

        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular, scale: .large)

        schoolImage = UIImageView(image: UIImage(systemName: "graduationcap", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white))
        interestsImage = UIImageView(image: UIImage(systemName: "star", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white))
        profilePicture = UIImageView()
        
        slideView = MTSlideToOpenViewCopy(frame: CGRect(x: 0, y: 0, width: 317, height: 56))
        
    
        userLoc = CLLocation()
        
        super.init(frame: .zero)
        layer.cornerRadius = 20
        
        zipsButton.setIconDimension(width: 60)
        messageButton.setIconDimension(width: 60)
        inviteButton.setIconDimension(width: 60)
        
        zipsButton.iconAddTarget(self, action: #selector(didTapZipsButton), for: .touchUpInside)
        messageButton.iconAddTarget(self, action: #selector(didTapMessageButton), for: .touchUpInside)
        inviteButton.iconAddTarget(self, action: #selector(didTapInviteButton), for: .touchUpInside)
        
      
        let usernameTap = UITapGestureRecognizer(target: self, action: #selector(openProfile))
        usernameLabel.isUserInteractionEnabled = true
        usernameLabel.addGestureRecognizer(usernameTap)
        
        let firstNameTap = UITapGestureRecognizer(target: self, action: #selector(openProfile))
        firstNameLabel.isUserInteractionEnabled = true
        firstNameLabel.addGestureRecognizer(firstNameTap)
        
        let lastNameTap = UITapGestureRecognizer(target: self, action: #selector(openProfile))
        lastNameLabel.isUserInteractionEnabled = true
        lastNameLabel.addGestureRecognizer(lastNameTap)
        
        let photoTap = UITapGestureRecognizer(target: self, action: #selector(openProfile))
        profilePicture.isUserInteractionEnabled = true
        profilePicture.addGestureRecognizer(photoTap)
        
       
        schoolLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        schoolImage.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        schoolLabel.numberOfLines = 2
        schoolLabel.lineBreakMode = .byWordWrapping
        
        interestsLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        interestsImage.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        interestsLabel.numberOfLines = 2
        interestsLabel.lineBreakMode = .byWordWrapping
        
        bioLabel.numberOfLines = 0
        bioLabel.lineBreakMode = .byWordWrapping

        tapToFlipLabel.text = "tap to flip"
        
        addSubviews()
        configureSubviewLayout()
        configureSlider()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapZipsButton(){
        guard let user = user, canRequest else {
            return
        }
        let vc = UsersTableViewController(users: [])

        DatabaseManager.shared.loadUserZipsIds(given: user.userId, completion: { result in
            switch result {
            case .success(let users):
                print("loading ezras friends \(users)")
                vc.reload(users: users)
            case .failure(let error):
                print("failure loading other users ids, Error: \(error)")
            }
        })
        vc.title = "\(user.firstName)'s Zips"
        
        delegate?.openVC(vc)
    }
    
    @objc private func didTapMessageButton() {
        
        guard let user = user, canRequest else {
            return
        }
        
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        DatabaseManager.shared.getAllConversations(for: selfId, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let conversations):
                if let targetConversation = conversations.first(where: {
                    $0.otherUser.userId == user.userId
                }) {
                    let vc = ChatViewController(toUser: targetConversation.otherUser, id: targetConversation.id)
                    vc.isNewConversation = false
                    vc.title = targetConversation.otherUser.firstName
                    strongSelf.delegate?.openVC(vc)
                } else {
                    strongSelf.createNewConversation(result: user)
                }
            case .failure(_):
                strongSelf.createNewConversation(result: user)
            }
        })
    }
    
    private func createNewConversation(result otherUser: User){
        // check in database if conversation with these two uses exists
        // if it does, reuse conversation id
        // otherwise use existing code
        DatabaseManager.shared.conversationExists(with: otherUser.userId, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result{
            case.success(let conversationId):
                let vc = ChatViewController(toUser: otherUser, id: conversationId)
                vc.isNewConversation = false
                vc.title = otherUser.firstName
                strongSelf.delegate?.openVC(vc)
            case .failure(_):
                let vc = ChatViewController(toUser: otherUser, id: nil)
                vc.isNewConversation = true
                vc.title = otherUser.firstName
                strongSelf.delegate?.openVC(vc)
            }
        })
        
        
    }
    
    @objc private func didTapInviteButton(){
        guard let user = user, canRequest else {
            return
        }
        delegate?.openVC(InviteUserToEventViewController(user: user))
    }
    
    @objc private func openProfile(){
        print("OPEN PROFILE")
        guard let user = user else {
            return
        }
        delegate?.openVC(OtherProfileViewController(id: user.userId))
    }
    
    @objc private func unrequestUser(){
        guard let user = user else { return }
        user.unsendRequest(completion: { [weak self] error in
            guard let strongSelf = self,
                  error == nil else {
                return
            }
            user.friendshipStatus = nil
            strongSelf.noStatusUI()
            strongSelf.frontView?.updateRequestButton()
        })
        GeoManager.shared.forceAddUser(user: user)
    }
    
    
    public func configure(user: User){
        backgroundColor = .clear
        self.user = user
        if user.hasSchool  {
            schoolImage.isHidden = false
        } else {
            schoolImage.isHidden = true
        }
        
        if user.hasInterests  {
            print(user.fullName, "has interests")
            print("interests = ", user.interests)
            interestsImage.isHidden = false
        } else {
            print(user.fullName, "doesn't have interests")
            print("interests = ", user.interests)
            interestsImage.isHidden = true
        }
        
        configureLabels()
        profilePicture.sd_setImage(with: user.profilePicUrl, completed: nil)
        updateSlider()
    }
    
    func updateSlider() {
        switch user?.friendshipStatus {
        case .none, .REQUESTED_INCOMING: noStatusUI()
        case .REQUESTED_OUTGOING: requestedUI()
        case .ACCEPTED: zippedUI()
        }
    }
    
    private func configureLabels() {
        guard let user = user else { return }
        usernameLabel.text = "@" + user.username
        firstNameLabel.text = user.firstName
        lastNameLabel.text = user.lastName
        ageLabel.text = "\(user.age) years old"
        bioLabel.text = user.bio
        distanceLabel.update(distance: user.getDistance())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        joinedDateLabel.text = "Join Zipper on " + dateFormatter.string(from: user.joinDate)

        if user.hasSchool {
            schoolLabel.text = user.school!
        } else {
            schoolLabel.text = ""

        }
        
        if user.hasInterests {
            interestsLabel.text = "Interests: " + user.interests.map{$0.description}.joined(separator: ", ")
        } else {
            interestsLabel.text = ""
        }
    }
    //MARK: - Configure Slider
    private func configureSlider(){
        slideView.thumnailImageView.image = UIImage(named: "zipperSlider")
        slideView.thumnailImageView.backgroundColor = .zipBlue
        slideView.thumnailImageView.contentMode = .scaleAspectFit
//        slideView.thumbnailViewStartingDistance = -10
        slideView.backgroundColor = .clear
        
        
        slideView.swipeDistanceMultiplier = 0.6
        slideView.sliderViewTopDistance = 7
        slideView.sliderCornerRadius = 15
        slideView.delegate = self
        slideView.sliderTextLabel.text = ""
        slideView.textLabel.text = ""

//        slideView.thumbnailViewStartingDistance = -10
        slideView.sliderHolderView.backgroundColor = .zipBlue.withAlphaComponent(0.5) //.zipBlue.withAlphaComponent(0.1)
        slideView.slidingColor = .clear
            //.zipBlue.withAlphaComponent(0.5)
        
        requestedLabel.text = "Requested"
        requestedLabel.textColor = .white
        requestedLabel.textAlignment = .center
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
    

    
    //MARK: - Add Subviews
    public func addSubviews(){
        addSubview(usernameLabel)
        
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
        addSubview(tapToFlipLabel)
    }
    
    //MARK: - Add Constraints
    func configureSubviewLayout(){
        let buffer = CGFloat(10.0)

        // Username label
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: topAnchor, constant: buffer).isActive = true

        // Age label
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor,constant: 5).isActive = true
        ageLabel.leftAnchor.constraint(equalTo: usernameLabel.leftAnchor).isActive = true


        // Profile Picture
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        profilePicture.leftAnchor.constraint(equalTo: usernameLabel.leftAnchor).isActive = true
        profilePicture.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 10).isActive = true
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
        distanceLabel.topAnchor.constraint(equalTo: lastNameLabel.bottomAnchor,constant: 5).isActive = true

        // Right buttons
        zipsButton.translatesAutoresizingMaskIntoConstraints = false
        zipsButton.topAnchor.constraint(equalTo: firstNameLabel.topAnchor).isActive = true
        zipsButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        zipsButton.widthAnchor.constraint(equalToConstant:  60).isActive = true
        
        messageButton.translatesAutoresizingMaskIntoConstraints = false
        messageButton.topAnchor.constraint(equalTo: zipsButton.bottomAnchor, constant: 20).isActive = true
        messageButton.rightAnchor.constraint(equalTo: zipsButton.rightAnchor).isActive = true
        messageButton.widthAnchor.constraint(equalTo: zipsButton.widthAnchor).isActive = true
        
        inviteButton.translatesAutoresizingMaskIntoConstraints = false
        inviteButton.topAnchor.constraint(equalTo: messageButton.bottomAnchor, constant: 20).isActive = true
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
        interestsImage.centerXAnchor.constraint(equalTo: schoolImage.centerXAnchor).isActive = true
        interestsImage.centerYAnchor.constraint(equalTo: interestsLabel.centerYAnchor).isActive = true
        
        interestsLabel.translatesAutoresizingMaskIntoConstraints = false
        interestsLabel.topAnchor.constraint(equalTo: schoolLabel.bottomAnchor, constant: 15).isActive = true
        interestsLabel.rightAnchor.constraint(equalTo: zipsButton.leftAnchor, constant: -10).isActive = true
        interestsLabel.leftAnchor.constraint(equalTo: schoolLabel.leftAnchor).isActive = true

        joinedDateLabel.translatesAutoresizingMaskIntoConstraints = false
        joinedDateLabel.leftAnchor.constraint(equalTo: usernameLabel.leftAnchor).isActive = true
        joinedDateLabel.rightAnchor.constraint(equalTo: interestsLabel.rightAnchor).isActive = true
        joinedDateLabel.bottomAnchor.constraint(equalTo: inviteButton.bottomAnchor).isActive = true
        

        // Bio Label
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.topAnchor.constraint(equalTo: inviteButton.bottomAnchor, constant: 20).isActive = true
        bioLabel.leftAnchor.constraint(equalTo: usernameLabel.leftAnchor).isActive = true
        bioLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -buffer).isActive = true
        bioLabel.bottomAnchor.constraint(lessThanOrEqualTo: slideView.topAnchor).isActive = true
        
        
        // SlideView
        slideView.translatesAutoresizingMaskIntoConstraints = false
        slideView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        slideView.leftAnchor.constraint(equalTo: leftAnchor, constant: buffer).isActive = true
        slideView.rightAnchor.constraint(equalTo: rightAnchor, constant: -buffer).isActive = true
        slideView.heightAnchor.constraint(equalToConstant: 50).isActive = true
  
        tapToFlipLabel.translatesAutoresizingMaskIntoConstraints = false
        tapToFlipLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        tapToFlipLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        
    }

}

//MARK: - Slider Delegate
extension ZFCardBackView: MTSlideToOpenDelegateCopy {
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenViewCopy) {
        print("X end point = \(slideView.xEndingPoint)")
        request()
    }
    
    public func request() {
        guard let user = user else {
            return
        }
        
        user.sendRequest(completion: { [weak self] error in
            guard let strongSelf = self,
                  error == nil else {
                return
            }
            user.friendshipStatus = .REQUESTED_OUTGOING
            strongSelf.requestedUI()
            strongSelf.frontView?.updateRequestButton()
        })
        
        GeoManager.shared.addedOrBlockedUser(user: user)
    }
    
    public func requestedUI() {
        let cfg = UIImage.SymbolConfiguration(pointSize: 50.0)
        guard let imgA = UIImage(systemName: "xmark.circle.fill", withConfiguration: cfg)?.withTintColor(.zipBlue, renderingMode: .alwaysOriginal) else {
            fatalError("Could not load SF Symbol: \("xmark.circle.fill")!")
        }
        
        guard let cgRef = imgA.cgImage else {
            fatalError("Could not get cgImage!")
        }
        
        let imgB = UIImage(cgImage: cgRef, scale: imgA.scale, orientation: imgA.imageOrientation)
                    .withTintColor(.zipBlue, renderingMode: .alwaysOriginal)
        
        requestedLabel.text = "Requested"
        slideView.thumnailImageView.image = imgB
        slideView.thumnailImageView.backgroundColor = .white
        slideView.updateThumbnailXPosition(slideView.xEndingPoint)
        slideView.isFinished = true
        
    }
    
    public func zippedUI() {
        let cfg = UIImage.SymbolConfiguration(pointSize: 50.0)
        guard let imgA = UIImage(systemName: "checkmark.circle.fill", withConfiguration: cfg)?.withTintColor(.zipBlue, renderingMode: .alwaysOriginal) else {
            fatalError("Could not load SF Symbol: \("xmark.circle.fill")!")
        }
        
        guard let cgRef = imgA.cgImage else {
            fatalError("Could not get cgImage!")
        }
        
        let imgB = UIImage(cgImage: cgRef, scale: imgA.scale, orientation: imgA.imageOrientation)
                    .withTintColor(.zipBlue, renderingMode: .alwaysOriginal)
        
        requestedLabel.text = "Zipped"
        slideView.thumnailImageView.image = imgB
        slideView.thumnailImageView.backgroundColor = .white
        slideView.updateThumbnailXPosition(slideView.xEndingPoint)
        print("end point = \(slideView.xEndingPoint)")
        slideView.isFinished = true
    }
    
    public func noStatusUI() {
        slideView.resetStateWithAnimation(true)
        slideView.thumnailImageView.image = UIImage(named: "zipperSlider")
        slideView.thumnailImageView.backgroundColor = .zipBlue
        slideView.isFinished = false
    }
    
    
}
