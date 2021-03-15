//
//  AllClinicVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit
import Alamofire
import SDWebImage
import JTMaterialSpinner
import CoreLocation
import Toast_Swift
import MapKit
class AllClinicVC: UIViewController ,UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var homeVC : HomeVC!
    var oneclinicVC : OneClinicVC!
    var allClinics = [Clinic]()
    var clatitude : String!
    var clongtitude : String!
    let locationManager = CLLocationManager()
    var spinnerView = JTMaterialSpinner()
    var currentlocation : CLLocation!

    @IBOutlet weak var clinicTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        clinicTable.delegate = self
        clinicTable.dataSource = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    self.view.makeToast("To show clinic list, you must enable location.")
                    print("No access")
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
                @unknown default:
                break
            }
            
        }else{
            print("not allowed")
        }
//        getData()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        clatitude = "\(locValue.latitude)"
        clongtitude = "\(locValue.longitude)"
        currentlocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        print("locations = " + clatitude + ":" + clongtitude)
        getData()
    }
    func getData(){
        allClinics = []
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()

        AF.request(Global.baseUrl + "api/getClinicsInfo", method: .get).responseJSON{ response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let clinicsInfos = value["clinicsInfo"] as? [[String: AnyObject]]
                
                
                if(clinicsInfos!.count > 0){
                    for i in 0 ... (clinicsInfos!.count)-1 {
                        let id = clinicsInfos![i]["id"] as! String
                        let name = clinicsInfos![i]["clinicname"] as! String
                        let location = clinicsInfos![i]["location"] as! String
                        let photo = clinicsInfos![i]["photo"] as! String
                        let description = clinicsInfos![i]["information"] as! String
                        let phone = clinicsInfos![i]["mobile"] as! String
                        let whatsapp = clinicsInfos![i]["whatsapp"] as! String
                        let doctor = "0"
                        let latitude = clinicsInfos![i]["latitude"] as! String
                        let longitude = clinicsInfos![i]["longitude"] as! String
                        
                        let cliniccell = Clinic(id: id, name: name, location: location, photo: photo, description: description, phone: phone, whatsapp: whatsapp, doctor: doctor, latlng: latitude + "," + longitude, latitude: latitude, longitude: longitude)
                        self.allClinics.append(cliniccell)
                    }
                    self.sortList()
                }
                
            }
        }
        
    }
    func sortList(){
        for i in 0 ... (allClinics.count)-1 {
            if( i < allClinics.count - 1){
                if(allClinics.count > 1){
                    for j in i + 1 ... (allClinics.count)-1 {
                        let oneClinic: Clinic
                        let coordinatei = CLLocation(latitude: Double(allClinics[i].latitude)!, longitude: Double(allClinics[i].longitude)!)
                        let coordinatej = CLLocation(latitude: Double(allClinics[j].latitude)!, longitude: Double(allClinics[j].longitude)!)
                        if(currentlocation.distance(from: coordinatei) > currentlocation.distance(from: coordinatej)){
                            oneClinic = allClinics[i]
                            allClinics[i] = allClinics[j]
                            allClinics[j] = oneClinic
                        }
                    }
                }                
            }
            
        }
        self.clinicTable.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allClinics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let oneClinic: Clinic
        oneClinic =  allClinics[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AllClinicCell
        cell.clinicImg.sd_setImage(with: URL(string: Global.baseUrl + oneClinic.photo), completed: nil)
        cell.nameTxt.text = oneClinic.name
        cell.addressTxt.text = oneClinic.location
        cell.phoneTxt.text = oneClinic.phone
        cell.whatsappTxt.text = oneClinic.whatsapp
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppDelegate.shared().clinicID = allClinics[indexPath.row].id
        self.oneclinicVC = self.storyboard?.instantiateViewController(withIdentifier: "oneclinicVC") as? OneClinicVC
        self.oneclinicVC.modalPresentationStyle = .fullScreen
        self.present(self.oneclinicVC, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    @IBAction func onBtnBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
