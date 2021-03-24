//
//  ClinicOfferAddVC.swift
//  Proderma
//
//  Created by bird on 3/16/21.
//

import UIKit
import Alamofire
import JTMaterialSpinner
import Toast_Swift
class ClinicOfferAddVC: UIViewController {
    var spinnerView = JTMaterialSpinner()
    @IBOutlet weak var titleTxt: UITextField!
    @IBOutlet weak var infoTxt: UITextView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var lblOfferinfo: UILabel!
    var clinicID : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        clinicID = AppDelegate.shared().currentClinicID
        setReady()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setReady(){
        lblOfferinfo.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "offerInfo", comment: "")
        btnAdd.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "add", comment: ""), for: .normal)
        
        if(UserDefaults.standard.string(forKey: "lang")! == "ar"){
            btnBack.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        }
    }
    @IBAction func onAddOffer(_ sender: Any) {
        let title = titleTxt.text!
        let info = infoTxt.text!
        if(title != "" && info != ""){
            self.view.addSubview(spinnerView)
            spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
            spinnerView.circleLayer.lineWidth = 2.0
            spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
            spinnerView.beginRefreshing()
            let parameters: Parameters = ["id": clinicID!, "title": title, "info": info]
            AF.request(Global.baseUrl + "api/addOffer", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
                print(response)
                self.spinnerView.endRefreshing()
                if let value = response.value as? [String: AnyObject] {
                    self.view.makeToast("Add Success, Please Wait approve!")
                }
            }
        }else{
            self.view.makeToast("Please input title and information!")
        }
        
    }
    
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
