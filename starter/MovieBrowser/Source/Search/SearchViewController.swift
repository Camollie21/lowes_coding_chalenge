//
//  SearchViewController.swift
//  SampleApp
//
//  Created by Struzinski, Mark on 2/19/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    let network: Network = Network()
    var movieList: MovieList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Movie Search";
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
    }
    
    func getMovieList(searchQuery: String) {
        network.sendRequest(searchQuery: searchQuery, completion: { [weak self] (results) in
            DispatchQueue.main.async {
                self?.movieList = results
                self?.tableView.reloadData()
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
        segue.identifier == "MovieDetailSegue",
        let indexPath = tableView.indexPathForSelectedRow,
        let movieDetailViewController = segue.destination as? MovieDetailViewController
        else {
            return
        }
        
        if let movie: Movie = movieList?.results[indexPath.row] {
            movieDetailViewController.movie = movie
        } else {
            return
        }
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        if let title = self.movieList?.results[indexPath.row].title {
            cell.title?.text = title
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        if let releaseDate = self.movieList?.results[indexPath.row].release_date {
            if let dateFromString = dateFormatter.date(from: releaseDate) {
                dateFormatter.dateStyle = .long
                cell.releaseDate?.text = dateFormatter.string(from: dateFromString)
            } else {
                cell.releaseDate?.text = releaseDate
            }
            
        }
        
        if let rating = self.movieList?.results[indexPath.row].vote_average{
            cell.rating?.text = rating.description
        }
        
        cell.poster?.image = UIImage(named: "placeholder")
        
        if let path = self.movieList?.results[indexPath.row].poster_path {
            /*we use token to store the uuid linked to the dataTask request, this way we can cancel unneeded
             inflight request as the cells update with fresh search results */
            let token = network.loadImage(imageId: path, completion: { (image) in
                guard let image = image else { return }
                DispatchQueue.main.async {
                    cell.poster?.image = image
                }
            })
            /*On reuse being called we cancel the pending request. Since the cell is preparing
            to update with new data the pending image is no longer needed */
            cell.onReuse = {
                if let token = token {
                    self.network.cancelLoad(token)
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = movieList {
            return list.results.count
        } else {
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
}

/* Instead of implementing a "go" button to intialize the search, I tied the search request
to the searchController delegate. This enables live search results as the user types their querey.
 I felt this was a little sleeker, and gets the user their search results faster with fewer touches. */
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            if text != "" {
                self.getMovieList(searchQuery: text)
            }
        }
    }
}
