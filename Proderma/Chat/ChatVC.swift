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
    override func viewDidLoad() {
        super.viewDidLoad()
        chatUV.layer.borderColor = UIColor(red:156/255, green:37/255, blue:31/255, alpha: 1).cgColor
    }

    @IBAction func onSendMessage(_ sender: Any) {
        let urlWhats = "whatsapp://send?phone=+123123123&text=" + messageTxt.text!
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL) {
                    UIApplication.shared.openURL(whatsappURL)
                } else {
                    let whatsappURL = URL(string: "https://api.whatsapp.com/send?phone=+1234567890" )
                    if UIApplication.shared.canOpenURL(whatsappURL!) {
                        UIApplication.shared.open(whatsappURL!, options: [:], completionHandler: nil)
                        }
                    print("Install Whatsapp")
                }
            }
        }
    }
    
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
