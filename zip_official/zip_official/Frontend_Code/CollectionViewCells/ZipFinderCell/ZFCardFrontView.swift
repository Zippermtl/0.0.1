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
    var userLoc = CLLocation()
    
    
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
        print("unzip \(user.firstName) \(user.lastName)")
        zipButton.isHidden = false
        requestedButton.isHidden = true
    }
    
    @objc private func didTapZipButton(){
        zipButton.isHidden = true
        requestedButton.isHidden = false
        print("unzip \(user.firstName) \(user.lastName)")
    }
    
    //MARK: - Configure
    public func configure(user: User, cellColor: UIColor, loc: CLLocation){
        backgroundColor = .clear
        layer.cornerRadius = 20
        
        self.user = user
        self.cellColor = cellColor
        userLoc = loc
        
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
        
//        let name = user.name.components(separatedBy: " ")
//        self.firstNameLabel.text = name[0]
//        self.lastNameLabel.text = name[1]
        
        firstNameLabel.text = user.firstName
        lastNameLabel.text = user.lastName

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
                distanceLabel.text = "<1 \(unit)"
            } else if distance >= 500 {
                distanceLabel.text = ">500 \(unit)"
            } else {
                distanceLabel.text = String(intDistance) + " \(unit)"
            }
            distanceLabel.textColor = cellColor
        } else {
            if distance <= 1 {
                if unit == "miles" {
                    unit = "mile"
                }
                distanceLabel.text = "<1 \(unit)"
            } else if distance >= 500 {
                distanceLabel.text = ">500 \(unit)"
            } else {
                distanceLabel.text = String(distance) + " \(unit)"
            }
            distanceLabel.textColor = cellColor
        }
       
        bioLabel.text = user.bio

    }
    
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
    
    //MARK: - PictureCofig
    private func configurePictures(){
        pictureCollectionLayout.scrollDirection = .horizontal
        let size = UIScreen.main.bounds.width-25 //AWFUL CODE --> autolayout is super weird with collectionView cells
        pictureCollectionLayout.itemSize = CGSize(width: size, height: size)
        pictureCollectionView.collectionViewLayout = pictureCollectionLayout
        
        pictureCollectionView.register(PictureCollectionViewCell.self, forCellWithReuseIdentifier: PictureCollectionViewCell.identifier)
        pictureCollectionView.dataSource = self
        pictureCollectionView.isOpaque = true
        pictureCollectionView.backgroundColor = .clear
        pictureCollectionView.decelerationRate = .fast
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
        let buffer = CGFloat(10.0)
        
        firstNameLabel.translatesAutoresizingMaskIntoConstraints = false
        firstNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        firstNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: buffer).isActive = true
        firstNameLabel.heightAnchor.constraint(equalToConstant: firstNameLabel.intrinsicContentSize.height).isActive = true
        
        lastNameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastNameLabel.topAnchor.constraint(equalTo: firstNameLabel.bottomAnchor).isActive = true
        lastNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: buffer).isActive = true

        pictureCollectionView.translatesAutoresizingMaskIntoConstraints = false
        pictureCollectionView.topAnchor.constraint(equalTo: lastNameLabel.bottomAnchor, constant: 5).isActive = true
        pictureCollectionView.heightAnchor.constraint(equalTo: pictureCollectionView.widthAnchor).isActive = true
        pictureCollectionView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
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
    
        let bioLabelHeight = frame.height - pictureCollectionView.frame.maxY - distanceLabel.intrinsicContentSize.height - 25
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 2).isActive = true
        bioLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: buffer).isActive = true
        bioLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -buffer).isActive = true
        bioLabel.heightAnchor.constraint(lessThanOrEqualToConstant: bioLabelHeight).isActive = true
        
        tapToFlipLabel.translatesAutoresizingMaskIntoConstraints = false
        tapToFlipLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        tapToFlipLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        swipeToViewLabel.translatesAutoresizingMaskIntoConstraints = false
        swipeToViewLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        swipeToViewLabel.topAnchor.constraint(equalTo: pictureCollectionView.bottomAnchor).isActive = true

    }

}

//MARK: - Picture Datasource
extension ZFCardFrontView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = user.pictureURLs[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PictureCollectionViewCell.identifier, for: indexPath) as! PictureCollectionViewCell
        
        cell.configure(with: model)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return user.pictureURLs.count
    }
}
