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
    @IBOutlet weak var overviewLabel: UILabel!
    
    // Variables
    var movieImageUrl: NSURL?
    var movieTitle: String?
    var movieOverview: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = movieTitle
        displayMovieInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayMovieInfo() {
        
        // Display the movie's title and overview
        overviewLabel.text = movieOverview
        
        // Display the poster image, if there is one
        posterBackgroundView.setImageWithURL(movieImageUrl!)
        
    }
}
