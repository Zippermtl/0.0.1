//
//  UserPhotosViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 1/6/22.
//

import UIKit

class UserPhotosViewController: UIViewController {

    @objc private func didTapPreviewButton() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
    }
    
    private func configureNavBar(){
        title = "Photos"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Preview",
                                                            style: UIBarButtonItem.Style.done,
                                                            target: self,
                                                            action: #selector(didTapPreviewButton))
        //removes the text section of the back button from pushed VCs
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
}
