//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by Raphael on 3/15/16.
//  Copyright © 2016 Skyleaf Design. All rights reserved.
//

import UIKit

class TweetDetailTableViewController: UITableViewController, UITextViewDelegate {
    
    var searchHistory = SearchHistory()
    
    private enum Detail {
        case Keyword(Tweet.IndexedKeyword)
        case Link(NSURL?)
        case Image(UIImage?)
    }
    
    private var details = [(name: String, items: [Detail])]()
    
    var tweet: Tweet! {
        didSet {
            details.removeAll()
            if tweet.media.count > 0 {
                details.append(("Images", tweet.media.map({ media in
                    // Blocks the main thread.
                    if let imageData = NSData(contentsOfURL: media.url) {
                        if let image = UIImage(data: imageData) {
                            return Detail.Image(image)
                        }
                    }
                    return Detail.Image(nil)
                })))
            }
            if tweet.hashtags.count > 0 {
                details.append(("Hashtags", tweet.hashtags.map({ Detail.Keyword($0) })))
            }
            if tweet.urls.count > 0 {
                details.append(("Links", tweet.urls.map({ keyword in
                    if let url = NSURL(string: keyword.keyword) {
                        return Detail.Link(url)
                    }
                    return Detail.Link(nil)
                })))
            }
            if tweet.userMentions.count > 0 {
                details.append(("User Mentions", tweet.userMentions.map({ Detail.Keyword($0) })))
            }
        }
    }
    
    
    
    // MARK: - View controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
    
    // MARK: - UITableViewDataSource implementation
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var sectionCount = 0
        for (_, detailCollection) in details {
            sectionCount += min(detailCollection.count, 1)
        }
        return sectionCount
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details[section].items.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return details[section].name
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let detail = details[indexPath.section].items[indexPath.row]
        
        switch detail {
            
        case .Image(let image):
            let cell = tableView.dequeueReusableCellWithIdentifier("ImageDetail", forIndexPath: indexPath) as! ImageTableViewCell
            cell.detailImage.image = image
            return cell
            
        case .Keyword(let keyword):
            let cell = tableView.dequeueReusableCellWithIdentifier("KeywordDetail", forIndexPath: indexPath) as! KeywordTableViewCell
            cell.label.text = keyword.keyword
            return cell
            
        case .Link(let link):
            let cell = tableView.dequeueReusableCellWithIdentifier("LinkDetail", forIndexPath: indexPath) as! LinkTableViewCell
            cell.url = link
            return cell
        }
    }
    
    
    
    // MARK: - UITableViewDelegate implementation
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let detail = details[indexPath.section].items[indexPath.row]
        if case let Detail.Image(image) = detail {
            if image != nil {
                let cellRatio = tableView.bounds.size.width / image!.size.width
                return image!.size.height * cellRatio
            }
        }
        return UITableViewAutomaticDimension
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showKeywordSearch":
                if let destination = segue.destinationViewController as? TweetTableViewController {
                    if let keywordCell = sender as? KeywordTableViewCell {
                        destination.searchText = keywordCell.label.text
                    }
                }
            case "showImage":
                if let destination = segue.destinationViewController as? ImageScrollViewController {
                    if let imageCell = sender as? ImageTableViewCell {
                        destination.image = imageCell.detailImage.image
                    }
                }
            case "showLinkResource":
                if let destination = segue.destinationViewController as? WebViewController {
                    if let linkCell = sender as? LinkTableViewCell {
                        destination.url = linkCell.url
                    }
                }
            default: break
            }
        }
    }
}
