//
//  DetailViewController.swift
//  MovieApp
//
//  Created by Vikalp on 03/11/17.
//  Copyright © 2017 Vikalp. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imgViewPoster: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    var dictData  = Dictionary<String, AnyObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dictData)
        
        lblDate.text = dictData["release_date"] as?String
        let voting = dictData["vote_average"] as? Float
        lblRating.text = "\(voting!)"
        if let imgURL = dictData["poster_path"] as? String
        {
            let imgUrl = "\(imageURLPrefix)/w780/\(imgURL)"
            imgViewPoster.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "placeholder.jpeg"))
        }
        
        lblTitle.text = dictData["original_title"] as? String
        lblDescription.text = dictData["overview"] as? String
        
        lblRating.layer.cornerRadius = 6.0
        lblRating.layer.masksToBounds = true
        
        self.title = lblTitle.text
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
