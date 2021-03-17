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
    
    var avatarImage : UIImage!
    var whatsappnum : String!
    var clinicLocation : String!
    var clinicCode : String!
    var clinicInfo : String!
    var imgSel = 0
    var latitude : String!
    var longitude : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageTapGesture = UITapGestureRecognizer(target:self,action:#selector(self.selClinicImg))
        clinicImg.isUserInteractionEnabled = true
        clinicImg.addGestureRecognizer(imageTapGesture)

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
        if imgSel == 0{
            self.view.makeToast("Please select image")
        }else{
            if(whatsappnum != "" && clinicLocation != "" && clinicCode != ""){
                let data = avatarImage.jpegData(compressionQuality: 0.6)
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
                            self.view.makeToast("Signup Success, Please wait accept or contact to support team")
                        }else if status == "existemail"{
                            self.view.makeToast("Your account already exist, Please contact to support team")
                        }else {
                            self.view.makeToast("Fail signup")
                        }
                    }
                }
                
                
            }else{
                self.view.makeToast("Please input empty field")
            }
        }
    }
    
    @IBAction func locationTap(_ sender: Any) {
        locationTxt.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
        
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
