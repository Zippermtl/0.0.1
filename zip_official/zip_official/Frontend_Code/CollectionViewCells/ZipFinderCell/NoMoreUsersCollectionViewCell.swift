//
//  NoMoreUsersCollectionViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/8/22.
//

import UIKit
protocol DidTapGlobalProtocol: AnyObject {
    func goGlobal()
}

class NoMoreUsersCollectionViewCell: UICollectionViewCell {
    static let identifier = "lastCell"
    
    private let cardView: UIView
    private let oopsLabel: UILabel
    private let goToSettingsLabel: UILabel
    private let changeSettingsButton: UIButton
    
    weak var delegate: DidTapGlobalProtocol?
    
    override init(frame: CGRect) {
        cardView = UIView()
        oopsLabel = UILabel.zipHeader()
        goToSettingsLabel = UILabel.zipTextFill()
        changeSettingsButton = UIButton()
        
        super.init(frame: frame)
        changeSettingsButton.addTarget(self, action: #selector(didTapGlobal), for: .touchUpInside)
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        cardView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        cardView.heightAnchor.constraint(equalToConstant: contentView.frame.height).isActive = true
        cardView.widthAnchor.constraint(equalToConstant: contentView.frame.width-25).isActive = true

        cardView.layer.cornerRadius = 30
        cardView.layer.borderColor = UIColor.white.cgColor //UIColor.zipBlue.cgColor
        cardView.layer.borderWidth = 2
        cardView.backgroundColor = .zipGray
        
        contentView.addSubview(oopsLabel)
        oopsLabel.numberOfLines = 0
        oopsLabel.lineBreakMode = .byWordWrapping
        oopsLabel.text = "Opps! There's no more people to show you!"
        
        oopsLabel.translatesAutoresizingMaskIntoConstraints = false
        oopsLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        oopsLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 75).isActive = true
        oopsLabel.widthAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.75).isActive = true

        
        
        contentView.addSubview(goToSettingsLabel)
        goToSettingsLabel.numberOfLines = 0
        goToSettingsLabel.lineBreakMode = .byWordWrapping
        goToSettingsLabel.text = "Go to Settings to change the search filters to show you more users"
        
        goToSettingsLabel.translatesAutoresizingMaskIntoConstraints = false
        goToSettingsLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        goToSettingsLabel.topAnchor.constraint(equalTo: oopsLabel.bottomAnchor, constant: 20).isActive = true
        goToSettingsLabel.widthAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.6).isActive = true

        
        contentView.addSubview(changeSettingsButton)
        changeSettingsButton.setTitle("Change search filters", for: .normal)
        changeSettingsButton.setTitleColor(.white, for: .normal)
        changeSettingsButton.backgroundColor = .zipVeryLightGray
        
        changeSettingsButton.translatesAutoresizingMaskIntoConstraints = false
        changeSettingsButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        changeSettingsButton.topAnchor.constraint(equalTo: goToSettingsLabel.bottomAnchor, constant: 20).isActive = true
        changeSettingsButton.widthAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.6).isActive = true


    }
    
    @objc private func didTapGlobal() {
        delegate?.goGlobal()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
