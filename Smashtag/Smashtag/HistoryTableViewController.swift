//
//  HistoryTableViewController.swift
//  Smashtag
//
//  Created by Raphael on 3/28/16.
//  Copyright © 2016 Skyleaf Design. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    
    var searchHistory = SearchHistory()
    
    let notificationCenter = NSNotificationCenter.defaultCenter()

    
    @objc func refresh(notification: NSNotification) {
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource implementation
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistory.priorTerms.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Keyword search history"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let keyword = searchHistory.priorTerms[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("HistoryKeyword", forIndexPath: indexPath) as! KeywordTableViewCell
        cell.label.text = keyword
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showHistorySearch":
                if let destination = segue.destinationViewController as? TweetTableViewController {
                    if let historyCell = sender as? KeywordTableViewCell {
                        destination.searchText = historyCell.label.text
                        // didSet on destination.searchText fires before this is set... for some reason?
                    }
                }
            default: break
            }
        }
    }
    
    override func viewDidLoad() {
        notificationCenter.addObserver(self, selector: #selector(self.refresh(_:)), name: "didUpdateHistory", object: nil)
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}
