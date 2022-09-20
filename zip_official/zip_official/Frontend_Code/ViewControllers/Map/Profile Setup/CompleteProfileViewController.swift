//
//  EditProfileViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/2/21.
//

import UIKit
import UIImageCropper
import JGProgressHUD
class CompleteProfileViewController: EditProfileViewController {
    
   
    private var collectionView: UICollectionView?
    private let addPicturesLabel: UILabel
    private let picturesDescLabel: UILabel
    
    let imageCropper : UIImageCropper
    var userPictures = [PictureHolder]()

    
    override func didTapDoneButton(){
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
            
            
            DatabaseManager.shared.updateImages(key: strongSelf.user.userId, images: strongSelf.userPictures, imageType: DatabaseManager.ImageType.picIndices, completion: { [weak self] res in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.navigationController?.popViewController(animated: true)
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
    
    
    override init(user: User){
        self.addPicturesLabel = UILabel.zipTextFillBold()
        self.picturesDescLabel = UILabel.zipTextNoti()
        self.imageCropper = UIImageCropper(cropRatio: UIImageCropper.CROP_RATIO)
        super.init(user: user)
        addPicturesLabel.text = "Add Pictures:"
        picturesDescLabel.text = "These pictures can be viewed from your profile and from your card in the ZipFinder"
        picturesDescLabel.textColor = .zipVeryLightGray
        picturesDescLabel.textAlignment = .center
        picturesDescLabel.lineBreakMode = .byWordWrapping
        picturesDescLabel.numberOfLines = 0
        
        imageCropper.picker = imagePicker
        imageCropper.delegate = self
        
       
//        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
        
        configureNavBar()
        configureCollectionView()
        configureTable()
        configureTableHeader()
        setupKeyboardHiding()
    }
    
    private func setupKeyboardHiding() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    var originalY : CGFloat?
    @objc private func keyboardWillShow(sender: NSNotification) {
        originalY = view.frame.origin.y
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let currentTextField = UIResponder.currentFirst() as? UITextView else {
            return
        }
        
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        let convertedTextFieldFrame = view.convert(currentTextField.frame, from: currentTextField.superview)
        let textFieldBottomY = convertedTextFieldFrame.origin.y + convertedTextFieldFrame.size.height
//        let maxSize = UIScreen.main.bounds.height
//        let inset =  maxSize - textFieldBottomY
//        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: inset, right: 0)
        if textFieldBottomY > keyboardTopY {
            let textBoxY = convertedTextFieldFrame.origin.y
            let newFrameY = (textBoxY - keyboardTopY / 2) * -1
            view.frame.origin.y = newFrameY
        }
    }
    
    @objc private func keyboardWillHide(notification : NSNotification) {
        if let originalY = originalY {
            view.frame.origin.y = originalY
        }
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
    
    override func configureTableHeader() {
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
            cell.xButton.isHidden = false
            cell.configure(pictureHolder: userPictures[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addImage", for: indexPath) as! AddImageCollectionViewCell
            cell.delegate = self
            cell.backgroundColor = .clear
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
