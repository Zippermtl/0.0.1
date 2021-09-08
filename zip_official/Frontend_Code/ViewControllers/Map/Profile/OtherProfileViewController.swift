//
//  OtherProfileViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/26/21.
//

import UIKit
import MapKit
import CoreLocation

class OtherProfileViewController: UIViewController {
    static let identifier = "profile"
    static let identifierWithImage = "profileWithImage"
    static let identifierLastCell = "profileLastCell"

    private var user = User()
    private var tableData = [String]()
    private var birthday = ""
    
    // MARK: - SubViews
    private var topViewContainer = UIView()
    private var pictureCollectionView: UICollectionView!
    private var profileContainer = UIView()
    private var infoHeaderContainer = UIView()
    private var tableView = UITableView()

    private var lastCell = UIView()

    
    // MARK: - Labels
    private var usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(26)
        label.sizeToFit()
        return label
    }()
    
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
    
    // MARK: - Buttons
    private var backButton:  UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "backarrow"), for: .normal)
        return btn
    }()
    
    private var reportButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "report"), for: .normal)
        return btn
    }()
    
    private var messageButton: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        btn.backgroundColor = .zipBlue
        btn.setTitle("MESSAGE", for: .normal)
        btn.titleLabel?.textColor = .white
        btn.titleLabel?.font = .zipBodyBold
        btn.titleLabel?.textAlignment = .center
        btn.contentVerticalAlignment = .center
        btn.layer.cornerRadius = btn.frame.size.height/2
        return btn
    }()
    
    private var addButton:  UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "add"), for: .normal)
        return btn
    }()
    
    private var myZipsButton: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        btn.backgroundColor = .zipBlue
        btn.setTitle("ZIPS", for: .normal)
        btn.titleLabel?.font = .zipBodyBold.withSize(22)
        btn.titleLabel?.textAlignment = .center
        btn.contentVerticalAlignment = .center
        btn.layer.cornerRadius = 15
        return btn
    }()
    
    private var myEventsButton: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        btn.backgroundColor = .zipMyEventsYellow
        btn.setTitle("EVENTS", for: .normal)
        btn.titleLabel?.font = .zipBodyBold.withSize(22)
        btn.titleLabel?.textAlignment = .center
        btn.contentVerticalAlignment = .center
        btn.layer.cornerRadius = 15
        return btn
    }()
    
    //MARK: - Button Actions
    @objc private func didTapBackButton(){
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: nil)

        self.dismiss(animated: false, completion: nil)
    }

    @objc private func didTapReportButton(){
        print("report Tapped" )
    }

    @objc private func didTapMessageButton(){
        print("Message tapped")
    }
    
    @objc private func didTapAddButton(){
        print("add tapped")
    }
    
    @objc private func didTapMyZipsButton(){
        let myZipsView = MyZipsViewController()

        present(myZipsView, animated: true, completion: nil)
        print("myZips tapped")
    }
    
    @objc private func didTapMyEventsButton(){
        let myEventsView = MyEventsViewController()

        present(myEventsView, animated: true, completion: nil)
        print("myEvents tapped")
    }
    

    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        
       
        
    }
    
    //MARK: - ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        adjustScaleAndAlpha()
    }
    
    //MARK: - ViewWillLayoutSubviews
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureSubviewLayout()
        if user.pictures.count > 2 {
            pictureCollectionView.scrollToItem(at: IndexPath(row: user.pictures.count*2000, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    public func configure(_ user: User){
        self.user = user
        
        configureLabels()
        configureButtons()
        configureTable()
        configurePictures()
        addSubviews()
        addButtonTargets()
    }
    
    
    //MARK: - Table Config
    private func configureTable(){
        configureTableData()
        
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileViewController.identifier)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileViewController.identifierWithImage)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileViewController.identifierLastCell)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.separatorInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    private func configureTableData(){
        tableData.append(user.bio)
        if user.school != nil {
            tableData.append(user.school!)
        }
        tableData.append("Interests: " + user.interests.map{$0}.joined(separator: ", "))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        birthday = dateFormatter.string(from: user.birthday)
        tableData.append(birthday)
    }
    
    //MARK: - CollectionView config
    private func configurePictures(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        pictureCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        pictureCollectionView.register(PictureCollectionViewCell.self, forCellWithReuseIdentifier: PictureCollectionViewCell.identifier)
        pictureCollectionView.showsHorizontalScrollIndicator = false
        pictureCollectionView.dataSource = self
        pictureCollectionView.delegate = self
        pictureCollectionView.backgroundColor = .clear
        pictureCollectionView.decelerationRate = .fast

    }
    
    //MARK: - Button config
    private func configureButtons() {
        

        
        
        configureLastCell()
    }
    
    private func configureLastCell(){
        lastCell.addSubview(myZipsButton)
        lastCell.addSubview(myEventsButton)
                
        myZipsButton.translatesAutoresizingMaskIntoConstraints = false
        myZipsButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        myZipsButton.centerYAnchor.constraint(equalTo: lastCell.centerYAnchor).isActive = true
        myZipsButton.rightAnchor.constraint(equalTo: lastCell.centerXAnchor, constant: -5).isActive = true
        myZipsButton.leftAnchor.constraint(equalTo: lastCell.leftAnchor, constant: 15).isActive = true

        myEventsButton.translatesAutoresizingMaskIntoConstraints = false
        myEventsButton.heightAnchor.constraint(equalTo: myZipsButton.heightAnchor).isActive = true
        myEventsButton.centerYAnchor.constraint(equalTo: lastCell.centerYAnchor).isActive = true
        myEventsButton.leftAnchor.constraint(equalTo: lastCell.centerXAnchor, constant: 5).isActive = true
        myEventsButton.rightAnchor.constraint(equalTo: lastCell.rightAnchor, constant: -15).isActive = true
    }
    
    private func addButtonTargets(){
        // topViewContainer
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        reportButton.addTarget(self, action: #selector(didTapReportButton), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)

        // infoHeaderContainer
        messageButton.addTarget(self, action: #selector(didTapMessageButton), for: .touchUpInside)
        myZipsButton.addTarget(self, action: #selector(didTapMyZipsButton), for: .touchUpInside)
        myEventsButton.addTarget(self, action: #selector(didTapMyEventsButton), for: .touchUpInside)

    }

    //MARK: - Label Config
    private func configureLabels(){
        nameLabel.text = user.name
        ageLabel.text = String(user.age)
        usernameLabel.text = "@" + user.username
    }
    
    //MARK: - Add Subviews

    private func addSubviews(){
        //username and top buttons
        view.addSubview(topViewContainer)
        topViewContainer.addSubview(usernameLabel)
        topViewContainer.addSubview(backButton)
        topViewContainer.addSubview(reportButton)

        //photos
        view.addSubview(pictureCollectionView!)
        
        // Profile Container
        // Info Header
        view.addSubview(profileContainer)
        profileContainer.addSubview(infoHeaderContainer)
        infoHeaderContainer.addSubview(nameLabel)
        infoHeaderContainer.addSubview(ageLabel)
        infoHeaderContainer.addSubview(messageButton)
        infoHeaderContainer.addSubview(addButton)
        
        //table view
        profileContainer.addSubview(tableView)
        

    }

    //MARK: - Layout Subviews
    private func configureSubviewLayout(){
        //Dimensions
        let width = view.frame.size.width
        
        //Pictures
        let pictureWidth = width/2
        pictureCollectionView.frame = CGRect(x: 0, y: pictureWidth/2+10, width: width, height: pictureWidth)
        
        // Containers
        // Top container
        topViewContainer.frame = CGRect(x: 0,
                                     y: view.safeAreaInsets.top,
                                     width: width,
                                     height: pictureCollectionView!.frame.minY-view.safeAreaInsets.top)
        
        // Profile Container constraints
        profileContainer.translatesAutoresizingMaskIntoConstraints = false
        profileContainer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        profileContainer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        profileContainer.topAnchor.constraint(equalTo: pictureCollectionView.bottomAnchor).isActive = true
        profileContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        // info header constraints
        // height = height of contents + 5 buffer
        let infoHeaderHeight = nameLabel.intrinsicContentSize.height + messageButton.frame.height + ageLabel.intrinsicContentSize.height
        infoHeaderContainer.translatesAutoresizingMaskIntoConstraints = false
        infoHeaderContainer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        infoHeaderContainer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        infoHeaderContainer.topAnchor.constraint(equalTo: profileContainer.topAnchor, constant: 10).isActive = true
        infoHeaderContainer.heightAnchor.constraint(equalToConstant: infoHeaderHeight).isActive = true

        // tableView constraints
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        tableView.topAnchor.constraint(equalTo: infoHeaderContainer.bottomAnchor, constant: 10).isActive = true
        tableView.bottomAnchor.constraint(equalTo: profileContainer.bottomAnchor).isActive = true
        
        // many more constraints
        addLabelConstraints()
        addButtonConstraints()
    }
    
    private func addLabelConstraints(){
        // username label constraints
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.centerXAnchor.constraint(equalTo: topViewContainer.centerXAnchor).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: topViewContainer.topAnchor, constant: 5).isActive = true
        
        // name label constraints
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.widthAnchor.constraint(equalToConstant: nameLabel.intrinsicContentSize.width).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: nameLabel.intrinsicContentSize.height).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: infoHeaderContainer.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: infoHeaderContainer.topAnchor).isActive = true
        
        // age label constraints
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.widthAnchor.constraint(equalToConstant: ageLabel.intrinsicContentSize.width).isActive = true
        ageLabel.heightAnchor.constraint(equalToConstant: ageLabel.intrinsicContentSize.height).isActive = true
        ageLabel.centerXAnchor.constraint(equalTo: infoHeaderContainer.centerXAnchor).isActive = true
        ageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
    }
    
    
    private func addButtonConstraints(){
        // Top View Container
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.topAnchor.constraint(equalTo: usernameLabel.topAnchor).isActive = true
        backButton.bottomAnchor.constraint(equalTo: usernameLabel.bottomAnchor).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: usernameLabel.intrinsicContentSize.height*1.5).isActive = true
        backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: topViewContainer.leftAnchor, constant: 20).isActive = true
        backButton.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor).isActive = true
        
        reportButton.translatesAutoresizingMaskIntoConstraints = false
        reportButton.topAnchor.constraint(equalTo: usernameLabel.topAnchor).isActive = true
        reportButton.bottomAnchor.constraint(equalTo: usernameLabel.bottomAnchor).isActive = true
        reportButton.heightAnchor.constraint(equalToConstant: usernameLabel.intrinsicContentSize.height*1.5).isActive = true
        reportButton.widthAnchor.constraint(equalTo: backButton.heightAnchor).isActive = true
        reportButton.rightAnchor.constraint(equalTo: topViewContainer.rightAnchor, constant: -20).isActive = true
        reportButton.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor).isActive = true

        // Info Header Container
        messageButton.translatesAutoresizingMaskIntoConstraints = false
        messageButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        messageButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        messageButton.topAnchor.constraint(equalTo: ageLabel.bottomAnchor).isActive = true
        messageButton.centerXAnchor.constraint(equalTo: infoHeaderContainer.centerXAnchor).isActive = true
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.leftAnchor.constraint(equalTo: messageButton.rightAnchor, constant: 10).isActive = true
        addButton.centerYAnchor.constraint(equalTo: messageButton.centerYAnchor).isActive = true

        addButton.widthAnchor.constraint(equalTo: messageButton.heightAnchor).isActive = true
        addButton.heightAnchor.constraint(equalTo: messageButton.heightAnchor).isActive = true
    }
    
    // MARK: - Scale/Alpha
    func adjustScaleAndAlpha(){
        let centerX = self.pictureCollectionView!.center.x
        for cell in self.pictureCollectionView!.visibleCells {
            let basePosition = cell.convert(CGPoint.zero, to: self.view)
            let cellCenterX = basePosition.x + cell.frame.size.width/2
            let distance = abs(centerX-cellCenterX)
            let tolerance : CGFloat = 0.02
        

            
            var scale = 1.00 + tolerance - ((distance/centerX)*0.205)
            if scale > 1.0 {
                scale = 1.0
            }

            if scale < 0.5 {
                scale = 0.5
            }

            
            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            let coverCell = cell as! PictureCollectionViewCell
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

// MARK: - CollectionView DataSource
extension OtherProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = user.pictures[indexPath.row % user.pictures.count]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PictureCollectionViewCell.identifier, for: indexPath) as! PictureCollectionViewCell
        
        cell.configure(with:model)
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100000 //user.pictures.count
    }
}

//MARK: - CollectionView Flow Delegate
extension OtherProfileViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/2, height: collectionView.frame.size.width/2)
    }
}

extension OtherProfileViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView : UIScrollView){
        adjustScaleAndAlpha()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        var indexOfCellWithLargestWidth = 0
        var largestWidth: CGFloat = 1
        
        for cell in self.pictureCollectionView!.visibleCells {
            if cell.frame.size.width > largestWidth {
                largestWidth = cell.frame.size.width
                if let indexPath = self.pictureCollectionView.indexPath(for: cell){
                    indexOfCellWithLargestWidth = indexPath.item
                }
            }
        }
        pictureCollectionView.scrollToItem(at: IndexPath(item: indexOfCellWithLargestWidth, section: 0), at: .centeredHorizontally, animated: true)
    }
}

//MARK: TableDelegate
extension OtherProfileViewController :  UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < tableData.count{
            return tableData[indexPath.row].heightForWrap(width: tableView.frame.width) + 30
        } else {
            return 60
        }
    }
}

//MARK: TableDataSource
extension OtherProfileViewController :  UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count + 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < tableData.count {
            switch tableData[indexPath.row] {
            case user.school:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.identifierWithImage, for: indexPath) as! ProfileTableViewCell
                cell.textLabel?.text = ""
                
                cell.configure(with: tableData[indexPath.row], image: UIImage(named: "school")!)
                cell.backgroundColor = .clear
//                cell.backgroundColor = .green
                cell.selectionStyle = .none
                cell.clipsToBounds = true
                return cell
                
            case birthday:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.identifierWithImage, for: indexPath) as! ProfileTableViewCell
                cell.configure(with: tableData[indexPath.row], image: UIImage(named: "birthday")!)
                cell.backgroundColor = .clear
//                cell.backgroundColor = .green
                cell.selectionStyle = .none
                cell.clipsToBounds = true
                return cell
            
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.identifier, for: indexPath) as! ProfileTableViewCell
                
                let label = cell.textLabel!
                label.text = tableData[indexPath.row]
                label.textColor = .white
                label.font = .zipBody
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
                label.sizeToFit()
                label.frame = cell.frame
                
                cell.layoutMargins = .zero
                cell.preservesSuperviewLayoutMargins = false

//                cell.backgroundColor = .red
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.clipsToBounds = true
                return cell
            }
        } else {
            print("HERE")
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.identifierLastCell, for: indexPath) as! ProfileTableViewCell
            cell.contentView.addSubview(lastCell)
            lastCell.translatesAutoresizingMaskIntoConstraints = false
            lastCell.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor).isActive = true
            lastCell.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor).isActive = true
            lastCell.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
            lastCell.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.clipsToBounds = true
            return cell
        }
    }
}


