//
//  GenderSelectViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/9/22.
//

import UIKit

protocol GenderCellDelegate: AnyObject {
    func selectGender(s: String)
}

class GenderSelectViewController: UIViewController {
    
    var gender = ""
    var user: User
    let tableView: UITableView
    let cellLabels: [String]

    init(user: User) {
        self.user = user
        tableView = UITableView()
        cellLabels = ["Man", "Woman", "Other", "Prefer Not To Say"]

        super.init(nibName: nil, bundle: nil)
        navigationItem.backBarButtonItem =  BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: UIBarButtonItem.Style.done,
                                                            target: self,
                                                            action: #selector(didTapDoneButton))
        
        title = "Select Your Gender"
        view.backgroundColor = .zipGray
        
        tableView.backgroundColor = .zipGray
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GenderCell.self, forCellReuseIdentifier: GenderCell.idnetifier)
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @objc public func didTapDoneButton(){
        guard gender != "" else {
            return
        }
        user.gender = gender
        let vc = BasicProfileSetupViewController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension GenderSelectViewController: GenderCellDelegate {
    func selectGender(s: String) {
        let idx = cellLabels.firstIndex(of: s)
        for cell in tableView.visibleCells.map({ $0 as! GenderCell })  {
            cell.selectionButton.isSelected = false
        }
        (tableView.cellForRow(at: IndexPath(row: idx!, section: 0)) as! GenderCell).selectionButton.isSelected = true
        
        switch idx {
        case 0: gender = "M"
        case 1: gender = "W"
        case 2: gender = "O"
        default: gender = "P"
        }
    }
}

extension GenderSelectViewController:  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellLabels.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GenderCell.idnetifier) as! GenderCell
        cell.configure(text: cellLabels[indexPath.row])
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
}

extension GenderSelectViewController {
    
    internal class GenderCell: UITableViewCell {
        static let idnetifier = "gendercell"
        weak var delegate: GenderCellDelegate?
        
        let typeLabel: UILabel
        let selectionButton: UIButton
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            typeLabel = UILabel.zipTextFill()
            selectionButton = UIButton()
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = .clear
            contentView.backgroundColor = .zipLightGray
            contentView.layer.masksToBounds = true
            contentView.layer.cornerRadius = 15
            
            let circleConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .light, scale: .large)
            let checkConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)

            selectionButton.setImage(UIImage(systemName: "circle", withConfiguration: circleConfig)?.withRenderingMode(.alwaysOriginal).withTintColor(.white ), for: .normal)
            selectionButton.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: checkConfig)?.withRenderingMode(.alwaysOriginal).withTintColor(.zipBlue), for: .selected)
            selectionButton.addTarget(self, action: #selector(didTapSwitch), for: .touchUpInside)
            contentView.addSubview(typeLabel)
            contentView.addSubview(selectionButton)
            
            typeLabel.translatesAutoresizingMaskIntoConstraints = false
            typeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            typeLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15).isActive = true
            
            selectionButton.translatesAutoresizingMaskIntoConstraints = false
            selectionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            selectionButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15).isActive = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public func configure(text: String) {
            selectionButton.isSelected = false
            typeLabel.text = text
        }
        
        @objc private func didTapSwitch() {
            print("switchtap")
            delegate?.selectGender(s: typeLabel.text!)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
        }
           
    }
}
