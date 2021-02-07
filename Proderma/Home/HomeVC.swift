//
//  HomeVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit
import Alamofire
import SDWebImage
import Toast_Swift
import JTMaterialSpinner

class HomeVC: UIViewController{
    var allproductVC : AllProductVC!
    var allclinicVC : AllClinicVC!
    var spinnerView = JTMaterialSpinner()

    @IBOutlet weak var txtNews: UITextView!
    @IBOutlet weak var cvProduct: UICollectionView!
    @IBOutlet weak var cvClinic: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getData()
    }
    func getData(){
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        AF.request(Global.baseUrl + "api/getHomeData", method: .post).responseJSON{ response in
            print(response)
            self.spinnerView.endRefreshing()
//            if let value = response.value as? [String: AnyObject] {
//                let result = value["result"] as? [[String: AnyObject]]
//
//            }

        }
    }
    
    @IBAction func onBtnAllProduct(_ sender: Any) {
        self.allproductVC = self.storyboard?.instantiateViewController(withIdentifier: "allproductVC") as? AllProductVC
        self.allproductVC.modalPresentationStyle = .fullScreen
        self.present(self.allproductVC, animated: true, completion: nil)
    }
    
    @IBAction func onBtnAllClinic(_ sender: Any) {
        self.allclinicVC =     self.storyboard?.instantiateViewController(withIdentifier: "allclinicVC") as? AllClinicVC
        self.allclinicVC.modalPresentationStyle = .fullScreen
        self.present(self.allclinicVC, animated: true, completion: nil)
    }
    
    @IBAction func onBtnClinic(_ sender: Any) {
    }
    
    @IBAction func onBtnEvent(_ sender: Any) {
    }
    
    @IBAction func onBtnChat(_ sender: Any) {
    }
    
    @IBAction func onBtnHistory(_ sender: Any) {
    }
    
    @IBAction func onBtnSetting(_ sender: Any) {
    }
    
}
