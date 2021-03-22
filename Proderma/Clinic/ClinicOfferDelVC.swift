//
//  ClinicOfferDelVC.swift
//  Proderma
//
//  Created by bird on 3/16/21.
//

import UIKit
import Alamofire
import JTMaterialSpinner
class ClinicOfferDelVC: UIViewController {

    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var titleTxt: UITextField!
    @IBOutlet weak var infoTxt: UITextView!
    var spinnerView = JTMaterialSpinner()
    var offerID : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        offerID = AppDelegate.shared().offerID
        getData()
        setReady()
    }
    func setReady(){
        
        btnDelete.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "delete", comment: ""), for: .normal)        
        
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
        let parameters: Parameters = ["id": offerID!]
        AF.request(Global.baseUrl + "api/getOfferInfo", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let offerInfo = value["offerInfo"] as? [String: AnyObject]
                let title = offerInfo!["title"] as! String
                let info = offerInfo!["description"] as! String
                self.titleTxt.text = title
                self.infoTxt.text = info                
            }
        }
    }

    @IBAction func onDelBtn(_ sender: Any) {
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["id": offerID!]
        AF.request(Global.baseUrl + "api/deleteOffer", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
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
