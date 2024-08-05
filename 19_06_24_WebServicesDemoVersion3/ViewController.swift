//
//  ViewController.swift
//  19_06_24_WebServicesDemoVersion3
//
//  Created by Vishal Jagtap on 05/08/24.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {

    @IBOutlet weak var productsCollectionView: UICollectionView!
    var url : URL?
    var urlRequest : URLRequest?
    var urlSession : URLSession?
    var products : [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initlializeViews()
        registerCellWithXIB()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        parseJSON()
    }
    
    private func registerCellWithXIB(){
        let uiNib = UINib(nibName: Constants.reuseIdentifierForProductsCollectionViewCell, bundle: nil)
        self.productsCollectionView.register(uiNib, forCellWithReuseIdentifier: Constants.reuseIdentifierForProductsCollectionViewCell)
    }
    
    private func initlializeViews(){
        productsCollectionView.delegate = self
        productsCollectionView.dataSource = self
    }
    
    
    private func parseJSON(){
        url = URL(string: Constants.urlString)
        
        urlRequest = URLRequest(url: url!)
        urlRequest?.httpMethod = "GET"
        
        urlSession = URLSession(configuration: .default)
        
        let productDataTask = urlSession?.dataTask(with: urlRequest!, completionHandler: { data, response, error in
            do{
                let productApiResponse = try JSONSerialization.jsonObject(with: data!) as! [[String:Any]]
                
                for eachProduct in productApiResponse{
                    let eachProductId = eachProduct["id"] as! Int
                    let eachProductTitle = eachProduct["title"] as! String
                    let eachProductPrice = eachProduct["price"] as! Double
                    let eachProductDescription = eachProduct["description"] as! String
                    let eachProductCategory = eachProduct["category"] as! String
                    let eachProductImage = eachProduct["image"] as! String
                    
                    
                    let eachProductRating = eachProduct["rating"] as! [String:Any]  //imp as there is nesting
                    let eachProductRate = eachProductRating["rate"] as! Double
                    let eachProductCount = eachProductRating["count"] as! Int
                    
                    let parsedJSONObject = Product(
                        id: eachProductId,
                        title: eachProductTitle,
                        price: eachProductPrice,
                        description: eachProductDescription,
                        category: eachProductCategory,
                        image: eachProductImage,
                        rate: eachProductRate,
                        count: eachProductCount)
                    
                    self.products.append(parsedJSONObject)
                    
                    print(self.products)
                }
                
                DispatchQueue.main.async {
                    self.productsCollectionView.reloadData()
                }
            }catch{
                print(error)
            }
        })
        
        productDataTask?.resume()
    }
}

extension ViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let productCollectionViewCell = self.productsCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.reuseIdentifierForProductsCollectionViewCell, for: indexPath) as! ProductCollectionViewCell
        productCollectionViewCell.backgroundColor = .cyan
        productCollectionViewCell.layer.borderColor = CGColor(red: 0.0, green: 100.0, blue: 100.0, alpha: 3.0)
        productCollectionViewCell.layer.borderWidth = 9.0
        
        productCollectionViewCell.productImageView.kf.setImage(
            with: URL(string: products[indexPath.item].image),
            placeholder: UIImage(named: "test_image_2")
        )
        
        productCollectionViewCell.productLabel.text = String(products[indexPath.item].rate)
        productCollectionViewCell.productLabel.backgroundColor = .orange
        
        return productCollectionViewCell
    }
}

extension ViewController : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }
}

extension ViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthofCollectionView = self.productsCollectionView.frame.width
        return CGSize(width: widthofCollectionView/2.5, height: widthofCollectionView/2.0)
    }
}
