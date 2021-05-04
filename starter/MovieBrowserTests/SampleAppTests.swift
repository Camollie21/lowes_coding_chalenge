//
//  SampleAppTests.swift
//  SampleAppTests
//
//  Created by Struzinski, Mark - Mark on 9/17/20.
//  Copyright © 2020 Lowe's Home Improvement. All rights reserved.
//

import XCTest
import UIKit

@testable import MovieBrowser

class MovieBrowserTests: XCTestCase {
    let network = Network()
    
    func testMovieSearchRequest() {
        let expectation = self.expectation(description: "testNilMoviePosterSearchResult")
        let searchQuery = "The Empire Strikes Back"
        var movieList: MovieList? = nil
        
        network.sendRequest(searchQuery: searchQuery, completion: { (results) in
            movieList = results
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(movieList?.results[0].poster_path != nil)
        XCTAssertTrue(movieList?.results[0].title == "The Empire Strikes Back")
        XCTAssertTrue(movieList?.results[0].release_date == "1980-05-20")
    }
    
    func testImageLoad() {
        let expectation = self.expectation(description: "testImageLoad")
        
        let poster_path =  "/qJ2tW6WMUDux911r6m7haRef0WH.jpg"
        var moviePoster: UIImage? = nil
        
        _ = network.loadImage(imageId: poster_path, completion: { (image) in
            moviePoster = image
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        if let mockImageData: Data = UIImage(named: "batman_test")?.pngData(),
           let fetchedImageData: Data = moviePoster?.pngData() {
            XCTAssertEqual(mockImageData, fetchedImageData)
        } else {
            XCTFail()
        }
    }
    
    func testImageCaching() {
        let expectation = self.expectation(description: "testImageCaching")
        let poster_path = "/hziiv14OpD73u9gAak4XDDfBKa2.jpg"
        
        _ = network.loadImage(imageId: poster_path, completion: { (image) in
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(network.cache.object(forKey: "/hziiv14OpD73u9gAak4XDDfBKa2.jpg") != nil)
    }
}
