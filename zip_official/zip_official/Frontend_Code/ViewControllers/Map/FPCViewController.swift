//
//  FPCViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 11/15/21.
//

import UIKit
import CoreLocation
import FirebaseFirestore

protocol FPCMapDelegate: AnyObject {
    func openZipFinder()
    func openVC(_ vc: UIViewController)
    func openFPC()
    func createEvent()
}

protocol FPCTableDelegate: AnyObject {
    func updateZipsLabel(cellItems: [CellItem])
    func updateEventsLabel(cellItems: [CellItem])

}

class FPCViewController: UIViewController {

    weak var delegate: FPCMapDelegate?
    private var userLoc: CLLocation
    private var scrollView: UIScrollView
    private var zipFinderButton: UIButton

    let searchBar: UITextField
    private var collectionView: UICollectionView

    private let zipRequestsLabel: UILabel
    private let eventsLabel: UILabel
    private let zipRequestsButton: UIButton
    private let eventsButton: UIButton
    
    private let eventsContainer: UIView
    private let zipRequestContainer: UIView
    public var eventsTableView: InvitedTableViewController
    private var zipRequestsTableView: InvitedTableViewController
    private var searchTable: MasterTableViewController
    private var searchBg: UIView
    var events: [Event]
    var requests: [User]
    
    private let findEventsIcon: IconButton
    private let createEventIcon: IconButton
    private let notificationIcon: IconButton
    private let messagesIcon: IconButton
    
    private let icons: [IconButton]

    private let zipsHeader : UIView
    private let eventsHeader : UIView
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
        self.requests = []
        
        self.searchBg = UIView()
        
        self.zipRequestContainer = UIView()
        self.eventsContainer = UIView()
        self.zipRequestsTableView = InvitedTableViewController(cellItems: User.getMyRequests())
        self.eventsTableView = InvitedTableViewController(cellItems: events.filter({ User.getUDEvents(toKey: .goingEvents).contains( $0 ) }))
        self.searchTable = MasterTableViewController(cellData: [], cellType: CellType(userType: .zipList, eventType: .save))
        
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
        
        self.zipsHeader = UIView()
        self.eventsHeader = UIView()
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
        
        messagesIcon.iconButton.addTarget(self, action: #selector(openMessages), for: .touchUpInside)
        findEventsIcon.iconButton.addTarget(self, action: #selector(findEvents), for: .touchUpInside)
        createEventIcon.iconButton.addTarget(self, action: #selector(createEvent), for: .touchUpInside)
        notificationIcon.iconButton.addTarget(self, action: #selector(openNotifications), for: .touchUpInside)
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        searchBar.inputAccessoryView = doneToolbar
    }
    
    public func addEvent(event: Event) {
        eventsTableView.addItem(cellItem: event)
    }
    
    public func removeEvent(event: Event) {
        eventsTableView.removeItem(cellItem: event)
    }
    
    func observeZipRequests() {
        DatabaseManager.shared.observeZipRequests(completion: { result in
            switch result {
            case .success(let users):
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.zipRequestsTableView.reload(cellItems: users)
                    strongSelf.updateZipsLabel(cellItems: users)
                }
            case .failure(let error):
                print("error observing zip requests")
                break
            }
        })
    }
    
    @objc func doneButtonAction(){
        searchBar.resignFirstResponder()
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
        let vc = InvitedTableViewController(cellItems: User.getMyRequests())
        vc.title = "Zip Requests"
        delegate?.openVC(vc)
    }
    
    @objc private func didTapEventInvites(){
        print("we can tap")
        let vc = InvitedTableViewController(cellItems: events + User.getUDEvents(toKey: .goingEvents) + User.getUDEvents(toKey: .notGoingEvents),removeCells: false )
        vc.title = "Event Invites"
        delegate?.openVC(vc)
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
        
        zipRequestsTableView.FPCZipDelegate = self
        zipRequestsTableView.noItemsLabel.text = "You have no Zip Requests"
        zipRequestsTableView.tableView.isScrollEnabled = false
        
        eventsTableView.FPCEventDelegate = self
        eventsTableView.noItemsLabel.text = "You have no event invites"
        eventsTableView.tableView.isScrollEnabled = false

      
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
        
        scrollView.addSubview(searchBg)
        searchBg.addSubview(searchTable.view)
        addChild(searchTable)
        searchTable.didMove(toParent: self)
        
        
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

        searchTable.view.translatesAutoresizingMaskIntoConstraints = false
        searchTable.view.topAnchor.constraint(equalTo: searchBg.topAnchor).isActive = true
        searchTable.view.bottomAnchor.constraint(equalTo: searchBg.bottomAnchor).isActive = true
        searchTable.view.rightAnchor.constraint(equalTo: searchBg.rightAnchor).isActive = true
        searchTable.view.leftAnchor.constraint(equalTo: searchBg.leftAnchor).isActive = true
        searchTable.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 250, right: 0)
//        searchTable.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 350))

        scrollView.addSubview(eventsLabel)
        scrollView.addSubview(eventsButton)
        

        scrollView.bringSubviewToFront(searchBg)
    }
    
    private func configureTableHeaders() {
        zipsHeader.isUserInteractionEnabled = true
        zipsHeader.addSubview(zipRequestsLabel)
        zipsHeader.addSubview(zipRequestsButton)
        
        zipRequestsLabel.translatesAutoresizingMaskIntoConstraints = false
        zipRequestsLabel.leftAnchor.constraint(equalTo: zipsHeader.leftAnchor, constant: 12).isActive = true
        zipRequestsLabel.topAnchor.constraint(equalTo: zipsHeader.topAnchor).isActive = true
//        zipRequestsButton.bottomAnchor.constraint(equalTo: zipsHeader.bottomAnchor).isActive = true
        
        zipRequestsButton.translatesAutoresizingMaskIntoConstraints = false
        zipRequestsButton.rightAnchor.constraint(equalTo: zipsHeader.rightAnchor, constant: -12).isActive = true
        zipRequestsButton.centerYAnchor.constraint(equalTo: zipRequestsLabel.centerYAnchor).isActive = true
        
        eventsHeader.isUserInteractionEnabled = true
        eventsHeader.addSubview(eventsLabel)
        eventsHeader.addSubview(eventsButton)

        eventsLabel.translatesAutoresizingMaskIntoConstraints = false
        eventsLabel.leftAnchor.constraint(equalTo: eventsHeader.leftAnchor, constant: 12).isActive = true
        eventsLabel.topAnchor.constraint(equalTo: eventsHeader.topAnchor).isActive = true
//        eventsLabel.bottomAnchor.constraint(equalTo: eventsHeader.bottomAnchor).isActive = true
        
        eventsButton.translatesAutoresizingMaskIntoConstraints = false
        eventsButton.rightAnchor.constraint(equalTo: eventsHeader.rightAnchor, constant: -12).isActive = true
        eventsButton.centerYAnchor.constraint(equalTo: eventsLabel.centerYAnchor).isActive = true
        
        zipsHeader.translatesAutoresizingMaskIntoConstraints = false
        zipsHeader.bottomAnchor.constraint(equalTo: zipRequestsLabel.bottomAnchor).isActive = true
        zipsHeader.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true

        eventsHeader.translatesAutoresizingMaskIntoConstraints = false
        eventsHeader.bottomAnchor.constraint(equalTo: eventsLabel.bottomAnchor).isActive = true
        eventsHeader.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true

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
        zipRequestContainer.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        eventsContainer.translatesAutoresizingMaskIntoConstraints = false
        eventsContainer.topAnchor.constraint(equalTo: zipRequestContainer.bottomAnchor, constant: 5).isActive = true
        eventsContainer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        eventsContainer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        eventsContainer.heightAnchor.constraint(equalToConstant: 390).isActive = true
        
        configureTableHeaders()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.updateContentView()
        zipsHeader.setNeedsLayout()
        zipsHeader.layoutIfNeeded()
        eventsHeader.setNeedsLayout()
        eventsHeader.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeZipRequests()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DatabaseManager.shared.removeAllObservers()
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
        searchBg.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            searchBg.isHidden = true
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else{
            return
        }
        
        //        if(SearchManager.shared.newQuery(searchString: text)){
        SearchManager.shared.StartSearch(searchString: text, event: true, user: true, finishedLoadingCompletion: { result in
            switch result {
            case .success(let searchObject):
                if searchObject != "0" {
                    let object = SearchManager.shared.loadedData[searchObject]!
                    if let user = object as? User {
                        if let cell = user.tableViewCell {
                            cell.configure(user)
                        }
                    } else if let event = object as? Event {
                        if let cell = event.tableViewCell {
                            cell.configure(event)
                        }
                    }
                }
            case .failure(let error):
                print("Error loading object in search Error: \(error)")
            }
        }, allCompletion: { [weak self] result in
            print("completing")
            guard let strongSelf = self else { return }
            switch result {
            case .success(let searchResults):
                let allResults = searchResults.map({  SearchManager.shared.loadedData[$0]!.cellItem  })
                let userResults = allResults.filter({ $0.isUser })
                let eventResults = allResults.filter({ $0.isEvent })
                strongSelf.searchTable.reload(multiSectionData: [
                    MultiSectionData(title: "All", sections:
                                        [CellSectionData(title: nil, items: allResults, cellType: CellType(userType: .zipList, eventType: .save))]),
                    MultiSectionData(title: "Users", sections:
                                        [CellSectionData(title: nil, items: userResults, cellType: CellType(userType: .zipList, eventType: .save))]),
                    MultiSectionData(title: "Events", sections:
                                        [CellSectionData(title: nil, items: eventResults, cellType: CellType(userType: .zipList, eventType: .save))])
                ], reloadTable: false)
                
            case .failure(let error):
                print("Error searching with querytext \(text) and Error: \(error)")
            }
        })
        //        }
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("clearing")
        textField.endEditing(true)
        
        return true
    }
    
}


extension FPCViewController: FPCTableDelegate {
    func updateZipsLabel(cellItems: [CellItem]) {
        zipRequestsLabel.text = "Zip Requests (\(cellItems.count))"
    }
    
    func updateEventsLabel(cellItems: [CellItem]) {
        eventsLabel.text = "Event Invites (\(cellItems.count))"
    }
}

extension FPCViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        print("CHECKING TOUCH")
        print("touch view = \(touch.view)")
        print(searchBar.isEditing)
        print(touch.view is UITextField)

        if touch.view is UITextField {
            print("returning where it is supposed to")
            return false
        }
        
        if !searchBar.isEditing {
            return false
        }
        
        return !(touch.view is UIControl) && !(touch.view is IconButton)
    }
}
