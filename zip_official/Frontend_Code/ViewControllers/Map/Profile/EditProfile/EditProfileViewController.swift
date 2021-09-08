//
//  EditProfileViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/2/21.
//

import UIKit

class EditProfileViewController: UIViewController {
    static let photosIdentifier = "photosIdentifier"
    static let textIdentifier = "textIdentifier"
    static let nameIdentifier = "nameIdentifier"
    static let schoolIdentifier = "schoolIdentifier"
    static let interestsIdentifier = "interestsIdentifier"


    var user = User()
    //MARK: - Subviews
    //Table
    var tableView = UITableView()
    
    //Pictures
    var collectionView: UICollectionView?
    
    //Name
    var firstNameText: UITextView = {
        let text = UITextView()
        
        return text
    }()
    
    var lastNameText = UITextField()
    //MARK: - Labels
    private var usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(26)
        label.sizeToFit()
        label.text = "@"
        return label
    }()
    
    
    // MARK: - Buttons
    var backButton = UIButton()
    
    
    
    //MARK: - Button Actions
    @objc private func didTapBackButton(){
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Configure
    public func configure(with user: User){
        self.user = user
        usernameLabel.text = "@" + user.username
        configureTable()
    }
    
    //MARK: - Layout Subviews
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureHeader()
    }
    
    //MARK: - Header Cofnig
    private func configureHeader(){
        backButton.setImage(UIImage(named: "backarrow"), for: .normal)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        view.addSubview(backButton)
        view.addSubview(usernameLabel)

        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.heightAnchor.constraint(equalToConstant: usernameLabel.intrinsicContentSize.height*1.5).isActive = true
        backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        backButton.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor).isActive = true
        
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 10).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    }
    
    //MARK: - Table Config
    private func configureTable() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: EditProfileViewController.photosIdentifier)
        tableView.register(NameTableViewCell.self, forCellReuseIdentifier: NameTableViewCell.identifier)
        tableView.register(GrowingCellTableViewCell.self, forCellReuseIdentifier: GrowingCellTableViewCell.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: EditProfileViewController.schoolIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: EditProfileViewController.interestsIdentifier)
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 20))
        tableView.contentInset = UIEdgeInsets(top: -22, left: 0, bottom: 0, right: 0)
        tableView.tableHeaderView?.backgroundColor = .clear
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
        tableView.separatorStyle = .none
    }
    
    //MARK: - Photo Config
    private func configurePhotos() -> UIView{
        let view = UIView()
   
        view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width)
        
        
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.view.frame.width/3,height: self.view.frame.width/3)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "pictureCell")
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "lastCell")
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        collectionView?.backgroundColor = .zipGray
        view.addSubview(collectionView!)
        return view
    }
}

//MARK: - TableViewDelegte
extension EditProfileViewController :  UITableViewDelegate {
    
    
    //MARK: - HeightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return view.frame.width
        case 1: return 40
        case 2: return UITableView.automaticDimension
        case 3: return 40
        case 4:
            let text = "Interests: " + user.interests.map{$0}.joined(separator: ", ")
            return text.heightForWrap(width: view.frame.width-60) + 10
        default: return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
}

//MARK: - TableDataSource
extension EditProfileViewController :  UITableViewDataSource {
    
    
    //MARK: Table Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 20))
        view.backgroundColor = .zipGray
        let titleLabel = UILabel()
        titleLabel.textColor = .white
        titleLabel.font = .zipBodyBold
        view.addSubview(titleLabel)
        switch section {
        case 0:
            titleLabel.text = "Photos"
        case 1:
            titleLabel.text = "Name"
        case 2:
            titleLabel.text = "Bio"
        case 3:
            titleLabel.text = "School"
        case 4:
            titleLabel.text = "Interests"
        default: break
        }
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        
        switch section{
        case 0: break
        case 1:
            let bottomLine = UIView()
            bottomLine.backgroundColor = .zipLightGray
            view.addSubview(bottomLine)
            
            bottomLine.translatesAutoresizingMaskIntoConstraints = false
            bottomLine.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            bottomLine.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            bottomLine.widthAnchor.constraint(equalToConstant: view.frame.width-20).isActive = true
            bottomLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        default:
            let bottomLine = UIView()
            bottomLine.backgroundColor = .zipLightGray
            view.addSubview(bottomLine)
            
            bottomLine.translatesAutoresizingMaskIntoConstraints = false
            bottomLine.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            bottomLine.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            bottomLine.widthAnchor.constraint(equalToConstant: view.frame.width-20).isActive = true
            bottomLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            let topLine = UIView()
            topLine.backgroundColor = .zipLightGray
            view.addSubview(topLine)
            
            topLine.translatesAutoresizingMaskIntoConstraints = false
            topLine.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            topLine.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            topLine.widthAnchor.constraint(equalToConstant: view.frame.width-20).isActive = true
            topLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }

        return view
    }
    
    //MARK: # Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 2
        }
        return 1
    }
    
    
    //MARK: cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileViewController.photosIdentifier, for: indexPath)
            cell.contentView.addSubview(configurePhotos())
            cell.backgroundColor = .zipGray
            cell.selectionStyle = .none
            cell.clipsToBounds = true
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: NameTableViewCell.identifier, for: indexPath) as! NameTableViewCell
            cell.configure(with: user, idx: indexPath.row)
            cell.backgroundColor = .zipGray
            cell.selectionStyle = .none
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: GrowingCellTableViewCell.identifier, for: indexPath) as! GrowingCellTableViewCell
            cell.configure(with: user)
            cell.cellDelegate = self
            cell.selectionStyle = .none
            cell.backgroundColor = .zipGray

            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileViewController.schoolIdentifier, for: indexPath)
            if user.school != nil {
                cell.textLabel?.text = user.school
            } else {
                cell.textLabel?.text = "Add School"
            }
            cell.textLabel?.font = .zipBody
            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = .zipGray
            cell.selectionStyle = .none
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileViewController.interestsIdentifier, for: indexPath)
            cell.backgroundColor = .zipGray
            cell.selectionStyle = .none
            cell.accessoryType = .disclosureIndicator

            let label = cell.textLabel!
            label.text = "Interests: " + user.interests.map{$0}.joined(separator: ", ")
            label.font = .zipBody
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 0
            

            return cell
        default: return UITableViewCell()
        }
        
    }
    
    
    //MARK: didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            let schoolSearch = SchoolSearchViewController()
            schoolSearch.schoolLabel.text = user.school
            schoolSearch.delegate = self
            schoolSearch.modalPresentationStyle = .overCurrentContext
            present(schoolSearch, animated: true, completion: nil)
        } else if indexPath.section == 4 {
            let interestSelection = InterestSelectionViewController()
            interestSelection.delegate = self
            interestSelection.userInterests = user.interests
            interestSelection.modalPresentationStyle = .overCurrentContext
            present(interestSelection, animated: true, completion: nil)

        }
    }
}


//MARK: - CollectionView Delegate
extension EditProfileViewController: UICollectionViewDelegate {
    
}

//MARK: - CollectionView DataSource
extension EditProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 9
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if user.pictures.count < 9 && indexPath.row >= user.pictures.count{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "lastCell", for: indexPath)
            cell.backgroundColor = .zipGray
            let pictureView = UIView(frame: CGRect(x: 10, y: 10, width: cell.frame.width-20, height: cell.frame.height-20))
            pictureView.backgroundColor = .zipLightGray

            let addButton = UIImageView(image: UIImage(named: "addFilled")?.withTintColor(.zipVeryLightGray))
            pictureView.addSubview(addButton)
            addButton.translatesAutoresizingMaskIntoConstraints = false
            addButton.heightAnchor.constraint(equalTo: pictureView.heightAnchor, multiplier: 0.5).isActive = true
            addButton.widthAnchor.constraint(equalTo: pictureView.widthAnchor, multiplier: 0.5).isActive = true
            addButton.centerYAnchor.constraint(equalTo: pictureView.centerYAnchor).isActive = true
            addButton.centerXAnchor.constraint(equalTo: pictureView.centerXAnchor).isActive = true
            
            cell.contentView.addSubview(pictureView)

            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pictureCell", for: indexPath)
        let pictureView = UIView(frame: CGRect(x: 5, y: 5, width: cell.frame.width-10, height: cell.frame.height-10))
        let img = UIImageView(image: user.pictures[indexPath.row])
        let xButton = UIButton()
        xButton.setImage(UIImage(named: "redXButton")?.withTintColor(.zipVeryLightGray), for: .normal)

        xButton.tag = indexPath.row
        xButton.addTarget(self, action: #selector(removePicture(_:)), for: .touchUpInside)
        pictureView.addSubview(img)
        pictureView.addSubview(xButton)
        
        img.translatesAutoresizingMaskIntoConstraints = false
        img.heightAnchor.constraint(equalTo: pictureView.heightAnchor, constant: -10).isActive = true
        img.widthAnchor.constraint(equalTo: pictureView.widthAnchor, constant: -10).isActive = true
        img.leftAnchor.constraint(equalTo: pictureView.leftAnchor, constant: 5).isActive = true
        img.topAnchor.constraint(equalTo: pictureView.topAnchor, constant: 5).isActive = true
        
        xButton.translatesAutoresizingMaskIntoConstraints = false
        xButton.centerYAnchor.constraint(equalTo: img.topAnchor).isActive = true
        xButton.centerXAnchor.constraint(equalTo: img.rightAnchor).isActive = true
        xButton.heightAnchor.constraint(equalToConstant: 28).isActive = true
        xButton.widthAnchor.constraint(equalTo: xButton.heightAnchor).isActive = true
        
        cell.contentView.addSubview(pictureView)
        
        cell.backgroundColor = .zipGray
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= user.pictures.count && user.pictures.count < 9 {
            let picturePickerVC = UIImagePickerController()
            picturePickerVC.allowsEditing = true
            picturePickerVC.delegate = self
            picturePickerVC.sourceType = .photoLibrary
            picturePickerVC.modalPresentationStyle = .overCurrentContext
            self.present(picturePickerVC, animated: true)
        }
    }
    
    @objc func removePicture(_ sender: UIButton){
        let deleteAlert = UIAlertController(title: "Are you sure you want to delete this image?", message: "", preferredStyle: UIAlertController.Style.alert)

        deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
            self.user.pictures.remove(at: sender.tag)
            self.collectionView?.reloadData()
            self.tableView.reloadData()
        }))

        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
              print("Handle Cancel Logic here")
        }))

        present(deleteAlert, animated: true, completion: nil)
    }
    
}

//MARK: - PicturePicker Delegate
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            print("edited image")
            user.pictures.append(image)
        }
        
        collectionView?.reloadData()
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - GrowingCellProtocol
extension EditProfileViewController: GrowingCellProtocol {
    func updateHeightOfRow(_ cell: GrowingCellTableViewCell, _ textView: UITextView) {
        let size = textView.bounds.size
        let newSize = tableView.sizeThatFits(CGSize(width: size.width,
                                                        height: CGFloat.greatestFiniteMagnitude))
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
}

//MARK: - UpdateSchoolProtocol
extension EditProfileViewController: UpdateSchoolProtocol {
    func updateSchoolLabel(_ school: String) {
        print("school = \(school)")
        if school != "None" {
            user.school = school
        } else {
            user.school = nil
        }
        tableView.reloadData()
    }
}

//MARK: - UpdateInterestsProtocol
extension EditProfileViewController: UpdateInterestsProtocol {
    func updateInterests(_ interests: [String]) {
        user.interests = interests
//        print("user interests = \(user.interests.description)")
        tableView.reloadData()
    }
}
