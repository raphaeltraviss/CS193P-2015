//
//  WebViewController.swift
//  Smashtag
//
//  Created by Raphael on 3/23/16.
//  Copyright © 2016 Skyleaf Design. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    var url: NSURL?
    
    @IBOutlet weak var webView: UIWebView! {
        didSet {
            if let validResource = url {
                webView.loadRequest(NSURLRequest(URL: validResource))
            }
        }
    }
}
