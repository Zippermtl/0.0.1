//
//  UserPhotosViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 1/6/22.
//

import UIKit

class UserPhotosViewController: UIViewController {
    var user = User()
    
    var originalPicUrls = [URL]()
    var userPictures = [PictureHolder]()
    
    private var collectionView: UICollectionView?

    private var focusedImageScale = CGFloat(0)
    private var focusedImage: UIImageView = {
        let img = UIImageView()
        img.isHidden = true
        img.isUserInteractionEnabled = true
        return img
    }()
    
    private let photosLabel: UILabel = {
        let label = UILabel()
        label.font = .zipTitle
        label.textColor = .white
        label.text = "PHOTOS"
        return label
    }()
    
    private let xButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        btn.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        return btn
    }()
    
    let previewButton: UIButton = {
        let btn = UIButton()
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                         .foregroundColor: UIColor.white ,
                                                         .underlineStyle: NSUnderlineStyle.single.rawValue]
        
        btn.setAttributedTitle(NSMutableAttributedString(string: "Preview", attributes: attributes), for: .normal)
        btn.addTarget(self, action: #selector(didTapPreviewButton), for: .touchUpInside)
        return btn
    }()
    
    let editButton: UIButton = {
        let btn = UIButton()
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                         .foregroundColor: UIColor.white ,
                                                         .underlineStyle: NSUnderlineStyle.single.rawValue]

        

        btn.setAttributedTitle(NSMutableAttributedString(string: "Edit", attributes: attributes), for: .normal)
        
        btn.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
    
        return btn
    }()
    
    @objc private func didTapFocusedImage(){
        focusedImage.layer.removeAllAnimations()
        guard let collectionView = collectionView else {
            return
        }
        
        guard let cellAttributes = collectionView.layoutAttributesForItem(at: IndexPath(row: focusedImage.tag, section: 0)) else {
            return
        }
        
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.focusedImage.transform = CGAffineTransform(scaleX: 1, y: 1)//1/(self?.focusedImageScale ?? 1),
                                                                  //y: 1/(self?.focusedImageScale ?? 1))
            self?.focusedImage.center.y = collectionView.frame.minY + cellAttributes.frame.midY
            self?.focusedImage.center.x = collectionView.frame.minX + cellAttributes.frame.midX
        },completion: { [weak self] _ in
            self?.focusedImage.isHidden = true
        })
    }
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapEditButton() {
        if editButton.titleLabel?.text == "Edit" { // edit
            //show xButtons
            for i in 0..<user.picNum {
                let cell = collectionView?.cellForItem(at: IndexPath(row: i, section: 0)) as! EditPicturesCollectionViewCell
                cell.xButton.isHidden = false
            }
            
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                             .foregroundColor: UIColor.zipBlue ,
                                                             .underlineStyle: NSUnderlineStyle.single.rawValue]

            editButton.setAttributedTitle(NSMutableAttributedString(string: "Save", attributes: attributes), for: .normal)
            previewButton.setAttributedTitle(NSMutableAttributedString(string: "Cancel", attributes: attributes), for: .normal)
            
            collectionView?.reloadData()
            
        } else { // save
            saveImages(completion: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                StorageManager.shared.SetPicNum(size: strongSelf.userPictures.count )
                DatabaseManager.shared.updatePicNum(id: strongSelf.user.userId,
                                                    picNum: strongSelf.userPictures.count,
                                                    completion: { [weak self] success in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.user.picNum = strongSelf.userPictures.count
                    
                    let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                                     .foregroundColor: UIColor.white ,
                                                                     .underlineStyle: NSUnderlineStyle.single.rawValue]

                    strongSelf.editButton.setAttributedTitle(NSMutableAttributedString(string: "Edit", attributes: attributes), for: .normal)
                    strongSelf.previewButton.setAttributedTitle(NSMutableAttributedString(string: "Preview", attributes: attributes), for: .normal)
                    
                    strongSelf.collectionView?.reloadData()
                })
            })
        }
    }
    
    @objc private func didTapPreviewButton() {
        if editButton.titleLabel?.text == "Edit" { // Preview
            let vc = ZFSingleCardViewController()
            vc.configure(user: user)
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        } else { // Cancel
            //Hide xButtons
            for i in 0..<user.picNum {
                let cell = collectionView?.cellForItem(at: IndexPath(row: i, section: 0)) as! EditPicturesCollectionViewCell
                cell.xButton.isHidden = true
            }
            
            //undo changes
            user.picNum = originalPicUrls.count
            userPictures.removeAll()
            for url in originalPicUrls {
                userPictures.append(PictureHolder(url: url))
            }
            
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                             .foregroundColor: UIColor.white ,
                                                             .underlineStyle: NSUnderlineStyle.single.rawValue]

            editButton.setAttributedTitle(NSMutableAttributedString(string: "Edit", attributes: attributes), for: .normal)
            previewButton.setAttributedTitle(NSMutableAttributedString(string: "Preview", attributes: attributes), for: .normal)
            collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        view.isOpaque = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapFocusedImage))
        focusedImage.addGestureRecognizer(tap)
    }
    
    public func configure(user: User) {
        self.user = user
        collectionView?.reloadData()
        originalPicUrls = user.pictureURLs
        
        for url in user.pictureURLs {
            userPictures.append(PictureHolder(url: url))
        }
        
        configureCollectionView()
        addSubviews()
        layoutSubviews()
    }
    
    private func saveImages(completion: @escaping () -> Void){
        print("saving")
        var idx = 0
        for pic in userPictures {
            let cell = collectionView?.cellForItem(at: IndexPath(row: idx, section: 0)) as! EditPicturesCollectionViewCell
            if pic.isUrl() {
                pic.image = cell.picture.image
            }
            if idx == 0 {
                let path = "\(AppDelegate.userDefaults.value(forKey: "userId") as! String)/profile_picture.png"
                pic.upload(path: path, completion: { [weak self] result in
                    switch result {
                    case .success(let url):
                        AppDelegate.userDefaults.set(result.debugDescription.description, forKey: "profilePictureUrl")
                        self?.userPictures[0].url = URL(string: url)
                    case .failure(let error):
                        print("failed to get download url for profile picture: \(error)")
                    }
                })
            } else {
                let path = "\(AppDelegate.userDefaults.value(forKey: "userId") as! String)/img\(idx-1).png"
                pic.upload(path: path, completion: { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.userPictures[idx].url = URL(string: url)
                    case .failure(let error):
                        print("failed to get download url: \(error)")
                    }
                })
            }
            idx += 1
        }
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
    }
    
    private func addSubviews(){
        view.addSubview(collectionView!)
        view.addSubview(photosLabel)
        view.addSubview(xButton)
        view.addSubview(previewButton)
        view.addSubview(editButton)
        view.addSubview(focusedImage)
    }
    
    private func layoutSubviews(){
        guard let collectionView = collectionView else {
            return
        }

        photosLabel.translatesAutoresizingMaskIntoConstraints = false
        photosLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 5).isActive = true
        photosLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        xButton.translatesAutoresizingMaskIntoConstraints = false
        xButton.centerYAnchor.constraint(equalTo: photosLabel.centerYAnchor).isActive = true
        xButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor).isActive = true
        
        previewButton.translatesAutoresizingMaskIntoConstraints = false
        previewButton.bottomAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
        previewButton.leftAnchor.constraint(equalTo: collectionView.leftAnchor).isActive = true
        
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.topAnchor.constraint(equalTo: previewButton.topAnchor).isActive = true
        editButton.rightAnchor.constraint(equalTo: collectionView.rightAnchor).isActive = true
    }
    
}


extension UserPhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < user.pictureURLs.count {
            guard let cellAttributes = collectionView.layoutAttributesForItem(at: indexPath) else {
                return
            }
            
            focusedImage.sd_setImage(with: user.pictureURLs[indexPath.row], completed: nil)
            focusedImage.frame = CGRect(x: collectionView.frame.minX + cellAttributes.frame.minX,
                                        y: collectionView.frame.minY + cellAttributes.frame.minY,
                                        width: cellAttributes.frame.width,
                                        height: cellAttributes.frame.height)
            focusedImage.isHidden = false
            focusedImage.tag = indexPath.row
            
            focusedImageScale = collectionView.frame.width/cellAttributes.frame.width
            UIView.animate(withDuration: 0.1, animations: { [weak self] in
                self?.focusedImage.transform = CGAffineTransform(scaleX: self?.focusedImageScale ?? 1,
                                                                      y: self?.focusedImageScale ?? 1)
                self?.focusedImage.center.y = self?.view.frame.midY ?? 0
                self?.focusedImage.center.x = self?.view.frame.midX ?? 0
            })
        }
    }
}

extension UserPhotosViewController: AddImageCollectionViewCellDelegate {
    func addImage() {
        let picturePickerVC = UIImagePickerController()
        picturePickerVC.allowsEditing = true
        picturePickerVC.delegate = self
        picturePickerVC.sourceType = .photoLibrary
        picturePickerVC.modalPresentationStyle = .overCurrentContext
        present(picturePickerVC, animated: true)
    }
}

extension UserPhotosViewController: EditPicturesCollectionViewCellDelegate {
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

extension UserPhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < userPictures.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pictureCell", for: indexPath) as! EditPicturesCollectionViewCell
            cell.delegate = self
            cell.xButton.tag = indexPath.row
            if editButton.titleLabel?.text == "Save" {
                cell.xButton.isHidden = false
            }
            
            cell.configure(pictureHolder: userPictures[indexPath.row])
            
            return cell
        } else if editButton.titleLabel?.text == "Edit" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath)
            cell.backgroundColor = .zipLightGray.withAlphaComponent(0.6)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addImage", for: indexPath) as! AddImageCollectionViewCell
            cell.delegate = self
            cell.backgroundColor = .zipLightGray.withAlphaComponent(0.6)
            return cell
        }
        
       
    }
    
    
}


extension UserPhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numCells = 3
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let totalSpace = collectionView.bounds.width - (flowLayout.minimumInteritemSpacing * CGFloat(numCells - 1))
        
        let size = totalSpace / CGFloat(numCells)
        return CGSize(width: size, height: size)
    }
}


extension UserPhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            userPictures.append(PictureHolder(image: image, edited: true))
        }
        
        collectionView?.reloadData()
        dismiss(animated: true, completion: nil)
    }
}
