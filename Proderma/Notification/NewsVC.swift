//
//  NotificationVC.swift
//  Proderma
//
//  Created by bird on 3/24/21.
//

import UIKit
import JTMaterialSpinner
import Alamofire
class NewsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var spinnerView = JTMaterialSpinner()
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblNotification: UILabel!
    @IBOutlet weak var newsTB: UITableView!
    var allnews  = [News]()
    var usertype : String!
    var loginStatus : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        setReady()
        newsTB.delegate = self
        newsTB.dataSource = self
        newsTB.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "cell")
        loginStatus = AppDelegate.shared().loginStatus
        usertype = AppDelegate.shared().userType
        getData()
    }
    func setReady(){
        lblNotification.isUserInteractionEnabled = true
        let gestureRecognizerw = UITapGestureRecognizer(target: self, action: #selector(onBackPage))
        lblNotification.addGestureRecognizer(gestureRecognizerw)
        lblNotification.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "notification", comment: "")
        if(UserDefaults.standard.string(forKey: "lang")! == "ar"){
            btnBack.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        }
    }
    func getData(){
        allnews = []
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        AF.request(Global.baseUrl + "api/getNotification", method: .post, encoding:JSONEncoding.default).responseJSON{response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let eventInfos = value["notificationsInfo"] as? [[String: AnyObject]]
                                
                if(eventInfos!.count > 0){
                    for i in 0 ... (eventInfos!.count)-1 {
                        let id = eventInfos![i]["id"] as! String
                        let title = eventInfos![i]["title"] as! String
                        let ndate = eventInfos![i]["date"] as! String
                        let type = eventInfos![i]["type"] as! String
                        let description = eventInfos![i]["description"] as! String
                        let newsCell = News(id: id, title: title, description: description, date: ndate, type: type)
                        if self.loginStatus == "yes"{
                            if type == "all"{
                                self.allnews.append(newsCell)
                            }
                            if type == self.usertype{
                                self.allnews.append(newsCell)
                            }
                            
                        }else{
                            if type == "all"{
                                self.allnews.append(newsCell)
                            }
                        }
                    }
                    self.newsTB.reloadData()
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allnews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let oneNews: News
        oneNews =  allnews[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotificationCell

        cell.lblTitle.text = oneNews.title
        cell.lblDescription.text = oneNews.description
        cell.lblDate.text = oneNews.date
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = self.getRowHeightFromText(strText: allnews[indexPath.row].description)
        return height
    }
    
    func getRowHeightFromText(strText : String!) -> CGFloat
    {
        let textView : UITextView! = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.95 - 20 ,  height: 0))
        textView.text = strText
        textView.font = UIFont(name: "system", size:  12.0)
        textView.sizeToFit()

        var txt_frame : CGRect! = CGRect()
        txt_frame = textView.frame

        var size : CGSize! = CGSize()
        size = txt_frame.size

        size.height = txt_frame.size.height

        return (size.height + 70) / 0.95
    }
    @objc func onBackPage(){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
