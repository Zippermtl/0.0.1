//
//  AbstractProfileViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/7/22.
//

import UIKit
import MapKit
import CoreLocation
import SDWebImage
import JGProgressHUD


class AbstractProfileViewController: UIViewController {
    var user: User
    var tableView: UITableView
    var tableHeader: UIView
    var profilePictureView: UIImageView
    private var spinner: JGProgressHUD
    private var refreshControl: UIRefreshControl
    
    // MARK: - Labels
    private var firstnameLabel: UILabel
    private var lastnameLabel: UILabel
    private var ageLabel: UILabel
    var photoCountButton: UIButton
    private var importanceLabel: UILabel

    // MARK: - Buttons
    var centerActionButton: UIButton
    private var B1Button: IconButton
    private var B2Button: IconButton
    private var B3Button: IconButton
    
    private var centerActionInfo: (String,UIColor)

    private var rightNavBarButton: UIBarButtonItem!
    
    @objc open func didTapB1Button(){}
    @objc open func didTapB2Button(){}
    @objc open func didTapB3Button(){}
    @objc open func didTapCenterActionButton(){}
    @objc open func didTapRightBarButton(){}
    @objc open func didTapPhotos(){}

    var bioCell : UITableViewCell?
    var schoolCell : UITableViewCell?
    var interestCell : UITableViewCell?
    var birthdayCell : UITableViewCell?
    
    var tableCells : [UITableViewCell]
    
    init(
        id: String,
        B1: IconButton,
        B2: IconButton,
        B3: IconButton,
        rightBarButtonIcon: UIImage,
        centerActionInfo: (String,UIColor)
    ) {
        self.tableCells = []
        
        self.user = User(userId: id)
        self.centerActionInfo = centerActionInfo
        
        self.B1Button = B1
        self.B2Button = B2
        self.B3Button = B3
        
        self.spinner = JGProgressHUD(style: .light)
        self.tableView = UITableView()
        self.tableHeader = UIView()
        self.refreshControl = UIRefreshControl()
        self.profilePictureView = UIImageView()
        self.firstnameLabel = UILabel.zipTitle()
        self.lastnameLabel = UILabel.zipTitle()
        self.importanceLabel = UILabel.zipSubtitle2()
        self.ageLabel = UILabel.zipSubtitle2()
        self.photoCountButton = UIButton()
        self.centerActionButton = UIButton()

        super.init(nibName: nil, bundle: nil)
        profilePictureView.backgroundColor = .zipLightGray
        navigationItem.backBarButtonItem =  BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        self.rightNavBarButton = UIBarButtonItem(image: rightBarButtonIcon,
                                                 landscapeImagePhone: nil,
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(didTapRightBarButton))
        
        configureButtons()
        configureTable()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        
        initUser()
        configureRefresh()
        configureNavBar()
        
        self.profilePictureView.isUserInteractionEnabled = true
        
//        tableHeader.frame = CGRect(x: 0,
//                                   y: 0,
//                                   width: view.frame.width,
//                                   height: B2Button.frame.maxY + 15)


        tableHeader.setNeedsLayout()
        tableHeader.layoutIfNeeded()

        let height = tableHeader.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = tableHeader.frame
        frame.size.height = height
        tableHeader.frame = frame

        tableView.tableHeaderView = tableHeader
    }
    
    func initUser() {
        fetchUser(completion: nil)
    }
    
    @objc private func refresh(){
        fetchUser(completion: { [weak self] in
            guard let refreshControl = self?.refreshControl else {
                return
            }
            refreshControl.endRefreshing()
        })
    }
    
    func fetchUser(completion: (() -> Void)? = nil) {
        profilePictureView.image = nil
        spinner.show(in: profilePictureView)
        DatabaseManager.shared.loadUserProfile(given: user, dataCompletion: { [weak self] result in
            guard let strongSelf = self
            else {
                if let complete = completion {
                    complete()
                }
                return
            }
            DispatchQueue.main.async {
                strongSelf.reloadUI()
            }
           
            if let complete = completion {
                complete()
            }
        }, pictureCompletion: { [weak self] result in
            switch result {
            case .success(let urls):
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.imageReloadUI()
                }
            case .failure(let error):
                break
            }
            
        })
//        user.load(status: .UserProfileUpdates, dataCompletion: { [weak self] result in
//            guard let strongSelf = self
//            else {
//                if let complete = completion {
//                    complete()
//                }
//                return
//            }
//            DispatchQueue.main.async {
//                strongSelf.reloadUI()
//            }
//
//            if let complete = completion {
//                complete()
//            }
//        }, completionUpdates: { [weak self] urls in
//            guard let strongSelf = self else { return }
//            DispatchQueue.main.async {
//                strongSelf.imageReloadUI()
//            }
//        })
    }
    
    private func reloadUI(){
        configureCells()
        
        title = "@" + user.username
        firstnameLabel.text = user.firstName
        lastnameLabel.text = user.lastName
        ageLabel.text = String(user.age) + " years old"
        tableView.reloadData()
        if let userType = user.getHighestPermission(),
           let userTypeString = user.userTypeString {
            importanceLabel.isHidden = false
            importanceLabel.backgroundColor = userType.color
            importanceLabel.text = "  " + userTypeString + "  "
            importanceLabel.textColor = userType.textColor
        }
    }
    
    private func imageReloadUI() {
        configurePhotoCountText()
        spinner.dismiss()
        guard let url = user.profilePicUrl else {
            if user.userId == AppDelegate.userDefaults.value(forKey: "userId") as? String {
                if let profileString = AppDelegate.userDefaults.value(forKey: "profilePictureUrl") as? String {
                    profilePictureView.sd_setImage(with: URL(string: profileString), completed: nil)
                } else {
                    profilePictureView.image = UIImage(named: "defaultProfilePic")
                }
            } else {
                profilePictureView.image = UIImage(named: "defaultProfilePic")
            }
           
            return
        }
        profilePictureView.sd_setImage(with: url, completed: nil)
    }
    
    private func configureRefresh() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray,
                                                                         NSAttributedString.Key.font: UIFont.zipTextFill])
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func configurePhotoCountText() {
        photoCountButton.setTitle("\(user.pictureURLs.count)", for: .normal)
        photoCountButton.setTitle("", for: .selected)
    
        if user.pictureURLs.count == 0 {
            photoCountButton.isHidden = true
        }
        
        photoCountButton.backgroundColor = .zipBlue
        photoCountButton.layer.masksToBounds = true
        photoCountButton.titleLabel!.textColor = .white
        photoCountButton.titleLabel!.textAlignment = .center
    }
    

    
    private func configureButtons() {
        let tapPic = UITapGestureRecognizer(target: self, action: #selector(didTapPhotos))
        profilePictureView.addGestureRecognizer(tapPic)
        photoCountButton.addTarget(self, action: #selector(didTapPhotos), for: .touchUpInside)
        
        centerActionButton.backgroundColor = centerActionInfo.1
        centerActionButton.setTitle(centerActionInfo.0, for: .normal)
        centerActionButton.titleLabel?.textColor = .white
        centerActionButton.titleLabel?.font = .zipSubtitle2
        centerActionButton.titleLabel?.textAlignment = .center
        centerActionButton.contentVerticalAlignment = .center
        
        B1Button.iconAddTarget(self, action: #selector(didTapB1Button), for: .touchUpInside)
        B2Button.iconAddTarget(self, action: #selector(didTapB2Button), for: .touchUpInside)
        B3Button.iconAddTarget(self, action: #selector(didTapB3Button), for: .touchUpInside)

    }
    
    //MARK: - Nav Bar Config
    private func configureNavBar() {
        navigationItem.title = "@" + user.username
        
        navigationItem.rightBarButtonItem = rightNavBarButton
        
        //removes the text section of the back button from pushed VCs
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
       
        
    }
    
    private func configureTable() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "bio")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 150))
        configureTableHeaderLayout()
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
        
        tableHeader.addSubview(photoCountButton)
        photoCountButton.translatesAutoresizingMaskIntoConstraints = false
        photoCountButton.topAnchor.constraint(equalTo: profilePictureView.topAnchor,constant: 30).isActive = true
        photoCountButton.rightAnchor.constraint(equalTo: profilePictureView.rightAnchor).isActive = true
        photoCountButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        photoCountButton.widthAnchor.constraint(equalTo: photoCountButton.heightAnchor).isActive = true
        
        tableHeader.addSubview(firstnameLabel)
        firstnameLabel.translatesAutoresizingMaskIntoConstraints = false
        firstnameLabel.centerXAnchor.constraint(equalTo: profilePictureView.centerXAnchor).isActive = true
        firstnameLabel.topAnchor.constraint(equalTo: profilePictureView.bottomAnchor, constant: 5).isActive = true
        
        tableHeader.addSubview(lastnameLabel)
        lastnameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastnameLabel.centerXAnchor.constraint(equalTo: profilePictureView.centerXAnchor).isActive = true
        lastnameLabel.topAnchor.constraint(equalTo: firstnameLabel.bottomAnchor).isActive = true

        tableHeader.addSubview(ageLabel)
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.centerXAnchor.constraint(equalTo: profilePictureView.centerXAnchor).isActive = true
        ageLabel.topAnchor.constraint(equalTo: lastnameLabel.bottomAnchor).isActive = true
        
        tableHeader.addSubview(centerActionButton)
        centerActionButton.translatesAutoresizingMaskIntoConstraints = false
        centerActionButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        centerActionButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        centerActionButton.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 10).isActive = true
        centerActionButton.centerXAnchor.constraint(equalTo: profilePictureView.centerXAnchor).isActive = true
       
        tableHeader.addSubview(importanceLabel)
        importanceLabel.translatesAutoresizingMaskIntoConstraints = false
        importanceLabel.topAnchor.constraint(equalTo: centerActionButton.bottomAnchor,constant: 10).isActive = true
        importanceLabel.centerXAnchor.constraint(equalTo: profilePictureView.centerXAnchor).isActive = true
        importanceLabel.heightAnchor.constraint(equalToConstant: 26).isActive = true
        importanceLabel.layer.cornerRadius = 13
        importanceLabel.layer.masksToBounds = true
        
        tableHeader.addSubview(B2Button)
        B2Button.translatesAutoresizingMaskIntoConstraints = false
        B2Button.centerXAnchor.constraint(equalTo: profilePictureView.centerXAnchor).isActive = true
        B2Button.topAnchor.constraint(equalTo: importanceLabel.bottomAnchor, constant: 10).isActive = true
        B2Button.setIconDimension(width: 60)

        tableHeader.addSubview(B1Button)
        B1Button.translatesAutoresizingMaskIntoConstraints = false
        B1Button.leftAnchor.constraint(equalTo: tableHeader.leftAnchor, constant: 55).isActive = true
        B1Button.topAnchor.constraint(equalTo: B2Button.topAnchor).isActive = true
        B1Button.setIconDimension(width: 60)


        tableHeader.addSubview(B3Button)
        B3Button.translatesAutoresizingMaskIntoConstraints = false
        B3Button.rightAnchor.constraint(equalTo: tableHeader.rightAnchor, constant: -55).isActive = true
        B3Button.topAnchor.constraint(equalTo: B2Button.topAnchor).isActive = true
        B3Button.setIconDimension(width: 60)

        centerActionButton.layer.cornerRadius = 8
        photoCountButton.layer.cornerRadius = 15
        B1Button.layer.cornerRadius = 30
        B2Button.layer.cornerRadius = 30
        B3Button.layer.cornerRadius = 30
        
        centerActionButton.addTarget(self, action: #selector(didTapCenterActionButton), for: .touchUpInside)
        B1Button.addTarget(self, action: #selector(didTapB1Button), for: .touchUpInside)
        B2Button.addTarget(self, action: #selector(didTapB2Button), for: .touchUpInside)
        B3Button.addTarget(self, action: #selector(didTapB3Button), for: .touchUpInside)
        
        tableHeader.translatesAutoresizingMaskIntoConstraints = false
//        tableHeader.topAnchor.constraint(equalTo: profilePictureView.topAnchor).isActive = true
        tableHeader.bottomAnchor.constraint(equalTo: B2Button.bottomAnchor,constant: 10).isActive = true
        tableHeader.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        
        tableView.tableHeaderView = tableHeader
        
        tableHeader.setNeedsLayout()
        tableHeader.layoutIfNeeded()

        let height = tableHeader.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = tableHeader.frame
        frame.size.height = height
        tableHeader.frame = frame

        tableView.tableHeaderView = tableHeader
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableHeader.setNeedsLayout()
        tableHeader.layoutIfNeeded()
    }
}


extension AbstractProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


extension AbstractProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = .zero
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableCells[indexPath.row]
    }
    
    func configureCells() {
        tableCells.removeAll()
        if user.hasBio {
            bioCell = UITableViewCell()
            bioCell!.backgroundColor = .clear
            bioCell!.selectionStyle = .none
            var content = bioCell!.defaultContentConfiguration()
            content.textProperties.color = .white
            content.textProperties.font = .zipTextFill
            content.text = user.bio
            bioCell!.contentConfiguration = content
            
            tableCells.append(bioCell!)
        }
        
        if user.hasSchool {
            schoolCell = UITableViewCell()
            schoolCell!.backgroundColor = .clear
            schoolCell!.selectionStyle = .none
            var content = schoolCell!.defaultContentConfiguration()
            content.textProperties.color = .white
            content.textProperties.font = .zipTextFill
            content.text = user.school
            let gradCapConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .medium)
            content.image = UIImage(systemName: "graduationcap", withConfiguration: gradCapConfig)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            schoolCell!.contentConfiguration = content
            
            tableCells.append(schoolCell!)
        }
        
        if user.hasInterests {
            interestCell = UITableViewCell()
            interestCell!.backgroundColor = .clear
            interestCell!.selectionStyle = .none
            var content = interestCell!.defaultContentConfiguration()
            content.textProperties.color = .white
            content.textProperties.font = .zipTextFill
            content.text = user.interestsString
            content.image = UIImage(systemName: "star")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            interestCell!.contentConfiguration = content
            
            tableCells.append(interestCell!)
        }
        
        birthdayCell = UITableViewCell()
        birthdayCell!.backgroundColor = .clear
        birthdayCell!.selectionStyle = .none
        var content = birthdayCell!.defaultContentConfiguration()
        content.textProperties.color = .white
        content.textProperties.font = .zipTextFill
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        content.text = dateFormatter.string(from: user.birthday)
        content.image = UIImage(systemName: "gift")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        
        birthdayCell!.contentConfiguration = content
        tableCells.append(birthdayCell!)

    }

}
