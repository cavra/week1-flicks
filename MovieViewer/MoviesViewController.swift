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

class MoviesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    // Outlets
    @IBOutlet weak var posterCollectionView: UICollectionView!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var networkErrorLabel: UILabel!
    @IBOutlet weak var emptySearchView: UIView!
    @IBOutlet weak var emptySearchLabel: UILabel!
    
    // Variables
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var endpoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        posterCollectionView.dataSource = self
        posterCollectionView.delegate = self

        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        posterCollectionView.insertSubview(refreshControl, atIndex: 0)
        
        // Get the data from the network
        loadDataFromNetwork()

        // Initialize a UISearchBar
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        // A bit of formatting
        emptySearchView.hidden = true
        emptySearchView.layer.cornerRadius = 15.0
        emptySearchView.layer.shadowOffset = CGSizeMake(1, 1)
        emptySearchView.layer.shadowOpacity = 1
        emptySearchView.layer.shadowRadius = 4
        
        checkNetwork(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        // Remove any selected styles from cells
        posterCollectionView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Close the keyboard if it's still open
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDataFromNetwork() {
        // Create the NSURLRequest
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
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
            
                // Remainder of response handling code
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            //print("response: \(responseDictionary)")
                            self.movies = (responseDictionary["results"] as! [NSDictionary])
                            self.filteredMovies = self.movies!
                            self.posterCollectionView.reloadData()
                    }
                    // Update the Network Error view
                    self.checkNetwork(true)
                }
                else {
                    // Update the Network Error view
                    self.checkNetwork(false)
                }
            }
        );
        task.resume()
    }
    
    func checkNetwork(value: Bool) {
        if value {
            // Hide the Network Error UIView if connection is successful
            self.networkErrorView.hidden = true
            self.networkErrorLabel.text = "Network Error"
        }
        else {
            // Otherwise, show the error
            print("An error occured")
            self.networkErrorView.hidden = false
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the count of the *filtered* movie array
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        }
        else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = posterCollectionView.dequeueReusableCellWithReuseIdentifier("posterCell", forIndexPath: indexPath) as! posterCell
        
        // A bit of cell formatting
        cell.layer.cornerRadius = 23.0
        cell.layer.shadowOffset = CGSizeMake(1, 1)
        cell.layer.shadowOpacity = 1
        cell.layer.shadowRadius = 4

        let movie = filteredMovies![indexPath.row]
        
        // Display the poster image, if there is one
        if let posterPath = movie["poster_path"] as? String {
            let posterSmallBase = "https://image.tmdb.org/t/p/w45"
            let posterLargeBase = "https://image.tmdb.org/t/p/original"

            // Get the small and large image requests
            let smallImageRequest = NSURLRequest(URL: NSURL(string: posterSmallBase + posterPath)!)
            let largeImageRequest = NSURLRequest(URL: NSURL(string: posterLargeBase + posterPath)!)
            
            cell.posterView.setImageWithURLRequest(
                smallImageRequest,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                    
                    // smallImageResponse will be nil if the smallImage is already available
                    // in cache (might want to do something smarter in that case).
                    cell.posterView.alpha = 0.0
                    cell.posterView.image = smallImage;
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        
                        cell.posterView.alpha = 1.0
                        
                        }, completion: { (sucess) -> Void in
                            
                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                            // per ImageView. This code must be in the completion block.
                            cell.posterView.setImageWithURLRequest(
                                largeImageRequest,
                                placeholderImage: smallImage,
                                success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                    
                                    cell.posterView.image = largeImage;
                                    
                                },
                                failure: { (request, response, error) -> Void in
                                    // do something for the failure condition of the large image request
                                    // possibly setting the ImageView's image to a default image
                            })
                    })
                },
                failure: { (request, response, error) -> Void in
                    // do something for the failure condition
                    // possibly try to get the large image
            })
        }
        else {
            cell.posterView.image = nil
        }
        
        // Customized Selection Styles
        // Set the default first
        let backgroundView = UIView()
        backgroundView.backgroundColor = .None
        cell.backgroundView = backgroundView
        
        // Followed by the selected style
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.darkGrayColor()
        cell.selectedBackgroundView = selectedBackgroundView
        
        return cell
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // If the searchBar text field is empty, set the filtered array to the full array
        if searchText.isEmpty {
            filteredMovies = movies
        }
        // Otherwise, filter through the full array based on the text in the searchBar field
        else {
            filteredMovies = movies?.filter({ (movie: NSDictionary) -> Bool in
                let movieTitle = movie["title"] as! String
                let movieTitleFound = movieTitle.rangeOfString(searchText)
                return movieTitleFound != nil
            })
            // Show the "No Results" view if necessary
            if filteredMovies!.count == 0 {
                emptySearchView.hidden = false
            }
            else {
                emptySearchView.hidden = true
            }
        }
        // Reload the collectionView data to show only the desired results
        posterCollectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        loadDataFromNetwork()
        refreshControl.endRefreshing()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Check for the correct segue
        if segue.identifier == "toInfoViewController" {
            
            let selectedIndex = posterCollectionView.indexPathForCell(sender as! UICollectionViewCell)
            let movie = filteredMovies![selectedIndex!.row]
            
            // Pass the movie info to the destination controller
            let itemToAdd = segue.destinationViewController as! MoviesInfoViewController
            itemToAdd.movie = movie
        }
    }
}