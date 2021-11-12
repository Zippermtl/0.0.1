//
//  MapViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/15/21.
//

/*
 
 
 /Users/yiannizavaliagkos/Desktop/Zip/fontend/zip_official/zip_official/Frontend_Code/ViewControllers/Map/MapViewController.swift
 
 
 */


import UIKit
import MapKit
import CoreLocation
import CoreGraphics
import SDWebImage



//MARK: View Controller
class MapViewController: UIViewController {
    static let title = "MapVC"
    static let profileIdentifier = "profile"

    
    var locationDelegate: LocationUpdateProtocol?
    var isNewAccount = false
    // MARK: - Rings
    var ring1 = MKCircle()
    var ring2 = MKCircle()
    var ring3 = MKCircle()

    // MARK: - Events
    //to be brought in via json file
    //func loadEventData()
    var user = User()
    var launchEvent = Event()
    var randomEvent = Event()
    
    
    // MARK: - Data
    private var events: [Event] = []
    
    // MARK: - Subviews
    let mapView = MKMapView()
    var filterButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "filterButton"), for: .normal)
        btn.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Button Actions
    @objc private func didTapHomeButton(){
        if(ZipperTabBarViewController.userLoc != nil ){
            zoomToLatestLocation(with: ZipperTabBarViewController.userLoc)
        }
    }
    
    @objc private func didTapFilterButton(){
        filterButton.isHidden = true
        let filtersVC = FiltersViewController()
        filtersVC.delegate = self
        filtersVC.modalPresentationStyle = .overCurrentContext
        present(filtersVC, animated: true, completion: nil)
    }
    
    @objc func didTapProfileButton() {
        let profileView = ProfileViewController()
        profileView.modalPresentationStyle = .overCurrentContext
        navigationController?.navigationBar.isHidden = false


        navigationController?.pushViewController(profileView, animated: true)
    }

    
    //MARK: - Ring Taps
    private func didTapRing1() {
        if let tabBarItem = (tabBarController as? ZipperTabBarViewController)?.tabBar.items![2] {
            tabBarItem.selectedImage = UIImage(named: "homeBlue")?.withRenderingMode(.alwaysOriginal)
        }
        presentZipFinder(ring1)
        print("ring1 tapped")
    }
    
    private func didTapRing2() {
        if let tabBarItem = (tabBarController as? ZipperTabBarViewController)?.tabBar.items![2] {
            tabBarItem.selectedImage = UIImage(named: "homeGreen")?.withRenderingMode(.alwaysOriginal)
        }
       presentZipFinder(ring2)
        print("ring2 tapped")

    }
    
    private func didTapRing3() {
        if let tabBarItem = (tabBarController as? ZipperTabBarViewController)?.tabBar.items![2] {
            tabBarItem.selectedImage = UIImage(named: "homePink")?.withRenderingMode(.alwaysOriginal)
        }
        presentZipFinder(ring3)
        print("ring3 tapped")

    }

    private func presentZipFinder(_ ring: MKCircle){
        let zipFinder = ZipFinderViewController()
        zipFinder.delegate = self
        zipFinder.loadDataByRingTap(ring: ring)
        
        let vc = UINavigationController(rootViewController: zipFinder)
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
        
    }
    
    // MARK: - Handle Tap
    

    //checks distance between click and user
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
//        if sender?.state != UIGestureRecognizer.State.began { return }
        let tapPoint = sender?.location(in: mapView)
        
        let tapCoordinate = mapView.convert(tapPoint!, toCoordinateFrom: mapView)
        let tapLocation = CLLocation(latitude: tapCoordinate.latitude, longitude: tapCoordinate.longitude)
        let userLocation = CLLocation(latitude: ZipperTabBarViewController.userLoc.latitude, longitude: ZipperTabBarViewController.userLoc.longitude)
        
        let tapDistance = userLocation.distance(from: tapLocation)
        
        if tapDistance < AppDelegate.userDefaults.double(forKey: "BlueRing") {
            didTapRing1()
            filterButton.isHidden = true
        } else if tapDistance < AppDelegate.userDefaults.double(forKey: "GreenRing") {
            didTapRing2()
            filterButton.isHidden = true
        } else if tapDistance < AppDelegate.userDefaults.double(forKey: "PinkRing") {
            didTapRing3()
            filterButton.isHidden = true
        }
    }
    


    
    
    // MARK: ViewDidLoad
    // essentially the main
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *){
            overrideUserInterfaceStyle = .dark
        }
        
        if let tabBar = tabBarController as? ZipperTabBarViewController {
            tabBar.reselectDelegate = self
            tabBar.locationDelegate = self
        }
        
        
        generateTestData()
        
        definesPresentationContext = true
        configureNavBar()
        configureSubviews()
        configureAnnotations()
        configureGestureRecognizer()
        
        print("finished map configure")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(0, for: .default)
        navigationController?.navigationBar.isHidden = true
        filterButton.isHidden = false
        
        if presentedViewController != nil {
            presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isNewAccount {
            isNewAccount = false
            let vc = NewAccountPopupViewController()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true, completion: nil)
        }
    
        
        guard let vc = presentingViewController else { return }
        while (vc.presentingViewController != nil ) {
            vc.dismiss(animated: false, completion: nil)
        }
        
        
    }
    


    //MARK: - Nav Bar Config
    private func configureNavBar(){
        navigationController?.navigationBar.isHidden = true
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    }
    

    // MARK: - Tap Recognizer Config
    private func configureGestureRecognizer(){
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        gestureRecognizer.delegate = self
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.numberOfTouchesRequired = 1
        
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    //MARK: - Configure Subviews
    private func configureSubviews(){
        mapView.showsUserLocation = true
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true

        view.addSubview(filterButton)
        filterButton.frame = CGRect(x: 10, y: 40, width: 50, height: 50)
    }
    

    //MARK: - Annotation Config
    // regisers annotation views and adds them to map
    func configureAnnotations(){
        mapView.delegate = self
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: EventAnnotation.identifier)

        //Events
        // MARK: London
        let event1 = EventAnnotation(event: launchEvent, coordinate:  CLLocationCoordinate2D(latitude: 51.5014, longitude: -0.1419))
        let event2 = EventAnnotation(event: randomEvent, coordinate: CLLocationCoordinate2D(latitude: 51.5313, longitude: -0.1570))
        
        //MARK: Montreal
//        let event1 = EventAnnotation(event: launchEvent, coordinate:  CLLocationCoordinate2D(latitude: 45.5317, longitude: -73.5873))
//        let event2 = EventAnnotation(event: randomEvent, coordinate: CLLocationCoordinate2D(latitude: 45.4817, longitude: -73.4873))
        
        
        mapView.addAnnotation(event1)
        mapView.addAnnotation(event2)
    }

    
    //configures ring overlays
    //MARK: - Ring Overlay Config
    func configureOverlays(){
        mapView.removeOverlays(mapView.overlays)
        
        ring1 = MKCircle(center: ZipperTabBarViewController.userLoc, radius: CLLocationDistance(AppDelegate.userDefaults.integer(forKey: "BlueRing")))
        ring2 = MKCircle(center: ZipperTabBarViewController.userLoc, radius: CLLocationDistance(AppDelegate.userDefaults.integer(forKey: "GreenRing")))
        ring3 = MKCircle(center: ZipperTabBarViewController.userLoc, radius: CLLocationDistance(AppDelegate.userDefaults.integer(forKey: "PinkRing")))
        
        mapView.addOverlay(ring1)
        mapView.addOverlay(ring2)
        mapView.addOverlay(ring3)
    }
   
  
    
    // MARK: - Map Functions
    //Zoom to user location
    private func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D, animated: Bool = true){
        //change 20000,20000 so that it fits all 3 rings
        let zoomDistance = Double(AppDelegate.userDefaults.integer(forKey: "PinkRing") + 2000)
        let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: zoomDistance,longitudinalMeters: zoomDistance)
        mapView.setRegion(zoomRegion, animated: animated)
    }

    
    

}





// MARK: MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation === mapView.userLocation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MapViewController.profileIdentifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: MapViewController.profileIdentifier)
            }
            annotationView?.frame = CGRect(x: 0, y: 0, width: 75, height: 75)
            let profileButton = UIButton()
            
            annotationView?.addSubview(profileButton)
            profileButton.frame = CGRect(x: 0, y: 0, width: 75, height: 75)
            let layer = profileButton.layer
            layer.borderWidth = 2
            layer.borderColor = UIColor.zipBlue.cgColor
            layer.cornerRadius = layer.frame.height/2
            layer.masksToBounds = true
            
            guard let urlString = AppDelegate.userDefaults.value(forKey: "profilePictureUrl") as? String else {
                return MKAnnotationView()
            }
            
            print("url = \(urlString)")
            let url = URL(string: urlString)

            profileButton.sd_setImage(with: url, for: .normal, completed: nil)
//            profileButton.setBackgroundImage(UIImage(named: "yianni1"), for: .normal)
            profileButton.addTarget(self, action: #selector(didTapProfileButton), for: .touchUpInside)
            
            annotationView?.layer.removeAllAnimations()
            annotationView?.zPriority = .max
            annotationView?.canShowCallout = false
            
            return annotationView
            
        } else if let eventAnnotation = annotation as? EventAnnotation {
            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: EventAnnotation.identifier) else { return MKAnnotationView() }
            
            let img = UIImageView(image: eventAnnotation.event.image)
            annotationView.addSubview(img)
            annotationView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)

            img.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            img.layer.cornerRadius = img.frame.height/2
            img.layer.masksToBounds = true
            img.layer.borderWidth = 1
            switch eventAnnotation.event.type {
            case "promoter": img.layer.borderColor = CGColor(red: 1, green: 1, blue: 0, alpha: 1)
            case "innerCircle": img.layer.borderColor = CGColor(red: 35/255, green: 207/255, blue: 244/255, alpha: 1)
            default: break
            }
            
            annotationView.canShowCallout = false
            return annotationView
        }

        print("ERROR IN MapViewController: MKMapViewDelegate - Should not be returning nil for annotations")
       // I think this will be an error in the future - only happens if it isnt determined annotation type
        return nil
    }
    
    //did select is how you click annotations
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.isZoomEnabled = true
        if let annotation = view.annotation as? EventAnnotation {
            let eventVC = EventViewController()
            eventVC.configure(annotation.event)
            eventVC.modalPresentationStyle = .overCurrentContext
            navigationController?.navigationBar.isHidden = false
            navigationController?.pushViewController(eventVC, animated: true)
            mapView.deselectAnnotation(view.annotation, animated: false)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle else { return MKOverlayRenderer() }
        
//        return UIColor(red: 106/255, green: 205/255, blue: 237/255, alpha: 1)
//
//        return UIColor(red: 154/255, green: 219/255, blue: 131/255, alpha: 1)
//        return UIColor(red: 233/255, green: 163/255, blue: 226/255, alpha: 1)
        
        let circleRenderer =  CircleRenderer(circle: circleOverlay)
        let blueDistance = AppDelegate.userDefaults.float(forKey: "BlueRing")
        let greenDistance = AppDelegate.userDefaults.float(forKey: "GreenRing")
        let pinkDistance = AppDelegate.userDefaults.float(forKey: "PinkRing")

        switch circleOverlay {
        case ring1:
            circleRenderer.gradientColor = [0.415, 0.80, 0.93, 0,
                                            0.415, 0.80, 0.93, 0.05,
                                            0.415, 0.80, 0.93, 0.85]
            let gradientDistance = CGFloat(0)
            circleRenderer.gradientLocations = [gradientDistance, 0.6 ,1.0]

            circleRenderer.strokeColor = .zipBlue
            circleRenderer.alpha = 1
        case ring2:
            circleRenderer.gradientColor = [0.25, 0.89, 0.659, 0,
                                            0.25, 0.89, 0.659, 0.3,
                                            0.25, 0.89, 0.659, 0.85]
            let gradientDistance = CGFloat(blueDistance/greenDistance)
            circleRenderer.gradientLocations = [gradientDistance, 0.8, 1.0]

            circleRenderer.strokeColor = .zipGreen
            circleRenderer.alpha = 1
        default:
            circleRenderer.gradientColor = [0.91, 0.64, 0.886, 0,
                                            0.91, 0.64, 0.886, 0.3,
                                            0.91, 0.64, 0.886, 0.85]
            let gradientDistance = CGFloat(greenDistance/pinkDistance)
            circleRenderer.gradientLocations = [gradientDistance, 0.8,1.0]

            circleRenderer.strokeColor = .zipPink
            circleRenderer.alpha = 1
        }
        
        return circleRenderer
    }

}

// MARK: UIGestureRecognizerDelegate
extension MapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is MKAnnotationView {
            mapView.isZoomEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.mapView.isZoomEnabled = true
            }
            return false
        }
        return true
    }
}


//MARK: Tabbar Reselect
extension MapViewController: TabBarReselectHandling {
    func handleReselect() {
        if let tabBarItem = (tabBarController as? ZipperTabBarViewController)?.tabBar.items![2] {
            tabBarItem.selectedImage = UIImage(named: "homeFullColor")?.withRenderingMode(.alwaysOriginal)
        }
        
        navigationController?.popToRootViewController(animated: true)

        if presentedViewController != nil {
            presentedViewController?.dismiss(animated: true, completion: nil)
        }
        
        if(ZipperTabBarViewController.userLoc != nil){
            zoomToLatestLocation(with: ZipperTabBarViewController.userLoc, animated: true)
        }
    }
}

extension MapViewController: LocationUpdateProtocol {
    func locationUpdated() {
        configureOverlays()
    }
    
    func zoomMap() {
        print("SHOULD BE ZOOMING MAP")
        if ZipperTabBarViewController.userLoc != nil {
            zoomToLatestLocation(with: ZipperTabBarViewController.userLoc, animated: false)
            configureOverlays()
        }
    }
    
    func updateProfilePic() {

    }
}

class CircleRenderer: MKCircleRenderer {
    var gradientColor: [CGFloat] = [0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0, 0.8]
    var gradientLocations: [CGFloat] = [0.4,0.7,1.0]
    
    override func fillPath(_ path: CGPath, in context: CGContext) {
        let rect: CGRect = path.boundingBox
        context.addPath(path)
        context.clip()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let gradient = CGGradient(colorSpace: colorSpace, colorComponents: gradientColor, locations: gradientLocations, count: 3) else { return }
        
        let gradientCenter = CGPoint(x: rect.midX, y: rect.midY)
        let gradientRadius = min(rect.size.width, rect.size.height) / 2
        context.drawRadialGradient(gradient, startCenter: gradientCenter, startRadius: 0, endCenter: gradientCenter, endRadius: gradientRadius, options: .drawsAfterEndLocation)
    }
}


extension MapViewController: FilterVCDelegate {
    func updateRings() {
        configureOverlays()
        zoomToLatestLocation(with: ZipperTabBarViewController.userLoc)
    }
    
    func showFilterButton() {
        filterButton.isHidden = false
    }
}

extension MapViewController: ZipFinderVCDelegate {
    func showFilterButtonFromZF() {
        filterButton.isHidden = false
    }
    
    func updateHomeButton() {
        if let tabBarItem = (tabBarController as? ZipperTabBarViewController)?.tabBar.items![2] {
            tabBarItem.selectedImage = UIImage(named: "homeFullColor")?.withRenderingMode(.alwaysOriginal)
        }
    }
    

}

extension MapViewController: NewAccountDelegate {
    func completeProfile() {
        let vc = CompleteProfileViewController()

        vc.user.userId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        vc.user.username = AppDelegate.userDefaults.value(forKey: "username") as! String
        vc.user.firstName = AppDelegate.userDefaults.value(forKey: "firstName") as! String
        vc.user.lastName = AppDelegate.userDefaults.value(forKey: "lastName") as! String
        vc.user.birthday = AppDelegate.userDefaults.value(forKey: "birthday") as! Date


        guard let urlString = AppDelegate.userDefaults.value(forKey: "profilePictureUrl") as? String,
              let url = URL(string: urlString) else {
            return
        }
        
        
        
        
        let getDataTask = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                vc.user.pictures.append(UIImage(data: data) ?? UIImage())
                vc.collectionView?.reloadData()
            }
            
        })
        getDataTask.resume()
        
        vc.modalPresentationStyle = .fullScreen
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = false
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}


extension MKAnnotationView {
    private var touchPath: UIBezierPath { return UIBezierPath(ovalIn: bounds) }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return touchPath.contains(point)
    }
}





extension MapViewController {
    func generateTestData(){
        var seungpics = [UIImage]()
        var ezrapics = [UIImage]()
        var yiannipics = [UIImage]()
        var eliaspics = [UIImage]()
        var gabepics = [UIImage]()
        
        seungpics.append(UIImage(named: "seung1")!)
        seungpics.append(UIImage(named: "seung2")!)
        seungpics.append(UIImage(named: "seung3")!)
        
        ezrapics.append(UIImage(named: "ezra1")!)
        ezrapics.append(UIImage(named: "ezra2")!)
        ezrapics.append(UIImage(named: "ezra3")!)

        yiannipics.append(UIImage(named: "yianni1")!)
        yiannipics.append(UIImage(named: "yianni2")!)
        yiannipics.append(UIImage(named: "yianni3")!)
        
        eliaspics.append(UIImage(named: "elias1")!)
        eliaspics.append(UIImage(named: "elias2")!)
        eliaspics.append(UIImage(named: "elias3")!)
        
        gabepics.append(UIImage(named: "gabe1")!)
        gabepics.append(UIImage(named: "gabe2")!)
        gabepics.append(UIImage(named: "gabe3")!)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let seungBirthday = formatter.date(from: "2002/01/01")!
        let ezraBirthday = formatter.date(from: "2001/10/23")!
        let yianniBirthday = formatter.date(from: "2001/12/06")!
        let gabeBirthday = formatter.date(from: "2002/06/06")!
        let eliasBirthday = formatter.date(from: "2002/03/14")!

        var seung = User(email: "seung.choi@gmail.com",
                         username: "seungchoi_",
                         firstName: "Seung",
                         lastName: "Choi",
//                         name: "Seung Choi",
                         zipped: true,
                         birthday: seungBirthday,
                         location:  CLLocation(latitude: 51.5014, longitude: -0.1419),
                         pictures: seungpics,
                         bio: "Hey, I'm Seung, rapper/producer and head of Zipper design and marketing",
                         school: "McGill University")
        
        var ezra = User(email: "ezrataylor55@gmail.com",
                         username: "ezrataylor55",
                         firstName: "Ezra",
                         lastName: "Taylor",
//                         name: "Ezra Taylor",
                         zipped: false,
                         birthday: ezraBirthday,
                         location: CLLocation(latitude: 51.5313, longitude: -0.1570),
                         pictures: ezrapics,
                         bio: "What's good, I'm Ezra, rapper/producer, sports enthusiast and head of Zipper legal and finance",
                         school: "McGill University")
        
        var yianni = User(email: "zavalyia@gmail.com",
                         username: "yianni_zav",
                         firstName: "Yianni",
                         lastName: "Zavaliagkos",
//                          name: "Yianni Zavaliagkos",
                         zipped: true,
                         birthday: yianniBirthday,
                         location: CLLocation(latitude: 51.5013, longitude: -0.2070),
                         pictures: yiannipics,
                         bio: "Yianni. I run this shit. Know the name",
                         school: "McGill Univeristy")

        var elias = User(email: "elias.levy@vanderbilt.edu",
                         username: "elias.levy",
                         firstName: "Elias",
                         lastName: "Levy",
//                         name: "Elias Levy",
                         zipped: true,
                         birthday: eliasBirthday,
                         location: CLLocation(latitude: 51.5013, longitude: -0.5070),
                         pictures: eliaspics,
                         bio: "Hey guys, I'm elias, robotics enthusiast and musician. One of the newest Zipper members. I developed the back end of the app basically making things work behind the scenes",
                         school: "Vanderbilt University")
        
        var gabe = User(email: "mason.g.denton@vanderbilt.edu",
                        username: "gabe_denton",
                        firstName: "Gabe",
                        lastName: "Denton",
//                        name: "Gabe Denton",
                        zipped: false,
                        birthday: gabeBirthday,
                        location: CLLocation(latitude: 51.5913, longitude: -0.1870),
                        pictures: gabepics,
                        bio: "Hello, I'm Mason Dental-Tools. Swim fast do Math eat Ass. In that order",
                        school: "Vanderbilt University")
        
        user = yianni
        
//        //Montreal
//        seung.location = CLLocation(latitude: 45.5017, longitude: -73.5673)
//        ezra.location = CLLocation(latitude: 45.4917, longitude: -73.4973)
//        yianni.location = CLLocation(latitude: 45.5517, longitude: -73.5873)
//        elias.location = CLLocation(latitude: 45.6717, longitude: -73.6073)
//        gabe.location = CLLocation(latitude: 45.5017, longitude: -73.6073)
        
        launchEvent = Event(title: "Zipper Launch Party",
                            hosts: [user],
                            description: "Come experience the release and launch of Zipper! Open Bar! Zipper profiles and ID's will be checked at the door. Must be 18 years or older",
                            address: "3781 St. Lauremt Blvd.",
                            maxGuests: 250,
                            usersGoing: [seung,yianni,gabe],
                            usersInterested: [elias,ezra],
                            type: "promoter",
                            startTime: Date(timeIntervalSinceNow: 1000),
                            duration: TimeInterval(2000),
                            image: UIImage(named: "launchevent")!)
        
        randomEvent = Event(title: "Fake Ass Frosh",
                            hosts: [user,gabe,seung,ezra],
                            description: "The FitnessGram™ Pacer Test is a multistage aerobic capacity test that progressively gets more difficult as it continues. The 20 meter pacer test will begin in 30 seconds. Line up at the start. The running speed starts slowly, but gets faster each minute after you hear this signal. Ding  A single lap should be completed each time you hear this sound. Ding  Remember to run in a straight line, and run as long as possible. The second time you fail to complete a lap before the sound, your test is over. The test will begin on the word start. On your mark, get ready, ding",
                            address: "3781 St. Lauremt Blvd.",
                            maxGuests: 250,
                            usersGoing: [ezra,yianni,gabe],
                            usersInterested: [elias,seung],
                            type: "innerCircle",
                            startTime: Date(timeIntervalSinceNow: 100000),
                            duration: TimeInterval(200),
                            image: UIImage(named: "muzique")!)
    }
    
    
    static func getTestUsers() -> [User] {
        var seungpics = [UIImage]()
        var ezrapics = [UIImage]()
        var yiannipics = [UIImage]()
        var eliaspics = [UIImage]()
        var gabepics = [UIImage]()
        
        seungpics.append(UIImage(named: "seung1")!)
        seungpics.append(UIImage(named: "seung2")!)
        seungpics.append(UIImage(named: "seung3")!)
        
        ezrapics.append(UIImage(named: "ezra1")!)
        ezrapics.append(UIImage(named: "ezra2")!)
        ezrapics.append(UIImage(named: "ezra3")!)

        yiannipics.append(UIImage(named: "yianni1")!)
        yiannipics.append(UIImage(named: "yianni2")!)
        yiannipics.append(UIImage(named: "yianni3")!)
        
        eliaspics.append(UIImage(named: "elias1")!)
        eliaspics.append(UIImage(named: "elias2")!)
        eliaspics.append(UIImage(named: "elias3")!)
        
        gabepics.append(UIImage(named: "gabe1")!)
        gabepics.append(UIImage(named: "gabe2")!)
        gabepics.append(UIImage(named: "gabe3")!)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let seungBirthday = formatter.date(from: "2002/01/01")!
        let ezraBirthday = formatter.date(from: "2001/10/23")!
        let yianniBirthday = formatter.date(from: "2001/12/06")!
        let gabeBirthday = formatter.date(from: "2002/06/06")!
        let eliasBirthday = formatter.date(from: "2002/03/14")!

        var seunginterests = [Interests]()
        var ezrainterests = [Interests]()
        var yianniinterests = [Interests]()
        var gabeinterests = [Interests]()
        var eliasinterests = [Interests]()
        
        seunginterests.append(.music)
        seunginterests.append(.makingMusic)
        seunginterests.append(.fashion)
        seunginterests.append(.sports)
        seunginterests.append(.graphicDesign)
        
        
        ezrainterests.append(.music)
        ezrainterests.append(.makingMusic)
        ezrainterests.append(.grabADrink)
        ezrainterests.append(.sports)
        ezrainterests.append(.football)
        
        yianniinterests.append(.skiing)
        yianniinterests.append(.coding)
        yianniinterests.append(.chess)
        yianniinterests.append(.wine)
        yianniinterests.append(.workingOut)
        
        gabeinterests.append(.skiing)
        gabeinterests.append(.coding)
        gabeinterests.append(.grabADrink)
        gabeinterests.append(.greekLife)
        gabeinterests.append(.workingOut)
        
        eliasinterests.append(.learning)
        eliasinterests.append(.coding)
        eliasinterests.append(.grabADrink)
        eliasinterests.append(.greekLife)
        eliasinterests.append(.music)
        
        seunginterests.sort(by: {$0.rawValue < $1.rawValue})
        ezrainterests.sort(by: {$0.rawValue < $1.rawValue})
        yianniinterests.sort(by: {$0.rawValue < $1.rawValue})
        gabeinterests.sort(by: {$0.rawValue < $1.rawValue})
        eliasinterests.sort(by: {$0.rawValue < $1.rawValue})

        var seung = User(email: "seung.choi@gmail.com",
                         username: "seungchoi_",
                         firstName: "Seung",
                         lastName: "Choi",
//                         name: "Seung Choi",
                         zipped: true,
                         birthday: seungBirthday,
                         location: CLLocation(latitude: 51.5014, longitude: -0.1419), //CLLocation(latitude: 45.5017, longitude: -73.5673),
                         pictures: seungpics,
                         bio: "Hey, I'm Seung, rapper/producer and head of Zipper design and marketing",
                         school: "McGill University",
                         interests: seunginterests)
        
        var ezra = User(email: "ezrataylor55@gmail.com",
                         username: "ezrataylor55",
                         firstName: "Ezra",
                         lastName: "Taylor",
//                         name: "Ezra Taylor",
                         zipped: false,
                         birthday: ezraBirthday,
                         location: CLLocation(latitude: 51.5313, longitude: -0.1570), //CLLocation(latitude: 45.4917, longitude: -73.4973),
                         pictures: ezrapics,
                         bio: "What's good, I'm Ezra, rapper/producer, sports enthusiast and head of Zipper legal and finance",
                         school: "McGill University",
                         interests: ezrainterests)
        
        var yianni = User(email: "zavalyia@gmail.com",
                         username: "yianni_zav",
                         firstName: "Yianni",
                         lastName: "Zavaliagkos",
//                          name: "Yianni Zavaliagkos",
                         zipped: true,
                         birthday: yianniBirthday,
                         location: CLLocation(latitude: 51.5013, longitude: -0.2070), //CLLocation(latitude: 45.5517, longitude: -73.5873),
                         pictures: yiannipics,
                         bio: "Yianni. I run this shit. Know the name",
                         school: "McGill Univeristy",
                         interests: yianniinterests)

        var elias = User(email: "elias.levy@vanderbilt.edu",
                         username: "elias.levy",
                         firstName: "Elias",
                         lastName: "Levy",
//                         name: "Elias Levy",
                         zipped: true,
                         birthday: eliasBirthday,
                         location: CLLocation(latitude: 51.5013, longitude: -0.5070), //CLLocation(latitude: 45.671, longitude: -73.6073),
                         pictures: eliaspics,
                         bio: "Hey guys, I'm elias, robotics enthusiast and musician. One of the newest Zipper members. I developed the back end of the app basically making things work behind the scenes",
                         school: "Vanderbilt University",
                         interests: eliasinterests)
        
        var gabe = User(email: "mason.g.denton@vanderbilt.edu",
                        username: "gabe_denton",
                        firstName: "Gabe",
                        lastName: "Denton",
//                        name: "Gabe Denton",
                        zipped: false,
                        birthday: gabeBirthday,
                        location: CLLocation(latitude: 51.5913, longitude: -0.1870), //CLLocation(latitude: 45.5017, longitude: -73.6073),
                        pictures: gabepics,
                        bio: "Hello, I'm Mason Dental-Tools. Swim fast do Math eat Ass. In that order",
                        school: "Vanderbilt University",
                        interests: gabeinterests)
        
        //Montreal
//        seung.location = CLLocation(latitude: 45.5017, longitude: -73.5673)
//        ezra.location = CLLocation(latitude: 45.4917, longitude: -73.4973)
//        yianni.location = CLLocation(latitude: 45.5517, longitude: -73.5873)
//        elias.location = CLLocation(latitude: 45.6717, longitude: -73.6073)
//        gabe.location = CLLocation(latitude: 45.5017, longitude: -73.6073)
        
        let list: [User] = [seung,ezra,yianni,elias,gabe]
        return list
    }
}

//Solves the corner problem
//extension UIButton {
//    private var touchPath: UIBezierPath { return UIBezierPath(ovalIn: bounds) }
//
//    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        return touchPath.contains(point)
//    }
//}
