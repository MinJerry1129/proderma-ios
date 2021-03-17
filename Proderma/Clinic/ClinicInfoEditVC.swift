//
//  ClinicInfoEditVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit
import Alamofire
import SDWebImage
import Toast_Swift
import JTMaterialSpinner
import GooglePlaces

class ClinicInfoEditVC: UIViewController {

    @IBOutlet weak var clinicImg: UIImageView!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var locationTxt: UITextField!
    @IBOutlet weak var phoneTxt: UITextField!
    @IBOutlet weak var whatsappTxt: UITextField!
    @IBOutlet weak var infoTxt: UITextView!
    
    var imagePicker = UIImagePickerController()
    var spinnerView = JTMaterialSpinner()
    var clinicID : String!
    var latitude : String!
    var longitude : String!
    var imgSel = "no"
    var avatarImage : UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        clinicID = AppDelegate.shared().currentClinicID
        let imageTapGesture = UITapGestureRecognizer(target:self,action:#selector(self.selClinicImg))
        clinicImg.isUserInteractionEnabled = true
        clinicImg.addGestureRecognizer(imageTapGesture)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getReady()
    }
    func getReady(){
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
                let clinicName = clinicInfo!["clinicname"] as? String
                let phone = clinicInfo!["mobile"] as? String
                let whatsapp = clinicInfo!["whatsapp"] as? String
                let location = clinicInfo!["location"] as? String
                let info = clinicInfo!["information"] as? String
                let image = clinicInfo!["photo"] as? String
                self.latitude = clinicInfo!["latitude"] as? String
                self.longitude = clinicInfo!["longitude"] as? String
                self.nameTxt.text = clinicName
                self.phoneTxt.text = phone
                self.whatsappTxt.text = whatsapp
                self.locationTxt.text = location
                self.infoTxt.text = info
                self.clinicImg.sd_setImage(with: URL(string: Global.baseUrl + image!), completed: nil)
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
    @IBAction func onLocationTxt(_ sender: Any) {
        locationTxt.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    
    @IBAction func onUpdateBtn(_ sender: Any) {
        let clinicname = nameTxt.text!
        let clocation = locationTxt.text!
        let cphone = phoneTxt.text!
        let cwhatsapp = whatsappTxt.text!
        let cinfo = infoTxt.text!
        if(clinicname != "" && clocation != "" && cphone != "" && cwhatsapp != ""){
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
            let parameters: Parameters = ["id": clinicID!, "clinicname": clinicname, "location": clocation,"latitude": latitude!, "longitude": longitude!, "phone": cphone,  "info": cinfo, "whatsapp": cwhatsapp,"isChange": imgSel, "photo": strBase64]
            AF.request(Global.baseUrl + "api/updateClinicInfo", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
                print(response)
                self.spinnerView.endRefreshing()
                if let value = response.value as? [String: AnyObject] {
                    self.view.makeToast("Update Success!")
                }
            }
        }else{
            self.view.makeToast("Please fill the empty field!")
        }
        
        
        
    }
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension ClinicInfoEditVC:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            print(editedImage)
            avatarImage = editedImage
            imgSel = "yes"
            self.clinicImg.image = editedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
}
extension ClinicInfoEditVC: GMSAutocompleteViewControllerDelegate {
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
