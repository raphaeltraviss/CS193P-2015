//
//  GraphingViewController.swift
//  NegaCalc
//
//  Created by Raphael on 2/7/16.
//  Copyright © 2016 Skyleaf Design LLC. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    @IBOutlet var graphView: GraphView! {
        didSet {
            graphView.axesOrigin = CGPoint(x: self.graphView.bounds.width / 2, y: self.graphView.bounds.height / 2)
        }
    }
    
    func viewDidAppear() {
        // By default, set the axes origin to the view's center.
        
    }
    
}
