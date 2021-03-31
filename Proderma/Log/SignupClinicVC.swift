//
//  SignupClinicVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit
import GooglePlaces
import Alamofire
import Toast_Swift
import JTMaterialSpinner

class SignupClinicVC: UIViewController {
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var clinicImg: UIImageView!
    @IBOutlet weak var whatsappTxt: UITextField!
    @IBOutlet weak var locationTxt: UITextField!
    @IBOutlet weak var infoTxt: UITextView!
    @IBOutlet weak var codeTxt: UITextField!
    
    var spinnerView = JTMaterialSpinner()
    var homeVC : HomeVC!
    
    var avatarImage : UIImage!
    var whatsappnum : String!
    var clinicLocation : String!
    var clinicCode : String!
    var clinicInfo : String!
    var imgSel = 0
    var latitude : String!
    var longitude : String!
    
    @IBOutlet weak var btnSignup: UIButton!
    @IBOutlet weak var lblClinicinfo: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageTapGesture = UITapGestureRecognizer(target:self,action:#selector(self.selClinicImg))
        clinicImg.isUserInteractionEnabled = true
        clinicImg.addGestureRecognizer(imageTapGesture)
        setReady()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setReady(){
        lblClinicinfo.isUserInteractionEnabled = true
        let gestureRecognizerw = UITapGestureRecognizer(target: self, action: #selector(onBackPage))
        lblClinicinfo.addGestureRecognizer(gestureRecognizerw)
        btnSignup.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "signup", comment: ""), for: .normal)        
        lblClinicinfo.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "clinicinfo", comment: "")
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
    @IBAction func onSignupBtn(_ sender: Any) {
        whatsappnum = whatsappTxt.text!
        clinicLocation = locationTxt.text!
        clinicCode = codeTxt.text!
        clinicInfo = infoTxt.text!
        if !validatedata(){
            return
        }
            
        let data = avatarImage.jpegData(compressionQuality: 0.8)
        let strBase64 = data!.base64EncodedString(options: .lineLength64Characters)
        
        let firstname = AppDelegate.shared().sign_firstname
        let lastname = AppDelegate.shared().sign_lastname
        let clinicname = AppDelegate.shared().sign_clinicname
        let email = AppDelegate.shared().sign_email
        let mobile = AppDelegate.shared().sign_phone
        let password = AppDelegate.shared().sign_password
        
        
        
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["firstname": firstname,"secondname": lastname, "clinicname": clinicname, "email": email, "phone": mobile, "password": password, "location": clinicLocation, "info": clinicInfo, "whatsapp": whatsappnum, "visacode": clinicCode, "photo": strBase64, "latitude": latitude, "longitude": longitude ]
        AF.request(Global.baseUrl + "api/signup", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
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
                }else if status == "noclinic"{
                    self.view.makeToast("You are not elite clinic. Check elite card number again.")
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
    
    func validatedata() -> Bool {
        if imgSel == 0{
            self.view.makeToast("Please select image")
            return false
        }
        if clinicLocation == ""{
            self.view.makeToast("Input Clinic Location")
            return false
        }
        if clinicCode == ""{
            self.view.makeToast("Input Card")
            return false
        }else{
            let codeRegEx = "[0-9]{16,17}"
            let codePred = NSPredicate(format:"SELF MATCHES %@", codeRegEx)
            if !codePred.evaluate(with: clinicCode){
                self.view.makeToast("Input correct phonenumber")
                return false
            }
        }
        
        if whatsappnum == ""{
            self.view.makeToast("Input whatsapp number")
            return false
        }else{
            let phoneRegEx = "[+]+[0-9]{10,17}"
            let phonePred = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
            if !phonePred.evaluate(with: whatsappnum){
                self.view.makeToast("Input correct whatsappnumber")
                return false
            }
        }
        
        return true
    }
    
    
    @IBAction func locationTap(_ sender: Any) {
        locationTxt.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
        
    }
    @objc func onBackPage(){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension SignupClinicVC:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            print(editedImage)
            avatarImage = editedImage
            imgSel = 1
            self.clinicImg.image = editedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        imgSel = 0
        self.dismiss(animated: true, completion: nil)
    }
}
extension SignupClinicVC: GMSAutocompleteViewControllerDelegate {
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    // Get the place name from 'GMSAutocompleteViewController'
    // Then display the name in textField
    locationTxt.text = place.formattedAddress
    latitude = "\(place.coordinate.latitude)"
    longitude = "\(place.coordinate.longitude)"
    dismiss(animated: true, completion: nil)
  }
func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // Handle the error
    print("Error: ", error.localizedDescription)
  }
func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    // Dismiss when the user canceled the action
    dismiss(animated: true, completion: nil)
  }
}
