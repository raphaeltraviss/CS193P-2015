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
            let scaleGesture = UIPinchGestureRecognizer(target: graphView, action: "adjustScale:")
            let panGesture = UIPanGestureRecognizer(target: graphView, action: "adjustOrigin:")
            graphView.addGestureRecognizer(scaleGesture)
            graphView.addGestureRecognizer(panGesture)
        }
    }
    
    
    
    override func viewDidLoad() {
        // By default, the axes orgin is the center of the view.
        graphView.axesOrigin = graphView.center
        graphView.axes = AxesDrawer(color: UIColor.blackColor(), contentScaleFactor: graphView.contentScaleFactor)
    }
    
}
