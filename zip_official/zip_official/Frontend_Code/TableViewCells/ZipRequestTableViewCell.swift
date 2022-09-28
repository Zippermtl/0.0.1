//
//  ZipRequestTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/18/21.
//
import UIKit



class ZipRequestTableViewCell: AbstractUserTableViewCell, InvitedCell {
    weak var delegate: InvitedTableViewDelegate?
    var iPath: IndexPath
    let acceptButton: UIButton
    let rejectButton: UIButton
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        rejectButton = UIButton()
        acceptButton = UIButton()
        iPath = IndexPath(row: 0, section: 0)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        extraInfoLabel.font = .zipTextNoti
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
        let rejectImg = UIImage(systemName: "xmark.circle.fill", withConfiguration: largeConfig)?
                        .withRenderingMode(.alwaysOriginal)
                        .withTintColor(.zipVeryLightGray)
        rejectButton.setImage(rejectImg, for: .normal)
        
        let acceptImg = UIImage(systemName: "checkmark.circle.fill", withConfiguration: largeConfig)?
                        .withRenderingMode(.alwaysOriginal)
                        .withTintColor(.zipBlue)
        acceptButton.setImage(acceptImg, for: .normal)
                
        acceptButton.addTarget(self, action: #selector(didTapAcceptButton), for: .touchUpInside)
        rejectButton.addTarget(self, action: #selector(didTapRejectButton), for: .touchUpInside)
        
        
        contentView.addSubview(rejectButton)
        rejectButton.translatesAutoresizingMaskIntoConstraints = false
        rejectButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        rejectButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
        
        contentView.addSubview(acceptButton)
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.centerYAnchor.constraint(equalTo: rejectButton.centerYAnchor).isActive = true
        acceptButton.rightAnchor.constraint(equalTo: rejectButton.leftAnchor, constant: -5).isActive = true
        
        nameLabel.rightAnchor.constraint(lessThanOrEqualTo: acceptButton.leftAnchor,constant: -5).isActive = true
    }
    
    func setIndexPath(indexPath: IndexPath) {
        iPath = indexPath
    }
    
    override func configure(_ user: User) {
        super.configure(user)
        extraInfoLabel.text = "@" + user.username
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @objc private func didTapAcceptButton(){

        user.acceptRequest(completion: { [weak self] error in
            guard let strongSelf = self,
                  error == nil else { return }
//            strongSelf.delegate?.removeCell(indexPath: strongSelf.iPath)
        })
    }
    
    @objc private func didTapRejectButton(){
        user.rejectRequest(completion: { [weak self] error in
            guard let strongSelf = self,
                  error == nil else { return }
//            strongSelf.delegate?.removeCell(indexPath: strongSelf.iPath)
        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = .none
    }
}
