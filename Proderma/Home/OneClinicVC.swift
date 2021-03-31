//
//  OneClinicVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit
import Alamofire
import SDWebImage
import Toast_Swift
import JTMaterialSpinner
import ImageSlideshow
class OneClinicVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate {
    
    

    @IBOutlet weak var doctorCV: UICollectionView!
    @IBOutlet weak var offerTB: UITableView!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var clinicSlider: ImageSlideshow!
    @IBOutlet weak var nameTxt: UILabel!
    @IBOutlet weak var clinicImg: UIImageView!
    @IBOutlet weak var locationTxt: UILabel!
    @IBOutlet weak var phoneTxt: UILabel!
    @IBOutlet weak var whatsappTxt: UILabel!
    @IBOutlet weak var infoTxt: UITextView!
    
    @IBOutlet weak var offerTBHeight: NSLayoutConstraint!
    @IBOutlet weak var doctorCVHeight: NSLayoutConstraint!
    
    var spinnerView = JTMaterialSpinner()
    var inputSource: [InputSource] = []
    var image : [UIImage] = []
    var allImages = [ClinicImage]()
    var allDoctors = [Doctor]()
    var allOffers = [Offer]()
    
    var clinicID : String!
    var clinicName : String!
    var clinicLocation : String!
    var clinicLatitude : String!
    var clinicLongitude : String!
    var clinicPhone : String!
    var clinicWhatsapp : String!
    var clinicInformation : String!
    var clinicPhoto : String!
    
    @IBOutlet weak var lblInformations: UILabel!
    @IBOutlet weak var lblClinic: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        infoView.layer.borderColor = UIColor(named: "major")?.cgColor
        clinicID = AppDelegate.shared().clinicID
        doctorCV.delegate = self
        doctorCV.dataSource = self
        doctorCVHeight.constant = 0
        offerTBHeight.constant = 0
        offerTB.delegate = self
        offerTB.dataSource = self
        offerTB.register(UINib(nibName: "OfferCell", bundle: nil), forCellReuseIdentifier: "cell")
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onOpenCall))
        phoneTxt.addGestureRecognizer(gestureRecognizer)
        phoneTxt.isUserInteractionEnabled = true
        
        locationTxt.isUserInteractionEnabled = true
        whatsappTxt.isUserInteractionEnabled = true
        let gestureRecognizerw = UITapGestureRecognizer(target: self, action: #selector(onOpenWhatsapp))
        whatsappTxt.addGestureRecognizer(gestureRecognizerw)
        
        let gestureRecognizerm = UITapGestureRecognizer(target: self, action: #selector(onOpenMap))
        locationTxt.addGestureRecognizer(gestureRecognizerm)
        setReady()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        inputSource = []
        getData()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setReady(){
        lblClinic.isUserInteractionEnabled = true
        let gestureRecognizerw = UITapGestureRecognizer(target: self, action: #selector(onBackPage))
        lblClinic.addGestureRecognizer(gestureRecognizerw)
        lblClinic.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "clinic", comment: "")
        lblInformations.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "informations", comment: "")
        
        if(UserDefaults.standard.string(forKey: "lang")! == "ar"){
            btnBack.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        }
    }
    @objc func onOpenCall(){
        let moblestr = "tel://" + phoneTxt.text!
        guard let number = URL(string: moblestr) else { return }
        UIApplication.shared.open(number)
    }
    @objc func onOpenWhatsapp(){
        let urlWhats = "whatsapp://send?phone=" + whatsappTxt.text!
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL) {
                    UIApplication.shared.openURL(whatsappURL)
                } else {
                    let whatsappURL = URL(string: "https://api.whatsapp.com/send?phone=" + whatsappTxt.text!)
                    if UIApplication.shared.canOpenURL(whatsappURL!) {
                        UIApplication.shared.open(whatsappURL!, options: [:], completionHandler: nil)
                        }
                    print("Install Whatsapp")
                }
            }
        }
    }
    @objc func onOpenMap(){
        let mapURL = "https://www.google.com/maps/@" + clinicLatitude + "," + clinicLongitude + ",14z"
        let whatsappURL = URL(string: mapURL)
        if UIApplication.shared.canOpenURL(whatsappURL!) {
            UIApplication.shared.open(whatsappURL!, options: [:], completionHandler: nil)
            }
    }
    func getData(){
        allDoctors = []
        allOffers = []
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["id": clinicID!]
        AF.request(Global.baseUrl + "api/getClinicInfo", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let doctorInfos = value["doctorsInfo"] as? [[String: AnyObject]]
                let offerInfos = value["clinicOffer"] as? [[String: AnyObject]]
                let clinicImages = value["clinicImages"] as? [[String: AnyObject]]
                let clinicInfo = value["clinicInfo"] as? [String: AnyObject]
                if(doctorInfos!.count > 0){
                    for i in 0 ... (doctorInfos!.count)-1 {
                        let id = doctorInfos![i]["id"] as! String
                        let clinicid = doctorInfos![i]["clinicid"] as! String
                        let name = doctorInfos![i]["name"] as! String
                        let photo = doctorInfos![i]["photo"] as! String
                        let description = doctorInfos![i]["information"] as! String
                        let status = doctorInfos![i]["status"] as! String
                        
                        let doctorCell = Doctor(id: id, clinicid: clinicid, name: name, photo: photo, description: description, status: status)
                        self.allDoctors.append(doctorCell)
                    }
                    self.doctorCVHeight.constant = 200
                }
                if(offerInfos!.count > 0){
                    for i in 0 ... (offerInfos!.count)-1 {
                        let id = offerInfos![i]["id"] as! String
                        let clinicid = offerInfos![i]["clinicid"] as! String
                        let title = offerInfos![i]["title"] as! String
                         let description = offerInfos![i]["description"] as! String
                        let status = offerInfos![i]["status"] as! String
                        
                        let offercell = Offer(id: id, clinicid: clinicid, title: title, description: description, status: status)
                        self.allOffers.append(offercell)
                    }
                    self.offerTBHeight.constant = 300
                }
                if(clinicImages!.count > 0){
                    for i in 0 ... (clinicImages!.count)-1 {
                        let id = clinicImages![i]["id"] as! String
                        let clinicid = clinicImages![i]["clinicid"] as! String
                        let photo = clinicImages![i]["url"] as! String
                        let status = clinicImages![i]["status"] as! String

                        let imagecell = ClinicImage(id: id, clinicid: clinicid, photo: photo, status: status)
                        self.allImages.append(imagecell)
                        self.inputSource.append(AlamofireSource(urlString: Global.baseUrl + photo)!)
                    }
                }
                self.clinicName = clinicInfo!["clinicname"] as? String
                self.clinicLocation = clinicInfo!["location"] as? String
                self.clinicPhone = clinicInfo!["mobile"] as? String
                self.clinicWhatsapp = clinicInfo!["whatsapp"] as? String
                self.clinicPhoto = clinicInfo!["photo"] as? String
                self.clinicInformation = clinicInfo!["information"] as? String
                self.clinicLatitude = clinicInfo!["latitude"] as? String
                self.clinicLongitude = clinicInfo!["longitude"] as? String
//
                self.showInfo();
                self.clinicSlider.setImageInputs(self.inputSource)
                self.doctorCV.reloadData()
                self.doctorCV.updateConstraints()
                self.offerTB.reloadData()
                self.offerTB.updateConstraints()
            }
        }
    }
    func showInfo(){
        nameTxt.text = clinicName
        locationTxt.text = clinicLocation
        phoneTxt.text = clinicPhone
        whatsappTxt.text = clinicWhatsapp
        infoTxt.text = clinicInformation
        clinicImg.sd_setImage(with: URL(string: Global.baseUrl + clinicPhoto), completed: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allOffers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OfferCell
        cell.infoTxt.text = allOffers[indexPath.row].description
        cell.titleTxt.text = allOffers[indexPath.row].title
        cell.mainView.layer.borderColor = UIColor(named: "major")?.cgColor
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = self.getRowHeightFromText(strText: allOffers[indexPath.row].description)
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

        return (size.height + 40) / 0.95
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allDoctors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let oneDoctor: Doctor
        oneDoctor =  allDoctors[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: "cell"), for: indexPath) as! HomeDoctorCell
        cell.doctorImg.sd_setImage(with: URL(string: Global.baseUrl + oneDoctor.photo), completed: nil)
        cell.nameTxt.text = oneDoctor.name
        cell.infoTxt.text = oneDoctor.description
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: collectionView.bounds.height)
    }
    @objc func onBackPage(){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
