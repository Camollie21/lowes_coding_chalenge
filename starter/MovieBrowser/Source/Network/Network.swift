//
//  Network.swift
//  SampleApp
//
//  Created by Struzinski, Mark - Mark on 9/17/20.
//  Copyright © 2020 Lowe's Home Improvement. All rights reserved.
//

import UIKit

class Network: NSObject {
    let utilityQueue = DispatchQueue.global(qos: .utility)
    let apiKey = "5885c445eab51c7004916b9c0313e2d3"
    let cache = NSCache<NSString, UIImage>()
    private var runningRequests = [UUID: URLSessionDataTask]()
    
    override init() {
        super.init()
    }
    
    func sendRequest(searchQuery: String, completion: @escaping (MovieList?) -> ()) {
        
        utilityQueue.async {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.themoviedb.org"
            components.path = "/3/search/movie"
            components.queryItems = [
                URLQueryItem(name: "api_key", value: self.apiKey),
                URLQueryItem(name: "query", value: searchQuery)]
            
            guard let url = components.url else {
                return
            }
            
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                
                if let data = data {
                    completion(self.parseJson(data: data))
                }
                
                if let error = error {
                    print(error)
                    return
                }
            })
            task.resume()
        }
    }
    
    func parseJson(data: Data) -> MovieList? {
        let decoder = JSONDecoder()
        do {
            let movieList = try decoder.decode(MovieList.self, from: data)
            return movieList
        } catch {
            print(error)
            return nil
        }
    }

    func loadImage(imageId: String, completion: @escaping (UIImage?) -> Void) -> UUID? {
        /* Since I implemented images into the tableview cells I addded a simple image cache to avoid unnecessary re-loading.
         If the image has been cached we return it and bail before sending a fresh request, NSCache automatically manages memory pressure
         so we dont have to worry about maually purging the chache. This should come in handy for the MovieDetailViewController since
         we can load its image directly from cache instead of having to send another network request.
        */
        if let cachedImage = self.cache.object(forKey: imageId as NSString) {
            completion(cachedImage)
        } else {
            let uuid = UUID()
            
            guard let url = URL(string: "https://image.tmdb.org/t/p/w600_and_h900_bestv2/\(imageId)") else { return nil }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                
                //Once the task is complete we remove the dataTask from our list of running requests 
                defer {self.runningRequests.removeValue(forKey: uuid) }
                
                if let data = data, let image = UIImage(data: data) {
                    self.cache.setObject(image, forKey: imageId as NSString)
                    completion(image)
                }
                
                if let error = error {
                    print(error)
                    return
                }
            }
            task.resume()
            
            //Add the dataTask to our running request dictionary.
            self.runningRequests[uuid] = task
            return uuid
        }
        return nil
    }
    
    //Here we cancel stale dataTasks and remove them from our runningRequest dictionary
    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
    

}
