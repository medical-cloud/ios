//
//  HCEditProfile.swift
//  Nextcloud iOS
//
//  Created by Marino Faggiana on 17/04/19.
//  Copyright (c) 2019 Marino Faggiana. All rights reserved.
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

class HCEditProfile: XLFormViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var backButton : UIBarButtonItem!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
        
    func initializeForm() {
        
        let form : XLFormDescriptor = XLFormDescriptor() as XLFormDescriptor
        form.rowNavigationOptions = XLFormRowNavigationOptions.stopDisableRow
        
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor

        let tableAccount = NCManageDatabase.sharedInstance.getAccountActive()
        
        section = XLFormSectionDescriptor.formSection()
        form.addFormSection(section)
        
        row = XLFormRowDescriptor(tag: "userfullname", rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("_user_full_name_", comment: ""))
        row.cellConfig["textLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textField.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textField.textAlignment"] = NSTextAlignment.right.rawValue
        row.cellConfig["imageView.image"] = CCGraphics.changeThemingColorImage(UIImage.init(named: "user"), width: 50, height: 50, color: NCBrandColor.sharedInstance.icon)
        row.value = tableAccount?.displayName
        if row.value == nil { row.value = "" }
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: "useraddress", rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("_user_address_", comment: ""))
        row.cellConfig["textLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textField.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textField.textAlignment"] = NSTextAlignment.right.rawValue
        row.cellConfig["imageView.image"] = CCGraphics.changeThemingColorImage(UIImage.init(named: "address"), width: 50, height: 50, color: NCBrandColor.sharedInstance.icon)
        row.value = tableAccount?.address
        if row.value == nil { row.value = "" }
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "usercity", rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("_user_city_", comment: ""))
        row.cellConfig["textLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textField.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textField.textAlignment"] = NSTextAlignment.right.rawValue
        row.cellConfig["imageView.image"] = CCGraphics.changeThemingColorImage(UIImage.init(named: "city"), width: 50, height: 50, color: NCBrandColor.sharedInstance.icon)
        row.value = tableAccount?.city
        if row.value == nil { row.value = "" }
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "userzip", rowType: XLFormRowDescriptorTypeZipCode, title: NSLocalizedString("_user_zip_", comment: ""))
        row.cellConfig["textLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textField.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textField.textAlignment"] = NSTextAlignment.right.rawValue
        row.cellConfig["imageView.image"] = CCGraphics.changeThemingColorImage(UIImage.init(named: "cityzip"), width: 50, height: 50, color: NCBrandColor.sharedInstance.icon)
        row.value = tableAccount?.zip
        if row.value == nil { row.value = "" }
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "usercountry", rowType: XLFormRowDescriptorTypeSelectorPickerView, title: NSLocalizedString("_user_country_", comment: ""))
        row.cellConfig["textLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["detailTextLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["imageView.image"] = CCGraphics.changeThemingColorImage(UIImage.init(named: "country"), width: 50, height: 50, color: NCBrandColor.sharedInstance.icon)
        var locales = [String]()
        for localeCode in NSLocale.isoCountryCodes {
            let countryName = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: localeCode) ?? ""
            if localeCode == tableAccount?.country {
                row.value = countryName
            }
            locales.append(countryName)
        }
        row.selectorOptions = locales.sorted()
        if row.value == nil { row.value = "" }
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "userphone", rowType: XLFormRowDescriptorTypePhone, title: NSLocalizedString("_user_phone_", comment: ""))
        row.cellConfig["textLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textField.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textField.textAlignment"] = NSTextAlignment.right.rawValue
        row.cellConfig["imageView.image"] = CCGraphics.changeThemingColorImage(UIImage.init(named: "phone"), width: 50, height: 50, color: NCBrandColor.sharedInstance.icon)
        row.value = tableAccount?.phone
        if row.value == nil { row.value = "" }
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "useremail", rowType: XLFormRowDescriptorTypeEmail, title: NSLocalizedString("_user_email_", comment: ""))
        row.cellConfig["textLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textField.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textField.textAlignment"] = NSTextAlignment.right.rawValue
        row.cellConfig["imageView.image"] = CCGraphics.changeThemingColorImage(UIImage.init(named: "email"), width: 50, height: 50, color: NCBrandColor.sharedInstance.icon)
        row.value = tableAccount?.email
        if row.value == nil { row.value = "" }
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "userweb", rowType: XLFormRowDescriptorTypeEmail, title: NSLocalizedString("_user_web_", comment: ""))
        row.cellConfig["textLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textField.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textField.textAlignment"] = NSTextAlignment.right.rawValue
        row.cellConfig["imageView.image"] = CCGraphics.changeThemingColorImage(UIImage.init(named: "web"), width: 50, height: 50, color: NCBrandColor.sharedInstance.icon)
        row.value = tableAccount?.webpage
        if row.value == nil { row.value = "" }
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "usertwitter", rowType: XLFormRowDescriptorTypeTwitter, title: NSLocalizedString("_user_twitter_", comment: ""))
        row.cellConfig["textLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textField.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textField.textAlignment"] = NSTextAlignment.right.rawValue
        row.cellConfig["imageView.image"] = CCGraphics.changeThemingColorImage(UIImage.init(named: "twitter"), width: 50, height: 50, color: NCBrandColor.sharedInstance.icon)
        row.value = tableAccount?.twitter
        if row.value == nil { row.value = "" }
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "userbusinesstype", rowType: XLFormRowDescriptorTypeMultipleSelector, title: NSLocalizedString("_user_businesstype_", comment: ""))
        row.cellConfig["textLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["detailTextLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["imageView.image"] = CCGraphics.changeThemingColorImage(UIImage.init(named: "businesstype"), width: 50, height: 50, color: NCBrandColor.sharedInstance.icon)
        row.selectorOptions = ["ARCHITECT","BRICKLAYER","CARPENTER","ELECTRICIAN","INSTALLER","PAINTER","PLUMBER","ROOFER","STOVEBUILDER","STUCCOER","WINDOWBUILDER","OTHER"]
        row.value = tableAccount?.businessType.components(separatedBy: ",")
        if row.value == nil { row.value = "" }
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "userbusinesssize", rowType: XLFormRowDescriptorTypeSelectorPickerView, title: NSLocalizedString("_user_businesssize_", comment: ""))
        row.cellConfig["textLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["detailTextLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["imageView.image"] = CCGraphics.changeThemingColorImage(UIImage.init(named: "users"), width: 50, height: 50, color: NCBrandColor.sharedInstance.icon)
        row.selectorOptions = ["1-4","5-9","10-19","20-49","50-99","100-249","250-499","500-999","1000+"];
        switch tableAccount?.businessSize {
        case 1: row.value = "1-4"
        case 5: row.value = "5-9"
        case 10: row.value = "10-19"
        case 20: row.value = "20-49"
        case 50: row.value = "50-99"
        case 100: row.value = "100-249"
        case 250: row.value = "250-499"
        case 500: row.value = "500-999"
        case 1000: row.value = "1000+"
        default: row.value = ""
        }
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "userrole", rowType: XLFormRowDescriptorTypeSelectorPickerView, title: NSLocalizedString("_user_role_", comment: ""))
        row.cellConfig["textLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["detailTextLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["imageView.image"] = CCGraphics.changeThemingColorImage(UIImage.init(named: "role"), width: 50, height: 50, color: NCBrandColor.sharedInstance.icon)
        row.selectorOptions = [NSLocalizedString("_user_owner_", comment: ""),NSLocalizedString("_user_employee_", comment: ""),NSLocalizedString("_user_contractor_", comment: "")];
        if tableAccount?.role == "owner" { row.value = NSLocalizedString("_user_owner_", comment: "") }
        else if tableAccount?.role == "employee" { row.value = NSLocalizedString("_user_employee_", comment: "") }
        else if tableAccount?.role == "contractor" { row.value = NSLocalizedString("_user_contractor_", comment: "") }
        else { row.value = "" }
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "usercompany", rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("_user_company_", comment: ""))
        row.cellConfig["textLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textField.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textField.textAlignment"] = NSTextAlignment.right.rawValue
        row.cellConfig["imageView.image"] = CCGraphics.changeThemingColorImage(UIImage.init(named: "company"), width: 50, height: 50, color: NCBrandColor.sharedInstance.icon)
        row.value = tableAccount?.company
        if row.value == nil { row.value = "" }
        section.addFormRow(row)
        
        self.form = form
    }
    
    override func formRowDescriptorValueHasChanged(_ formRow: XLFormRowDescriptor!, oldValue: Any!, newValue: Any!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("_user_editprofile_", comment: "")

        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = NCBrandColor.sharedInstance.brand
        self.navigationController?.navigationBar.tintColor = NCBrandColor.sharedInstance.brandText
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: NCBrandColor.sharedInstance.brandText]
        
        // Replace the default back button
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.backButton = UIBarButtonItem(title: NSLocalizedString("_manage_account_", comment: ""), style: UIBarButtonItem.Style.plain, target: self, action: #selector(goBack))
        self.navigationItem.leftBarButtonItem = backButton
        
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    
        initializeForm()
    }
    
    @objc func goBack() {
        
        NCUtility.sharedInstance.startActivityIndicator(view: self.view, bottom: 0)
        
        let displayname = self.form.formRow(withTag: "userfullname")!.value as! String
        let address = self.form.formRow(withTag: "useraddress")!.value as! String
        let city = self.form.formRow(withTag: "usercity")!.value as! String
        let zip = self.form.formRow(withTag: "userzip")!.value as! String
        
        var country = ""
        let countryNameRow = self.form.formRow(withTag: "usercountry")!.value as? String
        for localeCode in NSLocale.isoCountryCodes {
            let countryName = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: localeCode) ?? ""
            if countryNameRow == countryName {
                country = localeCode
                break
            }
        }
        let phone = self.form.formRow(withTag: "userphone")!.value as! String
        let email = self.form.formRow(withTag: "useremail")!.value as! String
        let website = self.form.formRow(withTag: "userweb")!.value as! String
        let twitter = self.form.formRow(withTag: "usertwitter")!.value as! String
        let company = self.form.formRow(withTag: "usercompany")!.value as! String
        
        var businesssize = "1"
        let businesssizeRow = self.form.formRow(withTag: "userbusinesssize")!.value as! String
        switch businesssizeRow {
        case "1-4": businesssize = "1"
        case "5-9": businesssize = "5"
        case "10-19": businesssize = "10"
        case "20-49": businesssize = "20"
        case "50-99": businesssize = "50"
        case "100-249": businesssize = "100"
        case "250-499": businesssize = "250"
        case "500-999": businesssize = "500"
        case "1000+": businesssize = "1000"
        default: break
        }
        
        var role_ = "contractor"
        let roleRow = self.form.formRow(withTag: "userrole")!.value as! String
        switch roleRow {
        case NSLocalizedString("_user_owner_", comment: ""): role_ = "owner"
        case NSLocalizedString("_user_employee_", comment: ""): businesssize = "employee"
        case NSLocalizedString("_user_contractor_", comment: ""): businesssize = "contractor"
        default: break
        }
        
        let businesstypeArray = self.form.formRow(withTag: "userbusinesstype")!.value
        let businesstype =  (businesstypeArray as! [String]).joined(separator: ",")
        
        OCNetworking.sharedManager()?.putHCUserProfile(withAccount: appDelegate.activeAccount, serverUrl: appDelegate.activeUrl, address: address, businesssize: businesssize, businesstype: businesstype, city: city, company: company, country: country, displayname: displayname, email: email, phone: phone, role_: role_, twitter: twitter, website: website, zip: zip, completion: { (account, message, errorCode) in
            if errorCode == 0 && account == self.appDelegate.activeAccount {
                self.navigationController?.popViewController(animated: true)
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            } else if errorCode != 0 {
                self.appDelegate.messageNotification("_error_", description: message, visible: true, delay: TimeInterval(k_dismissAfterSecond), type: TWMessageBarMessageType.error, errorCode: errorCode)
            }
            NCUtility.sharedInstance.stopActivityIndicator()
        })
    }
}
