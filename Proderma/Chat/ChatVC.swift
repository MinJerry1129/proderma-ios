//
//  ChatVC.swift
//  Proderma
//
//  Created by bird on 2/4/21.
//

import UIKit

class ChatVC: UIViewController {

    @IBOutlet weak var messageTxt: UITextView!
    @IBOutlet weak var chatUV: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var lblChats: UILabel!
    
    @IBOutlet weak var lblmessage: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
//        chatUV.layer.borderColor = UIColor(red:156/255, green:37/255, blue:31/255, alpha: 1).cgColor
        setReady()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setReady(){
        lblChats.isUserInteractionEnabled = true
        let gestureRecognizerw = UITapGestureRecognizer(target: self, action: #selector(onBackPage))
        lblChats.addGestureRecognizer(gestureRecognizerw)
        lblChats.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "chat", comment: "")
        lblmessage.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "sendMsg", comment: "")
        btnSend.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "send", comment: ""), for: .normal)
        if(UserDefaults.standard.string(forKey: "lang")! == "ar"){
            btnBack.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        }
    }

    @IBAction func onSendMessage(_ sender: Any) {
        let urlWhats = "whatsapp://send?phone=+97180077633762&text=" + messageTxt.text!
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL) {
                    UIApplication.shared.openURL(whatsappURL)
                } else {
                    let whatsappURL = URL(string: "https://api.whatsapp.com/send?phone=+97180077633762" )
                    if UIApplication.shared.canOpenURL(whatsappURL!) {
                        UIApplication.shared.open(whatsappURL!, options: [:], completionHandler: nil)
                        }
                    print("Install Whatsapp")
                }
            }
        }
    }
    @objc func onBackPage(){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
