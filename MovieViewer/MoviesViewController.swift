//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Cory Avra on 1/25/16.
//  Copyright © 2016 coryavra. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // Outlets
    @IBOutlet weak var posterCollectionView: UICollectionView!
    
    // Variables
    var movies: [NSDictionary]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        posterCollectionView.insertSubview(refreshControl, atIndex: 0)

        posterCollectionView.dataSource = self
        posterCollectionView.delegate = self
        
        loadDataFromNetwork()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toInfoViewController" {
    
            let selectedIndex = self.posterCollectionView.indexPathForCell(sender as! UICollectionViewCell)

            let itemToAdd = segue.destinationViewController as! MoviesInfoViewController
            
            let movieTitle = movies![selectedIndex!.row]["title"] as? String
            let movieOverview = movies![selectedIndex!.row]["overview"] as? String
            
            itemToAdd.movieTitle = movieTitle
            itemToAdd.movieOverview = movieOverview
            
            if let posterPath = movies![selectedIndex!.row]["poster_path"] as? String {
                let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
                let posterUrl = NSURL(string: posterBaseUrl + posterPath)
                itemToAdd.movieImageUrl = posterUrl
            }
            else {
                itemToAdd.movieImageUrl = nil
            }
            
        }
    
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let movies = movies {
            return movies.count
        }
        else {
            return 0
        }
    
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = posterCollectionView.dequeueReusableCellWithReuseIdentifier("posterCell", forIndexPath: indexPath) as! posterCell
        
        // Display data retrieved
        let movie = movies![indexPath.row]
        
        // Display the poster image, if there is one
        if let posterPath = movie["poster_path"] as? String {
            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
            let posterUrl = NSURL(string: posterBaseUrl + posterPath)
            cell.posterView.setImageWithURL(posterUrl!)
        }
        else {
            cell.posterView.image = nil
        }
        
        return cell
    }

    func loadDataFromNetwork() {
        
        // Create the NSURLRequest
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                // ... Remainder of response handling code ...
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            
                            self.movies = (responseDictionary["results"] as! [NSDictionary])
                            self.posterCollectionView.reloadData()
                    }
                }

        });
        task.resume()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        loadDataFromNetwork()
        
        refreshControl.endRefreshing()

    }
}
