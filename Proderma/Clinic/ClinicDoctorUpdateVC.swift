//
//  ClinicDoctorUpdateVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit
import Toast_Swift
import Alamofire
import JTMaterialSpinner
import SDWebImage
class ClinicDoctorUpdateVC: UIViewController {
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var doctorImg: UIImageView!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var infoTxt: UITextView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblDoctorInfo: UILabel!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    var imgSel = "no"
    var doctorID : String!
    var clinicID : String!
    var spinnerView = JTMaterialSpinner()
    var avatarImage : UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        clinicID = AppDelegate.shared().currentClinicID
        doctorID = AppDelegate.shared().doctorID
        let imageTapGesture = UITapGestureRecognizer(target:self,action:#selector(self.selClinicImg))
        doctorImg.isUserInteractionEnabled = true
        doctorImg.addGestureRecognizer(imageTapGesture)
        setReady()
        getData()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setReady(){
        lblDoctorInfo.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "doctorinfo", comment: "")
        btnDelete.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "delete", comment: ""), for: .normal)
        btnUpdate.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "update", comment: ""), for: .normal)
        
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
        let parameters: Parameters = ["id": doctorID!]
        AF.request(Global.baseUrl + "api/getDoctorInfo", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let doctorInfo = value["doctorInfo"] as? [String: AnyObject]
                
                let doctorName = doctorInfo!["name"] as? String
                let infomation = doctorInfo!["information"] as? String
                let doctorimage = doctorInfo!["photo"] as? String
                self.nameTxt.text = doctorName
                self.infoTxt.text = infomation
                self.doctorImg.sd_setImage(with: URL(string: Global.baseUrl + doctorimage!), completed: nil)
            }
        }
    }
    
    @objc func selClinicImg(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
                    self.openCamera()
                }))
                
                alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
                    self.openGallary()
                }))
                
                alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                
                //If you want work actionsheet on ipad then you have to use popoverPresentationController to present the actionsheet, otherwise app will crash in iPad
                
                self.present(alert, animated: true, completion: nil)
        
    }
    func openCamera(){
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
            //If you dont want to edit the photo then you can set allowsEditing to false
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
            }
            else{
                let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        //MARK: - Choose image from camera roll
        
    func openGallary(){
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        //If you dont want to edit the photo then you can set allowsEditing to false
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func onUpdateBtn(_ sender: Any) {
        let docName = nameTxt.text!
        let docInfo = infoTxt.text!
        if(docName != ""){
            var strBase64 = ""
            if imgSel == "yes"{
                let data = avatarImage.jpegData(compressionQuality: 0.6)
                strBase64 = data!.base64EncodedString(options: .lineLength64Characters)
            }
            
            self.view.addSubview(spinnerView)
            spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
            spinnerView.circleLayer.lineWidth = 2.0
            spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
            spinnerView.beginRefreshing()
            let parameters: Parameters = ["id": doctorID!, "name": docName, "age": "25","info": docInfo,"isChange":imgSel, "photo": strBase64]
            AF.request(Global.baseUrl + "api/updateDoctorInfo", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
                print(response)
                self.spinnerView.endRefreshing()
                if let value = response.value as? [String: AnyObject] {
                    self.view.makeToast("Update Success, Please Wait approve!")
                }
            }
        }else{
            self.view.makeToast("Input Doctor name")
        }
        
    }
    
    @IBAction func onDeleteBtn(_ sender: Any) {
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["id": doctorID!]
        AF.request(Global.baseUrl + "api/deleteDoctor", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let result = value["result"] as? String
                if result == "success"{
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension ClinicDoctorUpdateVC:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            print(editedImage)
            avatarImage = editedImage
            imgSel = "yes"
            self.doctorImg.image = editedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
}
