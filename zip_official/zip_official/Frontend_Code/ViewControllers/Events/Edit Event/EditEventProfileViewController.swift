//
//  EditEventProfileViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/7/22.
//

import UIKit

class EditEventProfileViewController: UIViewController {
    private var dismissTap: UITapGestureRecognizer?

    var event: Event
    
    var tableView: UITableView
    private var changeProfilePicBtn: UIButton
    private var profilePic: UIImageView
    private var tableHeader: UIView
    private var eventBorder: UIView
    private var imagePicker: UIImagePickerController

    
    init(event: Event) {
        self.event = event
        self.tableView = UITableView()
        self.changeProfilePicBtn = UIButton()
        self.profilePic = UIImageView()
        self.tableHeader = UIView()
        self.eventBorder = UIView()
        self.imagePicker = UIImagePickerController()
        
        super.init(nibName: nil, bundle: nil)
        dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardTouchOutside))
        dismissTap?.delegate = self
        tableView.addGestureRecognizer(dismissTap!)
        view.backgroundColor = .zipGray

        title = "Edit Event"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                            style: UIBarButtonItem.Style.done,
                                                            target: self,
                                                            action: #selector(didTapSave))
        navigationItem.rightBarButtonItem?.tintColor = .zipBlue
        
        eventBorder.layer.borderColor = event.getType().color.cgColor
        eventBorder.layer.borderWidth = 4
        
        
        imagePicker.delegate = self

        configureTable()
        configureTableHeader()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func dismissKeyboardTouchOutside(){
        view.endEditing(true)
    }
    
    @objc private func didTapSave(){
        
    }
    
    @objc private func didTapChangeProfilePic() {
        present(imagePicker, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePic.layer.cornerRadius = view.frame.width/8
        eventBorder.layer.cornerRadius = view.frame.width/8+8
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableHeader.setNeedsLayout()
        tableHeader.layoutIfNeeded()

    }
    
    private func configureTable() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(EditTextFieldTableViewCell.self, forCellReuseIdentifier: EditTextFieldTableViewCell.identifier)
        tableView.register(EditEventTypeTableViewCell.self, forCellReuseIdentifier: EditEventTypeTableViewCell.identifier)
        tableView.register(EditEventTimeTableViewCell.self, forCellReuseIdentifier: EditEventTimeTableViewCell.identifier)
        tableView.register(EditEventLocationTableViewCell.self, forCellReuseIdentifier: EditEventLocationTableViewCell.identifier)
        tableView.register(EditEventCapacityTableViewCell.self, forCellReuseIdentifier: EditEventCapacityTableViewCell.identifier)
    }
    
    private func configureTableHeader() {
        tableHeader.addSubview(profilePic)
        tableHeader.addSubview(changeProfilePicBtn)

        profilePic.translatesAutoresizingMaskIntoConstraints = false
        profilePic.topAnchor.constraint(equalTo: tableHeader.topAnchor,constant: 20).isActive = true
        profilePic.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        profilePic.widthAnchor.constraint(equalTo: tableHeader.widthAnchor, multiplier: 0.25).isActive = true
        profilePic.heightAnchor.constraint(equalTo: profilePic.widthAnchor).isActive = true
        
        tableHeader.addSubview(eventBorder)
        eventBorder.translatesAutoresizingMaskIntoConstraints = false
        eventBorder.centerXAnchor.constraint(equalTo: profilePic.centerXAnchor).isActive = true
        eventBorder.centerYAnchor.constraint(equalTo: profilePic.centerYAnchor).isActive = true
        eventBorder.widthAnchor.constraint(equalTo: profilePic.widthAnchor, constant: 16).isActive = true
        eventBorder.heightAnchor.constraint(equalTo: eventBorder.widthAnchor).isActive = true
        
        changeProfilePicBtn.translatesAutoresizingMaskIntoConstraints = false
        changeProfilePicBtn.topAnchor.constraint(equalTo: profilePic.bottomAnchor,constant: 10).isActive = true
        changeProfilePicBtn.centerXAnchor.constraint(equalTo: profilePic.centerXAnchor).isActive = true
        
        profilePic.sd_setImage(with: event.imageUrl, completed: nil)
        profilePic.layer.masksToBounds = true

        changeProfilePicBtn.setTitle("Change Profile Picture", for: .normal)
        changeProfilePicBtn.setTitleColor(.zipBlue, for: .normal)
        changeProfilePicBtn.titleLabel?.font = .zipTextFill

        
        tableHeader.translatesAutoresizingMaskIntoConstraints = false
        tableHeader.topAnchor.constraint(equalTo: profilePic.topAnchor, constant: -20).isActive = true
        tableHeader.bottomAnchor.constraint(equalTo: changeProfilePicBtn.bottomAnchor, constant: 10).isActive = true
        tableHeader.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        
        tableView.tableHeaderView = tableHeader
    }
}


extension EditEventProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func saveTitleFunc(_ s: String) {
        
    }
    
    func saveDescriptionFunc(_ s: String) {
        
    }
    
    func saveLocationFunc(_ s: String) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: // Public / Private
            let cell = tableView.dequeueReusableCell(withIdentifier: EditEventTypeTableViewCell.identifier, for: indexPath) as! EditEventTypeTableViewCell
            cell.configure(event: event)
            cell.selectionStyle = .none
            return cell
        case 1: // Title
            let cell = tableView.dequeueReusableCell(withIdentifier: EditTextFieldTableViewCell.identifier, for: indexPath) as! EditTextFieldTableViewCell
            cell.configure(label: "Title", content: event.title, saveFunc: saveTitleFunc(_:))
            cell.charLimit = 30
            cell.selectionStyle = .none
            cell.cellDelegate = self
            return cell
        case 2: // Date / time
//            return UITableViewCell()
            let cell = tableView.dequeueReusableCell(withIdentifier: EditEventTimeTableViewCell.identifier, for: indexPath) as! EditEventTimeTableViewCell
            cell.configure(event: event)
            cell.selectionStyle = .none

            return cell
        case 3: // location
            let cell = tableView.dequeueReusableCell(withIdentifier: EditEventLocationTableViewCell.identifier, for: indexPath) as! EditEventLocationTableViewCell
            cell.configure(event: event, saveFunc: saveLocationFunc(_:))
            cell.GMSDelegate = self
            cell.cellDelegate = self
            cell.selectionStyle = .none
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditTextFieldTableViewCell.identifier, for: indexPath) as! EditTextFieldTableViewCell
            cell.configure(label: "Description", content: event.description, saveFunc: saveDescriptionFunc(_:))
            cell.charLimit = 300
            cell.selectionStyle = .none
            cell.cellDelegate = self
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditEventCapacityTableViewCell.identifier, for: indexPath) as! EditEventCapacityTableViewCell
            cell.configure(event: event)
            cell.selectionStyle = .none
            return cell
        default: return UITableViewCell()
        }
    }
}


extension EditEventProfileViewController: GrowingCellProtocol {
    func updateHeightOfRow(_ cell: UITableViewCell, _ view: UIView) {
        let size = view.bounds.size
        let newSize = tableView.sizeThatFits(CGSize(width: size.width,
                                                        height: CGFloat.greatestFiniteMagnitude))
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
    
    func updateValue(value: String){
        
    }
}


extension EditEventProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            
            StorageManager.shared.updateIndividualImage(with: image, path: "Event/\(event.eventId)/", index: 0, completion: { [weak self] result in
                switch result {
                case .success(let url):
                    self?.event.imageUrl = URL(string: url)!
                    self?.dismiss(animated: true, completion: nil)
                    self?.profilePic.image = image
                case .failure(let error):
                    print("error uploading profile pic: \(error)")
                    let actionSheet = UIAlertController(title: "Failed to upload profile picture",
                                                        message: "Try again later",
                                                        preferredStyle: .actionSheet)
                    
                    actionSheet.addAction(UIAlertAction(title: "Ok",
                                                        style: .cancel,
                                                        handler: { [weak self] _ in
                        
                        self?.dismiss(animated: true, completion: nil)
                    }))
                    self?.present(actionSheet, animated: true)
                }
            })
        }
        
    }
}


extension EditEventProfileViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl) && !(touch.view is UITextView)
    }
}
