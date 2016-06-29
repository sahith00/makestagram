//
//  PostSectionHeaderView.swift
//  Makestagram
//
//  Created by Sahith Bhamidipati on 6/28/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse
import UIKit

class PostSectionHeaderView: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    
    var post: Post? {
        didSet {
            if let post = post {
                usernameLabel.text = post.user?.username
                postTimeLabel.text = post.createdAt?.shortTimeAgoSinceDate(NSDate())
            }
        }
    }

}
