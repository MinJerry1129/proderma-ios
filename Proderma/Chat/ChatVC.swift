//
//  ChatVC.swift
//  Proderma
//
//  Created by bird on 2/4/21.
//

import UIKit

class ChatVC: UIViewController {

    @IBOutlet weak var chatUV: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        chatUV.layer.borderColor = UIColor(red:156/255, green:37/255, blue:31/255, alpha: 1).cgColor
    }

}
