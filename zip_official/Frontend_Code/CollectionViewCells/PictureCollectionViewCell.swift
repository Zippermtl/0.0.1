//
//  PictureCollectionViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/18/21.
//

import UIKit

class PictureCollectionViewCell: UICollectionViewCell {
    static let identifier = "PictureCollectionViewCell"
    private var picture = UIImageView()
//    private var pictureContainer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with img: UIImage) {
        picture = UIImageView(image: img)
        contentView.addSubview(picture)

        picture.translatesAutoresizingMaskIntoConstraints = false
        picture.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        picture.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        picture.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        picture.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        picture = UIImage()
//        pictureContainer = UIView()
//    }
}


