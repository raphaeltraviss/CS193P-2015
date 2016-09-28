//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Raphael on 3/11/16.
//  Copyright © 2016 Skyleaf Design. All rights reserved.
//

import UIKit

@IBDesignable
class TweetTableViewCell: UITableViewCell {
    
    @IBInspectable var baseColor: UIColor = UIColor.blueColor()
    
    var tweet: Tweet? { didSet { updateUI() } }
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    private func updateUI() {
        if let tweet = self.tweet {
            if tweetTextLabel.text != nil {
                for _ in tweet.media {
                    tweet.text += " 📷"
                }
            }
            
            // Color the indexes of hashtags, links, and user mentions.
            let coloredText = NSMutableAttributedString(string: tweet.text)
            let colors = baseColor.colorScheme(Color.ColorScheme.Analagous)
            
            for hashTag in tweet.hashtags {
                coloredText.addAttribute(NSForegroundColorAttributeName, value: colors[0], range: hashTag.nsrange)
            }
            for user in tweet.userMentions {
                coloredText.addAttribute(NSForegroundColorAttributeName, value: colors[1], range: user.nsrange)
            }
            for url in tweet.urls {
                coloredText.addAttribute(NSForegroundColorAttributeName, value: colors[2], range: url.nsrange)
            }
            tweetTextLabel.attributedText = coloredText
            
            tweetScreenNameLabel.text = "\(tweet.user)"
            if let profileImageURL = tweet.user.profileImageURL {
                // Blocks the main thread.
                if let imageData = NSData(contentsOfURL: profileImageURL) {
                    tweetProfileImageView?.image = UIImage(data: imageData)
                }
            }
        }
    }
}
