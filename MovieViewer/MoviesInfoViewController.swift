//
//  MoviesInfoViewController.swift
//  MovieViewer
//
//  Created by Cory Avra on 1/30/16.
//  Copyright © 2016 coryavra. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesInfoViewController: UIViewController {

    // Outlets
    @IBOutlet weak var posterBackgroundView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    // Variables
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        displayMovieInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayMovieInfo() {
        
        //get the information from the NSDictionary
        let movieTitle = movie["title"] as? String
        let movieOverview = movie["overview"] as? String
        
        // Display the movie's title and overview
        self.title = movieTitle
        titleLabel.text = movieTitle
        overviewLabel.text = movieOverview
        overviewLabel.sizeToFit()

        // Display the poster image, if there is one
        if let posterPath = movie["poster_path"] as? String {
            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
            let posterUrl = NSURL(string: posterBaseUrl + posterPath)
            posterBackgroundView.setImageWithURL(posterUrl!)
        }
        else {
            posterBackgroundView.image = nil
        }
    }
}
