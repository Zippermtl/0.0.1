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

class ZFCardFrontView: UIView {
    // MARK: - Cell Data
    // Color
    var cellColor = UIColor.zipBlue.withAlphaComponent(1)
    
    //User
    private var user = User()
    let userLoc = CLLocation(latitude: MapViewController.userLoc.latitude, longitude: MapViewController.userLoc.longitude)
    
    
    //MARK: - Subviews
    
    
    
    private var pictureCollectionLayout = SnappingFlowLayout()
    var pictureCollectionView = UICollectionView(frame: .zero, collectionViewLayout: SnappingFlowLayout())
    private var distanceImage = UIImageView(image: UIImage(named: "distanceToWhite"))
    private var reportPopUp = DropDown()
    private var dropDownTitles: [String] = []
    
    
    //MARK: - Labels
    private var firstNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle
        return label
    }()
    
    private var lastNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    
    
    
    private var distanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.lineBreakMode = .byCharWrapping
        label.text = "A"
        return label
    }()
    
    
    private var bioLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.font = .zipBody
        return label
    }()
    
    private var tapToFlipLabel: UILabel = {
        let label = UILabel()
        label.textColor = .zipVeryLightGray
        label.numberOfLines = 0
        label.font = .zipBody.withSize(15)
        label.text = "tap to flip"
        return label
    }()
    
    private var swipeToViewLabel: UILabel = {
        let label = UILabel()
        label.textColor = .zipVeryLightGray
        label.numberOfLines = 0
        label.font = .zipBody.withSize(15)
        label.text = "swipe →"
        return label
    }()
    
    //MARK: - Button
    private var reportButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "report"), for: .normal)
        btn.addTarget(self, action: #selector(didTapReportButton), for: .touchUpInside)
        return btn
    }()
    
    private var zipButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "addFilled"), for: .normal)
        btn.addTarget(self, action: #selector(didTapZipButton), for: .touchUpInside)
        return btn
    }()
    
    private var requestedButton: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 0, y: 0, width: 75, height: 20)
        btn.layer.cornerRadius = 10
        btn.setTitle("Requested", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .zipBodyBold
        btn.addTarget(self, action: #selector(didTapRequestedButton), for: .touchUpInside)
        btn.backgroundColor = .zipGreen
        btn.isHidden = true
        return btn
    }()
    
    //MARK: - Button Actions
    @objc private func didTapReportButton(){
        reportPopUp.show()
        print("report tapped")
    }
    
    @objc private func didTapRequestedButton(){
        print("unzip \(user.name)")
        zipButton.isHidden = false
        requestedButton.isHidden = true
    }
    
    @objc private func didTapZipButton(){
        zipButton.isHidden = true
        requestedButton.isHidden = false
        print("zip \(user.name)")
    }
    
    //MARK: - Configure
    public func configure(user: User, cellColor: UIColor){
        backgroundColor = .clear
        layer.cornerRadius = 20
        
        self.user = user
        self.cellColor = cellColor
        
        zipButton.isHidden = false
        requestedButton.isHidden = true
        
        configureLabels()
        configurePictures()
        configureDropDown()
        addSubviews()
        configureSubviewLayout()
    }
    
    private func configureLabels(){
        //if you're a shitty person and have a home button
        if AppDelegate.userDefaults.bool(forKey: "hasHomeButton"){
            firstNameLabel.font = .zipTitle.withSize(20)
            lastNameLabel.font = .zipTitle.withSize(20)
            distanceLabel.font =  .zipTitle.withSize(16)
            bioLabel.font = .zipBody.withSize(15)
            tapToFlipLabel.font = .zipBody.withSize(10)
            swipeToViewLabel.font = .zipBody.withSize(10)
        }
        
        let name = user.name.components(separatedBy: " ")
        self.firstNameLabel.text = name[0]
        self.lastNameLabel.text = name[1]

       
        let distance = Double(round(10*(userLoc.distance(from: user.location))/1000))/10
        
        self.distanceLabel.text = String(distance) + " km"
        self.bioLabel.text = user.bio
    }
    
    private func configureDropDown(){
        let name = user.name.components(separatedBy: " ")
        dropDownTitles = ["Report \(name[0])",
                          "Block \(name[0])",
                          "Don't show me \(name[0])"]
        
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
        pictureCollectionLayout.itemSize = CGSize(width: frame.size.width, height: frame.size.width)
        
        pictureCollectionView.collectionViewLayout = pictureCollectionLayout
        
        self.pictureCollectionView.register(PictureCollectionViewCell.self, forCellWithReuseIdentifier: PictureCollectionViewCell.identifier)
        pictureCollectionView.dataSource = self
        pictureCollectionView.isOpaque = true
        pictureCollectionView.backgroundColor = .clear
    }
    
    //MARK: - Add Subviews
    private func addSubviews(){
        //Card FrontView
        addSubview(pictureCollectionView)

        addSubview(firstNameLabel)
        addSubview(lastNameLabel)
        addSubview(reportButton)

        addSubview(distanceLabel)
        addSubview(bioLabel)
        addSubview(zipButton)
        addSubview(requestedButton)
        addSubview(distanceImage)
        addSubview(tapToFlipLabel)
        addSubview(swipeToViewLabel)
        
    }


    //MARK: Add Constranits
    func configureSubviewLayout() {
        let width = frame.size.width
        let height = frame.size.height
        
        pictureCollectionView.frame = CGRect(x: 0, y: height/2-width/2 - 20 , width: width, height: width)
        let buffer = CGFloat(10.0)
        
        //Labels
        lastNameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastNameLabel.bottomAnchor.constraint(equalTo: pictureCollectionView.topAnchor, constant: -buffer).isActive = true
        lastNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: buffer).isActive = true
//        lastNameLabel.heightAnchor.constraint(equalToConstant: firstNameLabel.intrinsicContentSize.height).isActive = true
        lastNameLabel.rightAnchor.constraint(lessThanOrEqualTo: zipButton.leftAnchor).isActive = true
        
        
        
        firstNameLabel.translatesAutoresizingMaskIntoConstraints = false
        firstNameLabel.bottomAnchor.constraint(equalTo: lastNameLabel.topAnchor).isActive = true
        firstNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: buffer).isActive = true
        firstNameLabel.heightAnchor.constraint(equalToConstant: firstNameLabel.intrinsicContentSize.height).isActive = true

        reportButton.translatesAutoresizingMaskIntoConstraints = false
        reportButton.heightAnchor.constraint(equalToConstant: firstNameLabel.intrinsicContentSize.height*1.5).isActive = true
        reportButton.widthAnchor.constraint(equalTo: reportButton.heightAnchor).isActive = true
        reportButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -buffer).isActive = true
        reportButton.centerYAnchor.constraint(equalTo: firstNameLabel.centerYAnchor).isActive = true
        
        zipButton.translatesAutoresizingMaskIntoConstraints = false
        zipButton.heightAnchor.constraint(equalTo: reportButton.heightAnchor,multiplier: 0.8).isActive = true
        zipButton.widthAnchor.constraint(equalTo: zipButton.heightAnchor).isActive = true
        zipButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -buffer/2).isActive = true
        zipButton.bottomAnchor.constraint(equalTo: pictureCollectionView.bottomAnchor, constant: -buffer/2).isActive = true
        
        requestedButton.translatesAutoresizingMaskIntoConstraints = false
        requestedButton.heightAnchor.constraint(equalTo: reportButton.heightAnchor).isActive = true
        requestedButton.widthAnchor.constraint(equalTo: zipButton.heightAnchor).isActive = true
        requestedButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -buffer/2).isActive = true
        requestedButton.bottomAnchor.constraint(equalTo: pictureCollectionView.bottomAnchor, constant: -buffer/2).isActive = true
        
        distanceLabel.textColor = cellColor
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.leftAnchor.constraint(equalTo: distanceImage.rightAnchor).isActive = true
        distanceLabel.topAnchor.constraint(equalTo: pictureCollectionView.bottomAnchor, constant: 2).isActive = true
        
        distanceImage.image = distanceImage.image?.withTintColor(cellColor)
        distanceImage.translatesAutoresizingMaskIntoConstraints = false
        distanceImage.centerYAnchor.constraint(equalTo: distanceLabel.centerYAnchor).isActive = true
        distanceImage.leftAnchor.constraint(equalTo: leftAnchor, constant: buffer).isActive = true
        distanceImage.heightAnchor.constraint(equalToConstant: distanceLabel.intrinsicContentSize.height).isActive = true
        distanceImage.widthAnchor.constraint(equalTo: distanceImage.heightAnchor).isActive = true
    
        let bioLabelHeight = self.frame.height - pictureCollectionView.frame.maxY - distanceLabel.intrinsicContentSize.height - 25
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 2).isActive = true
        bioLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: buffer).isActive = true
        bioLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bioLabel.heightAnchor.constraint(lessThanOrEqualToConstant: bioLabelHeight).isActive = true
        
        tapToFlipLabel.translatesAutoresizingMaskIntoConstraints = false
        tapToFlipLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        tapToFlipLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        swipeToViewLabel.translatesAutoresizingMaskIntoConstraints = false
        swipeToViewLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        swipeToViewLabel.topAnchor.constraint(equalTo: pictureCollectionView.bottomAnchor).isActive = true
    }
    
}


//MARK: - Picture Datasource
extension ZFCardFrontView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = user.pictures[indexPath.row%user.pictures.count]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PictureCollectionViewCell.identifier, for: indexPath) as! PictureCollectionViewCell
        
        cell.configure(with:model)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return user.pictures.count
    }
}
