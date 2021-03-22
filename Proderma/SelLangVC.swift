//
//  ViewController.swift
//  Proderma
//
//  Created by bird on 1/27/21.
//

import UIKit

class SelLangVC: UIViewController {
    var splashVC : SplashVC!

    @IBOutlet weak var btnEng: UIButton!
    @IBOutlet weak var btnArc: UIButton!
    var sel_lang = "en"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onBtnEng(_ sender: Any) {
        LocalizationSystem.sharedInstance.setLanguage(languageCode: "en")
        UserDefaults.standard.set("en", forKey: "lang")
        UIView.appearance().semanticContentAttribute = .forceRightToLeft
        self.splashVC = self.storyboard?.instantiateViewController(withIdentifier: "splashVC") as? SplashVC
        let appDlg = UIApplication.shared.delegate as? SceneDelegate
        appDlg?.window?.rootViewController = splashVC
        self.splashVC.modalPresentationStyle = .fullScreen
        self.present(self.splashVC, animated: true, completion: nil)
    }
    
    @IBAction func onBtnArb(_ sender: Any) {
        LocalizationSystem.sharedInstance.setLanguage(languageCode: "ar")
        UserDefaults.standard.set("ar", forKey: "lang")
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        
        self.splashVC = self.storyboard?.instantiateViewController(withIdentifier: "splashVC") as? SplashVC
        let appDlg = UIApplication.shared.delegate as? SceneDelegate
        appDlg?.window?.rootViewController = splashVC
        self.splashVC.modalPresentationStyle = .fullScreen
        self.present(self.splashVC, animated: true, completion: nil)
    }
}

