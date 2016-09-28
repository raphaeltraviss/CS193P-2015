//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Raphael on 3/9/16.
//  Copyright © 2016 Skyleaf Design. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    var tweets = [[Tweet]]()
    
    var searchHistory = SearchHistory()
    
    var searchText: String? = "#stanford" {
        didSet {
            if searchText != nil {
                searchHistory.currentTerm = searchText!
            }
            lastSuccessfulRequest = nil
            searchTextField.text = searchText
            tweets.removeAll()
            tableView.reloadData()
            refresh()
        }
    }
    
    func updateHistory() {
        
    }
    
    

    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    private var lastSuccessfulRequest: TwitterRequest?
    
    private var nextRequestToAttempt: TwitterRequest? {
        if lastSuccessfulRequest == nil {
            if searchText != nil {
                return TwitterRequest(search: searchText!, count: 100)
            } else {
                return nil
            }
        } else {
            return lastSuccessfulRequest!.requestForNewer
        }
    }
            
    
    
    

    
    
    // MARK: ViewController life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the table view's row height only as an estimation.
        self.tableView.estimatedRowHeight = self.tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        refresh()
    }
    
    private func refresh() {
        if refreshControl != nil {
            refreshControl?.beginRefreshing()
        }
        refresh(refreshControl)
    }
    
    @IBAction func refresh(sender: UIRefreshControl?) {
        if searchText != nil {
            if let request = nextRequestToAttempt {
                request.fetchTweets { (newTweets) -> Void in
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        if newTweets.count > 0 {
                            self.lastSuccessfulRequest = request
                            self.tweets.insert(newTweets, atIndex: 0)
                            self.tableView.reloadData()
                        }
                        sender?.endRefreshing()
                    }
                }
            }
        } else {
            sender?.endRefreshing()
        }
    }
    
    

    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    private struct Storyboard  {
        static let CellReuseIdentifier = "Tweet"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! TweetTableViewCell
        cell.tweet = tweets[indexPath.section][indexPath.row]
        return cell
    }

    
    
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showTweetDetail":
                if let TweetViewController = sender as? TweetTableViewCell {
                    if let DetailViewController = segue.destinationViewController as? TweetDetailTableViewController {
                        DetailViewController.tweet = TweetViewController.tweet
                    }
                }
            default: break
            }
        }
    }

}
