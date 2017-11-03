//
//  MovieCollectionViewCell.swift
//  MovieApp
//
//  Created by Vikalp on 03/11/17.
//  Copyright © 2017 Vikalp. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgViewMovie: UIImageView!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    
    
    override func awakeFromNib() {
        
        lblRating.layer.cornerRadius = 4.0
        lblRating.layer.masksToBounds = true
        
    }
    
}
