//
//  CollectionViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/16/21.
//

import UIKit
import MapKit
import CoreLocation
import CoreGraphics

// ingnore this
protocol ZipFinderVCDelegate: AnyObject {
    func showFilterButtonFromZF()
    func updateHomeButton()
}

class ZipFinderViewController: UIViewController, UICollectionViewDelegate {
    var cellSize = CGSize()

    // userData
    var userLoc = CLLocation()
    
    
    //SubViews
    private var collectionView: UICollectionView?
    
    weak var delegate: ZipFinderVCDelegate?
    
    @objc private let closeButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "close"), for: .normal)
        return button
    }()
    
    private var hasMore = false
    
    private var maxRangeFilter = (AppDelegate.userDefaults.value(forKey: "maxRangeFilter") as? Double) ?? 50
        
    private var rangeMultiplier = Double(1)
    
    private var maxIndex = 0
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private var testUsers: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        view.isOpaque = false
        
        testUsers = MapViewController.getTestUsers()
        testUsers += MapViewController.getTestUsers()
        testUsers += MapViewController.getTestUsers()

        print("Entering View did load with userIdList size: \(GeoManager.shared.userIdList.count)")
        if NSLocale.current.regionCode == "US" {
            rangeMultiplier = 1.6
            maxRangeFilter *= rangeMultiplier
        }
        let coordinates = AppDelegate.userDefaults.value(forKey: "userLoc") as! [Double]
        GeoManager.shared.GetUserByLoc(location: CLLocation(latitude: coordinates[0], longitude: coordinates[1]), range: maxRangeFilter, max: 100, completion: {
            GeoManager.shared.LoadNextUsers(size: 10, completion: { [weak self] in
                self?.collectionView?.reloadData()
                print("RELOADING DATA")
            })
        })
        
        
        
       
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        collectionView?.isOpaque = true
        
        if AppDelegate.userDefaults.bool(forKey: "hasHomeButton"){
            cellSize = CGSize(width: view.frame.size.width,
                              height: round(view.frame.size.height*0.9))
        } else {
            cellSize = CGSize(width: view.frame.size.width,
                              height: round(view.frame.size.height*0.7))
        }
        let layout = SnappingFlowLayout() //UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        

        configCollection()
        
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.leftAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        closeButton.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor).isActive = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Eventually gonna scroll to the right place - make sure its not animated
        adjustScaleAndAlpha()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true

    }
    

    
    //Config
    private func configCollection(){
        guard let collectionView = collectionView else {
            return
        }

        
        //Collection View Layout config

        collectionView.register(ZipFinderCollectionViewCell.self, forCellWithReuseIdentifier: ZipFinderCollectionViewCell.identifier)
        collectionView.register(NoMoreUsersCollectionViewCell.self, forCellWithReuseIdentifier: NoMoreUsersCollectionViewCell.identifier)

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.decelerationRate = .fast
        collectionView.contentInset = UIEdgeInsets(top: (view.frame.height-cellSize.height)/2,
                                                    left: 0,
                                                    bottom: 0,
                                                    right: 0)
        collectionView.frame = view.bounds
        collectionView.scrollsToTop = false
        collectionView.backgroundColor = .clear
        
        view.addSubview(collectionView)
        view.addSubview(closeButton)
        
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    
    @objc func didTapCloseButton() {
        delegate?.updateHomeButton()
        delegate?.showFilterButtonFromZF()
        dismiss(animated: true, completion: nil)
    }
    
    func adjustScaleAndAlpha(){

        guard let collectionView = collectionView else {
            return
        }

        let centerY = view.frame.height/2
        
        for cell in collectionView.visibleCells {
            let basePosition = cell.convert(CGPoint.zero, to: view)
            let cellCenterY = basePosition.y + cell.frame.size.height/2
            let distance = abs(centerY-cellCenterY)
            let tolerance : CGFloat = 0.02
        

            
            var scale = 1.00 + tolerance - ((distance/centerY)*0.105)
            if scale > 1.0 {
                scale = 1.0
            }

            if scale < 0.85 {
                scale = 0.85
            }

            
            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            if let coverCell = cell as? ZipFinderCollectionViewCell {
                coverCell.alpha = sizeScaleToAlphaScale(scale)
            } else {
                let coverCell = cell as! NoMoreUsersCollectionViewCell
                coverCell.alpha = sizeScaleToAlphaScale(scale)
            }
        }
    }
    
    
    func sizeScaleToAlphaScale(_ x : CGFloat) -> CGFloat{
        let minScale : CGFloat = 0.5
        let maxScale : CGFloat = 1.0
        
        let minAlpha : CGFloat = 0.25
        let maxAlpha : CGFloat = 1.0
        
        return ((maxAlpha - minAlpha) * (x - minScale)) / (maxScale - minScale) + minAlpha
    }
    
//    func loadNextUsers(){
//        if(GeoManager.shared.ZFUlist.isEmpty){
//            let coordinates = AppDelegate.userDefaults.value(forKey: "userLoc") as! [Double]
//            GeoManager.shared.getUserByLoc(location: CLLocation(latitude: coordinates[0], longitude: coordinates[1]))
//        }
//        let userSize = GeoManager.shared.ZFUlist.count
//        if(userSize > 10){
//            data = GeoManager.shared.loadUsers(size: 10)
//            hasMore = true
//            print(GeoManager.shared.ZFUlist.count)
//        } else {
//            data = GeoManager.shared.loadUsers(size: userSize)
//            hasMore = false
//            print(GeoManager.shared.ZFUlist.count)
//        }
//        print("have data")
//    }
    
    
    private func PullNextUser(index: Int, completion: @escaping (User) -> Void) {
        if(GeoManager.shared.loadedUsers.count-index < 5){
            GeoManager.shared.LoadNextUsers(size: 10, completion: {
                if(GeoManager.shared.loadedUsers.count-index <= 0){
                    completion(GeoManager.shared.noUsers)
                } else {
                    completion(GeoManager.shared.loadedUsers[index])

                }
                print("index \(index)")
                print("loaded users count =  \(GeoManager.shared.loadedUsers.count)")

            })
        } else {
            completion(GeoManager.shared.loadedUsers[index])
        }
    }
    
   
}

// MARK: UICollectionViewDataSource
extension ZipFinderViewController: UICollectionViewDataSource {
    
    private func checkNeedsNewUsers() {
        print("got to the collection view with \(GeoManager.shared.userIdList.count) unloaded names and \(GeoManager.shared.loadedUsers.count) loaded on pass index: \(maxIndex)")
        
        if(maxIndex > GeoManager.shared.loadedUsers.count - 6){
            PullNextUser(index: maxIndex, completion: { _ in
       //                guard let user = user else {
       //                    return
       //                }
            })
            if(GeoManager.shared.userIdList.count == 0 && maxRangeFilter >= 55*rangeMultiplier && !GeoManager.shared.moreUsersInQuery){
                print("range is \(maxRangeFilter)")
                print("amoung of loaded users is \(GeoManager.shared.loadedUsers.count)")
                print("there are \(GeoManager.shared.userIdList.count) uncounted users and the query running is \(GeoManager.shared.queryRunning)")
       //                if(!queryRunning){
       //                    //MARK: Yianni Read Below
       //                    //Insert blank card with loading which updates once complete
       //
       //                } else {
       //                    //Insert no people near you card
       //
       //                }
            } else if(GeoManager.shared.userIdList.count < 10 ){
                var letNextQueryBegin = true
                if(GeoManager.shared.moreUsersInQuery || GeoManager.shared.queryRunning){
                    print("there are more users in query: \(GeoManager.shared.moreUsersInQuery)")
                    print("there are more users in query: \(GeoManager.shared.queryRunning)")
                    print("")
                    letNextQueryBegin = false
                }
                if(letNextQueryBegin){
                    if(maxRangeFilter < 5 * rangeMultiplier){
                        maxRangeFilter = 5 * rangeMultiplier
                    } else {
                        maxRangeFilter += 5 * rangeMultiplier
                    }
                }
                if (!GeoManager.shared.queryRunning){
                    let coordinates = AppDelegate.userDefaults.value(forKey: "userLoc") as! [Double]
                    GeoManager.shared.GetUserByLoc(location: CLLocation(latitude: coordinates[0], longitude: coordinates[1]), range: maxRangeFilter, max: 100, completion: { [weak self] in
                        self?.collectionView?.reloadData()
                    })
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == GeoManager.shared.loadedUsers.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoMoreUsersCollectionViewCell.identifier, for: indexPath) as! NoMoreUsersCollectionViewCell
            return cell
        }
        
        if indexPath.row > maxIndex {
            maxIndex = indexPath.row
            checkNeedsNewUsers()
        }
        print("INDEXPATH = \(indexPath.row)")

        //MARK: delete this
        
//        model.pictures.append(UIImage(named: "gabe1")!)
        
//        let model = testUsers[indexPath.row]
        
        var model: User
        if (GeoManager.shared.loadedUsers.count == 0){
            model = User()
            if (maxRangeFilter >= 50 * rangeMultiplier && !GeoManager.shared.queryRunning && !GeoManager.shared.moreUsersInQuery){
            
            }
        } else {
            model = GeoManager.shared.loadedUsers[indexPath.row % GeoManager.shared.loadedUsers.count]

        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZipFinderCollectionViewCell.identifier, for: indexPath) as! ZipFinderCollectionViewCell

        cell.delegate = self
        cell.configure(user: model, loc: userLoc, idPath: indexPath.row)
//        print(model.location)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("collection view count = \(GeoManager.shared.loadedUsers.count)")
//        return .max
        return GeoManager.shared.loadedUsers.count + 1
    }
    
    
}


// MARK: UICollectionViewDelegate
extension ZipFinderViewController: ZFCardBackDelegate {
    
    func openProfile(_ user: User) {        
        let vc = OtherProfileViewController(id: user.userId)
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .overFullScreen
        present(navVC, animated: true)
    }
    
    func openZips(_ user: User) {
        let vc = UsersTableViewController(users: [])

        DatabaseManager.shared.loadUserZipsIds(given: user.userId, completion: { result in
            switch result {
            case .success(let users):
                print("loading ezras friends \(users)")
                vc.reload(users: users)
            case .failure(let error):
                print("failure loading other users ids, Error: \(error)")
            }
        })
        vc.title = "\(user.firstName)'s Zips"
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .overFullScreen
        navVC.title = "\(user.firstName)'s Zips"
        present(navVC, animated: true)
    }
    
    func inviteUser(_ user: User) {
        let vc = InviteUserToEventViewController()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .overFullScreen
        present(navVC, animated: true)
    }
    
    func messageUser(_ user: User) {
        let selfId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        DatabaseManager.shared.getAllConversations(for: selfId, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let conversations):
                if let targetConversation = conversations.first(where: {
                    $0.otherUser.userId == user.userId
                }) {
                    let vc = ChatViewController(toUser: targetConversation.otherUser, id: targetConversation.id)
                    vc.isNewConversation = false
                    vc.title = targetConversation.otherUser.firstName
                    let navVC = UINavigationController(rootViewController: vc)
                    strongSelf.present(navVC, animated: true)
                } else {
                    strongSelf.createNewConversation(result: user)
                }
            case .failure(_):
                strongSelf.createNewConversation(result: user)
            }
        })
    }
    
    private func createNewConversation(result otherUser: User){        
        // check in database if conversation with these two uses exists
        // if it does, reuse conversation id
        // otherwise use existing code
        DatabaseManager.shared.conversationExists(with: otherUser.userId, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result{
            case.success(let conversationId):
                let vc = ChatViewController(toUser: otherUser, id: conversationId)
                vc.isNewConversation = false
                vc.title = otherUser.firstName
                vc.navigationItem.largeTitleDisplayMode = .never
                let navVC = UINavigationController(rootViewController: vc)
                strongSelf.present(navVC, animated: true)
            case .failure(_):
                let vc = ChatViewController(toUser: otherUser, id: nil)
                vc.isNewConversation = true
                vc.title = otherUser.firstName
                vc.navigationItem.largeTitleDisplayMode = .never
                let navVC = UINavigationController(rootViewController: vc)
                strongSelf.present(navVC, animated: true)
            }
        })
        
        
    }
}


extension ZipFinderViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView : UIScrollView){
        adjustScaleAndAlpha()
    }
}
