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
    private var tableView: UITableView?
    var tableHeader: UIView?
    private var profilePictureView: UIImageView?
    private var spinner: JGProgressHUD?
    private var refreshControl: UIRefreshControl?
    
    // MARK: - Labels
    private var firstnameLabel: UILabel?
    private var lastnameLabel: UILabel?
    private var ageLabel: UILabel?
    private var photoCountLabel: UILabel?

    // MARK: - Buttons
    var centerActionButton: UIButton?
    private var B1Button: IconButton
    private var B2Button: IconButton
    private var B3Button: IconButton
    
    private var centerActionInfo: (String,UIColor)

    private var rightNavBarButton: UIBarButtonItem
    
    @objc open func didTapB1Button(){}
    @objc open func didTapB2Button(){}
    @objc open func didTapB3Button(){}
    @objc open func didTapCenterActionButton(){}
    @objc open func didTapRightBarButton(){}
    @objc open func didTapPhotos(){}

    init(
        id: String,
        B1: IconButton,
        B2: IconButton,
        B3: IconButton,
        rightBarButton: UIBarButtonItem,
        centerActionInfo: (String,UIColor)
    ) {
        self.user = User(userId: id)
        
        
        
        self.rightNavBarButton = rightBarButton
        self.centerActionInfo = centerActionInfo
        
        self.B1Button = B1
        self.B2Button = B2
        self.B3Button = B3

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        spinner = JGProgressHUD(style: .light)
        tableView = UITableView()
        tableHeader = UIView()
        refreshControl = UIRefreshControl()
        
        profilePictureView = UIImageView()
        profilePictureView?.isUserInteractionEnabled = true
        
        firstnameLabel = UILabel()
        lastnameLabel = UILabel()
        ageLabel = UILabel()
        photoCountLabel = UILabel()

        centerActionButton = UIButton()
        
        configureRefresh()
        configureLabels()
        configureButtons()
        fetchUser(completion: nil)
        configureTable()
        configureNavBar()
    }
    
    @objc private func refresh(){
        guard let photoCountLabel = photoCountLabel else {
            return
        }

        photoCountLabel.text = ""
        
        fetchUser(completion: { [weak self] in
            guard let refreshControl = self?.refreshControl else {
                return
            }
            refreshControl.endRefreshing()
        })
    }
    
    private func fetchUser(completion: (() -> Void)? = nil) {
        guard let profilePictureView = profilePictureView,
              let spinner = spinner
        else { return }

        profilePictureView.image = nil
        spinner.show(in: profilePictureView)
        DatabaseManager.shared.loadUserProfileZipFinder(given: user, completion: { [weak self] result in
            guard let strongSelf = self,
                  let tableView = strongSelf.tableView,

                  let firstnameLabel = strongSelf.firstnameLabel,
                  let lastnameLabel = strongSelf.lastnameLabel,
                  let ageLabel = strongSelf.ageLabel,
                  let photoCountLabel = strongSelf.photoCountLabel,

                  let profilePictureView = strongSelf.profilePictureView,
                  let spinner = strongSelf.spinner

            else {
                if let complete = completion {
                    complete()
                }
                return
            }
            
            print(strongSelf.user.bio)
                        
            strongSelf.title = "@" + strongSelf.user.username
            
            firstnameLabel.text = strongSelf.user.firstName
            lastnameLabel.text = strongSelf.user.lastName
            ageLabel.text = String(strongSelf.user.age)
            photoCountLabel.text = "\(strongSelf.user.pictureURLs.count)"
            tableView.reloadData()
            
            let profileURL: URL
            
            if strongSelf.user.userId == AppDelegate.userDefaults.value(forKey: "userId") as? String {
                guard let profileString = AppDelegate.userDefaults.value(forKey: "profilePictureUrl") as? String else {
                    return
                }
                profileURL = URL(string: profileString)!
            } else {
                profileURL = strongSelf.user.pictureURLs[0]
            }
            
            profilePictureView.sd_setImage(with: profileURL, completed: nil)

            
            spinner.dismiss()
            
            if let complete = completion {
                complete()
            }
        })
    }
    
    private func configureRefresh() {
        guard let tableView = tableView,
              let refreshControl = refreshControl
        else {
            return
        }

        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray,
                                                                         NSAttributedString.Key.font: UIFont.zipBody])
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    private func configureLabels() {
        guard let firstnameLabel = firstnameLabel,
              let lastnameLabel = lastnameLabel,
              let ageLabel = ageLabel,
              let photoCountLabel = photoCountLabel
              
        else { return }

        firstnameLabel.textColor = .white
        firstnameLabel.font = .zipTitle
        firstnameLabel.sizeToFit()
        
        lastnameLabel.textColor = .white
        lastnameLabel.font = .zipTitle
        lastnameLabel.sizeToFit()
        
        ageLabel.textColor = .white
        ageLabel.font = .zipTitle.withSize(26)
        ageLabel.sizeToFit()
        
        photoCountLabel.backgroundColor = .zipBlue
        photoCountLabel.layer.masksToBounds = true
        photoCountLabel.text = "1"
        photoCountLabel.font = .zipBody
        photoCountLabel.textColor = .white
        photoCountLabel.textAlignment = .center
        photoCountLabel.isUserInteractionEnabled = true

    }
    
    private func configureButtons() {
        guard let centerActionButton = centerActionButton,
              let photoCountLabel = photoCountLabel,
              let profilePictureView = profilePictureView
        else {
            return
        }
        
        let tapPic = UITapGestureRecognizer(target: self, action: #selector(didTapPhotos))
        let tapLabel = UITapGestureRecognizer(target: self, action: #selector(didTapPhotos))
        profilePictureView.addGestureRecognizer(tapPic)
        photoCountLabel.addGestureRecognizer(tapLabel)
        
        centerActionButton.backgroundColor = centerActionInfo.1
        centerActionButton.setTitle(centerActionInfo.0, for: .normal)
        centerActionButton.titleLabel?.textColor = .white
        centerActionButton.titleLabel?.font = .zipBodyBold
        centerActionButton.titleLabel?.textAlignment = .center
        centerActionButton.contentVerticalAlignment = .center
        
        B1Button.addTarget(self, action: #selector(didTapB1Button), for: .touchUpInside)
        B2Button.addTarget(self, action: #selector(didTapB2Button), for: .touchUpInside)
        B3Button.addTarget(self, action: #selector(didTapB3Button), for: .touchUpInside)

    }
    
    //MARK: - Nav Bar Config
    private func configureNavBar() {
        navigationItem.title = "@" + user.username
        
        navigationItem.rightBarButtonItem = rightNavBarButton
        
        //removes the text section of the back button from pushed VCs
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        dismissButton.frame = CGRect(x: 0, y: 0, width: 1, height: 34)
        dismissButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
    }
    
    private func configureTable() {
        guard let tableView = tableView else {
            return
        }
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
    

    
    private func configureTableHeaderLayout() {
        guard let tableView = tableView,
              let firstnameLabel = firstnameLabel,
              let lastnameLabel = lastnameLabel,
              let ageLabel = ageLabel,
              let photoCountLabel = photoCountLabel,
              let centerActionButton = centerActionButton,
              let profilePictureView = profilePictureView,
              let tableHeader = tableHeader
        else { return }
        
        tableHeader.addSubview(profilePictureView)
        profilePictureView.translatesAutoresizingMaskIntoConstraints = false
        profilePictureView.topAnchor.constraint(equalTo: tableHeader.topAnchor, constant: 10).isActive = true
        profilePictureView.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        profilePictureView.heightAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
        profilePictureView.widthAnchor.constraint(equalTo: profilePictureView.heightAnchor).isActive = true
        profilePictureView.layer.masksToBounds = true
        profilePictureView.layer.cornerRadius = view.frame.width/4
        
        tableHeader.addSubview(photoCountLabel)
        photoCountLabel.translatesAutoresizingMaskIntoConstraints = false
        photoCountLabel.topAnchor.constraint(equalTo: profilePictureView.topAnchor,constant: 30).isActive = true
        photoCountLabel.rightAnchor.constraint(equalTo: profilePictureView.rightAnchor).isActive = true
        photoCountLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        photoCountLabel.widthAnchor.constraint(equalTo: photoCountLabel.heightAnchor).isActive = true
        
        tableHeader.addSubview(firstnameLabel)
        firstnameLabel.translatesAutoresizingMaskIntoConstraints = false
        firstnameLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        firstnameLabel.topAnchor.constraint(equalTo: profilePictureView.bottomAnchor, constant: 5).isActive = true
        
        tableHeader.addSubview(lastnameLabel)
        lastnameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastnameLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        lastnameLabel.topAnchor.constraint(equalTo: firstnameLabel.bottomAnchor).isActive = true

        tableHeader.addSubview(ageLabel)
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        ageLabel.topAnchor.constraint(equalTo: lastnameLabel.bottomAnchor).isActive = true
        
        tableHeader.addSubview(centerActionButton)
        centerActionButton.translatesAutoresizingMaskIntoConstraints = false
        centerActionButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        centerActionButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        centerActionButton.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 10).isActive = true
        centerActionButton.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
       
        tableHeader.addSubview(B2Button)
        B2Button.translatesAutoresizingMaskIntoConstraints = false
        B2Button.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        B2Button.topAnchor.constraint(equalTo: centerActionButton.bottomAnchor, constant: 40).isActive = true
        B2Button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        B2Button.setIconDimension(width: 60)

        tableHeader.addSubview(B1Button)
        B1Button.translatesAutoresizingMaskIntoConstraints = false
        B1Button.leftAnchor.constraint(equalTo: tableHeader.leftAnchor, constant: 35).isActive = true
        B1Button.topAnchor.constraint(equalTo: B2Button.topAnchor).isActive = true
        B1Button.widthAnchor.constraint(equalTo: B2Button.widthAnchor).isActive = true
        B1Button.setIconDimension(width: 60)


        tableHeader.addSubview(B3Button)
        B3Button.translatesAutoresizingMaskIntoConstraints = false
        B3Button.rightAnchor.constraint(equalTo: tableHeader.rightAnchor, constant: -35).isActive = true
        B3Button.topAnchor.constraint(equalTo: B2Button.topAnchor).isActive = true
        B3Button.widthAnchor.constraint(equalTo: B3Button.heightAnchor).isActive = true
        B3Button.setIconDimension(width: 60)

        centerActionButton.layer.cornerRadius = 5
        photoCountLabel.layer.cornerRadius = 15
        B1Button.layer.cornerRadius = 30
        B2Button.layer.cornerRadius = 30
        B3Button.layer.cornerRadius = 30
        
        centerActionButton.addTarget(self, action: #selector(didTapCenterActionButton), for: .touchUpInside)
        B1Button.addTarget(self, action: #selector(didTapB1Button), for: .touchUpInside)
        B2Button.addTarget(self, action: #selector(didTapB2Button), for: .touchUpInside)
        B3Button.addTarget(self, action: #selector(didTapB3Button), for: .touchUpInside)
        
        tableHeader.translatesAutoresizingMaskIntoConstraints = false
        tableHeader.topAnchor.constraint(equalTo: profilePictureView.topAnchor).isActive = true
        tableHeader.bottomAnchor.constraint(equalTo: B2Button.bottomAnchor,constant: 10).isActive = true
        tableHeader.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        tableView.tableHeaderView = tableHeader
        
        //good for iphone 11 pro
//        tableHeader.frame = CGRect(x: 0,
//                                   y: 0,
//                                   width: view.frame.width,
//                                   height: 404 + 15)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let tableView = tableView,
              let tableHeader = tableHeader
        else {
            return
        }

        tableHeader.frame = CGRect(x: 0,
                                   y: 0,
                                   width: view.frame.width,
                                   height: B2Button.frame.maxY + 15)
                
        tableView.tableHeaderView = tableHeader
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @objc private func didTapDismiss(){
        dismiss(animated: true)
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
