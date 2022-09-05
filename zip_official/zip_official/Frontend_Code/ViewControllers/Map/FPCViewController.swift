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
    func openVC(_ vc: UIViewController)
    func openFPC()
    func createEvent()
}

protocol FPCTableDelegate: AnyObject {
    func updateLabel(cellItems: [CellItem])
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
    
    private let eventsContainer: UIView
    private let zipRequestContainer: UIView
    public var eventsTableView: InvitedTableViewController
    private var zipRequestsTableView: InvitedTableViewController
    private var searchTable: SearchBarTableView
    private var searchBg: UIView
    var events: [Event]
    
    private let findEventsIcon: IconButton
    private let createEventIcon: IconButton
    private let notificationIcon: IconButton
    private let messagesIcon: IconButton
    
    private let icons: [IconButton]

    
    private var dismissTap: UITapGestureRecognizer?
    private var dismissTapCV: UITapGestureRecognizer?
    
    init() {
        self.userLoc = CLLocation()
        self.scrollView = UIScrollView()
        self.zipFinderButton = UIButton()
        self.searchBar = UITextField()
        
        self.zipRequestsLabel = UILabel.zipTextFill()
        self.eventsLabel = UILabel.zipTextFill()
        self.zipRequestsButton = UIButton()
        self.eventsButton = UIButton()
        self.events = []
        
        self.searchBg = UIView()
        
        self.zipRequestContainer = UIView()
        self.eventsContainer = UIView()
        self.zipRequestsTableView = InvitedTableViewController(cellItems: User.getMyRequests())
        self.eventsTableView = InvitedTableViewController(cellItems: events.filter({ User.getUDEvents(toKey: .goingEvents).contains( $0 ) }))
        self.searchTable = SearchBarTableView()
        
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .large)
        let createEventConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .light, scale: .large)

        self.findEventsIcon = IconButton.eventsIcon()
        findEventsIcon.setTextLabel(s: "Find\nEvents")
        self.createEventIcon = IconButton(text: "Create\nEvent", icon: UIImage(systemName: "calendar.badge.plus"), config: createEventConfig )
        self.notificationIcon = IconButton(text: "Notifications", icon: UIImage(systemName: "bell"), config: iconConfig )
        self.messagesIcon = IconButton.messageIcon()
        
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
        let ZRattributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipTextPrompt2,
                                                         .foregroundColor: UIColor.zipVeryLightGray,
                                                         .underlineStyle: NSUnderlineStyle.single.rawValue]
        zipRequestsButton.setAttributedTitle(NSMutableAttributedString(string: "See All", attributes: ZRattributes), for: .normal)
        
        
        eventsButton.backgroundColor = .clear
        let Eattributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipTextPrompt2,
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
    
    @objc func dismissKeyboardTouchOutside(){
        print("forced end editing")
        view.endEditing(true)
    }

    
    @objc private func openZipFinder() {
        delegate?.openZipFinder()
    }
    
    @objc func findEvents() {
        delegate?.openVC(EventFinderViewController())
    }
    
    @objc private func didTapZipRequests(){
        delegate?.openVC(InvitedTableViewController(cellItems: User.getMyRequests()))
    }
    
    @objc private func didTapEventInvites(){
        delegate?.openVC(InvitedTableViewController(cellItems: events))
    }
    
    @objc func createEvent() {
        delegate?.createEvent()
    }
    
    @objc func openNotifications(){
        delegate?.openVC(NotificationsViewController())
    }
    
    @objc func openMessages(){
        delegate?.openVC(ZipMessagesViewController())
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        
        //Buttons
        zipFinderButton.addTarget(self, action: #selector(openZipFinder), for: .touchUpInside)
        zipRequestsButton.addTarget(self, action: #selector(didTapZipRequests), for: .touchUpInside)
        eventsButton.addTarget(self, action: #selector(didTapEventInvites), for: .touchUpInside)
        
        zipRequestsTableView.FPCDelegate = self
        eventsTableView.FPCDelegate = self
        zipRequestsTableView.noItemsLabel.text = "You have no Zip Requests"
        eventsTableView.noItemsLabel.text = "You have no event invites"

      
        zipRequestsLabel.text = "Zip Requests (\(User.getMyRequests().count))"
    
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
        
        
       
        
        scrollView.addSubview(zipRequestContainer)
        zipRequestContainer.addSubview(zipRequestsTableView.view)
        addChild(zipRequestsTableView)
        zipRequestsTableView.didMove(toParent: self)
        
        scrollView.addSubview(eventsContainer)
        eventsContainer.addSubview(eventsTableView.view)
        addChild(eventsTableView)
        eventsTableView.didMove(toParent: self)
        
        zipRequestsTableView.view.translatesAutoresizingMaskIntoConstraints = false
        zipRequestsTableView.view.topAnchor.constraint(equalTo: zipRequestContainer.topAnchor).isActive = true
        zipRequestsTableView.view.bottomAnchor.constraint(equalTo: zipRequestContainer.bottomAnchor).isActive = true
        zipRequestsTableView.view.rightAnchor.constraint(equalTo: zipRequestContainer.rightAnchor).isActive = true
        zipRequestsTableView.view.leftAnchor.constraint(equalTo: zipRequestContainer.leftAnchor).isActive = true

     
        eventsTableView.view.translatesAutoresizingMaskIntoConstraints = false
        eventsTableView.view.topAnchor.constraint(equalTo: eventsContainer.topAnchor).isActive = true
        eventsTableView.view.bottomAnchor.constraint(equalTo: eventsContainer.bottomAnchor).isActive = true
        eventsTableView.view.rightAnchor.constraint(equalTo: eventsContainer.rightAnchor).isActive = true
        eventsTableView.view.leftAnchor.constraint(equalTo: eventsContainer.leftAnchor).isActive = true


        scrollView.addSubview(eventsLabel)
        scrollView.addSubview(eventsButton)
        
        scrollView.addSubview(searchBg)
        searchBg.addSubview(searchTable)

        scrollView.bringSubviewToFront(searchBg)
    }
    
    private func configureTableHeaders() {
        let zipsHeader = UIView()
        zipsHeader.addSubview(zipRequestsLabel)
        zipsHeader.addSubview(zipRequestsButton)
        
        zipRequestsLabel.translatesAutoresizingMaskIntoConstraints = false
        zipRequestsLabel.leftAnchor.constraint(equalTo: zipsHeader.leftAnchor, constant: 12).isActive = true
        zipRequestsLabel.topAnchor.constraint(equalTo: zipsHeader.topAnchor).isActive = true
        
        zipRequestsButton.translatesAutoresizingMaskIntoConstraints = false
        zipRequestsButton.rightAnchor.constraint(equalTo: zipsHeader.rightAnchor, constant: -12).isActive = true
        zipRequestsButton.centerYAnchor.constraint(equalTo: zipRequestsLabel.centerYAnchor).isActive = true
        
        let eventsHeader = UIView()
        eventsHeader.addSubview(eventsLabel)
        eventsHeader.addSubview(eventsButton)
        
        eventsLabel.translatesAutoresizingMaskIntoConstraints = false
        eventsLabel.leftAnchor.constraint(equalTo: eventsHeader.leftAnchor, constant: 12).isActive = true
        eventsLabel.topAnchor.constraint(equalTo: eventsHeader.topAnchor).isActive = true
        
        eventsButton.translatesAutoresizingMaskIntoConstraints = false
        eventsButton.rightAnchor.constraint(equalTo: eventsHeader.rightAnchor, constant: -12).isActive = true
        eventsButton.centerYAnchor.constraint(equalTo: eventsLabel.centerYAnchor).isActive = true

        zipRequestsTableView.tableHeader = zipsHeader
        eventsTableView.tableHeader = eventsHeader
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
        
       
        zipRequestContainer.translatesAutoresizingMaskIntoConstraints = false
        zipRequestContainer.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 5).isActive = true
        zipRequestContainer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        zipRequestContainer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        zipRequestContainer.heightAnchor.constraint(equalToConstant: 80).isActive = true

        
        eventsContainer.translatesAutoresizingMaskIntoConstraints = false
        eventsContainer.topAnchor.constraint(equalTo: zipRequestContainer.bottomAnchor, constant: 5).isActive = true
        eventsContainer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        eventsContainer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        eventsContainer.heightAnchor.constraint(equalToConstant: 360).isActive = true
        
        configureTableHeaders()
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
        print("ending edit")
        if textField.text == "" {
            searchTable.isHidden = true
            searchBg.isHidden = true
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else{
            return
        }
        searchTable.searchData = []
        SearchManager.shared.StartSearch(searchString: text, event: true, user: true, finishedLoadingCompletion: { result in
            switch result {
            case .success(let searchObject):
                print(searchObject)
                break
            case .failure(let error):
                print("Error loading object in search Error: \(error)")
            }
        }, allCompletion: { [weak self] result in
            print("completing")
            guard let strongSelf = self else { return }
            switch result {
            case .success(let searchResults):
//                strongSelf.searchTable.searchData.append(contentsOf: searchResults)
                strongSelf.searchTable.configureTableData()
                print("SEARCH TABLE DATA = ", strongSelf.searchTable.searchData)
                strongSelf.searchTable.reloadData()
            case .failure(let error):
                print("Error searching with querytext \(text) and Error: \(error)")
            }
        })
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("clearing")
        textField.endEditing(true)
        
        return true
    }
    
}


extension FPCViewController: FPCTableDelegate {
    func updateLabel(cellItems: [CellItem]) {
        if let users = cellItems as? [User] {
            print("updaing users")
            zipRequestsLabel.text = "Zip Requests (\(users.count))"

        } else if let events = cellItems as? [Event] {
            eventsLabel.text = "Event Invites (\(events.count))"
            print("updating events")
            self.events = events
        }
        print("updating either")
    }
}

extension FPCViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl) && !(touch.view is IconButton)
    }
}
