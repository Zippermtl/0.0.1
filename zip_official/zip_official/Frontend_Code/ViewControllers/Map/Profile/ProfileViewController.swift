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


class ProfileViewController: AbstractProfileViewController {
    
    init(id: String) {
        let actionButtonInfo = ("EDIT", UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1))
        let settingsIcon = UIImage(systemName: "gearshape.fill")!.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        super.init(id: id,
                   B1: IconButton.eventsIcon(),
                   B2: IconButton.myCardIcon(),
                   B3: IconButton.zipsIcon(),
                   rightBarButtonIcon: settingsIcon,
                   centerActionInfo: actionButtonInfo
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didTapRightBarButton() {
        let settingsView = SettingsPageViewController()
        settingsView.modalPresentationStyle = .overCurrentContext
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        view.window!.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(settingsView, animated: true)
    }
    
    override func didTapCenterActionButton() {
        let editView = EditProfileViewController(user: user)
        editView.delegate = self
        editView.modalPresentationStyle = .overCurrentContext
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        view.window!.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(editView, animated: true)
    }
    
    override func didTapB1Button() {
        print("tapping events")
        let myEventsView = MyEventsViewController()
        myEventsView.modalPresentationStyle = .overCurrentContext
        navigationController?.pushViewController(myEventsView, animated: true)
    }
    
    override func didTapB2Button() {
        let cardPreview = ZFSingleCardViewController()
        cardPreview.configure(user: user)
        cardPreview.modalPresentationStyle = .overCurrentContext
        present(cardPreview, animated: true)
    }
    
    override func didTapB3Button() {
        let myZipsView = UsersTableViewController(users: User.getMyZips())
        myZipsView.title = "My Zips"
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

extension ProfileViewController: UpdateFromEditProtocol {
    func update() {
        print("updating")
        tableView.reloadData()
        title = user.username
        configureCells()
    }
}
