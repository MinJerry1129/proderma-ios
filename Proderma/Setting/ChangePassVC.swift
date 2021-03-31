//
//  ChangePassVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit
import Alamofire
import JTMaterialSpinner
import Toast_Swift
class ChangePassVC: UIViewController {

    @IBOutlet weak var originalTxt: UITextField!
    @IBOutlet weak var newTxt: UITextField!
    @IBOutlet weak var confirmTxt: UITextField!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblChangePassword: UILabel!
    
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var lblChangePasswordTitle: UILabel!
    var spinnerView = JTMaterialSpinner()
    var clinicid : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        clinicid = AppDelegate.shared().currentClinicID
        setReady()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setReady(){
        lblChangePassword.isUserInteractionEnabled = true
        let gestureRecognizerw = UITapGestureRecognizer(target: self, action: #selector(onBackPage))
        lblChangePassword.addGestureRecognizer(gestureRecognizerw)
        lblChangePassword.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "changepassword", comment: "")
        lblChangePasswordTitle.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "changepassword", comment: "")
        btnChange.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "changepassword", comment: ""), for: .normal)
        
        if(UserDefaults.standard.string(forKey: "lang")! == "ar"){
            btnBack.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        }
    }
    @IBAction func onChangeBtn(_ sender: Any) {
        let origin_pass = originalTxt.text!
        let new_pass = newTxt.text!
        let confirm_pass = confirmTxt.text!
        if(origin_pass != "" && new_pass != "" && confirm_pass != ""){
            if new_pass == confirm_pass {
                self.view.addSubview(spinnerView)
                spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
                spinnerView.circleLayer.lineWidth = 2.0
                spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
                spinnerView.beginRefreshing()
                let parameters: Parameters = ["id": clinicid!,"original": origin_pass, "new": new_pass]
                AF.request(Global.baseUrl + "api/updatePassword", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
                    print(response)
                    self.spinnerView.endRefreshing()
                    if let value = response.value as? [String: AnyObject] {
                        let status = value["status"] as? String
                        if status == "ok"{
                            self.view.makeToast("Password updated")
                        }else{
                            self.view.makeToast("Original password is wrong!")
                        }
                    }
                }
            }else{
                self.view.makeToast("New passwords not matches!")
            }
        }else{
            self.view.makeToast("Input password field!")
        }
        
    }
    @objc func onBackPage(){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
