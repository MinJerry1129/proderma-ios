//
//  EventHomeVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit
import Alamofire
import SDWebImage
import Toast_Swift
import JTMaterialSpinner
class EventHomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var spinnerView = JTMaterialSpinner()
    var allevent = [Event]()
    @IBOutlet weak var eventTB: UITableView!
    
    var eventoneVC : EventOneVC!
    
    
    @IBOutlet weak var lblEvent: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        eventTB.delegate = self
        eventTB.dataSource = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getData()
        setReady()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setReady(){
        lblEvent.isUserInteractionEnabled = true
        let gestureRecognizerw = UITapGestureRecognizer(target: self, action: #selector(onBackPage))
        lblEvent.addGestureRecognizer(gestureRecognizerw)
        lblEvent.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "homeevent", comment: "")
        
        if(UserDefaults.standard.string(forKey: "lang")! == "ar"){
            btnBack.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        }
    }
    func getData(){
        allevent = []
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        AF.request(Global.baseUrl + "api/getEventsInfo", method: .post, encoding:JSONEncoding.default).responseJSON{response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let eventInfos = value["eventsInfo"] as? [[String: AnyObject]]
                                
                if(eventInfos!.count > 0){
                    for i in 0 ... (eventInfos!.count)-1 {
                        let id = eventInfos![i]["id"] as! String
                        let title = eventInfos![i]["title"] as! String
                        let location = eventInfos![i]["location"] as! String
                        let edate = eventInfos![i]["date"] as! String
                        let etime = eventInfos![i]["time"] as! String
                        let image = eventInfos![i]["photo"] as! String
                        let description = eventInfos![i]["description"] as! String
                        
                        let date_Time = edate + " " + etime
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                        
                        let event_date = dateFormatter.date(from: date_Time)!
                       
                        let now = Date()
                        
                        if now < event_date{
                            let eventCell = Event(id: id, title: title, date: date_Time, location: location, description: description, photo: image)
                            self.allevent.append(eventCell)
                        }
                    }
                    self.eventTB.reloadData()
                }
            }
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allevent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let oneEvent: Event
        oneEvent =  allevent[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EventListCell
        cell.eventImg.sd_setImage(with: URL(string: Global.baseUrl + oneEvent.photo), completed: nil)
        cell.nameTxt.text = oneEvent.title
        cell.dateTxt.text = oneEvent.date
        cell.locationTxt.text = oneEvent.location
        cell.infoTxt.text = oneEvent.description
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppDelegate.shared().eventID = allevent[indexPath.row].id
        self.eventoneVC = self.storyboard?.instantiateViewController(withIdentifier: "eventoneVC") as? EventOneVC
        self.eventoneVC.modalPresentationStyle = .fullScreen
        self.present(self.eventoneVC, animated: true, completion: nil)
    }
    @objc func onBackPage(){
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
