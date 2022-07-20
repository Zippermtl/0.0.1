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


class OtherProfileViewController: AbstractProfileViewController  {
    private var distanceLabel: DistanceLabel
    
    init(id: String) {
        let actionButtonInfo = ("Zipped", UIColor.zipBlue)
        let reportIcon = UIImage(systemName: "ellipsis")!.withRenderingMode(.alwaysOriginal).withTintColor(.white)

        distanceLabel = DistanceLabel()
        
        super.init(id: id,
                   B1: IconButton.inviteIcon(),
                   B2: IconButton.messageIcon(),
                   B3: IconButton.zipsIcon(),
                   rightBarButtonIcon: reportIcon,
                   centerActionInfo: actionButtonInfo
        )
        
        tableHeader.addSubview(distanceLabel)
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        distanceLabel.topAnchor.constraint(equalTo: centerActionButton.bottomAnchor, constant: 10).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didTapRightBarButton() {
        let vc = ReportViewController(user: user)
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        switch user.friendshipStatus {
        case .ACCEPTED:
            setZippedState()
        case .REQUESTED_OUTGOING:
            setRequestedState()
        case .REQUESTED_INCOMING:
            setIncomingRequestState()
//        case default:
//            centerActionButton?.setTitle("Zip", for: .normal)
//            centerActionButton?.backgroundColor = .zipBlue
//
        }
         */
        
        setIncomingRequestState()
        distanceLabel.update(distance: user.getDistance())
        centerActionButton.layer.borderColor = UIColor.zipBlue.cgColor
        

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
    //                user.unzip
                
                self?.setNoRelationState()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "No",
                                                style: .cancel,
                                                handler: nil))
            
            present(actionSheet, animated: true)
        case .REQUESTED_OUTGOING: //
            //user.unrequest
            setNoRelationState()
        case .REQUESTED_INCOMING: // You have now accepted the follow request
            
            setZippedState()
            setNoRelationState()
        case .none:
            request()
            setRequestedState()
        }
    }
    
    private func request() {
        
    }
    
    private func setRequestedState(){
        centerActionButton.setTitle("Requested", for: .normal)
        centerActionButton.backgroundColor = .zipVeryLightGray
        centerActionButton.layer.borderWidth = 0
    }
    
    private func setNoRelationState(){
        centerActionButton.setTitle("Zip", for: .normal)
        centerActionButton.backgroundColor = .zipBlue
        centerActionButton.layer.borderWidth = 0
    }
    
    private func setZippedState(){
        centerActionButton.setTitle("Zipped", for: .normal)
        centerActionButton.backgroundColor = .zipGray
        centerActionButton.layer.borderWidth = 3
    }
    
    private func setIncomingRequestState() {
        centerActionButton.setTitle("Zip Back", for: .normal)
        centerActionButton.backgroundColor = .zipBlue
        centerActionButton.layer.borderWidth = 3
    }
    

    
    override func didTapB1Button() {
        let vc = InviteUserToEventViewController()
        vc.modalPresentationStyle = .overCurrentContext
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didTapB2Button() {
        
    }
    
    override func didTapB3Button() {
        let myZipsView = MyZipsViewController(user: user)
        myZipsView.modalPresentationStyle = .overCurrentContext
        navigationController?.pushViewController(myZipsView, animated: true)
    }
    
    override func didTapPhotos() {
        let vc = UserPhotosViewController()
        vc.configure(user: user)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    override func didTapDismiss(){
        navigationController?.popViewController(animated: true)
    }
}
