//
//  GraphingViewController.swift
//  NegaCalc
//
//  Created by Raphael on 2/7/16.
//  Copyright © 2016 Skyleaf Design LLC. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    
    var program: AnyObject?
    
    var brain: CalculatorBrain = CalculatorBrain()
    
    var samplePointsPerView: Double = 10
    
    @IBOutlet var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            let scaleGesture = UIPinchGestureRecognizer(target: graphView, action: "adjustScale:")
            let panGesture = UIPanGestureRecognizer(target: graphView, action: "adjustOrigin:")
            let tapGesture = UITapGestureRecognizer(target: graphView, action: "moveOrigin:")
            tapGesture.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(scaleGesture)
            graphView.addGestureRecognizer(panGesture)
            graphView.addGestureRecognizer(tapGesture)
        }
    }
    
    func pointsToGraph(sender: GraphView) -> [(x: Double, y: Double)] {
        // Use the scale of the view to get the upper and lower bounds for our points.
        // Every graph is sampled at ten points.
        return [(1,2),(1.5,3),(6,7),(8,10)]
    }
}
