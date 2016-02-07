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
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    // Variables
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let movieReleaseDate = movie["release_date"] as? String
        
        // Display the movie's title and overview
        titleLabel.text = movieTitle
        parseReleaseDate(movieReleaseDate!)
        overviewLabel.text = movieOverview
        overviewLabel.sizeToFit()

        // Resize the views to show all content
        infoView.frame.size.height = overviewLabel.frame.size.height + 70
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)

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
    
    func parseReleaseDate(movieReleaseDate: String) {
        
        var movieReleaseDateArr = movieReleaseDate.componentsSeparatedByString("-")
        
        switch movieReleaseDateArr[1] {
        case "01": movieReleaseDateArr[1] = "January"
        case "02": movieReleaseDateArr[1] = "February"
        case "03": movieReleaseDateArr[1] = "March"
        case "04": movieReleaseDateArr[1] = "April"
        case "05": movieReleaseDateArr[1] = "May"
        case "06": movieReleaseDateArr[1] = "June"
        case "07": movieReleaseDateArr[1] = "July"
        case "08": movieReleaseDateArr[1] = "August"
        case "09": movieReleaseDateArr[1] = "September"
        case "10": movieReleaseDateArr[1] = "October"
        case "11": movieReleaseDateArr[1] = "November"
        case "12": movieReleaseDateArr[1] = "December"
        default: movieReleaseDateArr[1] = "Unknown"
        }

        // Convert the digital format to standard written format
        releaseDateLabel.text = movieReleaseDateArr[1] + " " + movieReleaseDateArr[2] + ", " + movieReleaseDateArr[0]
    }
}
