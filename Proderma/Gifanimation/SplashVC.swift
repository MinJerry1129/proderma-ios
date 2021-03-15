//
//  SplashVC.swift
//  Proderma
//
//  Created by bird on 3/15/21.
//

import UIKit
import SwiftyGif
class SplashVC: UIViewController {

    let logoAnimationView = LogoAnimationView()
    var sellangVC : SelLangVC!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(logoAnimationView)
        logoAnimationView.pinEdgesToSuperView()
        logoAnimationView.logoGifImageView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logoAnimationView.logoGifImageView.startAnimatingGif()
    }
}
extension SplashVC: SwiftyGifDelegate {
    func gifDidStop(sender: UIImageView) {
        self.sellangVC = self.storyboard?.instantiateViewController(withIdentifier: "sellangVC") as? SelLangVC
        self.sellangVC.modalPresentationStyle = .fullScreen
        self.present(self.sellangVC, animated: true, completion: nil)
        logoAnimationView.isHidden = true
    }
}
