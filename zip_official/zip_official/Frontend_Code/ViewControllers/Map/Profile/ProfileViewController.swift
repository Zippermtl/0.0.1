//
//  SecondViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/2/21.
//


// Infinite Scroll Wheel of pictures
// https://stackoverflow.com/questions/34396108/how-to-implement-horizontally-infinite-scrolling-uicollectionview

import UIKit
import MapKit
import CoreLocation
import SDWebImage

class ProfileViewController: UIViewController {
    private var user = User()
    
    // MARK: - SubViews
    private var scrollView = UIScrollView()
//    private var pictureCollectionView: UICollectionView!
    private let profilePictureView = UIImageView()

    
    // MARK: - Labels
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle
        label.sizeToFit()
        return label
    }()
    
    private var ageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(26)
        label.sizeToFit()
        return label
    }()
    
    private var bioLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.sizeToFit()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var schoolLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()
    
    private var interestsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()
    
    private var birthdayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()
    
    let schoolImage = UIImageView(image: UIImage(named: "school"))
    let birthdayImage = UIImageView(image: UIImage(named: "birthday"))

    
    // MARK: - Buttons
    var editProfileButton = UIButton()
    var myZipsButton = UIButton()
    var myEventsButton = UIButton()
    
    
    
    //MARK: - Button Actions
    @objc private func didTapSettingsButton(){
        let settingsView = SettingsPageViewController()
        settingsView.modalPresentationStyle = .overCurrentContext
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        view.window!.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(settingsView, animated: true)
    }

    @objc private func didTapEditButton(){
        let editView = EditProfileViewController()
        editView.modalPresentationStyle = .overCurrentContext
        editView.configure(with: user)
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        view.window!.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(editView, animated: true)
    }
    
    @objc private func didTapMyZipsButton(){
        let myZipsView = MyZipsViewController()
        myZipsView.modalPresentationStyle = .overCurrentContext
        navigationController?.pushViewController(myZipsView, animated: true)
    }
    
    @objc private func didTapMyEventsButton(){
        let myEventsView = MyEventsViewController()
        myEventsView.modalPresentationStyle = .overCurrentContext
        navigationController?.pushViewController(myEventsView, animated: true)
    }
    

    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
//        generateTestData()
        
        
        fetchUser()
//
//
        configureLabels()
//        configurePictures()
        configureNavBar()
        configureButtons()
        addSubviews()
    }
    

    //MARK: - ViewWillLayoutSubviews
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureSubviewLayout()
//        scrollView.contentSize = CGSize(width: view.frame.width, height: myZipsButton.frame.maxY + 20)
        scrollView.updateContentView(20)
        
//        adjustScaleAndAlpha() // doesn't work
//        pictureCollectionView.scrollToItem(at: IndexPath(row: user.pictures.count*1000, section: 0),
//                                           at: .centeredHorizontally, animated: false) // doesn't work
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        pictureCollectionView.scrollToItem(at: IndexPath(row: user.pictures.count*1000, section: 0),
//                                           at: .centeredHorizontally, animated: false) //doesn't work
//        adjustScaleAndAlpha()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        pictureCollectionView.scrollToItem(at: IndexPath(row: user.pictures.count*1000, section: 0),
//                                           at: .centeredHorizontally, animated: true)
        
        super.viewDidAppear(animated)

//        pictureCollectionView.scrollToItem(at: IndexPath(row: user.pictures.count*1000, section: 0),
//                                           at: .centeredHorizontally, animated: false) //works after a second and glitches

//        adjustScaleAndAlpha() //works after a second and glitches
        
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

//        pictureCollectionView.scrollToItem(at: IndexPath(row: user.pictures.count*1000, section: 0),
//                                           at: .centeredHorizontally, animated: false)
    }
    
    private func fetchUser() {
        guard let id = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            return
        }

        DatabaseManager.shared.loadUserProfile(given: id, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
                        
            switch result {
            case .success(let user):

                DispatchQueue.main.async {
                    strongSelf.user = user
                    strongSelf.configureLabels()
                }
                
                let path = "images/\(id)/profile_picture.png"
                StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                    switch result {
                    case .success(let url):
                        DispatchQueue.main.async {
                            self?.profilePictureView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print("failed to get image URL: \(error)")
                    }
                    
                    
                })
                
//                let storagePath = "images/\(id)"
//                StorageManager.shared.getAllImages(for: storagePath, completion: { [weak self] result in
//                    switch result {
//                    case .success(let urls):
//                        self?.user.pictureURLs = urls
//                        self?.profilePictureView.sd_setImage(with: urls[0], completed: nil)
//
//                    case .failure(let error):
//                        print("error fetching images from database: \(error)")
//                    }
//
//                })
            case .failure(let error):
                print("failed to get user data: \(error)")
            }
        })
    }
    
    
    //MARK: - Nav Bar Config
    private func configureNavBar() {
        navigationItem.title = "@" + user.username
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "navBarSettings")!.withRenderingMode(.alwaysOriginal),
                                                            landscapeImagePhone: nil,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapSettingsButton))
        
        //removes the text section of the back button from pushed VCs
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    
    
    //MARK: - Label Config
    private func configureLabels(){
//        nameLabel.text = user.name
        navigationItem.title = "@" + user.username
        nameLabel.text = user.firstName + " " + user.lastName
        ageLabel.text = String(user.age)
        bioLabel.text = user.bio
        schoolLabel.text = user.school ?? ""
        interestsLabel.text = "Interests: " + user.interests.map{$0.description}.joined(separator: ", ")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        birthdayLabel.text = dateFormatter.string(from: user.birthday)
    }
    
    

    //MARK: - CollectionView config
//    private func configurePictures(){
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        pictureCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        pictureCollectionView.register(PictureCollectionViewCell.self, forCellWithReuseIdentifier: PictureCollectionViewCell.identifier)
//        pictureCollectionView.showsHorizontalScrollIndicator = false
//        pictureCollectionView.dataSource = self
//        pictureCollectionView.delegate = self
//        pictureCollectionView.isPagingEnabled = false
//        pictureCollectionView.backgroundColor = .clear
//        pictureCollectionView.decelerationRate = .fast
//    }
    
    
    
    
    
    // hello
    //MARK: - Button config
    private func configureButtons() {

        editProfileButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        editProfileButton.backgroundColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        editProfileButton.setTitle("EDIT", for: .normal)
        editProfileButton.titleLabel?.textColor = .white
        editProfileButton.titleLabel?.font = .zipBodyBold
        editProfileButton.titleLabel?.textAlignment = .center
        editProfileButton.contentVerticalAlignment = .center
        editProfileButton.layer.cornerRadius = editProfileButton.frame.size.height/2
        
        myZipsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        myZipsButton.backgroundColor = .zipMyZipsBlue
        myZipsButton.setTitle("MY ZIPS", for: .normal)
        myZipsButton.titleLabel?.font = .zipBodyBold.withSize(22)
        myZipsButton.titleLabel?.textAlignment = .center
        myZipsButton.contentVerticalAlignment = .center
        myZipsButton.layer.cornerRadius = 17
        
        myEventsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        myEventsButton.backgroundColor = .zipMyEventsYellow
        myEventsButton.setTitle("MY EVENTS", for: .normal)
        myEventsButton.titleLabel?.font = .zipBodyBold.withSize(22)
        myEventsButton.titleLabel?.textAlignment = .center
        myEventsButton.contentVerticalAlignment = .center
        myEventsButton.layer.cornerRadius = 17
        
        editProfileButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
        myZipsButton.addTarget(self, action: #selector(didTapMyZipsButton), for: .touchUpInside)
        myEventsButton.addTarget(self, action: #selector(didTapMyEventsButton), for: .touchUpInside)
    }
    
    



    
    
    //MARK: - Add Subviews
    private func addSubviews(){
        view.addSubview(scrollView)
        scrollView.addSubview(profilePictureView)
//        scrollView.addSubview(pictureCollectionView!)
        scrollView.addSubview(nameLabel)
        scrollView.addSubview(ageLabel)
        scrollView.addSubview(editProfileButton)
        scrollView.addSubview(bioLabel)
        scrollView.addSubview(schoolImage)
        scrollView.addSubview(schoolLabel)
        scrollView.addSubview(interestsLabel)
        scrollView.addSubview(birthdayImage)
        scrollView.addSubview(birthdayLabel)
        scrollView.addSubview(myZipsButton)
        scrollView.addSubview(myEventsButton)
    }

    //MARK: - Layout Subviews
    private func configureSubviewLayout(){
        //Dimensions
        
        let width = view.frame.size.width

        // scroll view constraints
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true


        // Picture constraints
//        pictureCollectionView.translatesAutoresizingMaskIntoConstraints = false
//        pictureCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
//        pictureCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        pictureCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//        pictureCollectionView.heightAnchor.constraint(equalToConstant: width/2).isActive = true
        
        profilePictureView.translatesAutoresizingMaskIntoConstraints = false
        profilePictureView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        profilePictureView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profilePictureView.heightAnchor.constraint(equalToConstant: width/2).isActive = true
        profilePictureView.widthAnchor.constraint(equalTo: profilePictureView.heightAnchor).isActive = true
        

        // name label constraints
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profilePictureView.bottomAnchor, constant: 5).isActive = true

        // age label constraints
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        ageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        
        // edit button constraints
        editProfileButton.translatesAutoresizingMaskIntoConstraints = false
        editProfileButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        editProfileButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        editProfileButton.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 10).isActive = true
        editProfileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let buffer = CGFloat(10)
        let heightBuffer = CGFloat(20)
        // bio label constraints
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: buffer).isActive = true
        bioLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -buffer).isActive = true
        bioLabel.topAnchor.constraint(equalTo: editProfileButton.bottomAnchor, constant: heightBuffer/2).isActive = true
        
        // school label constraints
        schoolImage.translatesAutoresizingMaskIntoConstraints = false
        schoolImage.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: buffer).isActive = true
        schoolImage.centerYAnchor.constraint(equalTo: schoolLabel.centerYAnchor).isActive = true
        schoolImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        schoolImage.widthAnchor.constraint(equalTo: schoolImage.heightAnchor).isActive = true

        schoolLabel.translatesAutoresizingMaskIntoConstraints = false
        schoolLabel.leftAnchor.constraint(equalTo: schoolImage.rightAnchor, constant: buffer).isActive = true
        schoolLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -buffer).isActive = true
        schoolLabel.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: heightBuffer).isActive = true
            
        // interests label constraints
        interestsLabel.translatesAutoresizingMaskIntoConstraints = false
        interestsLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: buffer).isActive = true
        interestsLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -buffer).isActive = true
        interestsLabel.topAnchor.constraint(equalTo: schoolLabel.bottomAnchor, constant: heightBuffer).isActive = true
        
        // birthday label constraints
        birthdayImage.translatesAutoresizingMaskIntoConstraints = false
        birthdayImage.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: buffer).isActive = true
        birthdayImage.centerYAnchor.constraint(equalTo: birthdayLabel.centerYAnchor).isActive = true
        birthdayImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        birthdayImage.widthAnchor.constraint(equalTo: birthdayImage.heightAnchor).isActive = true
        
        birthdayLabel.translatesAutoresizingMaskIntoConstraints = false
        birthdayLabel.leftAnchor.constraint(equalTo: birthdayImage.rightAnchor, constant: buffer).isActive = true
        birthdayLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: buffer).isActive = true
        birthdayLabel.topAnchor.constraint(equalTo: interestsLabel.bottomAnchor, constant: heightBuffer).isActive = true
        
        // my zips button constraints
        myZipsButton.translatesAutoresizingMaskIntoConstraints = false
        myZipsButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        myZipsButton.topAnchor.constraint(equalTo: birthdayLabel.bottomAnchor, constant: heightBuffer).isActive = true
        myZipsButton.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -5).isActive = true
        myZipsButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
    
        // my events button constraints
        myEventsButton.translatesAutoresizingMaskIntoConstraints = false
        myEventsButton.heightAnchor.constraint(equalTo: myZipsButton.heightAnchor).isActive = true
        myEventsButton.topAnchor.constraint(equalTo: birthdayLabel.bottomAnchor, constant: heightBuffer).isActive = true
        myEventsButton.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 5).isActive = true
        myEventsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
    }
    


    
    // MARK: - Scale/Alpha
//    func adjustScaleAndAlpha(){
//        let centerX = view.frame.midX
//        for cell in pictureCollectionView!.visibleCells {
//            let basePosition = cell.convert(CGPoint.zero, to: view)
//            let cellCenterX = basePosition.x + cell.frame.size.width/2
//            let distance = abs(centerX-cellCenterX)
//            let tolerance : CGFloat = 0.02
//
//
//
//            var scale = 1.00 + tolerance - ((distance/centerX)*0.205)
//            if scale > 1.0 {
//                scale = 1.0
//            }
//
//            if scale < 0.5 {
//                scale = 0.5
//            }
//
//
//            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
//
//            let coverCell = cell as! PictureCollectionViewCell
//            coverCell.alpha = sizeScaleToAlphaScale(scale)
//        }
//    }
//
//
//    func sizeScaleToAlphaScale(_ x : CGFloat) -> CGFloat{
//        let minScale : CGFloat = 0.5
//        let maxScale : CGFloat = 1.0
//
//        let minAlpha : CGFloat = 0.25
//        let maxAlpha : CGFloat = 1.0
//
//        return ((maxAlpha - minAlpha) * (x - minScale)) / (maxScale - minScale) + minAlpha
//    }
}

// MARK: - CollectionViewDataSource
//extension ProfileViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        var model: UIImage
//        if user.pictures.count > 2 {
//            model = user.pictures[indexPath.row % user.pictures.count]
//        } else {
//            model = user.pictures[indexPath.row]
//        }
//
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PictureCollectionViewCell.identifier, for: indexPath) as! PictureCollectionViewCell
//        cell.cornerRadius = 10
//        cell.configure(with:model)
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if user.pictures.count > 2 {
//            return 10000
//        } else {
//            return user.pictures.count
//        }
//    }
//}
// MARK: - CV Flow Delegate
//extension ProfileViewController : UICollectionViewDelegateFlowLayout{
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: view.frame.size.width/2, height: view.frame.size.width/2)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//    }
//}

// MARK: - Scroll View Delegate
//extension ProfileViewController : UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView : UIScrollView){
//        adjustScaleAndAlpha()
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        var indexOfCellWithLargestWidth = 0
//        var largestWidth: CGFloat = 1
//
//        for cell in pictureCollectionView!.visibleCells {
//            if cell.frame.size.width > largestWidth {
//                largestWidth = cell.frame.size.width
//                if let indexPath = pictureCollectionView.indexPath(for: cell){
//                    indexOfCellWithLargestWidth = indexPath.item
//                }
//            }
//        }
//        pictureCollectionView.scrollToItem(at: IndexPath(item: indexOfCellWithLargestWidth, section: 0), at: .centeredHorizontally, animated: true)
//    }
//}


//creates frame with wrapped text to see what the height will be
extension String {
    func heightForWrap(width: CGFloat) -> CGFloat{
        let tempLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        tempLabel.numberOfLines = 0
        tempLabel.lineBreakMode = .byWordWrapping
        tempLabel.font = .zipBody
        tempLabel.text = self
        tempLabel.sizeToFit()
        return tempLabel.frame.height
    }
}

extension UILabel {
    func heightForWrap(width: CGFloat) -> CGFloat{
        let tempLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        tempLabel.numberOfLines = 0
        tempLabel.lineBreakMode = .byWordWrapping
        tempLabel.font = .zipBody
        tempLabel.text = text
        tempLabel.sizeToFit()
        return tempLabel.frame.height
    }
}


//MARK: - TestData
extension ProfileViewController {
    func generateTestData(){
        var yiannipics = [UIImage]()
        var interests = [Interests]()
        
        interests.append(.skiing)
        interests.append(.coding)
        interests.append(.chess)
        interests.append(.wine)
        interests.append(.workingOut)


        yiannipics.append(UIImage(named: "yianni1")!)
        yiannipics.append(UIImage(named: "yianni2")!)
        yiannipics.append(UIImage(named: "yianni3")!)
        

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let yianniBirthday = formatter.date(from: "2001/12/06")!
        
        user = User(email: "zavalyia@gmail.com",
                     username: "yianni_zav",
                     firstName: "Yianni",
                     lastName: "Zavaliagkos",
//                          name: "Yianni Zavaliagkos",
                     birthday: yianniBirthday,
                     location: CLLocation(latitude: 51.5013, longitude: -0.2070),
                     pictures: yiannipics,
                     bio: "Yianni Zavaliagkos. Second Year at Mcgill. Add my snap and follow my insta @Yianni_Zav. I run this shit. Remember my name when I pass Zuckerberg on Forbes",
                     school: "McGill University",
                     interests: interests)
    }
}


