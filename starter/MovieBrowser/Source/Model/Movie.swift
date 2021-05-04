//
//  Movie.swift
//  MovieBrowser
//
//  Created by Cameron Ollivierre on 5/3/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import Foundation

struct Movie: Codable {
    var poster_path:String?
    var overview:String?
    var release_date:String?
    var id:Int?
    var original_title:String?
    var title:String?
    var vote_average:Float?
}

struct MovieList: Codable {
    var results: [Movie]
    
}
