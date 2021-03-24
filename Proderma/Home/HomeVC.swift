//
//  HomeVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit
import Alamofire
import SDWebImage
import Toast_Swift
import JTMaterialSpinner
import FirebaseInstanceID

class HomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    var allproductVC : AllProductVC!
    var allclinicVC : AllClinicVC!
    var oneproductVC : OneProductVC!
    var oneclinicVC : OneClinicVC!
    
    var chatVC : ChatVC!
    var historyhomeVC : HistoryHomeVC!
    var settinghomeVC : SettingHomeVC!
    var eventhomeVC : EventHomeVC!
    var clinichomeVC : ClinicHomeVC!
    var clinicnormalVC : ClinicNormalVC!
    var loghomeVC : LogHomeVC!
    
    var spinnerView = JTMaterialSpinner()

    @IBOutlet weak var txtNews: UITextView!
    @IBOutlet weak var cvProduct: UICollectionView!
    @IBOutlet weak var cvClinic: UICollectionView!
    
    var deviceID : String!
    var deviceToken : String!
    var allClinics = [Clinic]()
    var allProducts = [Product]()
    var loginstatus :String!
    var usertype : String!
    
    @IBOutlet weak var btnPSeeAll: UIButton!
    @IBOutlet weak var btnCSeeAll: UIButton!
    
    @IBOutlet weak var lblLastNews: UILabel!
    @IBOutlet weak var lblClinics: UILabel!
    @IBOutlet weak var lblProducts: UILabel!
    
    @IBOutlet weak var lblClinic: UILabel!
    @IBOutlet weak var lblEvent: UILabel!
    @IBOutlet weak var lblChat: UILabel!
    @IBOutlet weak var lblHistory: UILabel!
    @IBOutlet weak var lblSetting: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        cvClinic.delegate = self
        cvClinic.dataSource = self
        cvProduct.delegate = self
        cvProduct.dataSource = self
        setReady()
        
        
        usertype = AppDelegate.shared().userType
        txtNews.text = "PRODERMA ME was developed in 2007 in Dubai, in response to the ever --- growing demand and need for a complete Aeshetic, representing only approved worldwide aesthetic companies"
        getData()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setReady(){
        btnPSeeAll.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "see_all", comment: ""), for: .normal)
        btnCSeeAll.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "see_all", comment: ""), for: .normal)
        lblLastNews.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "lastnews", comment: "")
        lblClinics.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "clinics", comment: "")
        lblProducts.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "products", comment: "")
        
        lblClinic.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "clinic", comment: "")
        lblEvent.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "event", comment: "")
        lblChat.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "chat", comment: "")
        lblHistory.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "history", comment: "")
        lblSetting.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "setting", comment: "")        
    }
    func getData(){
        allProducts = []
        allClinics = []
        deviceID = UIDevice.current.identifierForVendor?.uuidString
        deviceToken = AppDelegate.shared().fcmtoken
        loginstatus = AppDelegate.shared().loginStatus

        //
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["deviceid": deviceID!, "phonetoken": deviceToken!]
        AF.request(Global.baseUrl + "api/getHomeData", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let clinicInfos = value["clinicsInfo"] as? [[String: AnyObject]]
                let productsInfos = value["productsInfo"] as? [[String: AnyObject]]
                if clinicInfos!.count > 0{
                    for i in 0 ... (clinicInfos!.count)-1 {
                        let id = clinicInfos![i]["id"] as! String
                        let name = clinicInfos![i]["clinicname"] as! String
                        let location = clinicInfos![i]["location"] as! String
                        let photo = clinicInfos![i]["photo"] as! String
                        let description = clinicInfos![i]["information"] as! String
                        let phone = clinicInfos![i]["mobile"] as! String
                        let whatsapp = clinicInfos![i]["whatsapp"] as! String
                        let doctor = "0"
                        let latitude = clinicInfos![i]["latitude"] as! String
                        let longitude = clinicInfos![i]["longitude"] as! String
                        
                        let cliniccell = Clinic(id: id, name: name, location: location, photo: photo, description: description, phone: phone, whatsapp: whatsapp, doctor: doctor, latlng: latitude+","+longitude, latitude: latitude, longitude: longitude)
                        self.allClinics.append(cliniccell)
                    }
                }
                if productsInfos!.count > 0{
                    for i in 0 ... (productsInfos!.count)-1 {
                        let id = productsInfos![i]["id"] as! String
                        let brandid = productsInfos![i]["brandid"] as! String
                        let name = productsInfos![i]["name"] as! String
                        let price = productsInfos![i]["price"] as! String
                        let percent = productsInfos![i]["percent"] as! String
                        let photo = productsInfos![i]["photo"] as! String
                        let description = productsInfos![i]["information"] as! String
                        
                        let productcell = Product(id: id,brandid: brandid, name: name, price: price, percent: percent, photo: photo, description: description)
                        self.allProducts.append(productcell)
                    }
                }
                
                self.cvClinic.reloadData()
                self.cvProduct.reloadData()
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView.tag == 101){
            if(allProducts.count > 5){
                return 5
            }else{
                return allProducts.count
            }
        }else{
            if(allClinics.count > 5){
                return 5
            }else{
                return allClinics.count
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 101{
            let oneProduct: Product
            oneProduct =  allProducts[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: "cell"), for: indexPath) as! HomeproductCell
//            cell.mainView.layer.borderColor = UIColor(red:156/255, green:37/255, blue:31/255, alpha: 1).cgColor
            cell.productImg.sd_setImage(with: URL(string: Global.baseUrl + oneProduct.photo), completed: nil)
            cell.nameTxt.text = oneProduct.name
            return cell
        }else{
            let oneClinic: Clinic
            oneClinic = allClinics[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: "cell"), for: indexPath) as! HomeclinicCell
//            cell.mainView.layer.borderColor = UIColor(red:156/255, green:37/255, blue:31/255, alpha: 1).cgColor
            cell.clinicImg.sd_setImage(with: URL(string: Global.baseUrl + oneClinic.photo), completed: nil)
            cell.nameTxt.text = oneClinic.name
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 101 {
            AppDelegate.shared().productID = allProducts[indexPath.row].id
            self.oneproductVC = self.storyboard?.instantiateViewController(withIdentifier: "oneproductVC") as? OneProductVC
            self.oneproductVC.modalPresentationStyle = .fullScreen
            self.present(self.oneproductVC, animated: true, completion: nil)
            
        }else{
            AppDelegate.shared().clinicID = allClinics[indexPath.row].id
            self.oneclinicVC = self.storyboard?.instantiateViewController(withIdentifier: "oneclinicVC") as? OneClinicVC
            self.oneclinicVC.modalPresentationStyle = .fullScreen
            self.present(self.oneclinicVC, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.height * 0.95, height: collectionView.bounds.height * 0.95)
    }
    
    @IBAction func onBtnAllProduct(_ sender: Any) {
        self.allproductVC = self.storyboard?.instantiateViewController(withIdentifier: "allproductVC") as? AllProductVC
        self.allproductVC.modalPresentationStyle = .fullScreen
        self.present(self.allproductVC, animated: true, completion: nil)
    }
    
    @IBAction func onBtnAllClinic(_ sender: Any) {
        self.allclinicVC =     self.storyboard?.instantiateViewController(withIdentifier: "allclinicVC") as? AllClinicVC
        self.allclinicVC.modalPresentationStyle = .fullScreen
        self.present(self.allclinicVC, animated: true, completion: nil)
    }
    
    @IBAction func onBtnClinic(_ sender: Any) {
        if loginstatus == "no"{
            self.loghomeVC = self.storyboard?.instantiateViewController(withIdentifier: "loghomeVC") as? LogHomeVC
            self.loghomeVC.modalPresentationStyle = .fullScreen
            self.present(self.loghomeVC, animated: true, completion: nil)
        }else{
            if usertype == "elite"{
                self.clinichomeVC = self.storyboard?.instantiateViewController(withIdentifier: "clinichomeVC") as? ClinicHomeVC
                self.clinichomeVC.modalPresentationStyle = .fullScreen
                self.present(self.clinichomeVC, animated: true, completion: nil)
            }else{
                self.clinicnormalVC = self.storyboard?.instantiateViewController(withIdentifier: "clinicnormalVC") as? ClinicNormalVC
                self.clinicnormalVC.modalPresentationStyle = .fullScreen
                self.present(self.clinicnormalVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func onBtnEvent(_ sender: Any) {
        self.eventhomeVC = self.storyboard?.instantiateViewController(withIdentifier: "eventhomeVC") as? EventHomeVC
        self.eventhomeVC.modalPresentationStyle = .fullScreen
        self.present(self.eventhomeVC, animated: true, completion: nil)
    }
    
    @IBAction func onBtnChat(_ sender: Any) {
        self.chatVC = self.storyboard?.instantiateViewController(withIdentifier: "chatVC") as? ChatVC
        self.chatVC.modalPresentationStyle = .fullScreen
        self.present(self.chatVC, animated: true, completion: nil)
    }
    
    @IBAction func onBtnHistory(_ sender: Any) {
        if loginstatus == "no"{
            self.loghomeVC = self.storyboard?.instantiateViewController(withIdentifier: "loghomeVC") as? LogHomeVC
            self.loghomeVC.modalPresentationStyle = .fullScreen
            self.present(self.loghomeVC, animated: true, completion: nil)
        }else{
            self.historyhomeVC = self.storyboard?.instantiateViewController(withIdentifier: "historyhomeVC") as? HistoryHomeVC
            self.historyhomeVC.modalPresentationStyle = .fullScreen
            self.present(self.historyhomeVC, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func onBtnSetting(_ sender: Any) {
        self.settinghomeVC = self.storyboard?.instantiateViewController(withIdentifier: "settinghomeVC") as? SettingHomeVC
        self.settinghomeVC.modalPresentationStyle = .fullScreen
        self.present(self.settinghomeVC, animated: true, completion: nil)
    }
    
}
