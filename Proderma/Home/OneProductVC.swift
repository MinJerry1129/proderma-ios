//
//  OneProductVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit
import ImageSlideshow
import Alamofire
import SDWebImage
import JTMaterialSpinner

class OneProductVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var productSlider: ImageSlideshow!
    @IBOutlet weak var nameTxt: UILabel!
    @IBOutlet weak var countTxt: UITextField!
    @IBOutlet weak var extraTxt: UITextField!
    @IBOutlet weak var descriptionTxt: UITextView!
    @IBOutlet weak var productCV: UICollectionView!
    @IBOutlet weak var orderBtn: UIButton!
    @IBOutlet weak var cvConstraint: NSLayoutConstraint!
    @IBOutlet weak var priceViewHeight: NSLayoutConstraint!
    @IBOutlet weak var clinicViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var infoView: UIView!
    
    
    var productinfoVC : ProductInfoVC!
    var productID : String!
    var productName : String!
    var productPrice : String!
    var productPercent : String!
    var productInformation : String!
    var productPhoto : String!
    var clinicID : String!
    var userType : String!
    var loginStatus = "no"
    
    var allClinics = [Clinic]()
    var allImages = [ProductImage]()
    var spinnerView = JTMaterialSpinner()
    var image : [UIImage] = []
    var inputSource: [InputSource] = []
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblProduct: UILabel!
    @IBOutlet weak var lblMoreinfo: UIButton!
    @IBOutlet weak var lblQuality: UILabel!
    @IBOutlet weak var lblInformations: UILabel!
    @IBOutlet weak var btnOrder: UIButton!
    
    @IBOutlet weak var lblClinicProduct: UILabel!
    
    override func viewDidLoad() {
        productID = AppDelegate.shared().productID
        loginStatus = AppDelegate.shared().loginStatus
        clinicID = AppDelegate.shared().currentClinicID
        userType = AppDelegate.shared().userType
        super.viewDidLoad()
        productCV.delegate = self
        productCV.dataSource = self
        setReady()
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.black
        productSlider.pageIndicator = pageControl
        productSlider.activityIndicator = DefaultActivityIndicator()
        priceView.layer.borderColor = UIColor(named: "major")?.cgColor
        infoView.layer.borderColor = UIColor(named: "major")?.cgColor
        clinicViewHeight.constant = 0
        if loginStatus == "no"{
            cvConstraint.constant = 10
            priceViewHeight.constant = 0
            orderBtn.isHidden = true
        }
        countTxt.addTarget(self, action: #selector(countChange), for: .editingChanged)
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setReady(){
        lblProduct.isUserInteractionEnabled = true
        let gestureRecognizerw = UITapGestureRecognizer(target: self, action: #selector(onBackPage))
        lblProduct.addGestureRecognizer(gestureRecognizerw)
        lblProduct.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "products", comment: "")
        lblMoreinfo.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "moreinfo", comment: ""), for: .normal)
        lblClinicProduct.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "clinichaveproduct", comment: "")
        lblQuality.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "quality", comment: "")
        lblInformations.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "informations", comment: "")
        btnOrder.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "order", comment: ""), for: .normal)
        
        if(UserDefaults.standard.string(forKey: "lang")! == "ar"){
            btnBack.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        }
    }
    @objc func countChange(){
        if userType == "elite"{
            if(countTxt.text == ""){
                extraTxt.text = "0"
            }else{
                let countInt = Int(countTxt.text!)
                let percentInt = Int(productPercent)
                let extraInt = countInt! * percentInt!/100
                extraTxt.text = "\(extraInt)"
            }
        }else{
            extraTxt.text = "0"
        }
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        inputSource = []
        getData()
    }
    func getData(){
        allClinics = []
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["id": productID!]
        AF.request(Global.baseUrl + "api/getProductInfo", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let clinicInfos = value["productOrder"] as? [[String: AnyObject]]
                let productImages = value["productImages"] as? [[String: AnyObject]]
                let productInfo = value["productInfo"] as? [String: AnyObject]
                if(clinicInfos!.count > 0){
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
                    self.clinicViewHeight.constant = 150
                }
                if(productImages!.count > 0){
                    for i in 0 ... (productImages!.count)-1 {
                        let id = productImages![i]["id"] as! String
                        let productid = productImages![i]["productid"] as! String
                        let photo = productImages![i]["url"] as! String
                        let status = productImages![i]["status"] as! String
                                            
                        let imagecell = ProductImage(id: id, productid: productid, photo: photo, status: status)
                        self.allImages.append(imagecell)
                        self.inputSource.append(AlamofireSource(urlString: Global.baseUrl + photo)!)                        
                    }
                }
                self.productName = productInfo!["name"] as! String
                self.productPrice = productInfo!["price"] as! String
                self.productPercent = productInfo!["percent"] as! String
                self.productInformation = productInfo!["information"] as! String
                self.productPhoto = productInfo!["photo"] as! String
                if(UserDefaults.standard.string(forKey: "lang")! == "ar"){
                    self.productName = productInfo!["namear"] as! String
                    self.productInformation = productInfo!["informationar"] as! String
                }
                
                self.showInfo();
                self.productSlider.setImageInputs(self.inputSource)
                self.productCV.reloadData()
                self.productCV.updateConstraints()
            }
        }
    }
    
    func showInfo(){
        nameTxt.text = productName
        descriptionTxt.text = productInformation
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {           return allClinics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let oneClinic: Clinic
        oneClinic = allClinics[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: "cell"), for: indexPath) as! ProductClinicCell
//        cell.mainView.layer.borderColor = UIColor(red:156/255, green:37/255, blue:31/255, alpha: 1).cgColor
        cell.clinicImg.sd_setImage(with: URL(string: Global.baseUrl + oneClinic.photo), completed: nil)
        cell.nameTxt.text = oneClinic.name
        return cell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.height * 0.95, height: collectionView.bounds.height * 0.95)
    }
    
    @IBAction func onInfoBtn(_ sender: Any) {
        self.productinfoVC = self.storyboard?.instantiateViewController(withIdentifier: "productinfoVC") as? ProductInfoVC
        self.productinfoVC.modalPresentationStyle = .fullScreen
        self.present(self.productinfoVC, animated: true, completion: nil)
    }
    
    @IBAction func onOrderProduct(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let now = Date()
        let dateString = formatter.string(from: now)
        print(dateString)
        if countTxt.text! != ""{
            if Int(countTxt.text!)! > 0{
                self.view.addSubview(spinnerView)
                spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
                spinnerView.circleLayer.lineWidth = 2.0
                spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
                spinnerView.beginRefreshing()
                let parameters: Parameters = ["clinicid": clinicID!,"productid": productID!,"count": countTxt.text!,"extra": extraTxt.text!,"date": dateString]
                AF.request(Global.baseUrl + "api/requestOrder", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
                    print(response)
                    self.spinnerView.endRefreshing()
                    if let value = response.value as? [String: AnyObject] {
                        let result = value["result"] as! String
                        if(result == "ok"){
                            self.view.makeToast("Request order product success!")
                        }else{
                            self.view.makeToast("Request order product fail!")
                        }
                       
                    }
                }
            }
        }else{
            self.view.makeToast("Input Quantity of product")
        }
        
    }
    @objc func onBackPage(){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onBactBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
