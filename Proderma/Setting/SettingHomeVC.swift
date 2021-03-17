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
    
    var changepassVC : ChangePassVC!
    var loginStatus = "no"
    override func viewDidLoad() {
        super.viewDidLoad()
        loginStatus = AppDelegate.shared().loginStatus
        
        setReady()
        // Do any additional setup after loading the view.
    }
    
    func setReady(){
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
        
    }
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
