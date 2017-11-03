//
//  ViewController.swift
//  MovieApp
//
//  Created by Vikalp on 03/11/17.
//  Copyright © 2017 Vikalp. All rights reserved.
//

import UIKit
import SystemConfiguration
import SDWebImage

let APIKey = "7b7162faab5a3c0a1126b3fc479a1bb2"
let APIURLPrefix = "https://api.themoviedb.org/3"
let imageURLPrefix = "https://image.tmdb.org/t/p"
let cellIdentifier = "cell"

class ViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UISearchBarDelegate,UICollectionViewDelegateFlowLayout {

    //MARK: View Outlets
    @IBOutlet weak var collView: UICollectionView!
    @IBOutlet weak var searchField: UISearchBar!
    
    var arrMovies = [AnyObject]()
    var arrFilteredMovies = [AnyObject]()
    var pageIndex = 0
    var searchActive : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getListOfAllMovies(sort: "popularity.desc")
        
        self.title = "Home"
    }
    
    //MARK: Search Bar Delegate
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool
    {
        return true
    }
    
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar)
    {
      searchBar.resignFirstResponder()
      if isInternetAvailable() {
        
        let trimmedString = searchBar.text?.trimmingCharacters(in: .whitespaces)
        
          let url = NSURL(string: "\(APIURLPrefix)/search/movie?api_key=7b7162faab5a3c0a1126b3fc479a1bb2&query=\(trimmedString ?? "Batman")")! as URL
          let req = NSMutableURLRequest.init(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 100)
          self.dataTask(request: req , method: "GET") { (success, response) in
              if success
              {
                  self.arrFilteredMovies = response!["results"] as! [AnyObject]
                  let page = response!["page"] as? Int
                  self.pageIndex = page!
                  if(self.arrFilteredMovies.count == 0){
                      self.searchActive = false;
                  } else {
                      self.searchActive = true;
                  }
                
                  DispatchQueue.main.async {
                      self.collView.reloadData()
                      self.collView.setContentOffset(CGPoint.zero, animated: true)
                  }
              }
          }
      }
    }
    
    
    //MARK: CollectionView View Datasource
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width/2 - 5 , height: 186)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchActive {
            return arrFilteredMovies.count
        }
        return arrMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MovieCollectionViewCell
        
        if searchActive
        {
            let dictData = arrFilteredMovies[indexPath.row] as? Dictionary<String,AnyObject>
            cell.lblYear.text = dictData!["release_date"] as?String
            let voting = dictData!["vote_average"] as? Float
            cell.lblRating.text = "\(voting!)"
            if let imgURL = dictData!["poster_path"] as? String
            {
                let imgUrl = "\(imageURLPrefix)/w780/\(imgURL)"
                cell.imgViewMovie.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "placeholder.jpeg"))
            }
        }
        else
        {
            let dictData = arrMovies[indexPath.row] as? Dictionary<String,AnyObject>
            cell.lblYear.text = dictData!["release_date"] as?String
            let voting = dictData!["vote_average"] as? Float
            cell.lblRating.text = "\(voting!)"
            
            if let imgURL = dictData!["poster_path"] as? String
            {
                let imgUrl = "\(imageURLPrefix)/w780/\(imgURL)"
                cell.imgViewMovie.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "placeholder.jpeg"))
            }
        }
        
        return cell;
    }
    
    //MARK: Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailView = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        if searchActive {
            detailView.dictData = arrFilteredMovies[indexPath.row] as! [String : AnyObject]
        }
        else
        {
            detailView.dictData = arrMovies[indexPath.row] as! [String : AnyObject]
        }
        self.navigationController?.pushViewController(detailView, animated: true)
    }
    
    //MARK: scroll view delegate
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        //Bottom Refresh
        
        if scrollView == collView{
            
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
            {
                loadMoreMovies()
            }
        }
    }
    
    //MARK: Get movie list
    
    func getListOfAllMovies(sort : String)
    {
        if isInternetAvailable() {
            let url = NSURL(string: "\(APIURLPrefix)/discover/movie?api_key=7b7162faab5a3c0a1126b3fc479a1bb2&sort_by=\(sort)")! as URL
            let req = NSMutableURLRequest.init(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 100)
            self.dataTask(request: req , method: "GET") { (success, response) in
                if success
                {
                    self.arrMovies = response!["results"] as! [AnyObject]
                    let page = response!["page"] as? Int
                    self.pageIndex = page!
                    DispatchQueue.main.async {
                        self.collView.reloadData()
                    }
                }
            }
        }
    }
    
    //MARK: Load more movies on last scroll index
    
    func loadMoreMovies()
    {
        if isInternetAvailable() {
            self.pageIndex = pageIndex + 1
            let url = NSURL(string: "\(APIURLPrefix)/discover/movie?api_key=7b7162faab5a3c0a1126b3fc479a1bb2&page=\(self.pageIndex)")! as URL
            let req = NSMutableURLRequest.init(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 100)
            self.dataTask(request: req , method: "GET") { (success, response) in
                if success
                {
                    //self.pageIndex = (response!["page"] as! NSString).integerValue
                    DispatchQueue.main.async {
                        let arrData = response!["results"] as? [AnyObject]
                        for item in arrData!
                        {
                            self.arrMovies.append(item)
                        }
                        self.collView.reloadData()
                    }
                }
            }
        }
    }
    
    //MARK: Common Datatask
    
    private func dataTask(request: NSMutableURLRequest, method: String, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        request.httpMethod = method
        
        DispatchQueue.main.async {
           // SwiftLoader.show(animated: true)
        }

        //Creating session with the url
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        // Session task to download the data
        session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                DispatchQueue.main.async {
                   // SwiftLoader.hide()
                }
                
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    completion(true, json as AnyObject)
                } else {
                    completion(false, json as AnyObject)
                }
            }
            }.resume()
    }
    
    
    
    //MARK: Check for internet connection
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    
    @IBAction func btnSortAction(_ sender: Any) {
        searchField.resignFirstResponder()
        let otherAlert = UIAlertController(title: "Sort Movies", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)

        let printSomething = UIAlertAction(title: "Sort by Rating", style: UIAlertActionStyle.default) { _ in
        self.getListOfAllMovies(sort: "vote_average.desc")
    }

        let callFunction = UIAlertAction(title: "Sort by Popularity", style: UIAlertActionStyle.default)
    { _ in
        self.getListOfAllMovies(sort: "popularity.desc")
    }

        let dismiss = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)

    // relate actions to controllers
    otherAlert.addAction(printSomething)
    otherAlert.addAction(callFunction)
    otherAlert.addAction(dismiss)

       self.present(otherAlert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

