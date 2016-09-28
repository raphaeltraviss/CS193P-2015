//
//  SearchHistory.swift
//  Smashtag
//
//  Created by Raphael on 4/12/16.
//  Copyright © 2016 Skyleaf Design. All rights reserved.
//

import Foundation

struct SearchHistory {
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // Does this really need to be optional?
    var currentTerm: String? {
        didSet {
            // Add to the search history, if this is indeed a new search term.
            var searchTerms = [currentTerm!]
            if let priorSearches = defaults.arrayForKey("priorSearches") as? [String] {
                if priorSearches.count > 0 {
                    if currentTerm == priorSearches[0] {
                        // Exclude the current term if it's a duplicate of the last search.
                        searchTerms = priorSearches
                    } else {
                        // Add new search terms.
                        searchTerms += priorSearches
                    }
                }
                // limit the array to 100 terms.
                while searchTerms.count > 100 {
                    searchTerms.removeLast()
                }
            }
            defaults.setObject(searchTerms, forKey: "priorSearches")
            defaults.synchronize()
            
            notificationCenter.postNotificationName("didUpdateHistory", object: priorTerms)
        }
    }
    var priorTerms: [String] {
        return defaults.arrayForKey("priorSearches") as! [String]
    }
}