//
//  ProductInfoVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit
import JTMaterialSpinner
import Alamofire
import Toast_Swift

class ProductInfoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var infoTB: UITableView!
    @IBOutlet weak var selType: UISegmentedControl!
    
    var spinnerView = JTMaterialSpinner()    
    var allPdf = [ProductPdf]()
    var allVideo = [Productvideo]()
    var productID : String!
    var sel_type = "video"
    
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var lblMoreinfo: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        productID = AppDelegate.shared().productID
        infoTB.delegate = self
        infoTB.dataSource = self
        setReady()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        allPdf = []
        allVideo = []
        getData()
    }
    func setReady(){
        lblMoreinfo.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "moreinfo", comment: "")
        
        if(UserDefaults.standard.string(forKey: "lang")! == "ar"){
            btnBack.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        }
    }
    func getData(){
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["id": productID!]
        AF.request(Global.baseUrl + "api/getTrainInfo", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let videoInfos = value["videoInfo"] as? [[String: AnyObject]]
                let pdfInfos = value["pdfInfo"] as? [[String: AnyObject]]
                if(videoInfos!.count > 0){
                    for i in 0 ... (videoInfos!.count)-1 {
                        let id = videoInfos![i]["id"] as! String
                        let title = videoInfos![i]["title"] as! String
                        let information = videoInfos![i]["information"] as! String
                        let url = videoInfos![i]["url"] as! String
//
                        let videocell = Productvideo(id: id, title: title, url: url, infomation: information)
                        self.allVideo.append(videocell)
                    }
                }
                if(pdfInfos!.count > 0){
                    for i in 0 ... (pdfInfos!.count)-1 {
                        let id = pdfInfos![i]["id"] as! String
                        let title = pdfInfos![i]["title"] as! String
                        let information = pdfInfos![i]["information"] as! String
                        let url = pdfInfos![i]["url"] as! String
//
                        let pdfcell = ProductPdf(id: id, title: title, url: url, infomation: information)
                        self.allPdf.append(pdfcell)
                    }
                }
                self.infoTB.reloadData()
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sel_type == "video"{
            return allVideo.count
        }else{
            return allPdf.count
        }
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.infoTB.dequeueReusableCell(withIdentifier: "cell") as! ProductinfoCell
        if indexPath.row % 2 == 1 {
            cell.mainView.backgroundColor = #colorLiteral(red: 1, green: 0.9647058824, blue: 0.9191721542, alpha: 1)
        }
        if sel_type == "video"{
            let oneVideo = allVideo[indexPath.row]
            cell.infoImg.image = UIImage(named: "icyoutube")
            cell.infoTitle.text = oneVideo.title
            cell.infoDes.text = oneVideo.infomation
        }else{
            let onePdf = allPdf[indexPath.row]
            cell.infoImg.image = UIImage(named: "icpdf")
            cell.infoTitle.text = onePdf.title
            cell.infoDes.text = onePdf.infomation
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sel_type == "video"{
            let oneVideo = allVideo[indexPath.row]
            let youtubeId = oneVideo.url
            var youtubeUrl = URL(string:"youtube://\(youtubeId)")!
            if UIApplication.shared.canOpenURL(youtubeUrl){
                UIApplication.shared.open(youtubeUrl)
            }else{
                youtubeUrl = URL(string:"https://www.youtube.com/watch?v=\(youtubeId)")!
                UIApplication.shared.open(youtubeUrl)
            }
            
        }else{
            print("pdf")
            let onepdf = allPdf[indexPath.row]
            let pdfurl = URL(string: Global.baseUrl + onepdf.url)!
            UIApplication.shared.open(pdfurl)
            
        }
    }
    
    @IBAction func onIndexChange(_ sender: Any) {
        switch selType.selectedSegmentIndex
            {
            case 0:
                self.sel_type = "video"
                self.infoTB.reloadData()
            case 1:
                self.sel_type = "pdf"
                self.infoTB.reloadData()
            default:
                break
            }
    }
    
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
