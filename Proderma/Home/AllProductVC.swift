//
//  AllProductVC.swift
//  Proderma
//
//  Created by bird on 2/5/21.
//

import UIKit
import JTMaterialSpinner
import SDWebImage
import Alamofire
class AllProductVC: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate{
        
    var homeVC : HomeVC!
    var oneproductVC : OneProductVC!
    var allProducts = [Product]()
    var allFilterProducts = [Product]()
    var allSearchFilterProducts = [Product]()
    var allBrands = [Brand]()
    var spinnerView = JTMaterialSpinner()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblProducts: UILabel!
    @IBOutlet weak var cvBrand: UICollectionView!
    @IBOutlet weak var cvProduct: UICollectionView!
    
    var search_Text = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cvProduct.delegate = self
        cvProduct.dataSource = self
        
        cvBrand.delegate = self
        cvBrand.dataSource = self
        searchBar.delegate = self
        setReady()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getData()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setReady(){
        lblProducts.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "products", comment: "")
        if(UserDefaults.standard.string(forKey: "lang")! == "ar"){
            btnBack.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        }
    }
    func getData(){
        allProducts = []
        allFilterProducts = []
        allBrands = []
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()

        AF.request(Global.baseUrl + "api/getProductsInfo", method: .get).responseJSON{ response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let productsInfos = value["productsInfo"] as? [[String: AnyObject]]
                let brandsInfos = value["brandsInfo"] as? [[String: AnyObject]]
                self.allBrands.append(Brand(id: "0", name: "A l l"))
                if(productsInfos!.count > 0){
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
                        self.allFilterProducts.append(productcell)
                        self.allSearchFilterProducts.append(productcell)
                    }
                }
                if(brandsInfos!.count > 0){
                    for i in 0 ... (brandsInfos!.count)-1 {
                        let id = brandsInfos![i]["id"] as! String
                        let name = brandsInfos![i]["name"] as! String
                        
                        let brandCell = Brand(id: id, name: name)
                        self.allBrands.append(brandCell)
                    }
                }
                
                self.cvProduct.reloadData()
                self.cvBrand.reloadData()
            }
        }
        
    }

    func filter(){
        allSearchFilterProducts = []
        if search_Text != nil {
            if search_Text == ""{
                for i in 0 ... allFilterProducts.count - 1{
                    allSearchFilterProducts.append(allFilterProducts[i])
                }
            }else{
                allSearchFilterProducts = allFilterProducts.filter({ (product: Product) -> Bool in
                    return product.name.lowercased().contains(search_Text.lowercased())
                })
            }
        }else{
            for i in 0 ... allFilterProducts.count - 1{
                allSearchFilterProducts.append(allFilterProducts[i])
            }
        }
        
        cvProduct.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        search_Text = searchText
        filter()

            // filterdata  = searchText.isEmpty ? data : data.filter {(item : String) -> Bool in

//            filterdata = searchText.isEmpty ? data : data.filter { $0.contains(searchText) }

            //return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil

//        tblview.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView.tag == 103){
            return allSearchFilterProducts.count
        }else{
            return allBrands.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 103{
            let oneProduct: Product
            oneProduct =  allSearchFilterProducts[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: "cell"), for: indexPath) as! AllproductCell
//            cell.mainView.layer.borderColor = UIColor(red:156/255, green:37/255, blue:31/255, alpha: 1).cgColor
            cell.productImg.sd_setImage(with: URL(string: Global.baseUrl + oneProduct.photo), completed: nil)
            cell.nameTxt.text = oneProduct.name
            return cell
        }else{
            let onBrand: Brand
            onBrand =  allBrands[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: "cell"), for: indexPath) as! BrandCell
            cell.brandTxt.text = onBrand.name
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 103{
            AppDelegate.shared().productID = allFilterProducts[indexPath.row].id
            self.oneproductVC = self.storyboard?.instantiateViewController(withIdentifier: "oneproductVC") as? OneProductVC
            self.oneproductVC.modalPresentationStyle = .fullScreen
            self.present(self.oneproductVC, animated: true, completion: nil)
        }else{
            allFilterProducts = []
            if indexPath.row == 0{
                if(allProducts.count > 0){
                    for i in 0 ... allProducts.count - 1 {
                        allFilterProducts.append(allProducts[i])
                    }
                }
            }else{
                if(allProducts.count > 0){
                    for i in 0 ... allProducts.count - 1 {
                        if allProducts[i].brandid == allBrands[indexPath.row].id{
                            allFilterProducts.append(allProducts[i])
                        }
                    }
                }
                
            }
            filter()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 103{
            return CGSize(width: (collectionView.bounds.width-40) * 0.5, height: (collectionView.bounds.width-40) * 0.5)
        }else{
            var width = self.getRowHeightFromText(strText: allBrands[indexPath.row].name)
            if width < 100{
                width = 100
            }
            return CGSize(width: width + 10, height: 40)
        }
    }

    @IBAction func onBtnBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getRowHeightFromText(strText : String!) -> CGFloat
    {
        let textView : UITextView! = UITextView(frame: CGRect(x: 0, y: 0, width: 0,  height: 40))
        textView.text = strText
        textView.font = UIFont(name: "system", size:  11.0)
        textView.sizeToFit()

        var txt_frame : CGRect! = CGRect()
        txt_frame = textView.frame

        var size : CGSize! = CGSize()
        size = txt_frame.size

        size.width = txt_frame.size.width

        return size.width
    }
}
