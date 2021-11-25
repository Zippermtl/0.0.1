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
    
    private var maxRangeFilter = AppDelegate.userDefaults.value(forKey: "maxRangeFilter") as! Double
        
    private var rangeMultiplier = Double(1)
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            
            let coverCell = cell as! ZipFinderCollectionViewCell
            coverCell.alpha = sizeScaleToAlphaScale(scale)
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
    
    
    private func PullNextUser(index: Int) -> User {
        if(GeoManager.shared.loadedUsers.count-index < 5){
            GeoManager.shared.LoadNextUsers(size: 10, completion: { [weak self] in
            })
        }
        if(GeoManager.shared.loadedUsers.count-index <= 0){
            return GeoManager.shared.noUsers
        }
        return GeoManager.shared.loadedUsers[index]
    }
}

// MARK: UICollectionViewDataSource
extension ZipFinderViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print("got to the collection view with \(GeoManager.shared.userIdList.count) unloaded names and \(GeoManager.shared.loadedUsers.count) loaded on pass index: \(indexPath.row)")
        
        if(indexPath.row > GeoManager.shared.loadedUsers.count - 6){
            let userCheck = PullNextUser(index: indexPath.row)
            if(GeoManager.shared.userIdList.count < 10 && !GeoManager.shared.moreUsersInQuery && !GeoManager.shared.queryRunning){
                if(maxRangeFilter < 5 * rangeMultiplier){
                    maxRangeFilter = 5 * rangeMultiplier
                } else {
                    maxRangeFilter += 5 * rangeMultiplier
                }
                let coordinates = AppDelegate.userDefaults.value(forKey: "userLoc") as! [Double]
                GeoManager.shared.GetUserByLoc(location: CLLocation(latitude: coordinates[0], longitude: coordinates[1]), range: maxRangeFilter, max: 100, completion: {
                    
                })
            } else if (maxRangeFilter > 50){
                print("range is \(maxRangeFilter)")
//            else if(GeoManager.shared.userIdList.count == 0 && GeoManager.shared.loading){
//                if(maxRangeFilter > 50.0){
//
//                    //MARK: Insert no people near you card
//                } else {
//                    //MARK: Insert blank card with loading which updates once complete
//                }
            }
        }
        
        
        var model = GeoManager.shared.loadedUsers[indexPath.row % GeoManager.shared.loadedUsers.count]

        //MARK: delete this
        model.pictures.append(UIImage(named: "gabe1")!)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZipFinderCollectionViewCell.identifier, for: indexPath) as! ZipFinderCollectionViewCell

        cell.delegate = self
        cell.configure(with: model, loc: userLoc)
//        print(model.location)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("collection view count = \(GeoManager.shared.loadedUsers.count)")
        return .max
//        return 0 //GeoManager.shared.loadedUsers.count
    }
    
    
}


// MARK: UICollectionViewDelegate
extension ZipFinderViewController: ZFCardBackDelegate {
    func openProfile(_ user: User) {        
        let userProfileView = OtherProfileViewController()
        userProfileView.configure(user)
        userProfileView.modalPresentationStyle = .overCurrentContext

        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        view.window!.layer.add(transition, forKey: nil)

//        presentingViewController?.navigationController?.navigationBar.isHidden = false
//        presentingViewController?.navigationController?.pushViewController(userProfileView, animated: true)

        navigationController?.navigationBar.isHidden = false
        navigationController?.pushViewController(userProfileView, animated: true)
//        present(userProfileView, animated: false, completion: nil)
    }
}


extension ZipFinderViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView : UIScrollView){
        adjustScaleAndAlpha()
    }
}


