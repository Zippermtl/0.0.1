//
//  ZFviewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/28/21.
//

import Foundation
import UIKit
import MapKit
import MTSlideToOpen
import UIImageCropper

protocol ZFCardFrontDelegate: AnyObject {
    func presentReport(user: User)
}

class ZFCardFrontView: UIView {
    //User
    private var user: User?
    var backView: ZFCardBackView?
    var delegate: ZFCardFrontDelegate?

    //MARK: - Subviews
    private var pictureCollectionLayout: SnappingFlowLayout
    var pictureCollectionView: UICollectionView
    
    private var fadedBG: UIView
    //MARK: - Labels
    private var nameLabel: UILabel
    private var distanceLabel: DistanceLabel
    private var bioLabel: UILabel
    private var tapToFlipLabel: UILabel
    private var swipeToViewLabel: UILabel
    
    //MARK: - Button
    private var reportButton: UIButton
    private var requestButton: UIButton
    
    //MARK: - Button Actions
    @objc private func didTapReportButton(){
        guard let user = user else {
            return
        }
        delegate?.presentReport(user: user)
    }
    
    @objc private func didTapRequestButton(){
        guard let user = user else {
            return
        }

        switch user.friendshipStatus {
        case .none:
            user.sendRequest(completion: { [weak self] error in
                guard let strongSelf = self,
                      error == nil else {
                    return
                }
                user.friendshipStatus = .REQUESTED_OUTGOING
                strongSelf.updateRequestButton()
                strongSelf.backView?.requestedUI()
            })
            
        case .ACCEPTED:
            user.unsendRequest(completion: { [weak self] error in
                guard let strongSelf = self,
                      error == nil else {
                    return
                }
                user.friendshipStatus = nil
                strongSelf.updateRequestButton()
                strongSelf.backView?.noStatusUI()
            })
        case .REQUESTED_INCOMING:
            user.acceptRequest(completion: { [weak self] error in
                guard let strongSelf = self,
                      error == nil else {
                    return
                }
                user.friendshipStatus = .ACCEPTED
                strongSelf.updateRequestButton()
                strongSelf.backView?.zippedUI()

            })
        case .REQUESTED_OUTGOING:
            user.unsendRequest(completion: { [weak self] error in
                guard let strongSelf = self,
                      error == nil else {
                    return
                }
                user.friendshipStatus = nil
                strongSelf.updateRequestButton()
                strongSelf.backView?.noStatusUI()
            })
        }
    }
    
    private func updateRequestButtonImage(name: String, tintColor: UIColor) {
        // create UIImage from SF Symbol at "160-pts" size
        let cfg = UIImage.SymbolConfiguration(pointSize: 50.0)
        guard let imgA = UIImage(systemName: name, withConfiguration: cfg)?.withTintColor(tintColor, renderingMode: .alwaysOriginal) else {
            fatalError("Could not load SF Symbol: \(name)!")
        }
        
        guard let cgRef = imgA.cgImage else {
            fatalError("Could not get cgImage!")
        }
        
        let imgB = UIImage(cgImage: cgRef, scale: imgA.scale, orientation: imgA.imageOrientation)
                    .withTintColor(tintColor, renderingMode: .alwaysOriginal)
        
        requestButton.setImage(imgB, for: .normal)
    }
    

    
    init() {
        nameLabel = UILabel.zipHeader()
        bioLabel = UILabel.zipTextFill()
        distanceLabel = DistanceLabel()
        tapToFlipLabel = UILabel.zipTextPrompt()
        swipeToViewLabel = UILabel.zipTextPrompt()
        reportButton = UIButton()
        requestButton = UIButton()
        pictureCollectionView = UICollectionView(frame: .zero, collectionViewLayout: SnappingFlowLayout())
        pictureCollectionLayout = SnappingFlowLayout()
        fadedBG = UIView()
        
        super.init(frame: .zero)
        layer.cornerRadius = 20
        
        fadedBG.backgroundColor = .zipGray.withAlphaComponent(0.8)
        
        swipeToViewLabel.text = "swipe →"
        tapToFlipLabel.text = "tap to flip"
        
        let reportConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
        reportButton.setImage(UIImage(systemName: "ellipsis",withConfiguration: reportConfig)?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        reportButton.addTarget(self, action: #selector(didTapReportButton), for: .touchUpInside)
        
        configurePictures()
        addSubviews()
        configureSubviewLayout()
    
        
        pictureCollectionView.backgroundColor = .clear
        pictureCollectionView.alwaysBounceHorizontal = true

        
        requestButton.addTarget(self, action: #selector(didTapRequestButton), for: .touchUpInside)
        requestButton.layer.masksToBounds = true
        requestButton.backgroundColor = .zipBlue
        
        requestButton.imageView?.contentMode = .scaleAspectFill
        
        requestButton.layer.shadowColor = UIColor.black.cgColor
        requestButton.layer.shadowOpacity = 0.5
        requestButton.layer.shadowOffset = CGSize(width: 1, height: 4)
        requestButton.layer.shadowRadius = 2
        requestButton.layer.masksToBounds = false
        
        requestButton.layer.borderColor = UIColor.white.cgColor


        nameLabel.numberOfLines = 0
        
        bioLabel.numberOfLines = 3
        bioLabel.lineBreakMode = .byWordWrapping

        backgroundColor = .clear
        layer.cornerRadius = 20
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        requestButton.layer.cornerRadius = requestButton.frame.height/2
    }
    
    
    //MARK: - Configure
    public func configure(user: User){
        self.user = user
        configureLabels()
        updateRequestButton()
        pictureCollectionView.reloadData()
    }
    
    public func updateRequestButton() {
        switch user?.friendshipStatus {
        case .none:
            updateRequestButtonImage(name: "plus.circle.fill", tintColor: .white)
            requestButton.backgroundColor = .zipBlue
            requestButton.layer.borderWidth = 0
        case .ACCEPTED:
            updateRequestButtonImage(name: "checkmark.circle.fill", tintColor: .zipBlue)
            requestButton.backgroundColor = .white
            requestButton.layer.borderWidth = 0
        case .REQUESTED_INCOMING:
            updateRequestButtonImage(name: "plus.circle.fill", tintColor: .white)
            requestButton.backgroundColor = .zipBlue
            requestButton.layer.borderWidth = 0
        case .REQUESTED_OUTGOING:
            updateRequestButtonImage(name: "arrow.forward.circle.fill", tintColor: .zipYellow)
            requestButton.backgroundColor = .white
            requestButton.layer.borderWidth = 2
        }
    }
    
    private func configureLabels(){
        //if you're a shitty person and have a home button
//        if AppDelegate.userDefaults.bool(forKey: "hasHomeButton"){
//            firstNameLabel.font = .zipTitle.withSize(20)
//            lastNameLabel.font = .zipTitle.withSize(20)
//            distanceLabel.font =  .zipTitle.withSize(16)
//            bioLabel.font = .zipBody.withSize(15)
//            tapToFlipLabel.font = .zipBody.withSize(10)
//            swipeToViewLabel.font = .zipBody.withSize(10)
//        }
//        
        guard let user = user else {
            return
        }
                
        nameLabel.text = user.firstName + "\n" + user.lastName
        distanceLabel.update(distance: user.getDistance())
        bioLabel.text = user.bio

    }
    
  
    
    //MARK: - PictureCofig
    private func configurePictures(){
        pictureCollectionLayout.scrollDirection = .horizontal
        let size = UIScreen.main.bounds.width-25 //AWFUL CODE --> autolayout is super weird with collectionView cells
        pictureCollectionLayout.itemSize = CGSize(width: size, height: size/UIImageCropper.CROP_RATIO)
        pictureCollectionView.collectionViewLayout = pictureCollectionLayout
        
        pictureCollectionView.register(PictureCollectionViewCell.self, forCellWithReuseIdentifier: PictureCollectionViewCell.identifier)
        pictureCollectionView.dataSource = self
        pictureCollectionView.isOpaque = true
        pictureCollectionView.backgroundColor = .clear
        pictureCollectionView.decelerationRate = .fast
        pictureCollectionView.layer.masksToBounds = true
    }
    
    //MARK: - Add Subviews
    private func addSubviews(){
        //Card FrontView
        addSubview(pictureCollectionView)

        addSubview(nameLabel)
        addSubview(reportButton)
        
        addSubview(fadedBG)

        fadedBG.addSubview(distanceLabel)
        fadedBG.addSubview(bioLabel)
        fadedBG.addSubview(tapToFlipLabel)

        
        addSubview(requestButton)
        
        
        addSubview(swipeToViewLabel)
    }


    //MARK: Add Constranits
    func configureSubviewLayout() {
        let buffer = CGFloat(15.0)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: buffer).isActive = true
        
        pictureCollectionView.translatesAutoresizingMaskIntoConstraints = false
        pictureCollectionView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10).isActive = true
        pictureCollectionView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        pictureCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
//        pictureCollectionView.heightAnchor.constraint(equalTo: pictureCollectionView.widthAnchor, multiplier: 1/UIImageCropper.CROP_RATIO).isActive = true
        
        reportButton.translatesAutoresizingMaskIntoConstraints = false
//        reportButton.heightAnchor.constraint(equalToConstant: name.intrinsicContentSize.height*1.5).isActive = true
//        reportButton.widthAnchor.constraint(equalTo: reportButton.heightAnchor).isActive = true
        reportButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -buffer).isActive = true
        reportButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true

        fadedBG.translatesAutoresizingMaskIntoConstraints = false
        fadedBG.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        fadedBG.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        fadedBG.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        fadedBG.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.leftAnchor.constraint(equalTo: fadedBG.leftAnchor, constant: buffer).isActive = true
        distanceLabel.topAnchor.constraint(equalTo: fadedBG.topAnchor, constant: 10).isActive = true
        
        tapToFlipLabel.translatesAutoresizingMaskIntoConstraints = false
        tapToFlipLabel.centerXAnchor.constraint(equalTo: fadedBG.centerXAnchor).isActive = true
        tapToFlipLabel.bottomAnchor.constraint(equalTo: fadedBG.bottomAnchor, constant: -5).isActive = true

        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.leftAnchor.constraint(equalTo: distanceLabel.leftAnchor).isActive = true
        bioLabel.rightAnchor.constraint(equalTo: fadedBG.rightAnchor, constant: -buffer).isActive = true
        bioLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 10).isActive = true
        
        swipeToViewLabel.translatesAutoresizingMaskIntoConstraints = false
        swipeToViewLabel.rightAnchor.constraint(equalTo: fadedBG.rightAnchor, constant: -15).isActive = true
        swipeToViewLabel.centerYAnchor.constraint(equalTo: distanceLabel.centerYAnchor).isActive = true
        
        requestButton.translatesAutoresizingMaskIntoConstraints = false
        requestButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        requestButton.heightAnchor.constraint(equalTo: requestButton.widthAnchor).isActive = true
        requestButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        requestButton.bottomAnchor.constraint(equalTo: fadedBG.topAnchor, constant: -15).isActive = true
    }

}

//MARK: - Picture Datasource
extension ZFCardFrontView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let user = user else {
            return UICollectionViewCell()
        }
        print("getting here at least")
        
        var model: URL?
        if user.otherPictureUrls.count == 0 {
            model = nil
        } else {
            model = user.otherPictureUrls[indexPath.row]
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PictureCollectionViewCell.identifier, for: indexPath) as! PictureCollectionViewCell
        
        cell.configure(with: model)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let user = user else {
            return 0
        }
        if user.otherPictureUrls.count != 0 {
            return user.otherPictureUrls.count
        }
        return 1
    }
}
