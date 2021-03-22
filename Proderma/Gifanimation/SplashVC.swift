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
    var homeVC : HomeVC!
    var sel_lang = "no"
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(logoAnimationView)
        sel_lang = UserDefaults.standard.string(forKey: "lang") ?? "no"
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
        if(sel_lang != "no"){
            self.homeVC = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as? HomeVC
            self.homeVC.modalPresentationStyle = .fullScreen
            self.present(self.homeVC, animated: true, completion: nil)
            if sel_lang != "ar"{
                UIView.appearance().semanticContentAttribute = .forceLeftToRight
            }else{
                UIView.appearance().semanticContentAttribute = .forceRightToLeft
            }
            
        }else{
            self.sellangVC = self.storyboard?.instantiateViewController(withIdentifier: "sellangVC") as? SelLangVC
            self.sellangVC.modalPresentationStyle = .fullScreen
            self.present(self.sellangVC, animated: true, completion: nil)
        }
        
        logoAnimationView.isHidden = true
    }
}
