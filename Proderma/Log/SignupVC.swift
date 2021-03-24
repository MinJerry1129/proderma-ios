//
//  SignupVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit
import Alamofire
import JTMaterialSpinner
import Toast_Swift
import SimpleCheckbox
class SignupVC: UIViewController {

    @IBOutlet weak var btnAlready: UIButton!
    @IBOutlet weak var lblAreElite: UILabel!
    @IBOutlet weak var lblSignupTitle: UILabel!
    @IBOutlet weak var lblSingup: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var clinicNameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var phoneTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var typeCBox: Checkbox!
    var spinnerView = JTMaterialSpinner()
    var signupclinicVC : SignupClinicVC!
    var firstname = ""
    var lastname = ""
    var clinicname = ""
    var email = ""
    var mobile = ""
    var password = ""
    
    var clinic_type = "normal"
    override func viewDidLoad() {
        super.viewDidLoad()
        setReady()
        typeCBox.addTarget(self, action: #selector(checkboxValueChanged(sender:)), for: .valueChanged)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setReady(){
        signupBtn.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "signup", comment: ""), for: .normal)
        btnAlready.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "alreadyaccount", comment: ""), for: .normal)
        lblAreElite.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "eliteclinic", comment: "")
        lblSingup.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "signup", comment: "")
        lblSignupTitle.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "signup", comment: "")
        if(UserDefaults.standard.string(forKey: "lang")! == "ar"){
            btnBack.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        }
    }
    @objc func checkboxValueChanged(sender: Checkbox) {
        print("checkbox value change: \(sender.isChecked)")
        if sender.isChecked {
            clinic_type = "elite"
            signupBtn.setTitle("Next", for: .normal)
        }else{
            clinic_type = "normal"
            signupBtn.setTitle("Sign Up", for: .normal)
        }
    }
    
    @IBAction func onSignupBtn(_ sender: Any) {
        
        firstname = firstNameTxt.text!
        lastname = lastNameTxt.text!
        clinicname = clinicNameTxt.text!
        email = emailTxt.text!
        mobile = phoneTxt.text!
        password = passwordTxt.text!
        
        if(firstname != "" && lastname != "" && clinicname != "" && email != "" && mobile != "" && password != ""){
            if clinic_type == "normal"{
                onNormalSignup()
            }else{
                onElitePage()
            }
        }else{
            self.view.makeToast("Fill the empty field")
        }
       
    }
    func onNormalSignup(){
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["firstname": firstname,"secondname": lastname, "clinicname": clinicname, "email": email, "phone": mobile, "password": password]
        AF.request(Global.baseUrl + "api/signup_normal", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let status = value["status"] as? String
                if status == "ok"{
                    self.view.makeToast("Signup Success, Please wait accept or contact to support team")
                }else if status == "existemail"{
                    self.view.makeToast("Your account already exist, Please contact to support team")
                }else {
                    self.view.makeToast("Fail signup")
                }
            }
        }
    }
    func onElitePage(){
        AppDelegate.shared().sign_firstname = firstname
        AppDelegate.shared().sign_lastname = lastname
        AppDelegate.shared().sign_clinicname = clinicname
        AppDelegate.shared().sign_email = email
        AppDelegate.shared().sign_phone = mobile
        AppDelegate.shared().sign_password = password
        
        self.signupclinicVC = self.storyboard?.instantiateViewController(withIdentifier: "signupclinicVC") as? SignupClinicVC
        self.signupclinicVC.modalPresentationStyle = .fullScreen
        self.present(self.signupclinicVC, animated: true, completion: nil)
    }
    
    @IBAction func onGoLogHomeBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
