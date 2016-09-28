//
//  TweetTabViewController.swift
//  Smashtag
//
//  Created by Raphael on 3/29/16.
//  Copyright © 2016 Skyleaf Design. All rights reserved.
//

import UIKit

class TweetTabViewController: UITabBarController, UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        print("only here")
        if let theViewController = viewController as? HistoryTableViewController {
            print("got here")
        }
    }
}
