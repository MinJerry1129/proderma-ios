//
//  HistoryHomeVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit
import Alamofire
import SDWebImage
import JTMaterialSpinner
import Toast_Swift

class HistoryHomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var historyTB: UITableView!
    
    var clinicId : String!
    var spinnerView = JTMaterialSpinner()
    var allhistory = [OrderHistory]()
    
    @IBOutlet weak var lblHistory: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        clinicId = AppDelegate.shared().currentClinicID
        historyTB.delegate = self
        historyTB.dataSource = self
        getData()
        setReady()
    }
    func setReady(){
        lblHistory.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "history", comment: "")
        
        if(UserDefaults.standard.string(forKey: "lang")! == "ar"){
            btnBack.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        }
    }
    func getData(){
        allhistory = []
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["id": clinicId!]
        AF.request(Global.baseUrl + "api/getOrderHistoryInfo", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let orderInfos = value["ordersInfo"] as? [[String: AnyObject]]
                                
                if(orderInfos!.count > 0){
                    for i in 0 ... (orderInfos!.count)-1 {
                        let id = orderInfos![i]["id"] as! String
                        let name = orderInfos![i]["productname"] as! String
                        let photo = orderInfos![i]["photo"] as! String
                        let count = orderInfos![i]["count"] as! String
                        let extra = orderInfos![i]["extra"] as? String
                        let orderdate = orderInfos![i]["date"] as! String
                        let status = orderInfos![i]["status"] as! String
                        
                        let orderCell = OrderHistory(id: id, productname: name, productImage: photo, quantity: count, foc: extra ?? "0", date: orderdate, status: status)
                        self.allhistory.append(orderCell)
                    }
                    self.historyTB.reloadData()
                }                
            }
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allhistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let oneOrder: OrderHistory
        oneOrder =  allhistory[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OrderHistoryCell
        cell.productImg.sd_setImage(with: URL(string: Global.baseUrl + oneOrder.productImage), completed: nil)
        cell.nameTxt.text = oneOrder.productname
        cell.dateTxt.text = oneOrder.date
        cell.quantityTxt.text = oneOrder.quantity
        cell.focTxt.text = oneOrder.foc
        cell.statusTxt.text = oneOrder.status
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
