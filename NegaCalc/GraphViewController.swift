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
        let sampleValues = graphView.sampleValues
        brain.program = program!
        
        var points: [(x: Double, y: Double)] = []
        for value in sampleValues {
            // Set the variable value, and then execute the program to see the result.
            brain.variableValues["M"] = value
            if let yValue = brain.evaluate() {
                points.append((x: value, y: yValue))
            }
        }
        
        return points
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        // get the current axes origin's offset from the view's center.
        // add the offset to the new CGSize's center
        let centerOffset = (x: graphView.axesOrigin.x - graphView.center.x, y: graphView.axesOrigin.y - graphView.center.y)
        let newOrigin = CGPoint(x: size.width - centerOffset.x, y: size.width - centerOffset.y)
        print(graphView.axesOrigin)
        graphView?.axesOrigin = newOrigin
        print(newOrigin)
    }
}
