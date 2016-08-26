//
//  CocktailTableCell.swift
//  CocktailsApp
//
//  Created by Juan Alvarez on 12/8/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit

class CocktailTableCell: UITableViewCell {
    
    @IBOutlet weak var cocktailImage: UIImageView!
    @IBOutlet weak var textLable: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noImageLabel: UILabel!
}