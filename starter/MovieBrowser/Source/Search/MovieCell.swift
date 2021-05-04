//
//  MovieCell.swift
//  MovieBrowser
//
//  Created by Cameron Ollivierre on 5/3/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import Foundation
import UIKit

class MovieCell:UITableViewCell {
    @IBOutlet weak var title: UILabel?
    @IBOutlet weak var releaseDate: UILabel?
    @IBOutlet weak var rating: UILabel?
    /*I went ahead and added an image view to the tableView cell for the movie poster.
     Since we need the images anyway for our detailViewController it seemed like a good
    way to front load the images while offering added detail to the tableview */
    @IBOutlet weak var poster: UIImageView?
    
    var onReuse: () -> Void = {}
    
    /* to prevent left over images mismatching with the text while the new image loads
     we set the cell poster image to nil before reuse */
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
        poster?.image = nil
      }
}
