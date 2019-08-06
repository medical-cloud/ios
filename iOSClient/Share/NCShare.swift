//
//  NCShare.swift
//  Nextcloud
//
//  Created by Marino Faggiana on 17/07/2019.
//  Copyright © 2019 Marino Faggiana. All rights reserved.
//
//  Author Marino Faggiana <marino.faggiana@nextcloud.com>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import Parchment
import DropDown

class NCShare: UIViewController, UIGestureRecognizerDelegate, NCShareLinkCellDelegate, NCShareUserCellDelegate, NCShareNetworkingDelegate {
   
    @IBOutlet weak var viewContainerConstraint: NSLayoutConstraint!
    @IBOutlet weak var sharedWithYouByView: UIView!
    @IBOutlet weak var sharedWithYouByImage: UIImageView!
    @IBOutlet weak var sharedWithYouByLabel: UILabel!
    @IBOutlet weak var searchFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var shareLinkImage: UIImageView!
    @IBOutlet weak var shareLinkLabel: UILabel!
    @IBOutlet weak var buttonCopy: UIButton!
    @IBOutlet weak var buttonMenu: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var metadata: tableMetadata?
    public var height: CGFloat = 0
    private var shareLinkMenuView: NCShareLinkMenuView?
    private var shareUserMenuView: NCShareUserMenuView?
    private var shareMenuViewWindow: UIView?
    private var dropDown = DropDown()
    private var networking: NCShareNetworking?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewContainerConstraint.constant = height
        searchFieldTopConstraint.constant = 10
        
        searchField.placeholder = NSLocalizedString("_shareLinksearch_placeholder_", comment: "")
        
        shareLinkLabel.text = NSLocalizedString("_share_link_", comment: "")
        shareLinkImage.image = NCShareCommon.sharedInstance.createLinkAvatar()
        buttonCopy.setImage(CCGraphics.changeThemingColorImage(UIImage.init(named: "shareCopy"), width: 100, height: 100, color: UIColor.gray), for: .normal)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        
        tableView.register(UINib.init(nibName: "NCShareLinkCell", bundle: nil), forCellReuseIdentifier: "cellLink")
        tableView.register(UINib.init(nibName: "NCShareUserCell", bundle: nil), forCellReuseIdentifier: "cellUser")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData), name: NSNotification.Name(rawValue: "reloadDataNCShare"), object: nil)
        
        reloadData()
        
        networking = NCShareNetworking.init(metadata: metadata!, activeUrl: appDelegate.activeUrl, view: nil, delegate: self)
        networking?.readShare()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        shareLinkMenuView?.unLoad()
        shareLinkMenuView = nil
        shareUserMenuView?.unLoad()
        shareUserMenuView = nil
        dropDown.hide()
    }
    
    @objc func reloadData() {
        let shares = NCManageDatabase.sharedInstance.getTableShares(metadata: metadata!)
        if shares.firstShareLink == nil {
            buttonMenu.setImage(CCGraphics.changeThemingColorImage(UIImage.init(named: "shareAdd"), width: 100, height: 100, color: UIColor.gray), for: .normal)
            buttonCopy.isHidden = true
        } else {
            buttonMenu.setImage(CCGraphics.changeThemingColorImage(UIImage.init(named: "shareMenu"), width: 100, height: 100, color: UIColor.gray), for: .normal)
            buttonCopy.isHidden = false
        }
        tableView.reloadData()
    }
    
    // MARK: - IBAction

    @IBAction func searchFieldDidEndOnExit(textField: UITextField) {
        
        guard let searchString = textField.text else { return }

        networking?.getUserAndGroup(searchString: searchString)
    }
    
    @IBAction func touchUpInsideButtonCopy(_ sender: Any) {
        
        guard let metadata = self.metadata else { return }

        let shares = NCManageDatabase.sharedInstance.getTableShares(metadata: metadata)
        tapCopy(with: shares.firstShareLink, sender: sender)
    }
    
    @IBAction func touchUpInsideButtonMenu(_ sender: Any) {

        guard let metadata = self.metadata else { return }

        let shares = NCManageDatabase.sharedInstance.getTableShares(metadata: metadata)
        if shares.firstShareLink != nil {
            tapMenu(with: shares.firstShareLink!, sender: sender)
        } else {
            networking?.share(password: "", permission: 1, hideDownload: false)
        }
    }
    
    @objc func tapLinkMenuViewWindow(gesture: UITapGestureRecognizer) {
        shareLinkMenuView?.unLoad()
        shareLinkMenuView = nil
        shareUserMenuView?.unLoad()
        shareUserMenuView = nil
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return gestureRecognizer.view == touch.view
    }
    
    func tapCopy(with tableShare: tableShare?, sender: Any) {
        NCShareCommon.sharedInstance.copyLink(tableShare: tableShare, viewController: self)
    }
    
    func switchCanEdit(with tableShare: tableShare?, switch: Bool, sender: UISwitch) {
        
        guard let tableShare = tableShare else { return }
        guard let metadata = self.metadata else { return }

        let canShare = UtilsFramework.isPermission(toCanShare: tableShare.permissions)
        var permission: Int = 0
        
        if sender.isOn {
            permission = UtilsFramework.getPermissionsValue(byCanEdit: true, andCanCreate: true, andCanChange: true, andCanDelete: true, andCanShare: canShare, andIsFolder: metadata.directory)
        } else {
            permission = UtilsFramework.getPermissionsValue(byCanEdit: false, andCanCreate: false, andCanChange: false, andCanDelete: false, andCanShare: canShare, andIsFolder: metadata.directory)
        }
        
        networking?.updateShare(idRemoteShared: tableShare.idRemoteShared, password: nil, permission: permission, note: nil, expirationTime: nil, hideDownload: tableShare.hideDownload)
    }
    
    func tapMenu(with tableShare: tableShare?, sender: Any) {
        
        guard let tableShare = tableShare else { return }

        if tableShare.shareType == Int(shareTypeLink.rawValue) {
            let views = NCShareCommon.sharedInstance.openViewMenuShareLink(shareViewController: self, tableShare: tableShare, metadata: metadata!)
            shareLinkMenuView = views.shareLinkMenuView
            shareMenuViewWindow = views.viewWindow
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapLinkMenuViewWindow))
            tap.delegate = self
            shareMenuViewWindow?.addGestureRecognizer(tap)
        } else {
            let views = NCShareCommon.sharedInstance.openViewMenuUser(shareViewController: self, tableShare: tableShare, metadata: metadata!)
            shareUserMenuView = views.shareUserMenuView
            shareMenuViewWindow = views.viewWindow
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapLinkMenuViewWindow))
            tap.delegate = self
            shareMenuViewWindow?.addGestureRecognizer(tap)
        }
    }
    
    /// MARK: - NCShareNetworkingDelegate
    
    func readShareCompleted() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadDataNCShare"), object: nil, userInfo: nil)
    }
    
    func shareCompleted() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadDataNCShare"), object: nil, userInfo: nil)
    }
    
    func unShareCompleted() { }
    
    func updateShareWithError(idRemoteShared: Int) { }
    
    func getUserAndGroup(items: [OCShareUser]?) {
        
        guard let items = items else { return }

        dropDown = DropDown()
        let appearance = DropDown.appearance()
        
        appearance.backgroundColor = .white
        appearance.cornerRadius = 10
        appearance.shadowColor = UIColor(white: 0.5, alpha: 1)
        appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 25
        appearance.animationduration = 0.25
        appearance.textColor = .darkGray
        
        if #available(iOS 11.0, *) {
            appearance.setupMaskedCorners([.layerMaxXMaxYCorner, .layerMinXMaxYCorner])
        }
        
        for item in items {
            if item.displayName != nil && item.displayName != "" {
                dropDown.dataSource.append(item.displayName)
            } else {
                dropDown.dataSource.append(item.name)
            }
        }
        
        dropDown.anchorView = searchField
        dropDown.bottomOffset = CGPoint(x: 0, y: searchField.bounds.height)
        dropDown.width = searchField.bounds.width
        
        dropDown.cellNib = UINib(nibName: "NCShareUserDropDownCell", bundle: nil)
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? NCShareUserDropDownCell else { return }
            cell.imageItem.image = UIImage(named: "avatar")
            let item = items[index]
            NCShareCommon.sharedInstance.downloadAvatar(user: item.name, cell: cell)
            if item.shareeType == 0 { cell.imageShareeType.image = UIImage(named: "shareTypeUser")}     // shareTypeUser
            if item.shareeType == 1 { cell.imageShareeType.image = UIImage(named: "shareTypeGroup")}    // shareTypeGroup
            if item.shareeType == 3 { cell.imageShareeType.image = UIImage(named: "shareTypeLink")}     // shareTypeLink
            if item.shareeType == 4 { cell.imageShareeType.image = UIImage(named: "shareTypeEmail")}    // shareTypeEmail
            if item.shareeType == 5 { cell.imageShareeType.image = UIImage(named: "shareTypeUser")}     // shareTypeContact
            if item.shareeType == 6 { cell.imageShareeType.image = UIImage(named: "shareTypeLink")}     // shareTypeRemote
        }
        
        dropDown.selectionAction = { [weak self] (index, item) in
            let item = items[index]
            self!.networking?.shareUserAndGroup(name: item.name, shareeType: item.shareeType, metadata: self!.metadata!)
        }
        
        dropDown.show()
    }
}

// MARK: - UITableViewDelegate

extension NCShare: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - UITableViewDataSource

extension NCShare: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numOfRows = 0
        let shares = NCManageDatabase.sharedInstance.getTableShares(metadata: metadata!)
        
        if shares.share != nil {
            numOfRows = shares.share!.count
        }
        
        return numOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let shares = NCManageDatabase.sharedInstance.getTableShares(metadata: metadata!)
        let tableShare = shares.share![indexPath.row]
        
        // LINK
        if tableShare.shareType == Int(shareTypeLink.rawValue) {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "cellLink", for: indexPath) as? NCShareLinkCell {
                cell.tableShare = tableShare
                cell.delegate = self
                return cell
            }
        } else {
        // USER
            if let cell = tableView.dequeueReusableCell(withIdentifier: "cellUser", for: indexPath) as? NCShareUserCell {
                
                cell.tableShare = tableShare
                cell.delegate = self
                cell.labelTitle.text = tableShare.shareWith
                cell.isUserInteractionEnabled = true
                cell.switchCanEdit.isHidden = false
                cell.labelCanEdit.isHidden = false
                cell.buttonMenu.isHidden = false
                
                NCShareCommon.sharedInstance.downloadAvatar(user: tableShare.shareWith, cell: cell)
                if UtilsFramework.isAnyPermission(toEdit: tableShare.permissions) {
                    cell.switchCanEdit.setOn(true, animated: false)
                } else {
                    cell.switchCanEdit.setOn(false, animated: false)
                }
                
                // If the initiator or the recipient is not the current user, show the list of sharees without any options to edit it.
                if tableShare.uidOwner != self.appDelegate.activeUserID && tableShare.uidFileOwner != self.appDelegate.activeUserID {
                    cell.isUserInteractionEnabled = false
                    cell.switchCanEdit.isHidden = true
                    cell.labelCanEdit.isHidden = true
                    cell.buttonMenu.isHidden = true
                }
                
                // Shared with you by ...
                if tableShare.uidFileOwner != self.appDelegate.activeUserID {
                    
                    searchFieldTopConstraint.constant = 65
                    sharedWithYouByView.isHidden = false
                    sharedWithYouByLabel.text = NSLocalizedString("_shared_with_you_by_", comment: "") + " " + tableShare.displayNameFileOwner
                    
                    let fileNameLocalPath = CCUtility.getDirectoryUserData() + "/" + CCUtility.getStringUser(appDelegate.activeUser, activeUrl: appDelegate.activeUrl) + "-" + tableShare.displayNameFileOwner + ".png"
                    if FileManager.default.fileExists(atPath: fileNameLocalPath) {
                        if let image = UIImage(contentsOfFile: fileNameLocalPath) {
                            sharedWithYouByImage.image = image
                        }
                    } else {
                        let url = appDelegate.activeUrl + k_avatar + tableShare.displayNameFileOwner + "/128"
                        let encodedString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        OCNetworking.sharedManager()?.downloadContents(ofUrl: encodedString, completion: { (data, message, errorCode) in
                            if errorCode == 0 && UIImage(data: data!) != nil {
                                do {
                                    try data!.write(to: NSURL(fileURLWithPath: fileNameLocalPath) as URL, options: .atomic)
                                } catch { return }
                                self.sharedWithYouByImage.image = UIImage(data: data!)
                            } else {
                                self.sharedWithYouByImage.image = UIImage(named: "avatar")
                            }
                        })
                    }
                }
                return cell
            }
        }
        
        return UITableViewCell()
    }
}

// MARK: - NCShareLinkCell

class NCShareLinkCell: UITableViewCell {
    
    @IBOutlet weak var imageItem: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var buttonCopy: UIButton!
    @IBOutlet weak var buttonMenu: UIButton!
    
    private let iconShare: CGFloat = 200
    
    var tableShare: tableShare?
    var delegate: NCShareLinkCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageItem.image = NCShareCommon.sharedInstance.createLinkAvatar()
        labelTitle.text = NSLocalizedString("_share_link_", comment: "")
        buttonCopy.setImage(CCGraphics.changeThemingColorImage(UIImage.init(named: "shareCopy"), width:100, height: 100, color: UIColor.gray), for: .normal)
        buttonMenu.setImage(CCGraphics.changeThemingColorImage(UIImage.init(named: "shareMenu"), width:100, height: 100, color: UIColor.gray), for: .normal)
    }
    
    @IBAction func touchUpInsideCopy(_ sender: Any) {
        delegate?.tapCopy(with: tableShare, sender: sender)
    }
    
    @IBAction func touchUpInsideMenu(_ sender: Any) {
        delegate?.tapMenu(with: tableShare, sender: sender)
    }
}

protocol NCShareLinkCellDelegate {
    func tapCopy(with tableShare: tableShare?, sender: Any)
    func tapMenu(with tableShare: tableShare?, sender: Any)
}

// MARK: - NCShareUserCell

class NCShareUserCell: UITableViewCell {
    
    @IBOutlet weak var imageItem: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelCanEdit: UILabel!
    @IBOutlet weak var switchCanEdit: UISwitch!
    @IBOutlet weak var buttonMenu: UIButton!
    
    var tableShare: tableShare?
    var delegate: NCShareUserCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        switchCanEdit.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        switchCanEdit.onTintColor = NCBrandColor.sharedInstance.brand
        labelCanEdit.text = NSLocalizedString("_share_permission_edit_", comment: "")
        buttonMenu.setImage(CCGraphics.changeThemingColorImage(UIImage.init(named: "shareMenu"), width:100, height: 100, color: UIColor.gray), for: .normal)
    }
    
    @IBAction func switchCanEditChanged(sender: UISwitch) {
        delegate?.switchCanEdit(with: tableShare, switch: sender.isOn, sender: sender)
    }
    
    @IBAction func touchUpInsideMenu(_ sender: Any) {
        delegate?.tapMenu(with: tableShare, sender: sender)
    }
}

protocol NCShareUserCellDelegate {
    func switchCanEdit(with tableShare: tableShare?, switch: Bool, sender: UISwitch)
    func tapMenu(with tableShare: tableShare?, sender: Any)
}

class NCShareUserDropDownCell: DropDownCell {
    
    @IBOutlet weak var imageItem: UIImageView!
    @IBOutlet weak var imageShareeType: UIImageView!
}
