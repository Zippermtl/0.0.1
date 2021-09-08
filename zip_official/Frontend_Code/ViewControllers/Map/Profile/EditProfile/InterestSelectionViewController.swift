//
//  InterestSelectionViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/3/21.
//

import UIKit

protocol UpdateInterestsProtocol {
    func updateInterests(_ interests: [String])
}

class InterestSelectionViewController: UIViewController, UpdateInterestsProtocol {
    
    
    var userInterests: [String] = []
    var allInterests: [String] = ["Skiing", "Snowboarding", "Foodie", "Festivals", "Crossfit", "Walking", "Climbing", "Baking", "Running", "Travel", "Blogging", "Movies", "Golf", "Tattoos", "Vegan", "Photography", "Reading", "Surfing", "Writing", "Sports", "Vegetarian", "Athlete", "Coffee", "Fashion",  "Karaoke", "Grab a drink", "Mental Health Awareness", "Astrology", "LGBTQ+", "Spirituality", "Voter Rights", "Climate Change", "Cooking", "Soccer", "Dancing", "LGBTQ+ Rights", "Gardening", "Feminism", "Art", "DIY", "Politics", "Cycling", "Museum", "Outdoors", "Shopping", "Activism", "Picnicking", "Comedy", "Brunch", "Making music", "Military", "BLM", "Road Trips", "Dog lover", "Music", "Craft Beer", "Football", "Swimming", "Tea", "Board Games", "Trivia", "Volunteering", "Environmentalism", "Hiking", "Wine", "Vlogging", "Cat lover", "Working out", "Yoga", "Fishing", "Acting", "Basketball", "Binge-watching", "Cars", "Chess", "Partying", "Cannabis", "Coding", "DJing", "Mixology", "Giving advice", "Graphic design", "Gymnastics", "Ice Skating", "Hockey", "Makeup", "Poetry", "Puzzles", "Singing", "Rapping", "Sleeping", "Thrifting", "Video games", "Learning", "History", "Science", "Mathematics", "Language", "Collecting"]
    
    var delegate: UpdateInterestsProtocol?

    let doneButton = UIButton()
    let interestLabel = UILabel()
    
    var collectionView: UICollectionView?

    func updateInterests(_ interests: [String]) {
        delegate?.updateInterests(userInterests)
    }
    
    @objc private func didTapDoneButton(){
        updateInterests(userInterests)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allInterests.sort()
        
        view.backgroundColor = .zipGray
        configureCollectionView()
        
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.zipBlue, for: .normal)
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)

        interestLabel.font = .zipBody.withSize(26)
        interestLabel.textColor = .white
        interestLabel.numberOfLines = 0
        interestLabel.lineBreakMode = .byWordWrapping
        interestLabel.text = "Interests: " + userInterests.map{$0}.joined(separator: ", ")
        
        view.addSubview(interestLabel)
        view.addSubview(doneButton)
        view.addSubview(collectionView!)
    }
    


    
    override func viewWillLayoutSubviews() {
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.centerYAnchor.constraint(equalTo: interestLabel.centerYAnchor).isActive = true
        doneButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        doneButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: doneButton.titleLabel!.intrinsicContentSize.height).isActive = true
        
        interestLabel.translatesAutoresizingMaskIntoConstraints = false
        interestLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        interestLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        interestLabel.rightAnchor.constraint(equalTo: doneButton.leftAnchor).isActive = true
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.topAnchor.constraint(equalTo: interestLabel.bottomAnchor, constant: 10).isActive = true
        collectionView?.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 5).isActive = true
        collectionView?.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -5).isActive = true
        collectionView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    

    private func configureCollectionView() {
        let layout = LeftOreintedFlowLayout()
        layout.minimumLineSpacing = 5

        
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView?.register(InterestsCollectionViewCell.self, forCellWithReuseIdentifier: InterestsCollectionViewCell.identifier)
        
        collectionView?.dataSource = self
        collectionView?.delegate = self

        
        collectionView?.backgroundColor = .zipGray
        view.addSubview(collectionView!)
    }
    
    


}


//MARK: - CollectionView Delegate
extension InterestSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: UIFont.zipBody]
        return CGSize(width: (allInterests[indexPath.row] as NSString).size(withAttributes: fontAttributes).width+20,
                      height: 40)
        
    }
    

}

//MARK: - CollectionView DataSource
extension InterestSelectionViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allInterests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InterestsCollectionViewCell.identifier, for: indexPath) as! InterestsCollectionViewCell

        cell.label.text = allInterests[indexPath.row]
        cell.label.textColor = .white
        cell.label.font = .zipBody
        

        cell.configure()
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.zipLightGray.cgColor
        cell.layer.cornerRadius = 20
        
        if userInterests.contains(cell.label.text ?? "") {
            cell.label.textColor = .zipBlue
            cell.layer.borderColor = UIColor.zipBlue.cgColor
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! InterestsCollectionViewCell
        let idx = userInterests.firstIndex(of: cell.label.text!)
        if  idx != nil{
            userInterests.remove(at: idx!)
            collectionView.reloadData()
        } else if userInterests.count < 5 {
            userInterests.append(cell.label.text!)
            collectionView.reloadData()
        }

        interestLabel.text = "Interests: " + userInterests.map{$0}.joined(separator: ", ")
    }
    
    
}


class LeftOreintedFlowLayout : UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            guard layoutAttribute.representedElementCategory == .cell else {
                return
            }
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }

        return attributes
    }
}
