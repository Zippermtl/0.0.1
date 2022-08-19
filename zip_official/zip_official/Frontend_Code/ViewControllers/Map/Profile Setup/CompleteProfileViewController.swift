//
//  EditProfileViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/2/21.
//

import UIKit
import UIImageCropper
import JGProgressHUD
class CompleteProfileViewController: UIViewController, UIGestureRecognizerDelegate {
    weak var delegate: UpdateFromEditProtocol?
    let spinner = JGProgressHUD(style: .light)
    
    private var user: User
    private var tableView: UITableView
    private var tableHeader: UIView
    private var imagePicker: UIImagePickerController
    private var collectionView: UICollectionView?
    private let addPicturesLabel: UILabel
    private let picturesDescLabel: UILabel
    
    let imageCropper : UIImageCropper
    var userPictures = [PictureHolder]()

    
    @objc private func didTapDoneButton(){
        spinner.show(in: view)
        DatabaseManager.shared.updateUser(with: user, completion: { [weak self] err in
            guard let strongSelf = self,
                  err == nil else {
                DispatchQueue.main.async {
                    self?.spinner.dismiss(animated: true)
                }
                let alert = UIAlertController(title: "Error updating your profile.", message: "Try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: nil))
                self?.present(alert, animated: true)
                return
            }
           
            DatabaseManager.shared.updateImages(key: strongSelf.user.userId, images: strongSelf.userPictures, forKey: "picIndices", completion: { [weak self] res in
                guard let strongSelf = self else {
                    print("Big error on line 124 of UserPhotos...wController")
                    return
                }
                switch res {
                case .success(let pics):
                    print("temp")
                    //trusting no issues
                    var tempUrls: [URL] = []
                    for i in pics{
                        guard let url = i.url else {
                            print("something wrong with url in obj at line 134 of UserPhotos...wController")
                            continue
                        }
                        tempUrls.append(url)
                    }
                    DispatchQueue.main.async {
                        strongSelf.spinner.dismiss(animated: true)
                    }
                    strongSelf.dismiss(animated: true, completion: nil)
                    
                case .failure(let error):
                    print("error completing profile Error: \(error)")
                    DispatchQueue.main.async {
                        self?.spinner.dismiss(animated: true)
                    }
                    let alert = UIAlertController(title: "Error updating your profile.", message: "Try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: nil))
                    self?.present(alert, animated: true)
                }
            }, completionProfileUrl: {_ in})
            
            
        })
    }
    
    @objc private func didTapCancel() {
        let alert = UIAlertController(title: "Are you sure?", message: "None of the info you've entered will be saved", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes I'm sure", style: .default, handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Nevermind", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    
    init(user: User){
        self.user = user
        self.tableView = UITableView()
        self.tableHeader = UIView()
        self.imagePicker = UIImagePickerController()
        self.addPicturesLabel = UILabel.zipTextFill()
        self.picturesDescLabel = UILabel.zipTextNoti()
        self.imageCropper = UIImageCropper(cropRatio: UIImageCropper.CROP_RATIO)
        super.init(nibName: nil, bundle: nil)
        addPicturesLabel.text = "Add Pictures:"
        picturesDescLabel.text = "These pictures can be viewed from your profile and from your card in the ZipFinder"
        picturesDescLabel.textColor = .zipVeryLightGray
        picturesDescLabel.textAlignment = .center
        picturesDescLabel.lineBreakMode = .byWordWrapping
        picturesDescLabel.numberOfLines = 0
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .overCurrentContext
        imageCropper.picker = imagePicker
        imageCropper.delegate = self
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardTouchOutside))
        dismissTap.delegate = self
        tableView.addGestureRecognizer(dismissTap)
        
        configureNavBar()
        configureCollectionView()
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
    
    @objc private func dismissKeyboardTouchOutside(){
        print("dismissing")
        view.endEditing(true)
        
    }
    
    
    //MARK: - Nav Bar Config
    private func configureNavBar(){
        navigationItem.title = "Complete Profile"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: UIBarButtonItem.Style.done,
                                                            target: self,
                                                            action: #selector(didTapDoneButton))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: UIBarButtonItem.Style.done,
                                                            target: self,
                                                            action: #selector(didTapCancel))
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
    
    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        guard let collectionView = collectionView else {
            return
        }
        
        collectionView.register(EditPicturesCollectionViewCell.self, forCellWithReuseIdentifier: "pictureCell")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "default")
        collectionView.register(AddImageCollectionViewCell.self, forCellWithReuseIdentifier: "addImage")

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.bounces = false
        collectionView.isScrollEnabled = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }
    
    private func configureTableHeader() {
        guard let collectionView = collectionView else {
            return
        }
        tableHeader.addSubview(addPicturesLabel)
        tableHeader.addSubview(picturesDescLabel)
        tableHeader.addSubview(collectionView)

        addPicturesLabel.translatesAutoresizingMaskIntoConstraints = false
        addPicturesLabel.topAnchor.constraint(equalTo: tableHeader.topAnchor, constant: 15).isActive = true
        addPicturesLabel.leftAnchor.constraint(equalTo: tableHeader.leftAnchor,constant: 15).isActive = true
        
        picturesDescLabel.translatesAutoresizingMaskIntoConstraints = false
        picturesDescLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        picturesDescLabel.topAnchor.constraint(equalTo: addPicturesLabel.bottomAnchor,constant: 10).isActive = true
        picturesDescLabel.widthAnchor.constraint(equalTo: tableHeader.widthAnchor,multiplier: 0.6).isActive = true
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: picturesDescLabel.bottomAnchor, constant: 15).isActive = true
//        collectionView.bottomAnchor.constraint(equalTo: tableHeader.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: tableHeader.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: tableHeader.rightAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 7/6).isActive = true
        
        tableHeader.translatesAutoresizingMaskIntoConstraints = false
        tableHeader.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
        tableHeader.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        tableView.tableHeaderView = tableHeader
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableHeader.setNeedsLayout()
        tableHeader.layoutIfNeeded()
    }
        
    func saveBioFunc(_ s: String) {
        user.bio = s
    }
    
    func saveSchoolFunc(_ s: String) {
        user.school = s
    }
    
    
}

extension CompleteProfileViewController :  UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension CompleteProfileViewController :  UITableViewDataSource {
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
            cell.placeHolder = "Tell us a little about yourself."
            cell.charLimit = 300
            cell.cellDelegate = self
            cell.selectionStyle = .none

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditTextFieldTableViewCell.identifier, for: indexPath) as! EditTextFieldTableViewCell
            cell.configure(label: "School", content: user.school ?? "", saveFunc: saveSchoolFunc(_:))
            cell.placeHolder = "Where do you go to school?"
            cell.charLimit = 40
            cell.cellDelegate = self
            cell.selectionStyle = .none
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditInterestsTableViewCell.identifier, for: indexPath) as! EditInterestsTableViewCell
            cell.configure(label: "Interests", content: user.interests)
            cell.cellDelegate = self
            cell.presentInterestDelegate = self
            cell.updateInterestsDelegate = self
            return cell
        default: return UITableViewCell()
        }
    }
    
    

}


//MARK: - GrowingCellProtocol
extension CompleteProfileViewController: GrowingCellProtocol {
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
extension CompleteProfileViewController: UpdateInterestsProtocol {
    func updateInterests(_ interests: [Interests]) {
        user.interests = interests
//        print("user interests = \(user.interests.description)")
        tableView.reloadData()
    }
}


extension CompleteProfileViewController: PresentEditInterestsProtocol {
    func presentInterestSelect() {
        let interestSelection = InterestSelectionViewController(interests: user.interests)
        interestSelection.delegate = self
        navigationController?.pushViewController(interestSelection, animated: true)
    }
}


extension CompleteProfileViewController: UICollectionViewDelegate {
    
}

extension CompleteProfileViewController: AddImageCollectionViewCellDelegate {
    func addImage() {
        present(imagePicker, animated: true)
    }
}

extension CompleteProfileViewController: EditPicturesCollectionViewCellDelegate {
    func deleteCell(_ sender: UIButton) {
        let deleteAlert = UIAlertController(title: "Are you sure you want to delete this image?", message: "", preferredStyle: UIAlertController.Style.alert)

        deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] (action: UIAlertAction!) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.userPictures.remove(at: sender.tag)
            strongSelf.collectionView?.reloadData()
            
            for i in sender.tag..<strongSelf.userPictures.count {
                strongSelf.userPictures[i].isEdited = true
            }
        }))

        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
              print("Handle Cancel Logic here")
        }))

        present(deleteAlert, animated: true, completion: nil)
    }
}

extension CompleteProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < userPictures.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pictureCell", for: indexPath) as! EditPicturesCollectionViewCell
            cell.delegate = self
            cell.xButton.tag = indexPath.row
            cell.configure(pictureHolder: userPictures[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addImage", for: indexPath) as! AddImageCollectionViewCell
            cell.delegate = self
            cell.backgroundColor = .zipLightGray.withAlphaComponent(0.6)
            return cell
        }
    }
}


extension CompleteProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numCells = 3
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = collectionView.bounds.width - (flowLayout.minimumInteritemSpacing * CGFloat(numCells - 1))
        let size = totalSpace / CGFloat(numCells) - collectionView.contentInset.right - collectionView.contentInset.left
        return CGSize(width: size, height: size/UIImageCropper.CROP_RATIO)
    }
}

extension CompleteProfileViewController: UIImageCropperProtocol {
    func didCropImage(originalImage: UIImage?, croppedImage: UIImage?) {
        guard let croppedImage = croppedImage else {
            return
        }
        userPictures.append(PictureHolder(image: croppedImage, edited: true))
        collectionView?.reloadData()
    }
}


extension CompleteEventViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl) && !(touch.view is UITextView)
    }
}
