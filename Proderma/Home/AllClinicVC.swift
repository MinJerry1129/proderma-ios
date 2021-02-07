//
//  AllClinicVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit

class AllClinicVC: UIViewController {
    var homeVC : HomeVC!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onBtnBack(_ sender: Any) {
//        self.homeVC = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as? HomeVC
//        self.homeVC.modalPresentationStyle = .fullScreen
//        self.present(self.homeVC, animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
}
