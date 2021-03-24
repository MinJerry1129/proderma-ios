//
//  EventOneVC.swift
//  Proderma
//
//  Created by bird on 3/16/21.
//

import UIKit
import Alamofire
import SDWebImage
import JTMaterialSpinner
import Toast_Swift
import ImageSlideshow
class EventOneVC: UIViewController {

    @IBOutlet weak var eventSlide: ImageSlideshow!
    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var titleTxt: UILabel!
    @IBOutlet weak var dateTxt: UILabel!
    @IBOutlet weak var locationTxt: UILabel!
    @IBOutlet weak var infoTxt: UILabel!
    
    var loginStatus = "no"
    var clinicID : String!
    var eventID : String!
    var pdfUrl : String!
    
    var spinnerView = JTMaterialSpinner()
    var inputSource: [InputSource] = []
    var image : [UIImage] = []
    var allImages = [EventImage]()
    @IBOutlet weak var lblEvent: UILabel!
    @IBOutlet weak var lblInformation: UILabel!
    
    @IBOutlet weak var btnInterest: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        loginStatus = AppDelegate.shared().loginStatus
        clinicID = AppDelegate.shared().currentClinicID
        eventID = AppDelegate.shared().eventID
        setReady()
        getData()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setReady(){
        lblEvent.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "event", comment: "")
        lblInformation.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "informations", comment: "")
        btnInterest.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "interest", comment: ""), for: .normal)
        
        if(UserDefaults.standard.string(forKey: "lang")! == "ar"){
            btnBack.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        }
        if loginStatus == "no"{
            requestBtn.isHidden = true
        }        
    }
    func getData(){
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["id": eventID!]
        AF.request(Global.baseUrl + "api/getEventInfo", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let eventImages = value["eventImages"] as? [[String: AnyObject]]
                let eventInfo = value["eventInfo"] as? [String: AnyObject]
                
                if(eventImages!.count > 0){
                    for i in 0 ... (eventImages!.count)-1 {
                        let id = eventImages![i]["id"] as! String
                        let eventid = eventImages![i]["eventid"] as! String
                        let photo = eventImages![i]["url"] as! String
                        
                        let imagecell = EventImage(id: id, eventid: eventid, photo: photo)
                        self.allImages.append(imagecell)
                        self.inputSource.append(AlamofireSource(urlString: Global.baseUrl + photo)!)
                    }
                }
                self.titleTxt.text = eventInfo!["title"] as? String
                self.locationTxt.text = eventInfo!["location"] as? String
                let edate = eventInfo!["date"] as? String
                let etime = eventInfo!["time"] as? String
                self.dateTxt.text = edate! + " " + etime!
                self.infoTxt.text = eventInfo!["description"] as? String
                let pdf_url = eventInfo!["pdf"] as? String
                self.pdfUrl = Global.baseUrl + pdf_url!
                self.eventSlide.setImageInputs(self.inputSource)
            }
        }
    }
    
    @IBAction func onPdfOpen(_ sender: Any) {
        let pdf_url = URL(string: pdfUrl)!
        UIApplication.shared.open(pdf_url)
    }
    @IBAction func onRequestBtn(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let now = Date()
        let dateString = formatter.string(from: now)
        
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["clinicid": clinicID!, "eventid": eventID!, "date": dateString]
        AF.request(Global.baseUrl + "api/requestEvent", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let result = value["result"] as? String
                if result == "ok"{
                    self.view.makeToast("Success")
                }else{
                    self.view.makeToast("Fail")
                }
            }
        }
    }
    
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
