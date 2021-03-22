//
//  SettingHomeVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit

class SettingHomeVC: UIViewController {

    @IBOutlet weak var setLangBtn: UIButton!
    @IBOutlet weak var changePassBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    
    @IBOutlet weak var lblSetting: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    
    var changepassVC : ChangePassVC!
    var splashVC : SplashVC!
    var loginStatus = "no"
    override func viewDidLoad() {
        super.viewDidLoad()
        loginStatus = AppDelegate.shared().loginStatus
        
        setReady()
        // Do any additional setup after loading the view.
    }
    func setReady(){
        lblSetting.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "setting", comment: "")
        setLangBtn.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "language", comment: ""), for: .normal)
        changePassBtn.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "changepassword", comment: ""), for: .normal)
        logoutBtn.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "logout", comment: ""), for: .normal)
        
        if(UserDefaults.standard.string(forKey: "lang")! == "ar"){
            btnBack.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            
        }
        if(loginStatus == "no"){
            changePassBtn.isHidden = true
            logoutBtn.isHidden = true
        }
    }
    @IBAction func onLogoutBtn(_ sender: Any) {
        AppDelegate.shared().loginStatus = "no"
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onChangePasswordBtn(_ sender: Any) {
        self.changepassVC =     self.storyboard?.instantiateViewController(withIdentifier: "changepassVC") as? ChangePassVC
        self.changepassVC.modalPresentationStyle = .fullScreen
        self.present(self.changepassVC, animated: true, completion: nil)
    }
    @IBAction func onSetLang(_ sender: Any) {
        if(UserDefaults.standard.string(forKey: "lang")! == "ar" ){
            LocalizationSystem.sharedInstance.setLanguage(languageCode: "en")
            UserDefaults.standard.set("en", forKey: "lang")
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        }else{
            LocalizationSystem.sharedInstance.setLanguage(languageCode: "ar")
            UserDefaults.standard.set("ar", forKey: "lang")
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        
        
        self.splashVC = self.storyboard?.instantiateViewController(withIdentifier: "splashVC") as? SplashVC
        let appDlg = UIApplication.shared.delegate as? SceneDelegate
        appDlg?.window?.rootViewController = splashVC
        self.splashVC.modalPresentationStyle = .fullScreen
        self.present(self.splashVC, animated: true, completion: nil)
        
    }
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
