//
//  ClinicDoctorAddVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit
import Alamofire
import SDWebImage
import JTMaterialSpinner
import Toast_Swift
class ClinicDoctorAddVC: UIViewController {
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var DoctorImg: UIImageView!
    @IBOutlet weak var infoTxt: UITextView!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblDoctorInfo: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    var avatarImage : UIImage!
    var imgSel = 0
    var spinnerView = JTMaterialSpinner()
    var clinicID : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageTapGesture = UITapGestureRecognizer(target:self,action:#selector(self.selClinicImg))
        DoctorImg.isUserInteractionEnabled = true
        DoctorImg.addGestureRecognizer(imageTapGesture)
        clinicID = AppDelegate.shared().currentClinicID
        setReady()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setReady(){
        lblDoctorInfo.isUserInteractionEnabled = true
        let gestureRecognizerw = UITapGestureRecognizer(target: self, action: #selector(onBackPage))
        lblDoctorInfo.addGestureRecognizer(gestureRecognizerw)
        lblDoctorInfo.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "doctorinfo", comment: "")
        btnAdd.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "add", comment: ""), for: .normal)
        
        if(UserDefaults.standard.string(forKey: "lang")! == "ar"){
            btnBack.setImage(UIImage(systemName: "chevron.right"), for: .normal)
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
    
    @IBAction func onAddBtn(_ sender: Any) {
        let docName = nameTxt.text!
        let docInfo = infoTxt.text!
        if imgSel == 1{
            if(docName != ""){
                let data = avatarImage.jpegData(compressionQuality: 0.6)
                let strBase64 = data!.base64EncodedString(options: .lineLength64Characters)
                self.view.addSubview(spinnerView)
                spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
                spinnerView.circleLayer.lineWidth = 2.0
                spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
                spinnerView.beginRefreshing()
                let parameters: Parameters = ["id": clinicID!, "name": docName, "age": "25","info": docInfo, "photo": strBase64]
                AF.request(Global.baseUrl + "api/addDoctor", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
                    print(response)
                    self.spinnerView.endRefreshing()
                    if let value = response.value as? [String: AnyObject] {
                        self.view.makeToast("Add Success, Please Wait approve!")
                    }
                }
            }else{
                self.view.makeToast("Input Doctor name")
            }
        }else{
            self.view.makeToast("Select Doctor Image")
        }
        
    }
    @objc func onBackPage(){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension ClinicDoctorAddVC:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            print(editedImage)
            avatarImage = editedImage
            imgSel = 1
            self.DoctorImg.image = editedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        imgSel = 0
        self.dismiss(animated: true, completion: nil)
    }
}
