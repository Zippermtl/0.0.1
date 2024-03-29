//
//  EditEventProfileViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/7/22.
//

import UIKit
protocol UpdateFromEditEventProtocol: AnyObject {
    func update(event: Event)
}


class EditEventProfileViewController: UIViewController {
    private var dismissTap: UITapGestureRecognizer?
    weak var delegate : UpdateFromEditEventProtocol?
    var event: Event
    var changedPFP = false
    var tableView: UITableView
    private var changeProfilePicBtn: UIButton
    private var profilePic: UIImageView
    private var tableHeader: UIView
    private var eventBorder: UIView
    private var imagePicker: UIImagePickerController
    
    var initialEventType: EventType
    var newEventType: EventType

    
    init(event: Event) {
        self.event = event
        self.tableView = UITableView()
        self.changeProfilePicBtn = UIButton()
        self.profilePic = UIImageView()
        self.tableHeader = UIView()
        self.eventBorder = UIView()
        self.imagePicker = UIImagePickerController()
        print("INIT TYPE = \(event.getType())")
        self.initialEventType = event.getType()
        self.newEventType = event.getType()

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
        
        changeProfilePicBtn.addTarget(self, action: #selector(didTapChangeProfilePic), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        profilePic.isUserInteractionEnabled = true
        profilePic.addGestureRecognizer(tap)
        
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
    
    @objc public func didTapSave(){
        view.endEditing(true)
        
        if let event = event as? UserEvent {
            event.type = newEventType
        }
        
        DatabaseManager.shared.updateEvent(event: event, completion: { [weak self] error in
            guard let strongSelf = self,
                  error == nil else {
                return
            }

            if strongSelf.changedPFP {
                let id = strongSelf.event.eventId
                let pp = PictureHolder(image: strongSelf.profilePic.image!)
                pp.isEdited = true
                DatabaseManager.shared.updateImages(key: id, images: [pp], imageType: DatabaseManager.ImageType.eventCoverIndex, completion: { [weak self] res in
                    guard let strongSelf = self else {
                        return
                    }
                    switch res{
                    case .success(let urls):
                        if urls.count != 0 {
                            self?.event.imageUrl = urls[0].url
                        }
                        DispatchQueue.main.async {
                            strongSelf.navigationController?.popViewController(animated: true)
                            print("success changing profile 56 in editprofileviewcontroller")
                            strongSelf.delegate?.update(event: strongSelf.event)
                        }
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
                        
                        DispatchQueue.main.async {
                            strongSelf.present(actionSheet, animated: true)
                        }
                    }
                }, completionProfileUrl: {_ in})
            } else {
                DispatchQueue.main.async {
                    strongSelf.delegate?.update(event: strongSelf.event)
                    strongSelf.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
    
    @objc private func didTapChangeProfilePic() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Take a Photo with Camera",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                
                                                self?.presentCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Chose a Photo From Photo Library",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                
                                                self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
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
        tableView.register(EditCanInviteZipsTableViewCell.self, forCellReuseIdentifier: EditCanInviteZipsTableViewCell.identifier)
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
        
        if let url = event.imageUrl {
            profilePic.sd_setImage(with: event.imageUrl, completed: nil)
        } else {
            let imageName = event.getType() == .Promoter ? "defaultPromoterEventProfilePic" : "defaultEventProfilePic"
            profilePic.image = UIImage(named: imageName)
        }
        profilePic.layer.masksToBounds = true

        changeProfilePicBtn.setTitle("Change Event Cover Photo", for: .normal)
        changeProfilePicBtn.setTitleColor(.zipBlue, for: .normal)
        changeProfilePicBtn.titleLabel?.font = .zipTextFillBold

        
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
        return 5
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func saveTitleFunc(_ s: String) {
        print("s = \(s), title = \(event.title)")

        event.title = s
    }
    
    func saveDescriptionFunc(_ s: String) {
        
        event.bio = s
    }
    
    func saveLocationFunc(_ s: String) {
        event.address = s
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: return getTypeCell(tableView: tableView, indexPath: indexPath)
        case 1: return getTimeCell(tableView: tableView, indexPath: indexPath)
        case 2: return getLocationCell(tableView: tableView, indexPath: indexPath)
        case 3: return getBioCell(tableView: tableView, indexPath: indexPath)
        case 4: return getUserInvitesCell(tableView: tableView, indexPath: indexPath)
        default: return UITableViewCell()
        }
    }
    
    public func getTypeCell(tableView: UITableView, indexPath : IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditEventTypeTableViewCell.identifier, for: indexPath) as! EditEventTypeTableViewCell
        cell.configure(event: event)
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    public func getTitleCell(tableView: UITableView, indexPath : IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditTextFieldTableViewCell.identifier, for: indexPath) as! EditTextFieldTableViewCell
        cell.configure(label: "Title", content: event.title, saveFunc: saveTitleFunc(_:))
        cell.charLimit = 30
        cell.selectionStyle = .none
        cell.cellDelegate = self
        return cell
    }
    
    public func getTimeCell(tableView: UITableView, indexPath : IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditEventTimeTableViewCell.identifier, for: indexPath) as! EditEventTimeTableViewCell
        cell.configure(event: event)
        cell.selectionStyle = .none
        return cell
    }
    
    public func getLocationCell(tableView: UITableView, indexPath : IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditEventLocationTableViewCell.identifier, for: indexPath) as! EditEventLocationTableViewCell
        cell.configure(event: event, saveFunc: saveLocationFunc(_:))
        cell.GMSDelegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    public func getBioCell(tableView: UITableView, indexPath : IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditTextFieldTableViewCell.identifier, for: indexPath) as! EditTextFieldTableViewCell
        cell.configure(label: "Description", content: event.bio, saveFunc: saveDescriptionFunc(_:))
        cell.charLimit = 300
        cell.selectionStyle = .none
        cell.cellDelegate = self
        return cell
    }
    
    public func getUserInvitesCell(tableView: UITableView, indexPath : IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditCanInviteZipsTableViewCell.identifier, for: indexPath) as! EditCanInviteZipsTableViewCell
        cell.configure(event: event)
        cell.selectionStyle = .none
        return cell
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
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            dismiss(animated: true, completion: nil)
            profilePic.image = image
            changedPFP = true
        }
    }
}


extension EditEventProfileViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl) && !(touch.view is UITextView)
    }
}

extension EditEventProfileViewController: EventTypeCellDelegate {
    func isOpen() {
        newEventType = .Open
        
    }
    
    func isClosed() {
        newEventType = .Closed
    }
}
