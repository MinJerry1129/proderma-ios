//
//  HomeVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit

class HomeVC: UIViewController {
    var allproductVC : AllProductVC!
    var allclinicVC : AllClinicVC!

    override func viewDidLoad() {
        super.viewDidLoad()

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
