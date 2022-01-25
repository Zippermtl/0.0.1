//
//  LoadingViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 1/25/22.
//

import UIKit
import CoreLocation

class LoadingViewController: UIViewController {
    private let logo: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "logopng")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
//    private let progressView: UIProgressView = {
//        let view = UIProgressView(progressViewStyle: .bar)
//        view.trackTintColor = .clear
//        view.progressTintColor = .white
//        view.layer.borderWidth = 2
//        view.layer.borderColor = UIColor.white.cgColor
//        return view
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipLogoBlue
        configureLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationServices()
    }
    
    private func checkLocationServices() {
        let manager = CLLocationManager()
        if !CLLocationManager.locationServicesEnabled() || manager.authorizationStatus == .denied {
            let vc = LocationDeniedViewController()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true, completion: nil)
        } else {
            let vc = MapViewController()
            vc.isNewAccount = false
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true, completion: nil)
        }
    }
    
    private func configureLayout(){
        view.addSubview(logo)
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        logo.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        logo.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 250).isActive = true
//        logo.backgroundColor = .red
        
//        view.addSubview(progressView)
//        progressView.translatesAutoresizingMaskIntoConstraints = false
//        progressView.topAnchor.constraint(equalTo: logo.bottomAnchor).isActive = true
//        progressView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
//        progressView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
//        progressView.heightAnchor.constraint(equalToConstant: 20).isActive = true
//        progressView.setProgress(0, animated: false)
    }
    
    


}
