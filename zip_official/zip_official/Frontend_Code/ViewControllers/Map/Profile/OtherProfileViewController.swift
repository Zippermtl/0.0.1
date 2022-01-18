//
//  SecondViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/2/21.
//


import UIKit
import MapKit
import CoreLocation
import SDWebImage
import JGProgressHUD
import MTSlideToOpen

class OtherProfileViewController: UIViewController {
    private var user = User()
    
    // MARK: - SubViews

    //    private var pictureCollectionView: UICollectionView!
    private let tableView = UITableView()
    private let tableHeader = UIView()
    private let profilePictureView = UIImageView()
    private let spinner = JGProgressHUD(style: .light)
    
    private var needsLoadUser = false
    
    private var distanceImage = UIImageView(image: UIImage(named: "distanceToWhite")?.withTintColor(.zipBlue))

    private var distanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.lineBreakMode = .byCharWrapping
        label.text = "A"
        label.textColor = .zipBlue
        return label
    }()
    
    // MARK: - Labels
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle
        label.sizeToFit()
        return label
    }()

    
    private let ageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(26)
        label.sizeToFit()
        return label
    }()
    
    private var slideView: MTSlideToOpenView = {
        let slider = MTSlideToOpenView(frame: CGRect(x: 0, y: 0, width: 317, height: 56))
        slider.thumnailImageView.image = UIImage(named: "zipperSlider")
        slider.thumnailImageView.backgroundColor = .clear
        slider.backgroundColor = .zipGray
        return slider
    }()
    
    // MARK: - Buttons
    private let messageButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .zipLightGray
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .large)
        let img = UIImage(systemName: "message", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        let icon = UIImageView(image: img)
        icon.isExclusiveTouch = false
        icon.isUserInteractionEnabled = false
        
        btn.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.centerXAnchor.constraint(equalTo: btn.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: btn.centerYAnchor).isActive = true

        btn.layer.masksToBounds = true
        return btn
    }()
    
    private let messageHolder = UIView()

    
    private let photosButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .zipLightGray
        btn.layer.masksToBounds = true
        return btn
    }()
    
    
    private let zipsButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .zipLightGray
        
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        let img = UIImage(systemName: "person.3.fill", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        let icon = UIImageView(image: img)
        icon.isExclusiveTouch = false
        icon.isUserInteractionEnabled = false
        
        btn.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.centerXAnchor.constraint(equalTo: btn.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: btn.centerYAnchor).isActive = true

        btn.layer.masksToBounds = true
        return btn
    }()
    
    private let myEventsButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .zipLightGray
        
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        let img = UIImage(systemName: "envelope.open", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        let icon = UIImageView(image: img)
        icon.isExclusiveTouch = false
        icon.isUserInteractionEnabled = false
        
        btn.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.centerXAnchor.constraint(equalTo: btn.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: btn.centerYAnchor).isActive = true

        btn.layer.masksToBounds = true
        return btn
    }()
    
    private let photoCountLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .zipVeryLightGray
        label.layer.masksToBounds = true
        label.text = "1"
        label.font = .zipBody
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let myEventsLabel: UILabel = {
        let label = UILabel()
        label.text = "Invite"
        label.font = .zipBody.withSize(16)
        label.textColor = .white
        return label
    }()
    
    private let photosLabel: UILabel = {
        let label = UILabel()
        label.text = "Photos"
        label.font = .zipBody.withSize(16)
        label.textColor = .white
        return label
    }()
    
    private let myZipsLabel: UILabel = {
        let label = UILabel()
        label.text = "Zips"
        label.font = .zipBody.withSize(16)
        label.textColor = .white
        return label
    }()
    
    
    //MARK: - Button Actions
    @objc private func didTapSettingsButton(){
        let settingsView = SettingsPageViewController()
        settingsView.modalPresentationStyle = .overCurrentContext
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        view.window!.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(settingsView, animated: true)
    }


    
    @objc private func didTapzipsButton(){
        let myZipsView = MyZipsViewController()
        myZipsView.modalPresentationStyle = .overCurrentContext
        navigationController?.pushViewController(myZipsView, animated: true)
    }
    
    @objc private func didTapMyEventsButton(){
        let myEventsView = MyEventsViewController()
        myEventsView.modalPresentationStyle = .overCurrentContext
        navigationController?.pushViewController(myEventsView, animated: true)
    }
    
    @objc private func didTapPhotosButton(){
        let vc = UserPhotosViewController()
        vc.configure(user: user)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    @objc private func unrequestUser(){
        slideView.resetStateWithAnimation(true)
    }
    
    @objc private func didTapDismiss(){
        navigationController?.popViewController(animated: true)
//        dismiss(animated: true)
    }
    
    init(user: User, needsLoadUser: Bool = false) {
        self.user = user
        self.needsLoadUser = needsLoadUser
        super.init(nibName: nil, bundle: nil)
        
        configureSlider()
        configureTable()
        configureNavBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        
        if needsLoadUser {
            fetchUser()
        } else {
            title = "@" + user.username
            nameLabel.text = user.fullName
            ageLabel.text = String(user.age)
            photoCountLabel.text = "\(user.pictureURLs.count)"
            distanceLabel.text = getDistanceLabel(user: user)
            
            profilePictureView.sd_setImage(with: user.pictureURLs[0], completed: nil)
            
            if user.pictureURLs.count > 1 {
                photosButton.sd_setImage(with: user.pictureURLs[1], for: .normal, completed: nil)
            } else {
                photosButton.sd_setImage(with: user.pictureURLs[0], for: .normal, completed: nil)
            }
        }
    }
    

    
    private func fetchUser() {
        spinner.show(in: profilePictureView)
        DatabaseManager.shared.loadUserProfileZipFinder(given: user, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            print(strongSelf.user.bio)

                        
            strongSelf.title = "@" + strongSelf.user.username
            strongSelf.nameLabel.text = strongSelf.user.fullName
            strongSelf.ageLabel.text = String(strongSelf.user.age)
            strongSelf.photoCountLabel.text = "\(strongSelf.user.pictureURLs.count)"
            strongSelf.tableView.reloadData()
            strongSelf.profilePictureView.sd_setImage(with: strongSelf.user.pictureURLs[0], completed: nil)
            strongSelf.distanceLabel.text = getDistanceLabel(user: strongSelf.user)

            if strongSelf.user.pictureURLs.count > 1 {
                strongSelf.photosButton.sd_setImage(with: strongSelf.user.pictureURLs[1], for: .normal, completed: nil)
            } else {
                strongSelf.photosButton.sd_setImage(with: strongSelf.user.pictureURLs[0], for: .normal, completed: nil)
            }
            
            
            strongSelf.spinner.dismiss()

                
           
        })
    }
    
 
    
    //MARK: - Nav Bar Config
    private func configureNavBar() {
        navigationItem.title = "@" + user.username
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "navBarSettings")!.withRenderingMode(.alwaysOriginal),
                                                            landscapeImagePhone: nil,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapSettingsButton))
        
        //removes the text section of the back button from pushed VCs
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        dismissButton.frame = CGRect(x: 0, y: 0, width: 1, height: 34)
        dismissButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
    }
    
    private func configureSlider(){
        slideView.sliderViewTopDistance = 6
        slideView.sliderCornerRadius = 15
        slideView.delegate = self
        slideView.sliderTextLabel.text = ""
        
        slideView.backgroundColor = .clear

        let sliderHolderImg = UIImageView(image: UIImage(named: "sliderHolder")?.withTintColor(.zipVeryLightGray))
        slideView.sliderHolderView.addSubview(sliderHolderImg)
        sliderHolderImg.translatesAutoresizingMaskIntoConstraints = false
        sliderHolderImg.topAnchor.constraint(equalTo: slideView.sliderHolderView.topAnchor).isActive = true
        sliderHolderImg.leftAnchor.constraint(equalTo: slideView.sliderHolderView.leftAnchor).isActive = true
        sliderHolderImg.bottomAnchor.constraint(equalTo: slideView.sliderHolderView.bottomAnchor).isActive = true
        sliderHolderImg.rightAnchor.constraint(equalTo: slideView.sliderHolderView.rightAnchor).isActive = true
        
        slideView.thumbnailViewStartingDistance = -10
        slideView.sliderHolderView.backgroundColor = .clear //.zipBlue.withAlphaComponent(0.1)
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
        requestedLabel.widthAnchor.constraint(equalToConstant:view.frame.width-120).isActive = true

        let xButton = UIButton(frame: .zero)
        xButton.setImage(UIImage(named: "redX"), for: .normal)
        
        slideView.draggedView.addSubview(xButton)
        xButton.translatesAutoresizingMaskIntoConstraints = false
        xButton.centerYAnchor.constraint(equalTo: requestedLabel.centerYAnchor).isActive = true

//        xButton.topAnchor.constraint(equalTo: requestedLabel.topAnchor).isActive = true
//        xButton.bottomAnchor.constraint(equalTo: requestedLabel.bottomAnchor).isActive = true

        xButton.rightAnchor.constraint(equalTo: requestedLabel.rightAnchor).isActive = true
        xButton.heightAnchor.constraint(equalToConstant: requestedLabel.intrinsicContentSize.height).isActive = true
        xButton.widthAnchor.constraint(equalTo: xButton.heightAnchor).isActive = true
        
        let sliderTap = UITapGestureRecognizer(target: self, action: #selector(unrequestUser))
        slideView.addGestureRecognizer(sliderTap)
        
        let xTap = UITapGestureRecognizer(target: self, action: #selector(unrequestUser))
        xButton.addGestureRecognizer(xTap)
    }
    
    private func configureTable() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "bio")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        configureTableHeaderLayout()
    }
    
    private func configurePhotosButton() {
        photoCountLabel.text = user.pictures.count.description
        
        if user.pictures.count <= 1 {
            photosButton.setBackgroundImage(user.pictures[0], for: .normal)
        } else {
            photosButton.setBackgroundImage(user.pictures[1], for: .normal)
        }
    }
    
    private func configureTableHeaderLayout() {
        tableHeader.addSubview(profilePictureView)
        profilePictureView.translatesAutoresizingMaskIntoConstraints = false
        profilePictureView.topAnchor.constraint(equalTo: tableHeader.topAnchor, constant: 10).isActive = true
        profilePictureView.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        profilePictureView.heightAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
        profilePictureView.widthAnchor.constraint(equalTo: profilePictureView.heightAnchor).isActive = true
        profilePictureView.layer.masksToBounds = true
        profilePictureView.layer.cornerRadius = view.frame.width/4
        
        messageHolder.addSubview(messageButton)
        messageButton.translatesAutoresizingMaskIntoConstraints = false
        messageButton.centerYAnchor.constraint(equalTo: messageHolder.centerYAnchor).isActive = true
        messageButton.centerXAnchor.constraint(equalTo: messageHolder.centerXAnchor).isActive = true
        messageButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        messageButton.widthAnchor.constraint(equalTo: messageButton.heightAnchor).isActive = true

        messageButton.layer.cornerRadius = 20

        tableHeader.addSubview(messageHolder)
        messageHolder.translatesAutoresizingMaskIntoConstraints = false
        messageHolder.centerYAnchor.constraint(equalTo: profilePictureView.centerYAnchor).isActive = true
        messageHolder.leftAnchor.constraint(equalTo: profilePictureView.rightAnchor).isActive = true
        messageHolder.rightAnchor.constraint(equalTo: tableHeader.rightAnchor).isActive = true
        
        
        tableHeader.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profilePictureView.bottomAnchor, constant: 5).isActive = true

        tableHeader.addSubview(ageLabel)
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        ageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        
        tableHeader.addSubview(slideView)
        slideView.translatesAutoresizingMaskIntoConstraints = false
        slideView.topAnchor.constraint(equalTo: ageLabel.bottomAnchor).isActive = true
        slideView.leftAnchor.constraint(equalTo: tableHeader.leftAnchor, constant: 10).isActive = true
        slideView.rightAnchor.constraint(equalTo: tableHeader.rightAnchor, constant: -10).isActive = true
        slideView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        tableHeader.addSubview(distanceLabel)
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        distanceLabel.topAnchor.constraint(equalTo: slideView.bottomAnchor).isActive = true
        
        tableHeader.addSubview(distanceImage)
        distanceImage.translatesAutoresizingMaskIntoConstraints = false
        distanceImage.centerYAnchor.constraint(equalTo: distanceLabel.centerYAnchor).isActive = true
        distanceImage.rightAnchor.constraint(equalTo: distanceLabel.leftAnchor).isActive = true
        distanceImage.heightAnchor.constraint(equalToConstant: distanceLabel.intrinsicContentSize.height).isActive = true
        distanceImage.widthAnchor.constraint(equalTo: distanceImage.heightAnchor).isActive = true
        
        tableHeader.addSubview(photosButton)
        photosButton.translatesAutoresizingMaskIntoConstraints = false
        photosButton.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        photosButton.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 15).isActive = true
        photosButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        photosButton.widthAnchor.constraint(equalTo: photosButton.heightAnchor).isActive = true
        
        tableHeader.addSubview(photoCountLabel)
        photoCountLabel.translatesAutoresizingMaskIntoConstraints = false
        photoCountLabel.topAnchor.constraint(equalTo: photosButton.topAnchor).isActive = true
        photoCountLabel.rightAnchor.constraint(equalTo: photosButton.rightAnchor).isActive = true
        photoCountLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        photoCountLabel.widthAnchor.constraint(equalTo: photoCountLabel.heightAnchor).isActive = true

        tableHeader.addSubview(photosLabel)
        photosLabel.translatesAutoresizingMaskIntoConstraints = false
        photosLabel.centerXAnchor.constraint(equalTo: photosButton.centerXAnchor).isActive = true
        photosLabel.topAnchor.constraint(equalTo: photosButton.bottomAnchor, constant: 5).isActive = true

        tableHeader.addSubview(zipsButton)
        zipsButton.translatesAutoresizingMaskIntoConstraints = false
        zipsButton.rightAnchor.constraint(equalTo: tableHeader.rightAnchor, constant: -35).isActive = true
        zipsButton.topAnchor.constraint(equalTo: photosButton.topAnchor).isActive = true
        zipsButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        zipsButton.widthAnchor.constraint(equalTo: zipsButton.heightAnchor).isActive = true
        
        tableHeader.addSubview(myZipsLabel)
        myZipsLabel.translatesAutoresizingMaskIntoConstraints = false
        myZipsLabel.centerXAnchor.constraint(equalTo: zipsButton.centerXAnchor).isActive = true
        myZipsLabel.topAnchor.constraint(equalTo: photosLabel.topAnchor).isActive = true

        tableHeader.addSubview(myEventsButton)
        myEventsButton.translatesAutoresizingMaskIntoConstraints = false
        myEventsButton.leftAnchor.constraint(equalTo: tableHeader.leftAnchor, constant: 35).isActive = true
        myEventsButton.topAnchor.constraint(equalTo: photosButton.topAnchor).isActive = true
        myEventsButton.heightAnchor.constraint(equalTo: photosButton.heightAnchor).isActive = true
        myEventsButton.widthAnchor.constraint(equalTo: photosButton.widthAnchor).isActive = true

        tableHeader.addSubview(myEventsLabel)
        myEventsLabel.translatesAutoresizingMaskIntoConstraints = false
        myEventsLabel.centerXAnchor.constraint(equalTo: myEventsButton.centerXAnchor).isActive = true
        myEventsLabel.topAnchor.constraint(equalTo: photosLabel.topAnchor).isActive = true

        photoCountLabel.layer.cornerRadius = 10
        photosButton.layer.cornerRadius = 30
        zipsButton.layer.cornerRadius = 30
        myEventsButton.layer.cornerRadius = 30
        
        zipsButton.addTarget(self, action: #selector(didTapzipsButton), for: .touchUpInside)
        myEventsButton.addTarget(self, action: #selector(didTapMyEventsButton), for: .touchUpInside)
        photosButton.addTarget(self, action: #selector(didTapPhotosButton), for: .touchUpInside)
        
        tableHeader.translatesAutoresizingMaskIntoConstraints = false
        tableHeader.topAnchor.constraint(equalTo: profilePictureView.topAnchor).isActive = true
        tableHeader.bottomAnchor.constraint(equalTo: photosLabel.bottomAnchor).isActive = true
        tableHeader.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        tableView.tableHeaderView = tableHeader
        
        //good for iphone 11 pro
        tableHeader.frame = CGRect(x: 0,
                                   y: 0,
                                   width: view.frame.width,
                                   height: 404 + 15)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        print(photosLabel.frame.maxY)
        tableHeader.frame = CGRect(x: 0,
                                   y: 0,
                                   width: view.frame.width,
                                   height: photosLabel.frame.maxY + 15)
                
        tableView.tableHeaderView = tableHeader
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
}
    
extension OtherProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


extension OtherProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bio", for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            var content = cell.defaultContentConfiguration()
            content.textProperties.color = .white
            content.textProperties.font = .zipBody
            content.text = user.bio
            cell.contentConfiguration = content
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            var content = cell.defaultContentConfiguration()
            content.textProperties.color = .white
            content.textProperties.font = .zipBody
            

            switch indexPath.row {
            case 1: // school
                content.text = user.school
                content.image = UIImage(systemName: "graduationcap")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            case 2: // interests
                content.text = user.interestsString
                content.image = UIImage(systemName: "star")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            default: // birthday
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM d, yyyy"
                content.text = dateFormatter.string(from: user.birthday)
                content.image = UIImage(systemName: "gift")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            }
            
            cell.contentConfiguration = content
            
            return cell
        }
    }
}




//MARK: - TestData
extension OtherProfileViewController {
    func generateTestData(){
        var yiannipics = [UIImage]()
        var interests = [Interests]()
        
        interests.append(.skiing)
        interests.append(.coding)
        interests.append(.chess)
        interests.append(.wine)
        interests.append(.workingOut)


        yiannipics.append(UIImage(named: "yianni1")!)
        yiannipics.append(UIImage(named: "yianni2")!)
        yiannipics.append(UIImage(named: "yianni3")!)
        

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let yianniBirthday = formatter.date(from: "2001/12/06")!
        
        user = User(email: "zavalyia@gmail.com",
                     username: "yianni_zav",
                     firstName: "Yianni",
                     lastName: "Zavaliagkos",
//                          name: "Yianni Zavaliagkos",
                     birthday: yianniBirthday,
                     location: CLLocation(latitude: 51.5013, longitude: -0.2070),
                     pictures: yiannipics,
                     bio: "Yianni Zavaliagkos. Second Year at Mcgill. Add my snap and follow my insta @Yianni_Zav. I run this shit. Remember my name when I pass Zuckerberg on Forbes",
                     school: "McGill University",
                     interests: interests)
    }
}

extension OtherProfileViewController: MTSlideToOpenDelegate {
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        print("should zip here")
    }
    
}



/*
//
//  OtherOtherProfileViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/26/21.
//

import UIKit
import MapKit
import CoreLocation

class OtherOtherProfileViewController: UIViewController {
    private var user = User()
    
    // MARK: - SubViews
    private var scrollView = UIScrollView()
    private var pictureCollectionView: UICollectionView!


    // MARK: - Labels
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle
        label.sizeToFit()
        return label
    }()
    
    private var ageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(26)
        label.sizeToFit()
        return label
    }()
    
    private var bioLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.sizeToFit()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var schoolLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()
    
    private var interestsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()
    
    private var birthdayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()
    
    let schoolImage = UIImageView(image: UIImage(named: "school"))
    let birthdayImage = UIImageView(image: UIImage(named: "birthday"))

    
    // MARK: - Buttons
    
    private var messageButton: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        btn.backgroundColor = .zipBlue
        btn.setTitle("MESSAGE", for: .normal)
        btn.titleLabel?.textColor = .white
        btn.titleLabel?.font = .zipBodyBold
        btn.titleLabel?.textAlignment = .center
        btn.contentVerticalAlignment = .center
        btn.layer.cornerRadius = btn.frame.size.height/2
        return btn
    }()
    
    private var addButton:  UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "add"), for: .normal)
        return btn
    }()
    var zipsButton = UIButton()
    var myEventsButton = UIButton()
    
    
    
    //MARK: - Button Actions
    @objc private func didTapReportButton(){
        print("report Tapped" )
    }

    @objc private func didTapMessageButton(){
        print("Message tapped")
    }
    
    @objc private func didTapAddButton(){
        print("add tapped")
    }
    
    @objc private func didTapzipsButton(){
        let myZipsView = MyZipsViewController()
        myZipsView.modalPresentationStyle = .overCurrentContext
        navigationController?.pushViewController(myZipsView, animated: true)
    }
    
    @objc private func didTapMyEventsButton(){
        let myEventsView = MyEventsViewController()
        myEventsView.modalPresentationStyle = .overCurrentContext
        navigationController?.pushViewController(myEventsView, animated: true)
    }
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
    }
    
    public func configure(_ user: User){
        self.user = user
        configureNavBar()
        configureLabels()
        configureButtons()
        configurePictures()
        addSubviews()
        addButtonTargets()
        
    }
    
    //MARK: - ViewDidAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        adjustScaleAndAlpha()

    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        scrollView.contentSize = CGSize(width: view.frame.width, height: zipsButton.frame.maxY + 20)
        scrollView.updateContentView(20)
//        adjustScaleAndAlpha()

        
        

    }
    
    //MARK: - ViewWillLayoutSubviews
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureSubviewLayout()

//        scrollView.contentSize = CGSize(width: view.frame.width, height: zipsButton.frame.maxY + 20)
        scrollView.updateContentView(20)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pictureCollectionView.scrollToItem(at: IndexPath(row: user.pictures.count*1000, section: 0),
                                           at: .centeredHorizontally, animated: false)
        adjustScaleAndAlpha()
    }
    
    //MARK: - Nav Bar Config
    private func configureNavBar() {
        navigationItem.title = "@" + user.username
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "navBarReport")!.withRenderingMode(.alwaysOriginal),
                                                            landscapeImagePhone: nil,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapReportButton))
        
        //removes the text section of the back button from pushed VCs
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    //MARK: - Label Config
    private func configureLabels(){
//        nameLabel.text = user.name
        nameLabel.text = user.firstName + " " + user.lastName
        ageLabel.text = String(user.age)
        bioLabel.text = user.bio
        schoolLabel.text = user.school ?? ""
        interestsLabel.text = "Interests: " + user.interests.map{$0.description}.joined(separator: ", ")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        birthdayLabel.text = dateFormatter.string(from: user.birthday)
    }
    
    

    //MARK: - CollectionView config
    private func configurePictures(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        pictureCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        pictureCollectionView.register(PictureCollectionViewCell.self, forCellWithReuseIdentifier: PictureCollectionViewCell.identifier)
        pictureCollectionView.showsHorizontalScrollIndicator = false
        pictureCollectionView.dataSource = self
        pictureCollectionView.delegate = self
        pictureCollectionView.isPagingEnabled = false
        pictureCollectionView.backgroundColor = .clear
        pictureCollectionView.decelerationRate = .fast
    }
    
    //MARK: - Button config
    private func configureButtons() {        
        zipsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        zipsButton.backgroundColor = .zipMyZipsBlue
        zipsButton.setTitle("ZIPS", for: .normal)
        zipsButton.titleLabel?.font = .zipBodyBold.withSize(22)
        zipsButton.titleLabel?.textAlignment = .center
        zipsButton.contentVerticalAlignment = .center
        zipsButton.layer.cornerRadius = 17
        
        myEventsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        myEventsButton.backgroundColor = .zipMyEventsYellow
        myEventsButton.setTitle("EVENTS", for: .normal)
        myEventsButton.titleLabel?.font = .zipBodyBold.withSize(22)
        myEventsButton.titleLabel?.textAlignment = .center
        myEventsButton.contentVerticalAlignment = .center
        myEventsButton.layer.cornerRadius = 17
    }
    
    

    
    private func addButtonTargets(){
        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        messageButton.addTarget(self, action: #selector(didTapMessageButton), for: .touchUpInside)
        zipsButton.addTarget(self, action: #selector(didTapzipsButton), for: .touchUpInside)
        myEventsButton.addTarget(self, action: #selector(didTapMyEventsButton), for: .touchUpInside)

    }
    
    
    //MARK: - Add Subviews
    private func addSubviews(){
        //username and top buttons
        view.addSubview(scrollView)
        scrollView.addSubview(pictureCollectionView!)
        scrollView.addSubview(nameLabel)
        scrollView.addSubview(ageLabel)
        scrollView.addSubview(messageButton)
        scrollView.addSubview(addButton)
        scrollView.addSubview(bioLabel)
        scrollView.addSubview(schoolImage)
        scrollView.addSubview(schoolLabel)
        scrollView.addSubview(interestsLabel)
        scrollView.addSubview(birthdayImage)
        scrollView.addSubview(birthdayLabel)
        scrollView.addSubview(zipsButton)
        scrollView.addSubview(myEventsButton)
    }

    //MARK: - Layout Subviews
    private func configureSubviewLayout(){
        //Dimensions
        
        let width = view.frame.size.width

        // scroll view constraints
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        // Picture constraints
        pictureCollectionView.translatesAutoresizingMaskIntoConstraints = false
        pictureCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor,constant: 10).isActive = true
        pictureCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        pictureCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        pictureCollectionView.heightAnchor.constraint(equalToConstant: width/2).isActive = true

        // name label constraints
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: pictureCollectionView.bottomAnchor, constant: 5).isActive = true

        // age label constraints
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        ageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        
        // edit button constraints
        messageButton.translatesAutoresizingMaskIntoConstraints = false
        messageButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        messageButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        messageButton.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 5).isActive = true
        messageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.centerYAnchor.constraint(equalTo: messageButton.centerYAnchor).isActive = true
        addButton.leftAnchor.constraint(equalTo: messageButton.rightAnchor, constant: 5).isActive = true
        addButton.heightAnchor.constraint(equalTo: messageButton.heightAnchor).isActive = true
        addButton.widthAnchor.constraint(equalTo: addButton.heightAnchor).isActive = true

        
        let buffer = CGFloat(10)
        let heightBuffer = CGFloat(20)
        // bio label constraints
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: buffer).isActive = true
        bioLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -buffer).isActive = true
        bioLabel.topAnchor.constraint(equalTo: messageButton.bottomAnchor, constant: heightBuffer/2).isActive = true
        
        // school label constraints
        schoolImage.translatesAutoresizingMaskIntoConstraints = false
        schoolImage.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: buffer).isActive = true
        schoolImage.centerYAnchor.constraint(equalTo: schoolLabel.centerYAnchor).isActive = true
        schoolImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        schoolImage.widthAnchor.constraint(equalTo: schoolImage.heightAnchor).isActive = true

        schoolLabel.translatesAutoresizingMaskIntoConstraints = false
        schoolLabel.leftAnchor.constraint(equalTo: schoolImage.rightAnchor, constant: buffer).isActive = true
        schoolLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -buffer).isActive = true
        schoolLabel.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: heightBuffer).isActive = true
            
        // interests label constraints
        interestsLabel.translatesAutoresizingMaskIntoConstraints = false
        interestsLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: buffer).isActive = true
        interestsLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -buffer).isActive = true
        interestsLabel.topAnchor.constraint(equalTo: schoolLabel.bottomAnchor, constant: heightBuffer).isActive = true
        
        // birthday label constraints
        birthdayImage.translatesAutoresizingMaskIntoConstraints = false
        birthdayImage.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: buffer).isActive = true
        birthdayImage.centerYAnchor.constraint(equalTo: birthdayLabel.centerYAnchor).isActive = true
        birthdayImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        birthdayImage.widthAnchor.constraint(equalTo: birthdayImage.heightAnchor).isActive = true
        
        birthdayLabel.translatesAutoresizingMaskIntoConstraints = false
        birthdayLabel.leftAnchor.constraint(equalTo: birthdayImage.rightAnchor, constant: buffer).isActive = true
        birthdayLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: buffer).isActive = true
        birthdayLabel.topAnchor.constraint(equalTo: interestsLabel.bottomAnchor, constant: heightBuffer).isActive = true
        
        // my zips button constraints
        zipsButton.translatesAutoresizingMaskIntoConstraints = false
        zipsButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        zipsButton.topAnchor.constraint(equalTo: birthdayLabel.bottomAnchor, constant: heightBuffer).isActive = true
        zipsButton.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -5).isActive = true
        zipsButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
    
        // my events button constraints
        myEventsButton.translatesAutoresizingMaskIntoConstraints = false
        myEventsButton.heightAnchor.constraint(equalTo: zipsButton.heightAnchor).isActive = true
        myEventsButton.topAnchor.constraint(equalTo: birthdayLabel.bottomAnchor, constant: heightBuffer).isActive = true
        myEventsButton.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 5).isActive = true
        myEventsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
    }
    

    // MARK: - Scale/Alpha
    func adjustScaleAndAlpha(){
        let centerX = view.frame.midX
        for cell in pictureCollectionView!.visibleCells {
            let basePosition = cell.convert(CGPoint.zero, to: view)
            let cellCenterX = basePosition.x + cell.frame.size.width/2
            let distance = abs(centerX-cellCenterX)
            let tolerance : CGFloat = 0.02
        
            var scale = 1.00 + tolerance - ((distance/centerX)*0.205)
            if scale > 1.0 {
                scale = 1.0
            }

            if scale < 0.5 {
                scale = 0.5
            }

            
            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            let coverCell = cell as! PictureCollectionViewCell
            coverCell.alpha = sizeScaleToAlphaScale(scale)
        }
    }
    
    
    func sizeScaleToAlphaScale(_ x : CGFloat) -> CGFloat{
        let minScale : CGFloat = 0.5
        let maxScale : CGFloat = 1.0
        
        let minAlpha : CGFloat = 0.25
        let maxAlpha : CGFloat = 1.0
        
        return ((maxAlpha - minAlpha) * (x - minScale)) / (maxScale - minScale) + minAlpha
    }
}

// MARK: - CollectionView DataSource
extension OtherOtherProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = user.pictures[indexPath.row % user.pictures.count]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PictureCollectionViewCell.identifier, for: indexPath) as! PictureCollectionViewCell
        cell.cornerRadius = 10
//        cell.configure(with:model)
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100000 //user.pictures.count
    }
}

//MARK: - CollectionView Flow Delegate
extension OtherOtherProfileViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/2, height: collectionView.frame.size.width/2)
    }
}

extension OtherOtherProfileViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView : UIScrollView){
        adjustScaleAndAlpha()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        var indexOfCellWithLargestWidth = 0
        var largestWidth: CGFloat = 1
        
        for cell in pictureCollectionView!.visibleCells {
            if cell.frame.size.width > largestWidth {
                largestWidth = cell.frame.size.width
                if let indexPath = pictureCollectionView.indexPath(for: cell){
                    indexOfCellWithLargestWidth = indexPath.item
                }
            }
        }
        pictureCollectionView.scrollToItem(at: IndexPath(item: indexOfCellWithLargestWidth, section: 0), at: .centeredHorizontally, animated: true)
    }
}


*/
