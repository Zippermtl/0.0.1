//
//  EditProfileViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/2/21.
//

import UIKit
import JGProgressHUD

protocol PresentEditInterestsProtocol: AnyObject {
    func presentInterestSelect()
}

protocol UpdateFromEditProtocol: AnyObject {
    func update()
}

class EditProfileViewController: UIViewController {
    static let photosIdentifier = "photosIdentifier"
    static let textIdentifier = "textIdentifier"
    static let nameIdentifier = "nameIdentifier"
    static let schoolIdentifier = "schoolIdentifier"
    static let interestsIdentifier = "interestsIdentifier"
    
    let spinner = JGProgressHUD(style: .light)

    weak var delegate: UpdateFromEditProtocol?
    
    var user: User
    var tableView: UITableView
    var firstNameText: UITextField
    var lastNameText: UITextField
    private var changeProfilePicBtn: UIButton
    private var profilePic: UIImageView
    var tableHeader: UIView
    var imagePicker: UIImagePickerController
    private var changedPFP = false
    
    @objc func didTapDoneButton(){
        view.endEditing(true)
        spinner.show(in: view)
        DatabaseManager.shared.updateUser(with: user, completion: { [weak self] error in
            guard let strongSelf = self,
                  error == nil else {
                let alert = UIAlertController(title: "Error Saving Profile",
                                              message: "\(error!.localizedDescription)",
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok",
                                              style: .cancel,
                                              handler: { _ in
                }))
                
                DispatchQueue.main.async {
                    self?.present(alert, animated: true)
                    self?.spinner.dismiss()
                }
                
                return
            }
            
            if strongSelf.changedPFP {
                let id = strongSelf.user.userId
                let pp = PictureHolder(image: strongSelf.profilePic.image!)
                pp.isEdited = true
                DatabaseManager.shared.updateImages(key: id, images: [pp], imageType: DatabaseManager.ImageType.profileIndex, completion: { [weak self] res in
                    switch res{
                    case .success(let urls):
                        self?.user.profilePicUrl = urls[0].url
                        AppDelegate.userDefaults.setValue(urls[0].url?.absoluteString, forKey: "profilePictureUrl")
                        self?.navigationController?.popViewController(animated: true)
                        print("success changing profile 56 in editprofileviewcontroller")
                        self?.delegate?.update()
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
                        DispatchQueue.main.async {
                            self?.present(actionSheet, animated: true)
                        }
                    }
                }, completionProfileUrl: {_ in})
            } else {
                self?.delegate?.update()
                DispatchQueue.main.async {
                    self?.spinner.dismiss(animated: true)
                }
                strongSelf.navigationController?.popViewController(animated: true)
                
            }
        })
    }
    

    @objc private func didTapChangeProfilePic() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Take a Photo with Camera",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                
                                                self?.presentCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Chose a Photo From Photo Library",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                
                                                self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
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
        profilePic.backgroundColor = .zipLightGray

        changeProfilePicBtn.addTarget(self, action: #selector(didTapChangeProfilePic), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        profilePic.isUserInteractionEnabled = true
        profilePic.addGestureRecognizer(tap)
        
        imagePicker.delegate = self
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardTouchOutside))
        dismissTap.delegate = self
        tableView.addGestureRecognizer(dismissTap)
        
        configureNavBar()
        configureTable()
        configureTableHeader()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func dismissKeyboardTouchOutside(){
        print("dismissing")
        view.endEditing(true)
        
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
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.title = "Edit Profile"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: .done,
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
    
    func configureTableHeader() {
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
        changeProfilePicBtn.titleLabel?.font = .zipTextFillBold

        
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
    
    
    func saveFirstNameFunc(_ s: String) {
        user.firstName = s
    }
    
    func saveLastNameFunc(_ s: String) {
        user.lastName = s
    }
    
    func saveUsernameFunc(_ s: String) {
        user.username = s
    }
    
    func saveBioFunc(_ s: String) {
        user.bio = s
    }
    
    func saveSchoolFunc(_ s: String) {
        user.school = s
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
        return 3
    }
    
    //MARK: cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditTextFieldTableViewCell.identifier, for: indexPath) as! EditTextFieldTableViewCell
            cell.configure(label: "Bio", content: user.bio, saveFunc: saveBioFunc(_:))
            cell.placeHolder = "Tell us about yourself"
            cell.charLimit = 300
            cell.cellDelegate = self
            cell.selectionStyle = .none

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditTextFieldTableViewCell.identifier, for: indexPath) as! EditTextFieldTableViewCell
            cell.configure(label: "School", content: user.school ?? "", saveFunc: saveSchoolFunc(_:))
            cell.charLimit = 40
            cell.placeHolder = "Where do you go to school?"
            cell.cellDelegate = self
            cell.selectionStyle = .none
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditInterestsTableViewCell.identifier, for: indexPath) as! EditInterestsTableViewCell
            cell.configure(label: "Interests", content: user.interests)
            cell.cellDelegate = self
            cell.deleteInterestsDelegate = self
            cell.presentInterestDelegate = self
            cell.updateInterestsDelegate = self
            
            return cell
        default: return UITableViewCell()
        }
    }
}

//MARK: - PicturePicker Delegate
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            dismiss(animated: true, completion: nil)
            profilePic.image = image
            changedPFP = true
        }
    }
}

//MARK: - GrowingCellProtocol
extension EditProfileViewController: GrowingCellProtocol {
    func updateValue(value: String) {
        
    }
    
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

extension EditProfileViewController : DeleteInterestsProtocol {
    func deleteInterest(idx: Int) {
        user.interests.remove(at: idx)
    }
    
    func openInterestSelect() {
        
    }
    
    
}

extension EditProfileViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl) && !(touch.view is UITextView)
    }
}
