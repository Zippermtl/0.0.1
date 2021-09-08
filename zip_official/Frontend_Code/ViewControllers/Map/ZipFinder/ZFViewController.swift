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


class ZipFinderViewController: UIViewController, UICollectionViewDelegate {
    var cellSize = CGSize()

    // userData
    private var data = [User]()
    let userLoc = CLLocation(latitude: MapViewController.userLoc.latitude, longitude: MapViewController.userLoc.longitude)
    
    
    //SubViews
    private var collectionView: UICollectionView?
    
    @objc private let closeButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "close"), for: .normal)
        button.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)

        return button
    }()
    
    
        
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data = MapViewController.getTestUsers()
        collectionView?.isOpaque = true
        configCollection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Eventually gonna scroll to the right place - make sure its not animated
        adjustScaleAndAlpha()
        
    }
    
    //Config
    private func configCollection(){
        
        if AppDelegate.userDefaults.bool(forKey: "hasHomeButton"){
            cellSize = CGSize(width: view.frame.size.width,
                              height: round(view.frame.size.height*0.9))
        } else {
            cellSize = CGSize(width: view.frame.size.width,
                              height: round(view.frame.size.height*0.7))

        }
        //Collection View Layout config
        let layout = SnappingFlowLayout()//UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        
        
//        width = 375.0 height = 812.0


        //init CollectionView

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        
//        collectionView?.isPagingEnabled = true
        self.collectionView?.register(ZipFinderCollectionViewCell.self, forCellWithReuseIdentifier: ZipFinderCollectionViewCell.identifier)
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.decelerationRate = .fast


    }
    
    override func viewSafeAreaInsetsDidChange() {
        
        if !AppDelegate.userDefaults.bool(forKey: "hasHomeButton"){
            collectionView?.contentInset = UIEdgeInsets(top: cellSize.height/7,
                                                        left: 0,
                                                        bottom: 0,
                                                        right: 0)
        } else {
            collectionView?.contentInset = UIEdgeInsets(top: 5,
                                                        left: 0,
                                                        bottom: 0,
                                                        right: 0)
        }

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(collectionView!)
        view.addSubview(closeButton)

        collectionView?.frame = view.bounds

        collectionView?.backgroundColor = .clear
        
        let closeButtonSize = view.frame.width/16
        
        if AppDelegate.userDefaults.bool(forKey: "hasHomeButton"){
            closeButton.frame = CGRect(x: closeButtonSize, y: closeButtonSize, width: closeButtonSize, height: closeButtonSize)
        } else {
            closeButton.frame = CGRect(x: closeButtonSize, y: closeButtonSize+15, width: closeButtonSize, height: closeButtonSize)
        }
    }
    
    @objc func didTapCloseButton() {
        dismiss(animated: false, completion: nil)
    }
    
    public func loadDataByRingTap(ring: MKCircle){
        /*
         Right now there is an issue that when you open the rings the first time it isn't sdjugeted to the right height
         I THINK eventually this will be solved when we scroll to the right distance filter depending on the ring because we will scroll to
         */
    }
    
    func adjustScaleAndAlpha(){
        let centerY = self.collectionView!.contentInset.top + cellSize.height/2
        
        for cell in self.collectionView!.visibleCells {
            let basePosition = cell.convert(CGPoint.zero, to: self.view)
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
    
}

// MARK: UICollectionViewDataSource
extension ZipFinderViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let model = data[indexPath.row % data.count]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZipFinderCollectionViewCell.identifier, for: indexPath) as! ZipFinderCollectionViewCell
        cell.delegate = self
        cell.configure(with: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return .max //data.count
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
        self.view.window!.layer.add(transition, forKey: nil)
        present(userProfileView, animated: false, completion: nil)
    }
}



extension ZipFinderViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView : UIScrollView){
        adjustScaleAndAlpha()
    }
}




