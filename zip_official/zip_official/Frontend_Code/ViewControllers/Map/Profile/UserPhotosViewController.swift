//
//  UserPhotosViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 1/6/22.
//

import UIKit
import UIImageCropper
import JGProgressHUD

class UserPhotosViewController: UIViewController {
    var user = User()
    
    var originalPicUrls = [URL]()
    var userPictures = [PictureHolder]()
    weak var delegate: UpdateFromEditProtocol?
    
    private let spinner = JGProgressHUD(style: .light)

    let imagePicker = UIImagePickerController()
    let imageCropper = UIImageCropper(cropRatio: UIImageCropper.CROP_RATIO)
    
    private var collectionView: UICollectionView?

    private var focusedImageScale = CGFloat(0)
    private var focusedImageNumber = 0
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
        label.text = "Photos"
        return label
    }()
    
    private let xButton: UIButton = {
        let btn = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .medium)
        btn.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        return btn
    }()
    
    
    let editButton: UIButton = {
        let btn = UIButton()
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipSubtitle2,
                                                         .foregroundColor: UIColor.zipBlue]

        btn.setAttributedTitle(NSMutableAttributedString(string: "Edit", attributes: attributes), for: .normal)
        
    
        return btn
    }()
    
    var viewTap : UITapGestureRecognizer!
    var viewSwipe : UISwipeGestureRecognizer!
    var focusedSwipeDown : UISwipeGestureRecognizer!
    var focusedSwipeUp : UISwipeGestureRecognizer!
    var focusedSwipeLeft : UISwipeGestureRecognizer!
    var focusedSwipeRight : UISwipeGestureRecognizer!
    var focusedTap : UITapGestureRecognizer!
    
    @objc private func didSwipeLeftFocusedImage(){
        if focusedImageNumber < userPictures.count - 1 {
            focusedImageNumber += 1
            let imageToFocus = userPictures[focusedImageNumber]
            if imageToFocus.isUrl() {
                focusedImage.sd_setImage(with: imageToFocus.url, completed: nil)
            } else {
                focusedImage.image = imageToFocus.image
            }
        }
    }
    
    @objc private func didSwipeRightFocusedImage(){
        if focusedImageNumber > 0 {
            focusedImageNumber -= 1
            let imageToFocus = userPictures[focusedImageNumber]
            if imageToFocus.isUrl() {
                focusedImage.sd_setImage(with: imageToFocus.url, completed: nil)
            } else {
                focusedImage.image = imageToFocus.image
            }
        }
    }
    
    @objc private func didTapFocusedImage(){
        focusedImage.layer.removeAllAnimations()
        
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.focusedImage.transform = CGAffineTransform(scaleX: 1, y: 1)
            
            guard let strongSelf = self else { return }
            self?.focusedImage.center.y = strongSelf.view.frame.midY
            self?.focusedImage.center.x = strongSelf.view.frame.midX
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
            for i in 0..<userPictures.count {
                let cell = collectionView?.cellForItem(at: IndexPath(row: i, section: 0)) as? EditPicturesCollectionViewCell
                cell?.xButton.isHidden = false
            }
            
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipSubtitle2,
                                                             .foregroundColor: UIColor.zipBlue]

            editButton.setAttributedTitle(NSMutableAttributedString(string: "Done", attributes: attributes), for: .normal)
            
            collectionView?.reloadData()
            
        } else { // save
            let userId = AppDelegate.userDefaults.value(forKey: "userId") as! String

//            print(userPictures)
            spinner.show(in: view)
            DatabaseManager.shared.updateImages(key: userId, images: userPictures, imageType: DatabaseManager.ImageType.picIndices, completion: { [weak self] res in
                guard let strongSelf = self else {
                    print("Big error on line 124 of UserPhotos...wController")
                    return
                }
                switch res {
                case .success(let pics):
                    strongSelf.userPictures = pics
                    strongSelf.originalPicUrls = pics.map({$0.url!})
                    strongSelf.user.pictureURLs = strongSelf.originalPicUrls
                    strongSelf.user.picIndices = pics.map({ $0.idx })
                    DispatchQueue.main.async {
                        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipSubtitle2,
                                                                         .foregroundColor: UIColor.zipBlue]
                        strongSelf.editButton.setAttributedTitle(NSMutableAttributedString(string: "Edit", attributes: attributes), for: .normal)
                        
                        for i in 0..<strongSelf.userPictures.count {
                            let cell = strongSelf.collectionView?.cellForItem(at: IndexPath(row: i, section: 0)) as! EditPicturesCollectionViewCell
                            cell.xButton.isHidden = true
                        }
                        
                        strongSelf.collectionView?.reloadData()
                        strongSelf.delegate?.update()
                        strongSelf.spinner.dismiss(animated: true)
                    }
                    
                case .failure(let error):
                    self?.alert(error)
                    print("error: \(error)")
                }
            }, completionProfileUrl: {_ in})
            
        }
    }
    
    private func alert(_ error: Error) {
        let alert = UIAlertController(title: "Error Saving Profile",
                                      message: "\(error.localizedDescription)",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok",
                                      style: .cancel,
                                      handler: { _ in
        }))
        
        present(alert, animated: true)
        spinner.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if AppDelegate.userDefaults.value(forKey: "userId") as? String != user.userId {
            editButton.isHidden = true
        }
        
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        view.isOpaque = false

        viewSwipe = UISwipeGestureRecognizer(target: self, action: #selector(didTapCloseButton))
        viewSwipe.direction = .down
        viewTap = UITapGestureRecognizer(target: self, action: #selector(didTapCloseButton))

        focusedSwipeDown = UISwipeGestureRecognizer(target: self, action: #selector(didTapFocusedImage))
        focusedSwipeDown.direction = .down
        focusedSwipeUp = UISwipeGestureRecognizer(target: self, action: #selector(didTapFocusedImage))
        focusedSwipeUp.direction = .up
        focusedSwipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(didTapFocusedImage))
        focusedSwipeLeft.direction = .left
        focusedSwipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didTapFocusedImage))
        focusedSwipeRight.direction = .right
        focusedTap = UITapGestureRecognizer(target: self, action: #selector(didTapFocusedImage))
        
        view.addGestureRecognizer(viewTap)
        view.addGestureRecognizer(viewSwipe)

        focusedImage.addGestureRecognizer(focusedTap)
        focusedImage.addGestureRecognizer(focusedSwipeDown)
        focusedImage.addGestureRecognizer(focusedSwipeUp)
        
        focusedImage.addGestureRecognizer(focusedSwipeLeft)
        focusedImage.addGestureRecognizer(focusedSwipeRight)

        
        viewTap.delegate = self
        viewSwipe.delegate = self
        
        focusedSwipeUp.delegate = self
        focusedSwipeDown.delegate = self
        focusedSwipeLeft.delegate = self
        focusedSwipeRight.delegate = self
        focusedTap.delegate = self
        
        
        xButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)

        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .overCurrentContext
        
        imageCropper.picker = imagePicker
        imageCropper.delegate = self
    }
    
    public func configure(user: User) {
        self.user = user
        collectionView?.reloadData()
        originalPicUrls = user.pictureURLs
        
        var idx = 0
        for url in user.pictureURLs {
            userPictures.append(PictureHolder(url: url, index: user.picIndices[idx]))
            idx+=1
        }
        
        configureCollectionView()
        addSubviews()
        layoutSubviews()
    }
    
    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        guard let collectionView = collectionView else {
            return
        }
        
        collectionView.register(EditPicturesCollectionViewCell.self, forCellWithReuseIdentifier: EditPicturesCollectionViewCell.identifier)
        collectionView.register(AddImageCollectionViewCell.self, forCellWithReuseIdentifier: AddImageCollectionViewCell.identifier)

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.bounces = false
        collectionView.isScrollEnabled = false
        collectionView.contentInset = UIEdgeInsets(top: 100, left: 12, bottom: 0, right: 5)
    }
    
    private func addSubviews(){
        view.addSubview(collectionView!)
        view.addSubview(photosLabel)
        view.addSubview(xButton)
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
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 1.75).isActive = true
        
        
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.centerYAnchor.constraint(equalTo: photosLabel.centerYAnchor).isActive = true
        editButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
    }
    
}


extension UserPhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < user.otherPictureUrls.count {
            guard let cellAttributes = collectionView.layoutAttributesForItem(at: indexPath) else {
                return
            }
            focusedImageNumber = indexPath.row
            let imageToFocus = userPictures[indexPath.row]
            if imageToFocus.isUrl() {
                focusedImage.sd_setImage(with: imageToFocus.url, completed: nil)
            } else {
                focusedImage.image = imageToFocus.image
            }
            
            focusedImage.frame = CGRect(x: collectionView.frame.midX,
                                        y: collectionView.frame.midY,
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
        present(imagePicker, animated: true)
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditPicturesCollectionViewCell.identifier, for: indexPath) as! EditPicturesCollectionViewCell
            cell.delegate = self
            cell.xButton.tag = indexPath.row
            if editButton.titleLabel?.text == "Done" {
                cell.xButton.isHidden = false
            }
            cell.isUserInteractionEnabled = true
            cell.configure(pictureHolder: userPictures[indexPath.row])
            
            return cell
        } else if editButton.titleLabel?.text == "Edit" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddImageCollectionViewCell.identifier, for: indexPath) as! AddImageCollectionViewCell
            cell.delegate = self
            cell.addButton.isHidden = true
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddImageCollectionViewCell.identifier, for: indexPath) as! AddImageCollectionViewCell
            cell.delegate = self
            cell.addButton.isHidden = false

            return cell
        }
        
       
    }
    
    
}


extension UserPhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numCells = 3
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let totalSpace = collectionView.bounds.width - (flowLayout.minimumInteritemSpacing * CGFloat(numCells - 1))
        
        let size = totalSpace / CGFloat(numCells) - collectionView.contentInset.right - collectionView.contentInset.left
        return CGSize(width: size, height: size/UIImageCropper.CROP_RATIO)
    }
}


//extension UserPhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let image = info[.editedImage] as? UIImage {
//            userPictures.append(PictureHolder(image: image, edited: true))
//        }
//
//        collectionView?.reloadData()
//        dismiss(animated: true, completion: nil)
//    }
//}


extension UserPhotosViewController: UIImageCropperProtocol {
    func didCropImage(originalImage: UIImage?, croppedImage: UIImage?) {
        guard let croppedImage = croppedImage else {
            return
        }
        userPictures.append(PictureHolder(image: croppedImage, edited: true))
        collectionView?.reloadData()
    }
}


extension UserPhotosViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == viewTap || gestureRecognizer == viewSwipe  {
            if touch.view != self.view {
                return false
            }
        }

        return true
    }
}
