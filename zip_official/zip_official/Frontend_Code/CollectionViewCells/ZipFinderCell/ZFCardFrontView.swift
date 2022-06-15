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
    //User
    private var user: User?
    
    //MARK: - Subviews
    private var pictureCollectionLayout: SnappingFlowLayout
    var pictureCollectionView: UICollectionView
    private var reportPopUp: DropDown
    private var dropDownTitles: [String]
    
    
    //MARK: - Labels
    private var firstNameLabel: UILabel
    private var lastNameLabel: UILabel
    private var distanceLabel: DistanceLabel
    private var bioLabel: UILabel
    private var tapToFlipLabel: UILabel
    private var swipeToViewLabel: UILabel
    
    //MARK: - Button
    private var reportButton: UIButton
    private var zipButton: UIButton
    private var requestedButton: UIButton
    
    //MARK: - Button Actions
    @objc private func didTapReportButton(){
        reportPopUp.show()
        print("report tapped")
    }
    
    @objc private func didTapRequestedButton(){
        print("requested \(user?.firstName) \(user?.lastName)")
        
        //TODO: Update with nics new code
//        selfUser.requestFriend(to: user, completion: { error in
//
//
//        })
        zipButton.isHidden = false
        requestedButton.isHidden = true
    }
    
    @objc private func didTapZipButton(){
        zipButton.isHidden = true
        requestedButton.isHidden = false
        print("unzip \(user?.firstName) \(user?.lastName)")
    }
    
    init() {
        firstNameLabel = UILabel.zipHeader()
        lastNameLabel = UILabel.zipHeader()
        bioLabel = UILabel.zipTextFill()
        distanceLabel = DistanceLabel()
        tapToFlipLabel = UILabel.zipTextPrompt()
        swipeToViewLabel = UILabel.zipTextPrompt()
        dropDownTitles = []
        reportButton = UIButton()
        reportPopUp = DropDown()
        requestedButton = UIButton()
        zipButton = UIButton()
        pictureCollectionView = UICollectionView(frame: .zero, collectionViewLayout: SnappingFlowLayout())
        pictureCollectionLayout = SnappingFlowLayout()
        
        super.init(frame: .zero)
        layer.cornerRadius = 20
        
        swipeToViewLabel.text = "swipe →"
        tapToFlipLabel.text = "tap to flip"
        
        reportButton.setImage(UIImage(named: "report"), for: .normal)
        reportButton.addTarget(self, action: #selector(didTapReportButton), for: .touchUpInside)
       
        
        configurePictures()
        configureDropDown()
        addSubviews()
        configureSubviewLayout()
        
        requestedButton.frame = CGRect(x: 0, y: 0, width: 75, height: 20)
        requestedButton.layer.cornerRadius = 10
        requestedButton.setTitle("Requested", for: .normal)
        requestedButton.setTitleColor(.white, for: .normal)
        requestedButton.titleLabel?.font = .zipBodyBold
        requestedButton.addTarget(self, action: #selector(didTapRequestedButton), for: .touchUpInside)
        requestedButton.backgroundColor = .zipGreen
        requestedButton.isHidden = true
        
        
        zipButton.setImage(UIImage(named: "addFilled"), for: .normal)
        zipButton.addTarget(self, action: #selector(didTapZipButton), for: .touchUpInside)

        backgroundColor = .clear
        layer.cornerRadius = 20
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configure
    public func configure(user: User){
       
        
        self.user = user

        
        zipButton.isHidden = false
        requestedButton.isHidden = true
        
        configureLabels()
        
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
        
        guard let user = user else {
            return
        }
                
        firstNameLabel.text = user.firstName
        lastNameLabel.text = user.lastName
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
        addSubview(tapToFlipLabel)
        addSubview(swipeToViewLabel)
        
    }


    //MARK: Add Constranits
    func configureSubviewLayout() {
        let buffer = CGFloat(15.0)
        
        firstNameLabel.translatesAutoresizingMaskIntoConstraints = false
        firstNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        firstNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: buffer).isActive = true
        firstNameLabel.heightAnchor.constraint(equalToConstant: firstNameLabel.intrinsicContentSize.height).isActive = true
        
        lastNameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastNameLabel.topAnchor.constraint(equalTo: firstNameLabel.bottomAnchor).isActive = true
        lastNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: buffer).isActive = true

        pictureCollectionView.translatesAutoresizingMaskIntoConstraints = false
        pictureCollectionView.topAnchor.constraint(equalTo: lastNameLabel.bottomAnchor, constant: 10).isActive = true
        pictureCollectionView.heightAnchor.constraint(equalTo: pictureCollectionView.widthAnchor).isActive = true
        pictureCollectionView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        reportButton.translatesAutoresizingMaskIntoConstraints = false
        reportButton.heightAnchor.constraint(equalToConstant: firstNameLabel.intrinsicContentSize.height*1.5).isActive = true
        reportButton.widthAnchor.constraint(equalTo: reportButton.heightAnchor).isActive = true
        reportButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -buffer).isActive = true
        reportButton.centerYAnchor.constraint(equalTo: firstNameLabel.bottomAnchor).isActive = true
        
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
        
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.leftAnchor.constraint(equalTo: bioLabel.leftAnchor).isActive = true
        distanceLabel.topAnchor.constraint(equalTo: pictureCollectionView.bottomAnchor, constant: 2).isActive = true
        

    
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 5).isActive = true
        bioLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: buffer).isActive = true
        bioLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -buffer).isActive = true
        bioLabel.bottomAnchor.constraint(lessThanOrEqualTo: tapToFlipLabel.topAnchor).isActive = true
        
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
        guard let user = user else {
            return UICollectionViewCell()
        }
        
        let model = user.pictureURLs[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PictureCollectionViewCell.identifier, for: indexPath) as! PictureCollectionViewCell
        
        cell.configure(with: model)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let user = user else {
            return 0
        }
        
        return user.pictureURLs.count
    }
}
