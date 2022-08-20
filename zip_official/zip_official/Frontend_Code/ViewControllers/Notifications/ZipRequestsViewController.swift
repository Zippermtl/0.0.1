//
//  ZipRequestsViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/19/21.
//

import UIKit

class ZipRequestsViewController: UIViewController {
    var tableView: ZipRequestTableView
    
    
    init(){
        self.tableView = ZipRequestTableView()
        super.init(nibName: nil, bundle: nil)
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        title = "Zip Requests"
    }

}
