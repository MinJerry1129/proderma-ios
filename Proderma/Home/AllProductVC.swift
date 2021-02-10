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
class AllProductVC: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
        
    var homeVC : HomeVC!
    var oneproductVC : OneProductVC!
    var allProducts = [Product]()
    var spinnerView = JTMaterialSpinner()
    @IBOutlet weak var cvProduct: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        cvProduct.delegate = self
        cvProduct.dataSource = self
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getData()
    }
    
    func getData(){
        allProducts = []
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
                
                for i in 0 ... (productsInfos!.count)-1 {
                    let id = productsInfos![i]["id"] as! String
                    let name = productsInfos![i]["name"] as! String
                    let price = productsInfos![i]["price"] as! String
                    let photo = productsInfos![i]["photo"] as! String
                    let description = productsInfos![i]["information"] as! String
                    
                    let productcell = Product(id: id, name: name, price: price, photo: photo, description: description)
                    self.allProducts.append(productcell)
                }
                self.cvProduct.reloadData()
            }
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let oneProduct: Product
        oneProduct =  allProducts[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: "cell"), for: indexPath) as! AllproductCell
        cell.mainView.layer.borderColor = UIColor(red:156/255, green:37/255, blue:31/255, alpha: 1).cgColor
        cell.productImg.sd_setImage(with: URL(string: Global.baseUrl + oneProduct.photo), completed: nil)
        cell.nameTxt.text = oneProduct.name
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AppDelegate.shared().productID = allProducts[indexPath.row].id
        self.oneproductVC = self.storyboard?.instantiateViewController(withIdentifier: "oneproductVC") as? OneProductVC
        self.oneproductVC.modalPresentationStyle = .fullScreen
        self.present(self.oneproductVC, animated: true, completion: nil)

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width-40) * 0.5, height: (collectionView.bounds.width-40) * 0.5)
    }

    @IBAction func onBtnBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
