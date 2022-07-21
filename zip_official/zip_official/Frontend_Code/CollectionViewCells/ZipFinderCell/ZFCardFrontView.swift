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
import DropDown
import UIImageCropper

class ZFCardFrontView: UIView {
    //User
    private var user: User?
    
    //MARK: - Subviews
    private var pictureCollectionLayout: SnappingFlowLayout
    var pictureCollectionView: UICollectionView
    private var reportPopUp: DropDown
    private var dropDownTitles: [String]
    
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
        reportPopUp.show()
        print("report tapped")
    }
    
    @objc private func didTapRequestButton(){
        guard let user = user else {
            return
        }

        var nm = ""
        var tintColor = UIColor.white
        switch user.friendshipStatus {
        case .none:
            nm = "arrow.forward.circle.fill"
            user.friendshipStatus = .REQUESTED_OUTGOING
            tintColor = .zipBlue
            requestButton.backgroundColor = .white
            requestButton.layer.borderWidth = 2
        case .ACCEPTED:
            nm =  "plus.circle.fill"
            user.friendshipStatus = nil
            tintColor = .white
            requestButton.backgroundColor = .zipBlue
            requestButton.layer.borderWidth = 0
            
        case .REQUESTED_INCOMING:
            nm = "checkmark.circle.fill"
            user.friendshipStatus = .ACCEPTED
            tintColor = .zipBlue
            requestButton.backgroundColor = .white
            requestButton.layer.borderWidth = 2
        case .REQUESTED_OUTGOING:
            nm = "plus.circle.fill"
            user.friendshipStatus = nil
            tintColor = .white
            requestButton.backgroundColor = .zipBlue
            requestButton.layer.borderWidth = 0
        }
                
        // create UIImage from SF Symbol at "160-pts" size
        let cfg = UIImage.SymbolConfiguration(pointSize: 50.0)
        guard let imgA = UIImage(systemName: nm, withConfiguration: cfg)?.withTintColor(tintColor, renderingMode: .alwaysOriginal) else {
            fatalError("Could not load SF Symbol: \(nm)!")
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
        dropDownTitles = []
        reportButton = UIButton()
        reportPopUp = DropDown()
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
        configureDropDown()
        addSubviews()
        configureSubviewLayout()
    
        
        
        pictureCollectionView.backgroundColor = .zipBlue
        
        // create UIImage from SF Symbol at "160-pts" size
        let cfg = UIImage.SymbolConfiguration(pointSize: 50.0)
        guard let imgA = UIImage(systemName: "plus.circle.fill", withConfiguration: cfg)?.withTintColor(.white, renderingMode: .alwaysOriginal) else {
            fatalError("Could not load SF Symbol: \("plus.circle.fill")!")
        }
        
        guard let cgRef = imgA.cgImage else {
            fatalError("Could not get cgImage!")
        }
        
        let imgB = UIImage(cgImage: cgRef, scale: imgA.scale, orientation: imgA.imageOrientation)
                    .withTintColor(.white, renderingMode: .alwaysOriginal)
        
        requestButton.setImage(imgB, for: .normal)
        
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
    
    private func configureDropDown(){
//        let name = user.name.components(separatedBy: " ")
//        dropDownTitles = ["Report \(name[0])",
//                          "Block \(name[0])",
//                          "Don't show me \(name[0])"]
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
        
        let model = user.otherPictureUrls[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PictureCollectionViewCell.identifier, for: indexPath) as! PictureCollectionViewCell
        
        cell.configure(with: model)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let user = user else {
            return 0
        }
        
        return user.otherPictureUrls.count
    }
}
