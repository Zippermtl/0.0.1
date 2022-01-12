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

class ProfileViewController: UIViewController {
    private var user = User()
    
    // MARK: - SubViews

    //    private var pictureCollectionView: UICollectionView!
    private let tableView = UITableView()
    private let tableHeader = UIView()
    private let profilePictureView = UIImageView()
    private let spinner = JGProgressHUD(style: .light)
    
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
    

    // MARK: - Buttons
    private let editProfileButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        btn.setTitle("EDIT", for: .normal)
        btn.titleLabel?.textColor = .white
        btn.titleLabel?.font = .zipBodyBold
        btn.titleLabel?.textAlignment = .center
        btn.contentVerticalAlignment = .center
        return btn
    }()
    
    private let photosButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .zipLightGray
        btn.layer.masksToBounds = true
        return btn
    }()
    
    private let myZipsButton: UIButton = {
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
        
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        let img = UIImage(systemName: "calendar", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
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
        label.text = "My Events"
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
        label.text = "My Zips"
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

    @objc private func didTapEditButton(){
        let editView = EditProfileViewController()
        editView.modalPresentationStyle = .overCurrentContext
        editView.configure(with: user)
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        view.window!.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(editView, animated: true)
    }
    
    @objc private func didTapMyZipsButton(){
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
        let myPhotosView = UserPhotosViewController()
        myPhotosView.modalPresentationStyle = .overCurrentContext
        navigationController?.pushViewController(myPhotosView, animated: true)
    }
    
    @objc private func didTapDismiss(){
        dismiss(animated: true)
    }
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        
        
        fetchUser()

        configureTable()
        configureNavBar()
    }
    

    
    private func fetchUser() {
        guard let id = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            return
        }
        spinner.show(in: profilePictureView)
        DatabaseManager.shared.loadUserProfile(given: id, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
                        
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    strongSelf.user = user
                    strongSelf.title = "@" + user.username
                    strongSelf.nameLabel.text = user.fullName
                    strongSelf.ageLabel.text = String(user.age)
                    strongSelf.tableView.reloadData()
                }
                
                let path = "images/\(id)/profile_picture.png"
                StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                    switch result {
                    case .success(let url):
                        DispatchQueue.main.async {
                            self?.profilePictureView.sd_setImage(with: url, completed: nil)
                            self?.photosButton.sd_setImage(with: url, for: .normal, completed: nil)

                            
                            self?.spinner.dismiss()
                        }
                    case .failure(let error):
                        print("failed to get image URL: \(error)")
                    }
                    
                })
                
            case .failure(let error):
                print("failed to get user data: \(error)")
            }
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
        
        tableHeader.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profilePictureView.bottomAnchor, constant: 5).isActive = true

        tableHeader.addSubview(ageLabel)
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        ageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        
        tableHeader.addSubview(editProfileButton)
        editProfileButton.translatesAutoresizingMaskIntoConstraints = false
        editProfileButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        editProfileButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        editProfileButton.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 10).isActive = true
        editProfileButton.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        
        tableHeader.addSubview(photosButton)
        photosButton.translatesAutoresizingMaskIntoConstraints = false
        photosButton.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        photosButton.topAnchor.constraint(equalTo: editProfileButton.bottomAnchor, constant: 15).isActive = true
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

        tableHeader.addSubview(myZipsButton)
        myZipsButton.translatesAutoresizingMaskIntoConstraints = false
        myZipsButton.rightAnchor.constraint(equalTo: tableHeader.rightAnchor, constant: -35).isActive = true
        myZipsButton.topAnchor.constraint(equalTo: photosButton.topAnchor).isActive = true
        myZipsButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        myZipsButton.widthAnchor.constraint(equalTo: myZipsButton.heightAnchor).isActive = true
        
        tableHeader.addSubview(myZipsLabel)
        myZipsLabel.translatesAutoresizingMaskIntoConstraints = false
        myZipsLabel.centerXAnchor.constraint(equalTo: myZipsButton.centerXAnchor).isActive = true
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

        editProfileButton.layer.cornerRadius = 5
        photoCountLabel.layer.cornerRadius = 10
        photosButton.layer.cornerRadius = 30
        myZipsButton.layer.cornerRadius = 30
        myEventsButton.layer.cornerRadius = 30
        
        editProfileButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
        myZipsButton.addTarget(self, action: #selector(didTapMyZipsButton), for: .touchUpInside)
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
    
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


extension ProfileViewController: UITableViewDataSource {
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
                content.image = UIImage(systemName: "graduationcap.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            case 2: // interests
                content.text = user.interestsString
                content.image = UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            default: // birthday
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM d, yyyy"
                content.text = dateFormatter.string(from: user.birthday)
                content.image = UIImage(systemName: "gift.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            }
            
            cell.contentConfiguration = content
            
            return cell
        }
    }
}

//creates frame with wrapped text to see what the height will be
extension String {
    func heightForWrap(width: CGFloat) -> CGFloat{
        let tempLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        tempLabel.numberOfLines = 0
        tempLabel.lineBreakMode = .byWordWrapping
        tempLabel.font = .zipBody
        tempLabel.text = self
        tempLabel.sizeToFit()
        return tempLabel.frame.height
    }
}

extension UILabel {
    func heightForWrap(width: CGFloat) -> CGFloat{
        let tempLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        tempLabel.numberOfLines = 0
        tempLabel.lineBreakMode = .byWordWrapping
        tempLabel.font = .zipBody
        tempLabel.text = text
        tempLabel.sizeToFit()
        return tempLabel.frame.height
    }
}






//MARK: - TestData
extension ProfileViewController {
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


