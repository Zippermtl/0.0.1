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
import GeoFire

// ingnore this
protocol ZipFinderVCDelegate: AnyObject {
    func showFilterButtonFromZF()
    func updateHomeButton()
}

class ZipFinderViewController: UIViewController, UICollectionViewDelegate {
    var cellSize = CGSize()

    // userData
    var userLoc = CLLocation()
    
    var data: [User] = []
//    var data: [String] = []
    
    //SubViews
    private var collectionView: UICollectionView?
    
    weak var delegate: ZipFinderVCDelegate?
    
    
    @objc private let closeButton: UIButton = {
        let btn = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .medium)
        btn.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        return btn
    }()
    
    private var hasMore = false
    
    private var maxIndex = 0
    
    private var isInfite = false
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
//        if(GeoManager.shared.loadedUsers.count > 0){
//            for (i,k) in GeoManager.shared.loadedUsers {
//                data.append(k)
//            }
//        }
        getShuffleData()
        if(data.count > 0){
            isInfite = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private var testUsers: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        view.isOpaque = false

        print("Entering View did load with userIdList size: \(GeoManager.shared.userIdList.count)")
        if NSLocale.current.regionCode == "US" {
            GeoManager.shared.rangeMultiplier = 1.6
//            GeoManager.shared.maxRangeFilter *= GeoManager.shared.rangeMultiplier
            GeoManager.shared.setMaxRangeFilter(val: nil)
//            rangeMultiplier = 1.6
//            maxRangeFilter *= rangeMultiplier
        }
        if(data.count == 0){
            isInfite = false
        } else if (data.count > maxIndex){
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
        //if failure for the range change to maxRangeFilter
        let coordinates = AppDelegate.userDefaults.value(forKey: "userLoc") as! [Double]
        GeoManager.shared.GetUserByLoc(location: CLLocation(latitude: coordinates[0], longitude: coordinates[1]), range: GeoManager.shared.presentRange, max: 100, completion: {
            GeoManager.shared.LoadUsers(size: 10, completion: { [weak self] res in
                guard let strongSelf = self else {
                    return
                }
                switch res {
                case .success(let uId):
                    if let tmp = GeoManager.shared.loadedUsers[uId] {
                        if(!strongSelf.data.contains(tmp)){
                            strongSelf.data.append(tmp)
                            DispatchQueue.main.async {
                                self?.collectionView?.reloadData()
                            }
                        }
                    }
                    print("RELOADING DATA")
                case .failure(let err):
                    print(err)
                    print("failure on line 88 (ViewDidLoad) in ZFViewController")
                }
            }, updateCompletion: { [weak self] res in
                guard let strongSelf = self else {
                    return
                }
                let loc = strongSelf.data.firstIndex(of: User(userId: res))
                let user =  GeoManager.shared.loadedUsers[res]!
                strongSelf.data[loc!] = user
                guard let cell = user.ZFCell else {
                    return
                }
                cell.configureImage(user: user)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
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
        collectionView.showsVerticalScrollIndicator = false
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
        GeoManager.shared.hasMaxRange = true
        GeoManager.shared.blockFutureQueries = false
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
    
    
    private func PullNextUser(completion: @escaping (User) -> Void, completionPictures: @escaping (User) -> Void) {
        //MARK: Yianni change is constant once u implement the rest
//        if(GeoManager.shared.needsNewUsers(maxIndex: maxIndex, isConstant: !isInfite , range: presentRange)
        
        if(!GeoManager.shared.needsNewUsers(maxIndex: maxIndex, isConstant: (maxIndex != -1), completion: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            GeoManager.shared.LoadUsers(size: 10, completion: { [weak self] res in
                guard let strongSelf = self else {
                    return
                }
                switch res{
                case .success(let uId):
                    if let tmp = GeoManager.shared.loadedUsers[uId] {
                        if(!strongSelf.data.contains(tmp)){
                            strongSelf.data.append(tmp)
                        }
                        completion(tmp)
                    }
                case .failure(let err):
                    print("error in PullNext User completion")
                    print(err)
                    return
                }
                
            }, updateCompletion: { [weak self] res in
                guard let strongSelf = self else {
                    return
                }
                if let tmp = GeoManager.shared.loadedUsers[res] {
                    let loc = strongSelf.data.firstIndex(of: User(userId: res))
                    strongSelf.data[loc!] = GeoManager.shared.loadedUsers[res]!
                    completionPictures(tmp)
                }
            })
        })) {
            
            GeoManager.shared.LoadUsers(size: 10, completion: { [weak self] res in
                guard let strongSelf = self else {
                    return
                }
                switch res{
                case .success(let uId):
                    if let tmp = GeoManager.shared.loadedUsers[uId] {
                        if(!strongSelf.data.contains(tmp)){
                            strongSelf.data.append(tmp)
                        }
                        completion(tmp)
                    }
                case .failure(let err):
                    print("error in PullNext User completion")
                    print(err)
                    return
                }
                
            }, updateCompletion: { [weak self] res in
                guard let strongSelf = self else {
                    return
                }
                if let tmp = GeoManager.shared.loadedUsers[res] {
                    let loc = strongSelf.data.firstIndex(of: User(userId: res))
                    strongSelf.data[loc!] = GeoManager.shared.loadedUsers[res]!
                    completionPictures(tmp)
                }
            })
        }
    }
    
   
}

// MARK: fUICollectionViewDataSource
extension ZipFinderViewController: UICollectionViewDataSource {
    
//    private func checkNeedsNewUsers() {
//        print("in checkNeedsNewUsers")
//        if(!GeoManager.shared.hasMaxRange && !GeoManager.shared.blockFutureQueries){
////            let needsData = GeoManager.shared.needsNewUsers(maxIndex: maxIndex, isConstant: (maxIndex != -1), completion: { [weak self] in
//////            let reload = GeoManager.shared.needsNewUsers(maxIndex: maxIndex, isConstant: !isInfite, completion: {
////                guard let strongSelf = self else {
////                    return
////                }
////                if (!needsData) {
////
////                }
////
////            })
//            PullNextUser(index: <#T##Int#>, completion: <#T##(User) -> Void#>, completionPictures: <#T##(User) -> Void#>)
//        }
//        print("got to the collection view with \(GeoManager.shared.userIdList.count) unloaded names and \(GeoManager.shared.loadedUsers.count) loaded on pass index: \(maxIndex)")
//        if(!GeoManager.shared.hasMaxRange && GeoManager.shared.blockFutureQueries){
//            print("already queried the max distance")
//        } else if(maxIndex > GeoManager.shared.loadedUsers.count - 6){
//            PullNextUser(index: maxIndex, completion: { _ in
//       //                guard let user = user else {
//       //                    return
//       //                }
//            })
//            if(GeoManager.shared.userIdList.count == 0 && maxRangeFilter >= 55*rangeMultiplier && !GeoManager.shared.moreUsersInQuery && GeoManager.shared.hasMaxRange){
//                print("range is \(maxRangeFilter)")
//                print("amoung of loaded users is \(GeoManager.shared.loadedUsers.count)")
//                print("there are \(GeoManager.shared.userIdList.count) uncounted users and the query running is \(GeoManager.shared.queryRunning)")
//       //                if(!queryRunning){
//       //                    //MARK: Yianni Read Below
//       //                    //Insert blank card with loading which updates once complete
//       //
//       //                } else {
//       //                    //Insert no people near you card
//       //
//       //                }
//            } else if(GeoManager.shared.userIdList.count < 10 ){
//                var letNextQueryBegin = true
//                if(GeoManager.shared.moreUsersInQuery || GeoManager.shared.queryRunning){
//                    print("there are more users in query: \(GeoManager.shared.moreUsersInQuery)")
//                    print("there are more users in query: \(GeoManager.shared.queryRunning)")
//                    print("")
//                    letNextQueryBegin = false
//                }
//                if(letNextQueryBegin){
//                    if(maxRangeFilter < 5 * rangeMultiplier){
//                        maxRangeFilter = 5 * rangeMultiplier
//                    } else {
//                        maxRangeFilter += 5 * rangeMultiplier
//                    }
//                }
//                if (!GeoManager.shared.queryRunning){
//                    let coordinates = AppDelegate.userDefaults.value(forKey: "userLoc") as! [Double]
//                    GeoManager.shared.GetUserByLoc(location: CLLocation(latitude: coordinates[0], longitude: coordinates[1]), range: maxRangeFilter, max: 100, completion: { [weak self] in
//                        DispatchQueue.main.async {
//                            self?.collectionView?.reloadData()
//                        }
//                    })
//
//                }
//            }
//        }
//    }
    
    func makeFinite(){
        isInfite = false
    }
    
    func makeInfite(){
        isInfite = true
    }
    
    public func numberOfItemsInSelection() -> Int {
        if(isInfite){
            return .max
        }
        return GeoManager.shared.getPossiblePresentNumberOfCells()
    }
    
    public func numberOfLoadedItemsInSelection() -> Int {
        return GeoManager.shared.getNumberOfCells()
    }
    
    public func checkDataConcurency() -> Bool {
        if data.count != numberOfLoadedItemsInSelection() {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row > GeoManager.shared.getPossiblePresentNumberOfCells() {
            makeFinite()
        } else {
            if(!isInfite){
                makeInfite()
            }
        }
        if indexPath.row == GeoManager.shared.loadedUsers.count {
            if (checkDataConcurency()) {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoMoreUsersCollectionViewCell.identifier, for: indexPath) as! NoMoreUsersCollectionViewCell
                //MARK: Make finite
                cell.delegate = self
                PullNextUser(completion: {[weak self] _ in
                    guard let strongSelf = self else {
                        return
                    }
                    if(GeoManager.shared.needsReload(presIndex: indexPath.row, maxIndices: strongSelf.maxIndex, Incompletion: true, isInfinite: strongSelf.isInfite)){
                        DispatchQueue.main.async {
                            self?.maxIndex = indexPath.row
                            self?.collectionView?.reloadData()
                        }
                    }
                }, completionPictures: {_ in})
                return cell
            } else {
                PullNextUser(completion: {[weak self] _ in
                    guard let strongSelf = self else {
                        return
                    }
                    if(GeoManager.shared.needsReload(presIndex: indexPath.row, maxIndices: strongSelf.maxIndex, Incompletion: true, isInfinite: strongSelf.isInfite)){
                        DispatchQueue.main.async {
                            self?.maxIndex = indexPath.row
                            self?.collectionView?.reloadData()
                        }
                    }
                }, completionPictures: {_ in})
            }
            
        }
        //MARK: size indicator
        if indexPath.row >= maxIndex {
            maxIndex = indexPath.row
            PullNextUser(completion: {[weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                if(GeoManager.shared.needsReload(presIndex: indexPath.row, maxIndices: strongSelf.maxIndex, Incompletion: true, isInfinite: strongSelf.isInfite)){
                    DispatchQueue.main.async {
                        self?.maxIndex = indexPath.row
                        self?.collectionView?.reloadData()
                    }
                }
            }, completionPictures: {_ in})
        }
        print("INDEXPATH = \(indexPath.row)")

        //MARK: delete this
        
//        model.pictures.append(UIImage(named: "gabe1")!)
        
//        let model = testUsers[indexPath.row]
        
        var model: User
        if (GeoManager.shared.loadedUsers.count == 0){
            model = User()
        } else {
            let loc = data[indexPath.row % GeoManager.shared.loadedUsers.count]
//            model = GeoManager.shared.loadedUsers[indexPath.row % GeoManager.shared.loadedUsers.count]
            model = loc
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZipFinderCollectionViewCell.identifier, for: indexPath) as! ZipFinderCollectionViewCell

        cell.frontDelegate = self
        cell.backDelegate = self
        cell.configure(user: model, loc: userLoc, idPath: indexPath.row)
        model.ZFCell = cell
//        print(model.location)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //MARK: Gabe change to ids
//        print("collection view count = \(GeoManager.shared.loadedUsers.count)")
////        return .max
//        print(GeoManager.shared.loadedUsers)
//        return GeoManager.shared.loadedUsers.count + 1
        return GeoManager.shared.getNumberOfCells() + 1
    }
    
    public func getShuffleData(){
        var temp: [User] = []
        getFilterData()
        temp = data
        data = []
        while temp.count > 0 {
            let i = Int.random(in: 0..<(temp.count-1))
            guard temp[i] != nil else {
                continue
            }
            data.append(temp[i])
            temp.remove(at: i)
        }
    }
    
    public func filterData(){
        if(GeoManager.shared.filtersChanged){
            for i in data {
                if(!GeoManager.shared.matchesFilters(user: i)){
                    let j = data.firstIndex(of: i)
                    guard let f = j else {
                        continue
                    }
                    data.remove(at: f)
                }
            }
            GeoManager.shared.filtersChanged = false
        } else {
            return
        }
    }
    
    public func getFilterData(){
        data = GeoManager.shared.getFilteredData()
    }
}


// MARK: UICollectionViewDelegate
extension ZipFinderViewController: ZFCardBackDelegate {
    func openVC(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func popVC() {
        navigationController?.popViewController(animated: true)
    }
}

extension ZipFinderViewController: ZFCardFrontDelegate {
    func presentReport(user: User) {
        let vc = ReportViewController(user: user)
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false, completion: nil)
    }
}


extension ZipFinderViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView : UIScrollView){
        adjustScaleAndAlpha()
    }
}


extension ZipFinderViewController: DidTapGlobalProtocol {
    func goGlobal() {
        print("Touched Yianni's new button")
//        GeoManager.shared.blockFutureQueries = false
//        GeoManager.shared.hasMaxRange = false
//        checkNeedsNewUsers()
    }
}
