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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
