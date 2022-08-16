//
//  ZipNewsTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/15/22.
//

import UIKit

class ZipNewsTableViewCell: UITableViewCell {

    static let identifier = "myZipUser"
    
    //MARK: - User Data
    private var pictureView: UIImageView
    private var outlineView: UIView
    private var titleLabel: UILabel
    private var timeLabel: UILabel
    private let openButton: UIButton

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.pictureView = UIImageView()
        self.titleLabel = UILabel.zipTextNotiBold()
        self.timeLabel = UILabel.zipTextDetail()
        self.outlineView = UIView()
        self.openButton = UIButton()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .zipGray
        openButton.addTarget(self, action: #selector(didTapOpen), for: .touchUpInside)
        openButton.backgroundColor = .zipBlue
        openButton.setTitle("Open", for: .normal)
        openButton.setTitleColor(.white, for: .normal)
        openButton.titleLabel?.font = .zipTextNoti
        
        contentView.addSubview(openButton)
        openButton.translatesAutoresizingMaskIntoConstraints = false
        openButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        openButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -30).isActive = true
        openButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        pictureView.backgroundColor = .black
        pictureView.image = UIImage(named: "zipperLogo")
        pictureView.contentMode = .scaleAspectFit
        addSubviews()
        configureSubviewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapOpen(){
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pictureView.layer.cornerRadius = pictureView.frame.width/2
    }
    
    //MARK: - Configure
    public func configure(updateNumber: Float){
        titleLabel.text = "What's new in Zipper \(updateNumber)!"
        timeLabel.text = "need to implement time"
    }
    
    
    //MARK: -Add Subviews
    private func addSubviews(){
        contentView.addSubview(outlineView)
        outlineView.addSubview(pictureView)
        outlineView.addSubview(titleLabel)
        outlineView.addSubview(timeLabel)
    }

    //MARK: - Layout Subviews
    private func configureSubviewLayout(){
//        outlineView.frame = CGRect(x: 10, y: 10, width: contentView.frame.width-20, height: contentView.frame.height-20)
        outlineView.layer.cornerRadius = 15
        outlineView.backgroundColor = .zipLightGray
        pictureView.layer.masksToBounds = true
        
        outlineView.translatesAutoresizingMaskIntoConstraints = false
        outlineView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        outlineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        outlineView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        outlineView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true

        pictureView.translatesAutoresizingMaskIntoConstraints = false
        pictureView.leftAnchor.constraint(equalTo: outlineView.leftAnchor, constant: 10).isActive = true
        pictureView.topAnchor.constraint(equalTo: outlineView.topAnchor, constant: 5).isActive = true
        pictureView.bottomAnchor.constraint(equalTo: outlineView.bottomAnchor, constant: -5).isActive = true
        pictureView.widthAnchor.constraint(equalTo: pictureView.heightAnchor).isActive = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leftAnchor.constraint(equalTo: pictureView.rightAnchor, constant: 10).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: outlineView.centerYAnchor).isActive = true
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: outlineView.centerYAnchor).isActive = true
        

    }
    
    

}
