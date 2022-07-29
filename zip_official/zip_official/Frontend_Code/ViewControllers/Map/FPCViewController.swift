//
//  FPCViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 11/15/21.
//

import UIKit
import CoreLocation

protocol FPCMapDelegate: AnyObject {
    func openZipFinder()
    func findEvents()
    func createEvent()
    func openNotifications()
    func openMessages()
    func openFPC()
    func openZipRequests(requests: [ZipRequest])
    func openEventInvites(events: [Event])
}

class FPCViewController: UIViewController {
    weak var delegate: FPCMapDelegate?
    private var userLoc: CLLocation
    private var scrollView: UIScrollView
    private var zipFinderButton: UIButton

    private let searchBar: UITextField
    private var collectionView: UICollectionView

    private let zipRequestsLabel: UILabel
    private let eventsLabel: UILabel
    private let zipRequestsButton: UIButton
    private let eventsButton: UIButton
    private var zipRequestsTable: ZipRequestTableView
    private var eventsTable: EventInvitesTableView
    private var searchTable: SearchBarTableView
    private var searchBg: UIView
    private var events: [Event]
    var requests: [ZipRequest]
    
    private let findEventsIcon: IconButton
    private let createEventIcon: IconButton
    private let notificationIcon: IconButton
    private let messagesIcon: IconButton
    
    private let icons: [IconButton]

    
    private var dismissTap: UITapGestureRecognizer?
    private var dismissTapCV: UITapGestureRecognizer?
    
    init(requests: [ZipRequest], events: [Event]) {
        self.userLoc = CLLocation()
        self.scrollView = UIScrollView()
        self.zipFinderButton = UIButton()
        self.searchBar = UITextField()
        
        self.zipRequestsLabel = UILabel.zipTextFill()
        self.eventsLabel = UILabel.zipTextFill()
        self.zipRequestsButton = UIButton()
        self.eventsButton = UIButton()
        self.requests = requests
        self.events = events
        
        self.searchBg = UIView()
        self.zipRequestsTable = ZipRequestTableView(requests: requests)
        self.eventsTable = EventInvitesTableView(events: events)
        self.searchTable = SearchBarTableView(eventData: events)
        
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
        self.findEventsIcon = IconButton(text: "Find\nEvents", icon: UIImage(systemName: "calendar"), config: iconConfig )
        self.createEventIcon = IconButton(text: "Create\nEvent", icon: UIImage(systemName: "calendar.badge.plus"), config: iconConfig )
        self.notificationIcon = IconButton(text: "Notifications", icon: UIImage(systemName: "bell.fill"), config: iconConfig )
        self.messagesIcon = IconButton(text:  "Messages", icon: UIImage(systemName: "message.fill"), config: iconConfig )
        
        self.icons = [findEventsIcon, createEventIcon, notificationIcon, messagesIcon]
        
        let layout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.minimumInteritemSpacing = 5
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        
        super.init(nibName: nil, bundle: nil)
        
        dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardTouchOutside))
        dismissTapCV = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardTouchOutside))

        view.addGestureRecognizer(dismissTap!)
        collectionView.addGestureRecognizer(dismissTapCV!)
        dismissTap?.delegate = self
        dismissTapCV?.delegate = self
        
        addSubviews()
        configureSubviewLayout()

        zipFinderButton.layer.masksToBounds = true
        zipFinderButton.layer.cornerRadius = 20
        zipFinderButton.backgroundColor = .zipLightGray
        let config = UIImage.SymbolConfiguration(scale: .large)
        zipFinderButton.setImage(UIImage(systemName: "person.fill.badge.plus", withConfiguration: config)?
                                 .withRenderingMode(.alwaysOriginal)
                                 .withTintColor(.white), for: .normal)
       
        searchBar.layer.masksToBounds = true
        searchBar.layer.cornerRadius = 20
        searchBar.backgroundColor = .zipLightGray
        searchBar.tintColor = .white
        searchBar.leftViewMode = .always
           
        searchBar.placeholder = "Search for Users or Events"
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .unspecified, scale: .small)
        let img = UIImage(systemName: "magnifyingglass", withConfiguration: largeConfig)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.white)
        let imgView = UIImageView(image: img)
        let view = UIView()
        
        view.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        view.addSubview(imgView)
        if let size = img?.size {
            imgView.frame = CGRect(x: (view.frame.width-size.width)/2,
                                   y: (view.frame.height-size.height)/2,
                                   width: size.width,
                                   height: size.height)
            
            
        }
        searchBar.leftView = view
        
        
        zipRequestsButton.backgroundColor = .clear
        let ZRattributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                         .foregroundColor: UIColor.zipVeryLightGray,
                                                         .underlineStyle: NSUnderlineStyle.single.rawValue]
        zipRequestsButton.setAttributedTitle(NSMutableAttributedString(string: "See All", attributes: ZRattributes), for: .normal)
        
        
        eventsButton.backgroundColor = .clear
        let Eattributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                         .foregroundColor: UIColor.zipVeryLightGray,
                                                         .underlineStyle: NSUnderlineStyle.single.rawValue]
        eventsButton.setAttributedTitle(NSMutableAttributedString(string: "See All", attributes: Eattributes), for: .normal)
        
        searchBg.isHidden = true
        searchTable.isHidden = true
        
        messagesIcon.iconButton.addTarget(self, action: #selector(openMessages), for: .touchUpInside)
        findEventsIcon.iconButton.addTarget(self, action: #selector(findEvents), for: .touchUpInside)
        createEventIcon.iconButton.addTarget(self, action: #selector(createEvent), for: .touchUpInside)
        notificationIcon.iconButton.addTarget(self, action: #selector(openNotifications), for: .touchUpInside)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func dismissKeyboardTouchOutside(){
        print("tap is gay")
        view.endEditing(true)
    }

    
    @objc private func openZipFinder() {
        delegate?.openZipFinder()
    }
    
    @objc func findEvents() {
        delegate?.findEvents()
    }
    
    @objc private func didTapZipRequests(){
        delegate?.openZipRequests(requests: requests)
    }
    
    @objc private func didTapEventInvites(){
        delegate?.openEventInvites(events: events)
    }
    
    @objc func createEvent() {
        delegate?.createEvent()
    }
    
    @objc func openNotifications(){
        delegate?.openNotifications()
    }
    
    @objc func openMessages(){
        print("OPEN MESSAGES")
        delegate?.openMessages()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        
        //Buttons
        zipFinderButton.addTarget(self, action: #selector(openZipFinder), for: .touchUpInside)
        zipRequestsButton.addTarget(self, action: #selector(didTapZipRequests), for: .touchUpInside)
        eventsButton.addTarget(self, action: #selector(didTapEventInvites), for: .touchUpInside)
        
        zipRequestsTable.FPCDelegate = self
        eventsTable.FPCDelegate = self
        zipRequestsLabel.text = "Zip Requests (\(requests.count))"
        eventsLabel.text = "Event Invites (\(events.count))"

        //Search Bar
        searchBar.delegate = self
        searchBar.clearButtonMode = .whileEditing
        
        
        configureCollectionView()
    }
    
    
    private func configureCollectionView() {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.bounces = false
        collectionView.isScrollEnabled = false
    }
    


    
    private func addSubviews(){
        view.addSubview(scrollView)
        
        scrollView.addSubview(zipFinderButton)
        scrollView.addSubview(searchBar)
        scrollView.addSubview(collectionView)
        scrollView.addSubview(zipRequestsLabel)
        scrollView.addSubview(zipRequestsButton)
        scrollView.addSubview(zipRequestsTable)
        scrollView.addSubview(eventsLabel)
        scrollView.addSubview(eventsButton)
        scrollView.addSubview(eventsTable)
        
        scrollView.addSubview(searchBg)
        searchBg.addSubview(searchTable)

        scrollView.bringSubviewToFront(searchBg)
    }
    
    private func configureSubviewLayout(){
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true

        
        zipFinderButton.translatesAutoresizingMaskIntoConstraints = false
        zipFinderButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8).isActive = true
        zipFinderButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        zipFinderButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        zipFinderButton.widthAnchor.constraint(equalTo: zipFinderButton.heightAnchor).isActive = true

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.leftAnchor.constraint(equalTo: zipFinderButton.rightAnchor, constant: 12).isActive = true
        searchBar.topAnchor.constraint(equalTo: zipFinderButton.topAnchor).isActive = true
        searchBar.bottomAnchor.constraint(equalTo: zipFinderButton.bottomAnchor).isActive = true
        searchBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true

        
        searchBg.translatesAutoresizingMaskIntoConstraints = false
        searchBg.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        searchBg.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        searchBg.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        searchBg.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        searchBg.backgroundColor = .zipGray
        
        searchTable.translatesAutoresizingMaskIntoConstraints = false
        searchTable.topAnchor.constraint(equalTo: searchBg.topAnchor).isActive = true
        searchTable.bottomAnchor.constraint(equalTo: searchBg.bottomAnchor).isActive = true
        searchTable.leftAnchor.constraint(equalTo: searchBg.leftAnchor).isActive = true
        searchTable.rightAnchor.constraint(equalTo: searchBg.rightAnchor).isActive = true

        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 30).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        let height = (view.frame.width - 35)/4*0.8 + 40
        collectionView.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        zipRequestsLabel.translatesAutoresizingMaskIntoConstraints = false
        zipRequestsLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        zipRequestsLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20).isActive = true
        
        zipRequestsButton.translatesAutoresizingMaskIntoConstraints = false
        zipRequestsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true
        zipRequestsButton.centerYAnchor.constraint(equalTo: zipRequestsLabel.centerYAnchor).isActive = true
        
        zipRequestsTable.translatesAutoresizingMaskIntoConstraints = false
        zipRequestsTable.topAnchor.constraint(equalTo: zipRequestsLabel.bottomAnchor, constant: 5).isActive = true
        zipRequestsTable.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        zipRequestsTable.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        zipRequestsTable.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        eventsLabel.translatesAutoresizingMaskIntoConstraints = false
        eventsLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        eventsLabel.topAnchor.constraint(equalTo: zipRequestsTable.bottomAnchor, constant: 20).isActive = true
        
        eventsButton.translatesAutoresizingMaskIntoConstraints = false
        eventsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true
        eventsButton.centerYAnchor.constraint(equalTo: eventsLabel.centerYAnchor).isActive = true
        
        eventsTable.translatesAutoresizingMaskIntoConstraints = false
        eventsTable.topAnchor.constraint(equalTo: eventsLabel.bottomAnchor, constant: 5).isActive = true
        eventsTable.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        eventsTable.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        eventsTable.heightAnchor.constraint(equalToConstant: 360).isActive = true

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.updateContentView()
        
    }
    
    
    
}

extension FPCViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numCells = 4
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let totalSpace = flowLayout.sectionInset.left
                       + flowLayout.sectionInset.right
                       + (flowLayout.minimumInteritemSpacing * CGFloat(numCells - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(numCells))
        
        return CGSize(width: size, height: size + 40)
    }
    
}

extension FPCViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: findEvents()
        case 1: createEvent()
        case 2: openNotifications()
        case 3: openMessages()
        default:
            print("failed to select item at \(indexPath.row)")
        }
    }
}

extension FPCViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .zipGray
        
        let cellWidth = view.frame.width*0.2*0.8
        let icon = icons[indexPath.row]
        icon.setIconDimension(width: cellWidth)
        
        cell.contentView.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
        icon.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor).isActive = true
        icon.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor).isActive = true
        

        return cell
    }
}

extension FPCViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.openFPC()
        searchTable.isHidden = false
        searchBg.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            searchTable.isHidden = true
            searchBg.isHidden = true
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("clearing")
        textField.endEditing(true)
        
        return true
    }
    
}


extension FPCViewController: FPCTableDelegate {
    func updateRequestsLabel(requests: [ZipRequest]) {
        print("running this? ", requests.count)
        zipRequestsLabel.text = "Zip Requests (\(requests.count))"
        self.requests = requests
    }
    
    func updateEventsLabel(events: [Event]) {
        eventsLabel.text = "Event Invites (\(events.count))"
        self.events = events
    }
}


extension FPCViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl) && !(touch.view is IconButton)
    }
}
