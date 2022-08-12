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
    
    private let spinner = JGProgressHUD(style: .light)

    let imagePicker = UIImagePickerController()
    let imageCropper = UIImageCropper(cropRatio: UIImageCropper.CROP_RATIO)
    
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
        label.text = "Photos"
        return label
    }()
    
    private let xButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        return btn
    }()
    
    
    let editButton: UIButton = {
        let btn = UIButton()
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                         .foregroundColor: UIColor.zipBlue]

        btn.setAttributedTitle(NSMutableAttributedString(string: "Edit", attributes: attributes), for: .normal)
        
    
        return btn
    }()
    
    @objc private func didTapFocusedImage(){
        focusedImage.layer.removeAllAnimations()
//        guard let collectionView = collectionView else {
//            return
//        }
        
//        guard let cellAttributes = collectionView.layoutAttributesForItem(at: IndexPath(row: focusedImage.tag, section: 0)) else {
//            return
//        }
        
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.focusedImage.transform = CGAffineTransform(scaleX: 1, y: 1)//1/(self?.focusedImageScale ?? 1),
                                                                  //y: 1/(self?.focusedImageScale ?? 1))
            
            guard let strongSelf = self else { return }
            self?.focusedImage.center.y = strongSelf.view.frame.midY //collectionView.frame.minY + cellAttributes.frame.midY + collectionView.contentInset.top
            self?.focusedImage.center.x = strongSelf.view.frame.midX //collectionView.frame.minX + cellAttributes.frame.midX
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
                let cell = collectionView?.cellForItem(at: IndexPath(row: i, section: 0)) as? EditPicturesCollectionViewCell
                cell?.xButton.isHidden = false
            }
            
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                             .foregroundColor: UIColor.zipBlue]

            editButton.setAttributedTitle(NSMutableAttributedString(string: "Done", attributes: attributes), for: .normal)
            
            collectionView?.reloadData()
            
        } else { // save
            user.picNum = userPictures.count + 1
            AppDelegate.userDefaults.set(userPictures.count + 1, forKey: "picNum")
            var idx = 0
            for img in userPictures {
                if img.isEdited {
                    guard let cell = collectionView?.cellForItem(at: IndexPath(row: idx, section: 0)) as?  EditPicturesCollectionViewCell,
                          let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String,
                          let image = cell.picture.image else {
                              return
                          }
                    
                    StorageManager.shared.updateIndividualImage(with: image, path: "images/\(userId)/", index: idx, completion: { [weak self] result in
                        switch result {
                        case .success(let url):
                            // TODO: potential error with order of photos
                            img.url = URL(string: url)
                            self?.user.pictureURLs.append(URL(string: url)!)
                        case .failure(let error):
                            print("error: \(error)")
                        }
                    })
                }
                idx += 1
            }
            
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                             .foregroundColor: UIColor.zipBlue]
            editButton.setAttributedTitle(NSMutableAttributedString(string: "Edit", attributes: attributes), for: .normal)
            
            for i in 0..<userPictures.count {
                let cell = collectionView?.cellForItem(at: IndexPath(row: i, section: 0)) as! EditPicturesCollectionViewCell
                cell.xButton.isHidden = true
            }
            
            collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if AppDelegate.userDefaults.value(forKey: "userId") as? String != user.userId {
            editButton.isHidden = true
        }
        
        
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        view.isOpaque = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapFocusedImage))
        focusedImage.addGestureRecognizer(tap)
        xButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
//        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .overCurrentContext
        
        imageCropper.picker = imagePicker
        imageCropper.delegate = self
    }
    
    public func configure(user: User) {
        self.user = user
        collectionView?.reloadData()
        originalPicUrls = user.otherPictureUrls
        
        for url in user.otherPictureUrls {
            userPictures.append(PictureHolder(url: url))
        }
        
        configureCollectionView()
        addSubviews()
        layoutSubviews()
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
        collectionView.contentInset = UIEdgeInsets(top: 100, left: 12, bottom: 0, right: 12)
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
            
            focusedImage.sd_setImage(with: user.otherPictureUrls[indexPath.row], completed: nil)
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pictureCell", for: indexPath) as! EditPicturesCollectionViewCell
            cell.delegate = self
            cell.xButton.tag = indexPath.row
            if editButton.titleLabel?.text == "Done" {
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




//func shakeCell(_ cell: UICollectionViewCell ) {
//    let shakeAnimation = CABasicAnimation(keyPath: "transform.rotation")
//    shakeAnimation.duration = 0.05
//    shakeAnimation.repeatCount = 2
//    shakeAnimation.autoreverses = true
//    let startAngle: Float = (-2) * 3.14159/180
//    let stopAngle = -startAngle
//    shakeAnimation.fromValue = NSNumber(value: startAngle as Float)
//    shakeAnimation.toValue = NSNumber(value: 3 * stopAngle as Float)
//    shakeAnimation.autoreverses = true
//    shakeAnimation.duration = 0.15
//    shakeAnimation.repeatCount = 10000
//    shakeAnimation.timeOffset = 290 * drand48()
//
//    let layer: CALayer = cell.layer
//    layer.add(shakeAnimation, forKey:"shaking")
//}
//
//func stopShaking(_ cell: UICollectionViewCell) {
//    let layer: CALayer = cell.layer
//    layer.removeAnimation(forKey: "shaking")
//}
