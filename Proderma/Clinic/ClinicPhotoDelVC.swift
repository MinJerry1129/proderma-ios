//
//  ClinicPhotoDelVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit
import Alamofire
import SDWebImage
import JTMaterialSpinner

class ClinicPhotoDelVC: UIViewController {
    @IBOutlet weak var doctorImg: UIImageView!
    var spinnerView = JTMaterialSpinner()
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblPhoto: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    var imageID : String!
    var imageURL: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageID = AppDelegate.shared().clinicimageID
        imageURL = AppDelegate.shared().clinicimageURL
        doctorImg.sd_setImage(with: URL(string: Global.baseUrl + imageURL), completed: nil)
        setReady()
    }
    func setReady(){
        lblPhoto.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "photo", comment: "")
        btnDelete.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "delete", comment: ""), for: .normal)
        
        if(UserDefaults.standard.string(forKey: "lang")! == "ar"){
            btnBack.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        }
    }
    
    @IBAction func onDeleteBtn(_ sender: Any) {
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["id": imageID!]
        AF.request(Global.baseUrl + "api/deleteClinicImage", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
   
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
