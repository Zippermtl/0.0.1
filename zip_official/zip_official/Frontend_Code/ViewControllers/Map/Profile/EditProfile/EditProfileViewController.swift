//
//  EditProfileViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/2/21.
//

import UIKit
import SwiftUI

protocol PresentEditInterestsProtocol: AnyObject {
    func presentInterestSelect()
}

class EditProfileViewController: UIViewController {
    static let photosIdentifier = "photosIdentifier"
    static let textIdentifier = "textIdentifier"
    static let nameIdentifier = "nameIdentifier"
    static let schoolIdentifier = "schoolIdentifier"
    static let interestsIdentifier = "interestsIdentifier"


    private var user: User
    private var tableView: UITableView
    private var firstNameText: UITextField
    private var lastNameText: UITextField
    private var changeProfilePicBtn: UIButton
    private var profilePic: UIImageView
    private var tableHeader: UIView
    private var imagePicker: UIImagePickerController
    
    @objc private func didTapDoneButton(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapChangeProfilePic() {
        present(imagePicker, animated: true)
    }
    
    init(user: User){
        self.firstNameText = UITextField()
        self.lastNameText = UITextField()
        self.user = user
        self.tableView = UITableView()
        self.changeProfilePicBtn = UIButton()
        self.profilePic = UIImageView()
        self.tableHeader = UIView()
        self.imagePicker = UIImagePickerController()

        super.init(nibName: nil, bundle: nil)
        

        changeProfilePicBtn.addTarget(self, action: #selector(didTapChangeProfilePic), for: .touchUpInside)
        
        imagePicker.delegate = self
        
        configureNavBar()
        configureTable()
        configureTableHeader()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        let height = tableHeader.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = tableHeader.frame
        frame.size.height = height
        tableHeader.frame = frame
        view.backgroundColor = .zipGray        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    //MARK: - Nav Bar Config
    private func configureNavBar(){
        navigationItem.title = "Edit Profile"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: UIBarButtonItem.Style.done,
                                                            target: self,
                                                            action: #selector(didTapDoneButton))
    }
    
    //MARK: - Table Config
    private func configureTable() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(EditTextFieldTableViewCell.self, forCellReuseIdentifier: EditTextFieldTableViewCell.identifier)
        tableView.register(EditInterestsTableViewCell.self, forCellReuseIdentifier: EditInterestsTableViewCell.identifier)
            
        
    }
    
    private func configureTableHeader() {
        tableHeader.addSubview(profilePic)
        tableHeader.addSubview(changeProfilePicBtn)

        profilePic.translatesAutoresizingMaskIntoConstraints = false
        profilePic.topAnchor.constraint(equalTo: tableHeader.topAnchor,constant: 20).isActive = true
        profilePic.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        profilePic.widthAnchor.constraint(equalTo: tableHeader.widthAnchor, multiplier: 0.25).isActive = true
        profilePic.heightAnchor.constraint(equalTo: profilePic.widthAnchor).isActive = true
        
        changeProfilePicBtn.translatesAutoresizingMaskIntoConstraints = false
        changeProfilePicBtn.topAnchor.constraint(equalTo: profilePic.bottomAnchor,constant: 10).isActive = true
        changeProfilePicBtn.centerXAnchor.constraint(equalTo: profilePic.centerXAnchor).isActive = true
    
        
        
        profilePic.sd_setImage(with: user.profilePicUrl, completed: nil)
        profilePic.layer.masksToBounds = true

        changeProfilePicBtn.setTitle("Change Profile Picture", for: .normal)
        changeProfilePicBtn.setTitleColor(.zipBlue, for: .normal)
        changeProfilePicBtn.titleLabel?.font = .zipTextFill

        
        tableHeader.translatesAutoresizingMaskIntoConstraints = false
        tableHeader.topAnchor.constraint(equalTo: profilePic.topAnchor, constant: -20).isActive = true
        tableHeader.bottomAnchor.constraint(equalTo: changeProfilePicBtn.bottomAnchor, constant: 10).isActive = true
        tableHeader.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        
        tableView.tableHeaderView = tableHeader
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableHeader.setNeedsLayout()
        tableHeader.layoutIfNeeded()
        
        profilePic.layer.cornerRadius = view.frame.width/8
    }
    
    
}

//MARK: - TableViewDelegte
extension EditProfileViewController :  UITableViewDelegate {
    
    
    //MARK: - HeightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: - TableDataSource
extension EditProfileViewController :  UITableViewDataSource {
    //MARK: # Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    //MARK: cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditTextFieldTableViewCell.identifier, for: indexPath) as! EditTextFieldTableViewCell
            cell.configure(label: "First name", content: user.firstName)
            cell.selectionStyle = .none
            cell.cellDelegate = self

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditTextFieldTableViewCell.identifier, for: indexPath) as! EditTextFieldTableViewCell
            cell.configure(label: "Last name", content: user.lastName)
            cell.selectionStyle = .none
            cell.cellDelegate = self

            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditTextFieldTableViewCell.identifier, for: indexPath) as! EditTextFieldTableViewCell
            cell.configure(label: "Username", content: user.username)
            cell.cellDelegate = self
            cell.selectionStyle = .none

            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditTextFieldTableViewCell.identifier, for: indexPath) as! EditTextFieldTableViewCell
            cell.configure(label: "Bio", content: user.bio)
            cell.cellDelegate = self
            cell.selectionStyle = .none

            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditTextFieldTableViewCell.identifier, for: indexPath) as! EditTextFieldTableViewCell
            cell.configure(label: "School", content: user.school ?? "")
            cell.cellDelegate = self
            cell.selectionStyle = .none
            return cell
            
//            let cell = tableView.dequeueReusableCell(withIdentifier: EditTextFieldTableViewCell.identifier, for: indexPath) as! EditTextFieldTableViewCell
//            cell.configure(label: "School", content: user.school ?? "")
//            cell.cellDelegate = self
//            cell.accessoryType = .disclosureIndicator
//            cell.selectionStyle = .none
//            cell.backgroundColor = .zipGray
//            cell.textView.isUserInteractionEnabled = false
//            return cell
            
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditInterestsTableViewCell.identifier, for: indexPath) as! EditInterestsTableViewCell
            cell.configure(label: "Interests", content: user.interests)
            cell.cellDelegate = self
            cell.presentInterestDelegate = self
            cell.updateInterestsDelegate = self
            return cell
        default: return UITableViewCell()
        }
        
    }
    
    
    //MARK: didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row == 4 {
//            let schoolSearch = SchoolSearchViewController()
//            schoolSearch.schoolLabel.text = user.school
//            schoolSearch.delegate = self
//            schoolSearch.modalPresentationStyle = .overCurrentContext
//            navigationController?.pushViewController(schoolSearch, animated: true)
//        }
    }
}

//MARK: - PicturePicker Delegate
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            
            StorageManager.shared.updateIndividualImage(with: image, path: "images/\(user.userId)/", index: 0, completion: { [weak self] result in
                switch result {
                case .success(let url):
                    self?.user.pictureURLs[0] = URL(string: url)!
                    self?.dismiss(animated: true, completion: nil)
                    self?.profilePic.image = image
                case .failure(let error):
                    print("error uploading profile pic: \(error)")
                    let actionSheet = UIAlertController(title: "Failed to upload profile picture",
                                                        message: "Try again later",
                                                        preferredStyle: .actionSheet)
                    
                    actionSheet.addAction(UIAlertAction(title: "Ok",
                                                        style: .cancel,
                                                        handler: { [weak self] _ in
                        
                        self?.dismiss(animated: true, completion: nil)
                    }))
                    self?.present(actionSheet, animated: true)
                }
            })
        }
        
    }
}

//MARK: - GrowingCellProtocol
extension EditProfileViewController: GrowingCellProtocol {
    func updateHeightOfRow(_ cell: UITableViewCell, _ view: UIView) {
        let size = view.bounds.size
        let newSize = tableView.sizeThatFits(CGSize(width: size.width,
                                                        height: CGFloat.greatestFiniteMagnitude))
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
    
    func updateValue(value: String){
        
    }
}

//MARK: - UpdateSchoolProtocol
extension EditProfileViewController: UpdateSchoolProtocol {
    func updateSchoolLabel(_ school: String) {
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
    func updateInterests(_ interests: [Interests]) {
        user.interests = interests
//        print("user interests = \(user.interests.description)")
        tableView.reloadData()
    }
}


extension EditProfileViewController: PresentEditInterestsProtocol {
    func presentInterestSelect() {
        let interestSelection = InterestSelectionViewController(interests: user.interests)
        interestSelection.delegate = self
        navigationController?.pushViewController(interestSelection, animated: true)
    }    
}
