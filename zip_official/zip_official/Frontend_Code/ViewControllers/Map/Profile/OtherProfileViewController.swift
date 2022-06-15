//
//  SecondViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/2/21.
//


import UIKit
import MapKit
import CoreLocation
import SDWebImage
import JGProgressHUD
import MTSlideToOpen


//
//  SecondViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/2/21.
//


import UIKit
import MapKit
import CoreLocation
import SDWebImage
import JGProgressHUD

/*
 
 let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
 let img = UIImage(systemName: "calendar", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
 
 let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
 let img = UIImage(systemName: "person.3.fill", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
 
 
 let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
 let img = UIImage(systemName: "calendar", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
 let icon = UIImageView(image: img)
 
 
 
 
 
 
 */


class OtherProfileViewController: AbstractProfileViewController {
    private let settingsButton = UIBarButtonItem(image: UIImage.init(systemName: "ellipsis")!
                                                    .withRenderingMode(.alwaysOriginal)
                                                    .withTintColor(.white),
                                                     landscapeImagePhone: nil,
                                                     style: .plain,
                                                     target: self,
                                                     action: #selector(didTapRightBarButton))
    
    
    private var distanceLabel: DistanceLabel?
    
    init(id: String) {
        let actionButtonInfo = ("ZIPPED", UIColor.zipBlue)
        
        super.init(id: id,
                   B1: IconButton.inviteIcon(),
                   B2: IconButton.messageIcon(),
                   B3: IconButton.zipsIcon(),
                   rightBarButton:
                   settingsButton,
                   centerActionInfo: actionButtonInfo
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch user.friendshipStatus {
        case .ACCEPTED:
            centerActionButton?.setTitle("Zipped", for: .normal)
            centerActionButton?.backgroundColor = .zipBlue
        case .REQUESTED_OUTGOING:
            centerActionButton?.setTitle("Requested", for: .normal)
            centerActionButton?.backgroundColor = .zipYellow
        case .REQUESTED_INCOMING:
            centerActionButton?.setTitle("Accept?", for: .normal)
            centerActionButton?.backgroundColor = .zipGreen
//        case default:
//            centerActionButton?.setTitle("Zip", for: .normal)
//            centerActionButton?.backgroundColor = .zipBlue
//
        }
        
        
        distanceLabel = DistanceLabel(distance: user.getDistance())
        tableHeader?.addSubview(distanceLabel!)
        distanceLabel?.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel?.centerXAnchor.constraint(equalTo: tableHeader!.centerXAnchor).isActive = true
        distanceLabel?.topAnchor.constraint(equalTo: centerActionButton!.bottomAnchor, constant: 10).isActive = true

    }
    
    override func didTapRightBarButton() {

    }
    
    override func didTapCenterActionButton() {
        switch user.friendshipStatus {
        case .ACCEPTED:
            let actionSheet = UIAlertController(title: "Are you sure you would like to unfollow \(user.fullName)",
                                                message: "",
                                                preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Yes",
                                                style: .default,
                                                handler: { [weak self] _ in
                                                    
            //TODO: update with nics new code
//                user.rejectFriend
                
                self?.centerActionButton?.setTitle("Zip", for: .normal)
                self?.centerActionButton?.backgroundColor = .zipBlue
            }))
            
            actionSheet.addAction(UIAlertAction(title: "No",
                                                style: .cancel,
                                                handler: nil))
            
        case .REQUESTED_OUTGOING:
            //TODO: update with nics new code
//                user.cancelOutgoingRequest
            centerActionButton?.setTitle("Requested", for: .normal)
            centerActionButton?.backgroundColor = .zipYellow
        case .REQUESTED_INCOMING:
            //TODO: update with nics new code
//            user.acceptFriend
            centerActionButton?.setTitle("Accept?", for: .normal)
            centerActionButton?.backgroundColor = .zipGreen
//        case default:
            //TODO: update with nics new code
//            user.request friend
//            centerActionButton?.setTitle("Zip", for: .normal)
//            centerActionButton?.backgroundColor = .zipBlue
//
        }
    }
    
    override func didTapB1Button() {
        let myEventsView = MyEventsViewController()
        myEventsView.modalPresentationStyle = .overCurrentContext
        navigationController?.pushViewController(myEventsView, animated: true)
    }
    
    override func didTapB2Button() {
        
    }
    
    override func didTapB3Button() {
        let myZipsView = MyZipsViewController()
        myZipsView.modalPresentationStyle = .overCurrentContext
        navigationController?.pushViewController(myZipsView, animated: true)
    }
    
    override func didTapPhotos() {
        let vc = UserPhotosViewController()
        vc.configure(user: user)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }


}
