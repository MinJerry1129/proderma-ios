//
//  LoginVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit
import Alamofire
import Toast_Swift
import JTMaterialSpinner

class LoginVC: UIViewController {
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    var spinnerView = JTMaterialSpinner()
    var email : String!
    var password : String!
    var phoneToken : String!
    
    var homeVC : HomeVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneToken = AppDelegate.shared().fcmtoken
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        email = emailTxt.text!
        password = passwordTxt.text!
        if(email != "" && password != ""){
            self.view.addSubview(spinnerView)
            spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
            spinnerView.circleLayer.lineWidth = 2.0
            spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
            spinnerView.beginRefreshing()
            let parameters: Parameters = ["email": email!,"password": password!, "phonetoken": phoneToken!]
            AF.request(Global.baseUrl + "api/login", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
                print(response)
                self.spinnerView.endRefreshing()
                if let value = response.value as? [String: AnyObject] {
                    let status = value["clinic_id"] as? String
                    if status == "nouser"{
                        self.view.makeToast("Input correct email")
                    }else if status == "wrongpassword"{
                        self.view.makeToast("Input correct password")
                    }else if status == "deleted"{
                        self.view.makeToast("Your account is deleted")
                    }else if status == "waiting"{
                        self.view.makeToast("Your account is not allowed")
                    }else{
                        let clinicInfo = value["clinic_id"] as? [String: AnyObject]
                        let clinic_id = clinicInfo!["id"] as! String
                        let type = clinicInfo!["type"] as! String
                        AppDelegate.shared().currentClinicID = clinic_id
                        AppDelegate.shared().userType = type
                        AppDelegate.shared().loginStatus = "yes"
                        self.homeVC = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as? HomeVC
                        self.homeVC.modalPresentationStyle = .fullScreen
                        self.present(self.homeVC, animated: true, completion: nil)                        
                    }
                }
            }
        }else{
            self.view.makeToast("Input email && password")
        }
    }
    
    @IBAction func onGoLogHomeBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
