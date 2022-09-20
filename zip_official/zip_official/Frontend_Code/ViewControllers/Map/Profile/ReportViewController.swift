//
//  ReportViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/6/22.
//

import UIKit


protocol ReportMessageDelegate: AnyObject {
    func dismissVC()
    func sendReport(reason: String)
    func sendBlock()
}


class ReportViewController: UIViewController {
    enum ReportContext: CustomStringConvertible, CaseIterable {
        case Spam
        case Abuse
        case FakeProfile
        case InappropriatePic
        case InappropriateMessage
        case InappropriateBio
        case Danger


        var description: String {
            switch self {
            case .Spam: return "Spam"
            case .Abuse: return "Abuse/Harassment"
            case .FakeProfile: return "Fake profile/Spam"
            case .InappropriatePic: return "Inappropriate Photo"
            case .InappropriateBio: return "Inappropriate Messages"
            case .InappropriateMessage: return "Inappropriate Photo"
            case .Danger: return "Someone is in Danger"
            }
        }
    }
    
    private class ReportCaster {
        var context: ReportContext
        var cast: (_ context: ReportContext) -> Void
        init(context: ReportContext, cast: @escaping (ReportContext) -> Void){
            self.context = context
            self.cast = cast
        }
        
        func report() {
            cast(context)
        }
    }
    

    typealias ReportOptions = [ (String , (() -> Void) ) ]
    
    private var user: User
    private var reportTableContainer: UIView
    private var cancelButton: UIButton
    private var tableHeightConstraint: NSLayoutConstraint!
    private var bg: UIView
    
    private var reportContextOptions: ReportOptions!
    private var actionSelectOptions: ReportOptions!
    private var reportOptionsMenu: ReportOptionsMenu!
    
    private var sendReportView: ReportMessageView
    private var blockUserView: BlockUserView


    
    init(user: User) {
        self.user = user
        self.cancelButton = UIButton()
        self.reportTableContainer = UIView()
        self.bg = UIView()
        self.sendReportView = ReportMessageView()
        self.blockUserView = BlockUserView()
        
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .clear
        self.actionSelectOptions = [("Report",openReportUser),("Block",openBlockUser)]
        self.reportContextOptions = ReportContext.allCases.compactMap({ ($0.description, ReportCaster(context: $0, cast: reportUser).report) })
        self.reportOptionsMenu = ReportOptionsMenu(reportOptions: actionSelectOptions)
        
        reportTableContainer.isHidden = true
        sendReportView.isHidden = true
        sendReportView.delegate = self
        blockUserView.isHidden = true
        blockUserView.delegate = self
        
        bg.backgroundColor = .black.withAlphaComponent(0.7)
        let bgTap = UITapGestureRecognizer(target: self, action: #selector(didTapCancel))
        bg.addGestureRecognizer(bgTap)

        cancelButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 15
        cancelButton.backgroundColor = .zipGray
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .zipTextFill

        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        
        
        reportOptionsMenu.layer.masksToBounds = true
        reportOptionsMenu.layer.cornerRadius = 15
        
        addSubviews()
        configureSubviewLayout()
    }
    
    func reportUser(context: ReportContext) {
        sendReportView.update(context: context)
        slideDown(view: reportTableContainer, completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.slideUp(view: strongSelf.sendReportView, completion: nil)
        })
    }
    
    private func openBlockUser() {
        blockUserView.update(user: user)
        slideDown(view: reportTableContainer, completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.slideUp(view: strongSelf.blockUserView, completion: nil)
        })
    }
    
    private func openReportUser() {
        reportOptionsMenu.reportOptions = reportContextOptions
        slideDown(view: reportTableContainer, completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.reportOptionsMenu.reloadData()
            strongSelf.slideUp(view: strongSelf.reportTableContainer, completion: nil)
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func OpenReportOrBlockView() {
        var blockedUsers = AppDelegate.userDefaults.value(forKey: "blockedUsers") as? [String] ?? []
        blockedUsers.append(user.userId)
        AppDelegate.setValue(blockedUsers, forKey: "blockedUsers")
    }
    
    @objc private func didTapCancel(){
        slideDownAndDismiss(view: reportTableContainer)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        reportOptionsMenu.sizeToFit()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initialSlideUp()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reportOptionsMenu.frame = CGRect(x: 0, y: 0, width: reportTableContainer.frame.width, height: reportOptionsMenu.contentSize.height)
    }
    

    
    private func slideUp(view: UIView, completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: 0.5,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: { [weak self] in
            guard let strongSelf = self else { return }
            view.isHidden = false
            view.frame = CGRect(x: 0,
                                y: strongSelf.view.frame.height - view.frame.width,
                                width: strongSelf.view.frame.width,
                                height: view.frame.height)
        }, completion: completion)
    }
    
    private func slideDown(view: UIView, completion: ((Bool) -> Void)?)  {
        UIView.animate(withDuration: 0.5,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: { [weak self] in
            guard let strongSelf = self else { return }
            view.isHidden = true
            view.frame = CGRect(x: 0,
                                y: strongSelf.view.frame.height,
                                width: strongSelf.view.frame.width,
                                height: strongSelf.view.frame.height)
        }, completion: completion)
    }
    
    private func initialSlideUp () {
        UIView.animate(withDuration: 0.5,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.bg.alpha = 0.7
            strongSelf.reportTableContainer.isHidden = false
            strongSelf.reportTableContainer.frame = CGRect(x: 0,
                                                           y: strongSelf.view.frame.height - strongSelf.reportTableContainer.frame.width,
                                                           width: strongSelf.view.frame.width,
                                                           height: strongSelf.reportTableContainer.frame.height)
        }, completion: nil)
    }

    private func slideDownAndDismiss(view: UIView) {
        UIView.animate(withDuration: 0.5,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: { [weak self] in
            guard let strongSelf = self else { return }
            view.isHidden = true
            view.frame = CGRect(x: 0,
                                y: strongSelf.view.frame.height,
                                width: strongSelf.view.frame.width,
                                height: strongSelf.view.frame.height)
            strongSelf.bg.alpha = 0
        }, completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: false, completion: nil)
        })
    }
    
    private func addSubviews() {
        view.addSubview(bg)
        view.addSubview(sendReportView)
        view.addSubview(reportTableContainer)
        view.addSubview(blockUserView)
        reportTableContainer.addSubview(cancelButton)
        reportTableContainer.addSubview(reportOptionsMenu)
    }
    
    private func configureSubviewLayout(){
        bg.frame = view.bounds
        
        reportTableContainer.translatesAutoresizingMaskIntoConstraints = false
        reportTableContainer.topAnchor.constraint(equalTo: reportOptionsMenu.topAnchor).isActive = true
        reportTableContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        reportTableContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        reportTableContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true

        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.bottomAnchor.constraint(equalTo: reportTableContainer.bottomAnchor).isActive = true
        cancelButton.rightAnchor.constraint(equalTo: reportTableContainer.rightAnchor).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: reportTableContainer.leftAnchor).isActive = true
        cancelButton.topAnchor.constraint(equalTo: reportOptionsMenu.bottomAnchor,constant: 20).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        sendReportView.translatesAutoresizingMaskIntoConstraints = false
        sendReportView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        sendReportView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sendReportView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        sendReportView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        blockUserView.translatesAutoresizingMaskIntoConstraints = false
        blockUserView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        blockUserView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        blockUserView.widthAnchor.constraint(equalTo: sendReportView.widthAnchor).isActive = true
    }
    
    private class BlockUserView : UIView {
        let iconView: UIImageView
        let blockButton: UIButton
        let cancelButton: UIButton
        let blockUserLabel: UILabel
        
        weak var delegate: ReportMessageDelegate?
        
        init() {
            iconView = UIImageView()
            blockButton = UIButton()
            blockUserLabel = UILabel.zipSubtitle()
            cancelButton = UIButton()
            
            super.init(frame: .zero)
            backgroundColor = .zipGray
            layer.masksToBounds = true
            layer.cornerRadius = 15
            blockButton.addTarget(self, action: #selector(didTapBlock), for: .touchUpInside)
            cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)

            blockButton.setTitle("Block", for: .normal)
            blockButton.backgroundColor = .zipLightGray
            blockButton.setTitleColor(.white, for: .normal)
            blockButton.titleLabel?.font = .zipSubtitle2
            
            cancelButton.setTitle("Cancel", for: .normal)
            cancelButton.setTitleColor(.white, for: .normal)
            cancelButton.titleLabel?.font = .zipSubtitle2
            
            cancelButton.addTarget(self, action: #selector(didTapBlock), for: .touchUpInside)
            cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
            
            iconView.image = UIImage(systemName: "circle.slash")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)

            addSubviews()
            configureSubviewLayout()
        }
        
        @objc private func didTapBlock() {
            delegate?.sendBlock()
            delegate?.dismissVC()
        }
        
        @objc private func didTapCancel() {
            delegate?.dismissVC()
        }
        
        public func update(user: User) {
            blockUserLabel.text = "Block " + user.fullName + "?"
        }
        
        private func addSubviews() {
            addSubview(iconView)
            addSubview(blockButton)
            addSubview(blockUserLabel)
            addSubview(cancelButton)
        }
        
        private func configureSubviewLayout() {
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            
            blockUserLabel.translatesAutoresizingMaskIntoConstraints = false
            blockUserLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            blockUserLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 10).isActive = true

            blockButton.translatesAutoresizingMaskIntoConstraints = false
            blockButton.topAnchor.constraint(equalTo: blockUserLabel.bottomAnchor, constant: 15).isActive = true
            blockButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            blockButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
            blockButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
            
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            cancelButton.topAnchor.constraint(equalTo: blockButton.bottomAnchor, constant: 5).isActive = true
            cancelButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            cancelButton.heightAnchor.constraint(equalTo: blockButton.heightAnchor).isActive = true
            cancelButton.widthAnchor.constraint(equalTo: blockButton.widthAnchor).isActive = true
            
            translatesAutoresizingMaskIntoConstraints = false
            bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor,constant: 5).isActive = true
            
            blockButton.layer.masksToBounds = true
            blockButton.layer.cornerRadius = 15
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    private class ReportMessageView : UIView, UITextViewDelegate{
        let textView: UITextView
        var context: ReportContext!
        let sendButton: UIButton
        let cancelButton: UIButton
        let contextLabel: UILabel
        
        weak var delegate: ReportMessageDelegate?
        
        
        init() {
            textView = UITextView()
            sendButton = UIButton()
            contextLabel = UILabel.zipSubtitle()
            cancelButton = UIButton()
            
            super.init(frame: .zero)
            backgroundColor = .zipLightGray
            layer.masksToBounds = true
            layer.cornerRadius = 15
            
            sendButton.setTitle("Report", for: .normal)
            sendButton.backgroundColor = .zipVeryLightGray
            sendButton.setTitleColor(.white, for: .normal)
            sendButton.titleLabel?.font = .zipSubtitle2
            
            cancelButton.setTitle("Cancel", for: .normal)
            cancelButton.setTitleColor(.white, for: .normal)
            cancelButton.titleLabel?.font = .zipSubtitle2
            
            sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
            cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)

            textView.font = .zipTextFill
            textView.layer.cornerRadius = 8
            textView.layer.masksToBounds = true
            textView.delegate = self
            textView.text = "Tell us a little about your report..."
            textView.textColor = .zipVeryLightGray
            textView.backgroundColor = .zipGray

        
            addSubviews()
            configureSubviewLayout()
        }
        
        @objc private func didTapSend() {
            delegate?.sendReport(reason: context.description + ": " + textView.text)
            delegate?.dismissVC()
        }
        
        @objc private func didTapCancel() {
            delegate?.dismissVC()
        }
        
        public func update(context: ReportContext) {
            self.context = context
            contextLabel.text = "Report: " + context.description
        }
        
        private func addSubviews() {
            addSubview(textView)
            addSubview(sendButton)
            addSubview(contextLabel)
            addSubview(cancelButton)
        }
        
        private func configureSubviewLayout() {
            contextLabel.translatesAutoresizingMaskIntoConstraints = false
            contextLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
            contextLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            textView.widthAnchor.constraint(equalTo: widthAnchor, constant: -10).isActive = true
            textView.topAnchor.constraint(equalTo: contextLabel.bottomAnchor, constant: 10).isActive = true
            textView.bottomAnchor.constraint(equalTo: sendButton.topAnchor, constant: -10).isActive = true


            sendButton.translatesAutoresizingMaskIntoConstraints = false
            sendButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -5).isActive = true
            sendButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            sendButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
            sendButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
            
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -5).isActive = true
            cancelButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            cancelButton.heightAnchor.constraint(equalTo: sendButton.heightAnchor).isActive = true
            cancelButton.widthAnchor.constraint(equalTo: sendButton.widthAnchor).isActive = true
            
            sendButton.layer.masksToBounds = true
            sendButton.layer.cornerRadius = 15
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == .zipVeryLightGray {
                textView.textColor = .white
                textView.text = ""
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = "Tell us a little about your report..."
                textView.textColor = .zipVeryLightGray
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    private class ReportOptionsMenu: UITableView, UITableViewDelegate, UITableViewDataSource {
        private let cancelButton: UIButton
        var reportOptions: ReportOptions
                
        init(reportOptions: ReportOptions) {
            self.cancelButton = UIButton()
            self.reportOptions = reportOptions
            super.init(frame: .zero, style: .plain)
            configureTable()
            backgroundColor = .zipGray
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func configureTable() {
            bounces = false
            isScrollEnabled = false
            delegate = self
            dataSource = self
            register(ReportOptionTableViewCell.self, forCellReuseIdentifier: ReportOptionTableViewCell.identifier)
            tableHeaderView = nil
            tableFooterView = nil
        }
                
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return reportOptions.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReportOptionTableViewCell.identifier) as! ReportOptionTableViewCell
            cell.configure(string: reportOptions[indexPath.row].0)
            return cell
        }
       
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            reportOptions[indexPath.row].1()
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 40
        }
        
        func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
            return 40
        }
    }
    
    internal class ReportOptionTableViewCell: UITableViewCell {
        static let identifier = "reportOption"
        
        private let optionLabel: UILabel
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.optionLabel = UILabel.zipTextFill()
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            contentView.backgroundColor = .zipGray
            clipsToBounds = true
            selectionStyle = .none
        
            contentView.addSubview(optionLabel)
            optionLabel.translatesAutoresizingMaskIntoConstraints = false
            optionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            optionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func awakeFromNib() {
            super.awakeFromNib()
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        }
        
        public func configure(string: String){
            optionLabel.text = string
        }
    }
}


extension ReportViewController: ReportMessageDelegate {
    func sendReport(reason: String) {
        user.report(reason: reason)
    }
    
    func sendBlock() {
        var blockedUsers = AppDelegate.userDefaults.value(forKey: "blockedUsers") as? [String] ?? []
        blockedUsers.append(user.userId)
        AppDelegate.userDefaults.set(blockedUsers, forKey: "blockedUsers")
    }
    
    func dismissVC() {
        slideDownAndDismiss(view: sendReportView)
    }
}
