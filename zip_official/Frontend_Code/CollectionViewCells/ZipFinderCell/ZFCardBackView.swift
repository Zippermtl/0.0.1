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
    let userLoc = CLLocation(latitude: MapViewController.userLoc.latitude, longitude: MapViewController.userLoc.longitude)
    private var birthday: String = ""
    private var dropDownTitles: [String] = []
    
    //MARK: - Labels
    private var firstNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle
        label.numberOfLines = 1
        label.text = "A"
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
    
    //MARK: - Subviews
    private var scrollingContainer = UIView()
    private var profilePicture = UIImageView()
    private var tableView = UITableView()
    private var tableData: [String] = []
    private var userInfoView = UIView()
    private var reportPopUp = DropDown()
    private var reportButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "report"), for: .normal)
        btn.addTarget(self, action: #selector(didTapReportButton), for: .touchUpInside)
        return btn
    }()
    
    private var slideView: MTSlideToOpenView = {
        let slider = MTSlideToOpenView(frame: CGRect(x: 0, y: 0, width: 317, height: 56))
        slider.thumnailImageView.image = UIImage(named: "zipperSlider")
        slider.thumnailImageView.backgroundColor = .clear
        return slider
    }()
    
    //MARK: - Button Actions
    @objc private func didTapReportButton(){
        reportPopUp.show()
        print("report tapped")
    }
    
    @objc private func openProfile(){
        delegate?.openProfile(self.user)
    }
    
    @objc private func unrequestUser(){
        slideView.resetStateWithAnimation(true)
    }
    
    
    public func configure(user: User, cellColor: UIColor){
        backgroundColor = .clear
        layer.cornerRadius = 20
        self.user = user
        self.cellColor = cellColor
        self.profilePicture = UIImageView(image: user.pictures[0])
        
        configureLabels()
        configureTable()
        configureDropDown()
        configureSlider()
        addSubviews()
        configureSubviewLayout()
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
        let name = user.name.components(separatedBy: " ")

        firstNameLabel.text = name[0]
        lastNameLabel.text = name[1]

        ageLabel.text = String(user.age)
        distanceLabel.text = String(Double(round(10*(userLoc.distance(from: user.location))/1000))/10) + " km away"
        distanceLabel.textColor = cellColor
        
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        birthday = dateFormatter.string(from: user.birthday)
        
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
        
        slideView.thumbnailViewStartingDistance = -20
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
    
    //MARK: - Configure Table
    private func configureTable(){
        configureTableData()
        
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileViewController.identifierFirstCell)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileViewController.identifier)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileViewController.identifierWithImage)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorColor = .zipSeparator
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        tableView.tableHeaderView = nil
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 1))
    }
    
    private func configureTableData(){
        tableData.append(user.bio)
        if user.school != nil {
            tableData.append(user.school!)
        }
        
        if user.interests.count != 0 {
            tableData.append("Interests: " + user.interests.map{$0}.joined(separator: ", "))
        }
        
        tableData.append(birthday)
    }
    
    //MARK: - Add Subviews
    private func addSubviews(){
        //Card FrontView
        addSubview(usernameLabel)
        addSubview(reportButton)
        
        scrollingContainer.addSubview(profilePicture)
        scrollingContainer.addSubview(userInfoView)
        userInfoView.addSubview(firstNameLabel)
        userInfoView.addSubview(lastNameLabel)
        userInfoView.addSubview(ageLabel)
        
        userInfoView.addSubview(distanceLabel)
//        distanceView.addSubview(distanceImage)
        
        addSubview(tableView)
        
        addSubview(slideView)

    }

    
    //MARK: - Add Constraints
    private func configureSubviewLayout(){
        let buffer = CGFloat(10.0)

        // Username label
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: topAnchor, constant: buffer).isActive = true

        // Profile Picture
        let pictureHeight = firstNameLabel.intrinsicContentSize.height*2 + ageLabel.intrinsicContentSize.height*2 + buffer
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        profilePicture.leftAnchor.constraint(equalTo: scrollingContainer.leftAnchor).isActive = true
        profilePicture.topAnchor.constraint(equalTo: scrollingContainer.topAnchor).isActive = true
        profilePicture.heightAnchor.constraint(equalToConstant: pictureHeight).isActive = true
        profilePicture.widthAnchor.constraint(equalTo: profilePicture.heightAnchor).isActive = true

        // User Info View
        userInfoView.translatesAutoresizingMaskIntoConstraints = false
        userInfoView.leftAnchor.constraint(equalTo: profilePicture.rightAnchor, constant: buffer).isActive = true
        userInfoView.rightAnchor.constraint(equalTo: scrollingContainer.rightAnchor).isActive = true
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

        // Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.bottomAnchor.constraint(equalTo: slideView.topAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor,constant: 10).isActive = true
        tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true

        //SlideView
        slideView.translatesAutoresizingMaskIntoConstraints = false
        slideView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -buffer).isActive = true
        slideView.leftAnchor.constraint(equalTo: leftAnchor, constant: buffer).isActive = true
        slideView.rightAnchor.constraint(equalTo: rightAnchor, constant: -buffer).isActive = true
        slideView.heightAnchor.constraint(equalToConstant: frame.height/10).isActive = true
        
        //Report Button
        reportButton.translatesAutoresizingMaskIntoConstraints = false
        reportButton.heightAnchor.constraint(equalToConstant: usernameLabel.intrinsicContentSize.height*1.5).isActive = true
        reportButton.widthAnchor.constraint(equalTo: reportButton.heightAnchor).isActive = true
        reportButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -buffer).isActive = true
        reportButton.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor).isActive = true
    }

}

//MARK: - Slider Delegate
extension ZFCardBackView: MTSlideToOpenDelegate {
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        print("should zip here")
    }
    
}

/*
 bioLabel.font = .zipBody.withSize(15)
 schoolLabel.font = .zipBody.withSize(15)
 interestsLabel.font = .zipBody.withSize(15)
 birthdayLabel.font = .zipBody.withSize(15)
 */


//MARK: - Table Delegate
extension ZFCardBackView :  UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return firstNameLabel.intrinsicContentSize.height*2 + ageLabel.intrinsicContentSize.height*2 + 10
        } else {
            return tableData[indexPath.row-1].heightForWrap(width: tableView.frame.width) + 25
        }
    }
}

//MARK: TableDataSource
extension ZFCardBackView :  UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.identifierFirstCell, for: indexPath) as! ProfileTableViewCell
            cell.leftInset = 0
            cell.rightInset = 0
            
            cell.contentView.addSubview(scrollingContainer)
            scrollingContainer.translatesAutoresizingMaskIntoConstraints = false
            scrollingContainer.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor).isActive = true
            scrollingContainer.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor).isActive = true
            scrollingContainer.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
            scrollingContainer.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            
            
            cell.backgroundColor = .clear
//            cell.backgroundColor = .red

            cell.selectionStyle = .none
            cell.clipsToBounds = true
            return cell
            
        } else  {
            switch tableData[indexPath.row-1] {
            case user.school:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.identifierWithImage, for: indexPath) as! ProfileTableViewCell
                cell.textLabel?.text = ""
                cell.configure(with: tableData[indexPath.row-1], image: UIImage(named: "school")!)
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.clipsToBounds = true
                return cell
                
            case birthday:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.identifierWithImage, for: indexPath) as! ProfileTableViewCell
                cell.configure(with: tableData[indexPath.row-1], image: UIImage(named: "birthday")!)
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.clipsToBounds = true
                return cell
            
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.identifier, for: indexPath) as! ProfileTableViewCell
                let label = cell.textLabel!
                label.text = tableData[indexPath.row-1]
                label.textColor = .white
                label.font = .zipBody
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
                label.sizeToFit()
                label.frame = cell.frame
                
                cell.layoutMargins = .zero
                cell.preservesSuperviewLayoutMargins = false

                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.clipsToBounds = true
                return cell
            }
        }
    }

}

