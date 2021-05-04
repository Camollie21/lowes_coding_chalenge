//
//  MovieDetailViewController.swift
//  SampleApp
//
//  Created by Struzinski, Mark on 2/26/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var movieTitle: UILabel?
    @IBOutlet weak var releaseDate: UILabel?
    @IBOutlet weak var overview: UITextView?
    @IBOutlet weak var poster: UIImageView?
    
    let network: Network = Network()
    
    var movie: Movie? {
      didSet {
        setupView()
      }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        if let movie = movie {
        
            if let movieTitle = movieTitle {
                movieTitle.text = movie.title
            }
        
            if let releaseDate = releaseDate {
                releaseDate.text = "Release Date: \((movie.release_date) ?? "unknown")"
            }
        
            if let overview = overview {
                overview.text = movie.overview
            }
        
            
            if let poster = poster {
                if let path = movie.poster_path {
                    _ = network.loadImage(imageId: path, completion: { (image) in
                        guard let image = image else { return }
                        DispatchQueue.main.async {
                            poster.image = image
                        }
                    })
                } else { poster.image = UIImage(named: "placeholder")
                }
            }
        }
    }
}
