//
//  LocationDeniedViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 1/25/22.
//

import UIKit

class LocationDeniedViewController: UIViewController {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .zipTitle
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "Oops."
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBody
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "You must enable your Location Serivces in order to use Zipper.\n\nGo to Settings > Zipper > Location > Enable Location While Using the App"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipLogoBlue

        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -100).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true

        view.addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        subtitleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        subtitleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
    }
    
    

}
