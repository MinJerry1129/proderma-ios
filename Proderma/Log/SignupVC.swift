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
    var homeVC : HomeVC!
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
        lblSingup.isUserInteractionEnabled = true
        let gestureRecognizerw = UITapGestureRecognizer(target: self, action: #selector(onBackPage))
        lblSingup.addGestureRecognizer(gestureRecognizerw)
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
        if !validatedata(){
            return
        }
        
        if clinic_type == "normal"{
            onNormalSignup()
        }else{
            onElitePage()
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
                    let alert = UIAlertController(title: "Signup Result", message: "Signup success, Please wait accept or contact to support team", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "O K", style: .default, handler: { _ in
                                self.onHomePage()
                            }))
                            self.present(alert, animated: true, completion: nil)
                }else if status == "existemail"{
                    self.view.makeToast("Your account already exist, Please contact to support team")
                }else {
                    self.view.makeToast("Fail signup")
                }
            }
        }
    }
    func onHomePage(){
        self.homeVC = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as? HomeVC
        self.homeVC.modalPresentationStyle = .fullScreen
        self.present(self.homeVC, animated: true, completion: nil)
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
    func validatedata() -> Bool {
        if firstname == ""{
            self.view.makeToast("Input First name")
            return false
        }
        if lastname == ""{
            self.view.makeToast("Input Last name")
            return false
        }
        if clinicname == ""{
            self.view.makeToast("Input Clinic name")
            return false
        }
        if email == ""{
            self.view.makeToast("Input Email Address")
            return false
        }else{
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            if !emailPred.evaluate(with: email){
                self.view.makeToast("Input correct email address")
                return false
            }
        }
        
        if mobile == ""{
            self.view.makeToast("Input Phone number")
            return false
        }else{
            let phoneRegEx = "[+]+[0-9]{10,17}"
            let phonePred = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
            if !phonePred.evaluate(with: mobile){
                self.view.makeToast("Input correct phonenumber")
                return false
            }
        }
        if password == ""{
            self.view.makeToast("Input password")
            return false
        }else{
            if password.count < 6{
                self.view.makeToast("Input password more than 6 characters")
                return false
            }
        }
        return true
    }
    
    @IBAction func onGoLogHomeBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func onBackPage(){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
