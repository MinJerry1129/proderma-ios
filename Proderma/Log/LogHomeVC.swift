//
//  LogHomeVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit

class LogHomeVC: UIViewController {
    var loginVC : LoginVC!
    var signupVC : SignupVC!
    
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSingup: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setReady()
        
    }
    func setReady(){
        btnLogin.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "login", comment: ""), for: .normal)
        btnSingup.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "signup", comment: ""), for: .normal)
        if(UserDefaults.standard.string(forKey: "lang")! == "ar"){
            btnBack.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        }
    }
    @IBAction func onSignupBtn(_ sender: Any) {
        self.signupVC = self.storyboard?.instantiateViewController(withIdentifier: "signupVC") as? SignupVC
        self.signupVC.modalPresentationStyle = .fullScreen
        self.present(self.signupVC, animated: true, completion: nil)
    }
    
    @IBAction func onLoginBtn(_ sender: Any) {
        self.loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as? LoginVC
        self.loginVC.modalPresentationStyle = .fullScreen
        self.present(self.loginVC, animated: true, completion: nil)
    }
    
    @IBAction func onGoHome(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
