//
//  UserPhotosViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 1/6/22.
//

import UIKit

class UserPhotosViewController: UIViewController {
    var user = User()
    
    private var collectionView: UICollectionView?
    
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
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapEditButton() {
        if editButton.titleLabel?.text == "Edit" {
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                             .foregroundColor: UIColor.zipBlue ,
                                                             .underlineStyle: NSUnderlineStyle.single.rawValue]

            editButton.setAttributedTitle(NSMutableAttributedString(string: "Save", attributes: attributes), for: .normal)
            previewButton.setAttributedTitle(NSMutableAttributedString(string: "Cancel", attributes: attributes), for: .normal)
        } else {
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                             .foregroundColor: UIColor.white ,
                                                             .underlineStyle: NSUnderlineStyle.single.rawValue]

            editButton.setAttributedTitle(NSMutableAttributedString(string: "Edit", attributes: attributes), for: .normal)
            previewButton.setAttributedTitle(NSMutableAttributedString(string: "Preview", attributes: attributes), for: .normal)

        }
    }
    
    @objc private func didTapPreviewButton() {
        if editButton.titleLabel?.text == "Edit" {
            let vc = ZFSingleCardViewController()
            vc.configure(user: user)
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        } else {
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                             .foregroundColor: UIColor.white ,
                                                             .underlineStyle: NSUnderlineStyle.single.rawValue]

            editButton.setAttributedTitle(NSMutableAttributedString(string: "Edit", attributes: attributes), for: .normal)
            previewButton.setAttributedTitle(NSMutableAttributedString(string: "Preview", attributes: attributes), for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        view.isOpaque = false
    }
    
    public func configure(user: User) {
        self.user = user
        collectionView?.reloadData()
        
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
        
        collectionView.register(PictureCollectionViewCell.self, forCellWithReuseIdentifier: "pictureCell")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "default")

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
//            let cell = collectionView.cellForItem(at: indexPath)
//            focusedImage.sd_setImage(with: user.pictureURLs[indexPath.row], completed: nil)
//            focusedImage.frame = CGRect(x: cell.frame.minX, y: <#T##Double#>, width: <#T##Double#>, height: <#T##Double#>)
//
//
//
//
        }
    }
}

extension UserPhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < user.pictureURLs.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pictureCell", for: indexPath) as! PictureCollectionViewCell
            cell.configure(with: user.pictureURLs[indexPath.row])
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath)
        cell.backgroundColor = .zipLightGray.withAlphaComponent(0.6)
        return cell
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
