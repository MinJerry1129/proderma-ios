//
//  ClinicNormalVC.swift
//  Proderma
//
//  Created by bird on 3/21/21.
//

import UIKit
import Alamofire
import JTMaterialSpinner
import Toast_Swift
class ClinicNormalVC: UIViewController {
  
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtClinicname: UITextField!
    @IBOutlet weak var txtLastname: UITextField!
    @IBOutlet weak var txtFirstname: UITextField!
    var spinnerView = JTMaterialSpinner()
    var firstname: String!
    var lastname : String!
    var clinicname : String!
    var phone : String!
    var clinicID : String!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var lblClinic: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        clinicID = AppDelegate.shared().currentClinicID
        getData()
        setReady()
    }
    func setReady(){
        lblClinic.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "clinic", comment: "")
        btnUpdate.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "changepassword", comment: ""), for: .normal)
        
        if(UserDefaults.standard.string(forKey: "lang")! == "ar"){
            btnBack.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        }
    }
    func getData(){
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["id": clinicID!]
        AF.request(Global.baseUrl + "api/getOneClinicInfo", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let clinicInfo = value["clinicInfo"] as? [String: AnyObject]
                
                self.firstname = clinicInfo!["firstname"] as? String
                self.lastname = clinicInfo!["secondname"] as? String
                self.clinicname = clinicInfo!["clinicname"] as? String
                self.phone = clinicInfo!["mobile"] as? String
                self.setData()
            }
        }
    }
    func setData(){
        txtFirstname.text = firstname
        txtLastname.text = lastname
        txtClinicname.text = clinicname
        txtPhone.text = phone
    }
    
    
    @IBAction func onUpdateInfo(_ sender: Any) {
        firstname = txtFirstname.text!
        lastname = txtLastname.text!
        clinicname = txtClinicname.text!
        phone = txtPhone.text!
        if(firstname != "" && lastname != "" && clinicname != "" && phone != ""){
            self.view.addSubview(spinnerView)
            spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
            spinnerView.circleLayer.lineWidth = 2.0
            spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
            spinnerView.beginRefreshing()
            let parameters: Parameters = ["id": clinicID!, "firstname": firstname!, "secondname": lastname!, "clinicname": clinicname!, "phone": phone!]
            AF.request(Global.baseUrl + "api/updateNormalClinicInfo", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
                print(response)
                self.spinnerView.endRefreshing()
                if let value = response.value as? [String: AnyObject] {
                    self.view.makeToast("Update Success")
                }
            }
        }else{
            self.view.makeToast("Input empty field!")
        }
    }
    
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
