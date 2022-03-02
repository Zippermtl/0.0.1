//
//  LoadingViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 1/25/22.
//

import UIKit
import CoreLocation



class LoadingViewController: UIViewController {

     //info that needs to be loaded
    var zipRequests: [ZipRequest] = []

    
    
    
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
            loadZipRequests()
        }
    }
    
    private func loadZipRequests() {
        
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            return
        }
        
        let user = User(userId: userId)
        user.getIncomingRequests(completion: { [weak self] results in

            switch results {
            case .success(let requests):
                self?.zipRequests = requests
            case .failure(let error):
                print("failed to initialize zip requests on launch with error \(error)")
            }
            
            // present map regaurdless?
            self?.presentMap()


        })
    }
    
    private func presentMap(){
        let vc = MapViewController()
        vc.isNewAccount = false
        vc.zipRequests = zipRequests
        print("ZIP REQUESTS = \(zipRequests)")
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
    private func configureLayout(){
        view.addSubview(logo)
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        logo.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        logo.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 250).isActive = true
    }
    
    


}
