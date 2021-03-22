//
//  ClinicPhotoAllVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit
import Alamofire
import Toast_Swift
import SDWebImage
import JTMaterialSpinner
class ClinicPhotoAllVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var imageCV: UICollectionView!
    var spinnerView = JTMaterialSpinner()
    var allImages = [ClinicImage]()
    var avatarImage : UIImage!
    var clinicID : String!
    var clinicphotodelVC : ClinicPhotoDelVC!
    
    @IBOutlet weak var lblAllPhoto: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        clinicID = AppDelegate.shared().currentClinicID
        imageCV.delegate = self
        imageCV.dataSource = self
        setReady()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getData()
    }
    func setReady(){
        lblAllPhoto.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "allphoto", comment: "")
        
        if(UserDefaults.standard.string(forKey: "lang")! == "ar"){
            btnBack.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        }
    }
    func selClinicImg(){
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
    
    func getData(){
        allImages = []
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["id": clinicID!]
        AF.request(Global.baseUrl + "api/getClinicImage", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let clinicImages = value["clinicImages"] as? [[String: AnyObject]]
                self.allImages.append(ClinicImage(id: "0", clinicid: "0", photo: "", status: ""))
                
                if(clinicImages!.count > 0){
                    for i in 0 ... (clinicImages!.count)-1 {
                        let id = clinicImages![i]["id"] as! String
                        let clinicid = clinicImages![i]["clinicid"] as! String
                        let photo = clinicImages![i]["url"] as! String
                        let status = clinicImages![i]["status"] as! String

                        let imagecell = ClinicImage(id: id, clinicid: clinicid, photo: photo, status: status)
                        self.allImages.append(imagecell)
                    }
                }
                self.imageCV.reloadData()
            }
        }
    }
    func addimage(){
        let data = avatarImage.jpegData(compressionQuality: 0.6)
        let strBase64 = data!.base64EncodedString(options: .lineLength64Characters)
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["id": clinicID!,"photo": strBase64]
        AF.request(Global.baseUrl + "api/addClinicImage", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                self.getData()
            }
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return allImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let oneImage: ClinicImage
        oneImage =  allImages[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: "cell"), for: indexPath) as! ClinicImageCell
        if indexPath.row == 0{
            cell.clinicImg.image = UIImage(named: "icnewimg")
        }else{
            cell.clinicImg.sd_setImage(with: URL(string: Global.baseUrl + oneImage.photo), completed: nil)
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
            self.selClinicImg()
        }else{
            AppDelegate.shared().clinicimageID = allImages[indexPath.row].id
            AppDelegate.shared().clinicimageURL = allImages[indexPath.row].photo
            self.clinicphotodelVC = self.storyboard?.instantiateViewController(withIdentifier: "clinicphotodelVC") as? ClinicPhotoDelVC
            self.clinicphotodelVC.modalPresentationStyle = .fullScreen
            self.present(self.clinicphotodelVC, animated: true, completion: nil)
        }
        

       
        
        
        

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: (collectionView.bounds.width * 0.25 - 10), height: (collectionView.bounds.width * 0.25 - 10))
    }
    
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension ClinicPhotoAllVC:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            print(editedImage)
            avatarImage = editedImage
            self.addimage()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
}
