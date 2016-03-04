//
//  GraphingViewController.swift
//  NegaCalc
//
//  Created by Raphael on 2/7/16.
//  Copyright © 2016 Skyleaf Design LLC. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource, UIPopoverPresentationControllerDelegate {
    
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
    
    // Save the origin and scale for the graphview between launchings.
    typealias PropertyList = AnyObject
    
    
    
    // When a user turns the device, move the origin to the same point relative to the center of both bounds.
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if let currentAxesOffset = graphView.axesOffset {
            graphView.axesOrigin = CGPoint(
                x: (size.width / 2) + currentAxesOffset.x,
                y: (size.height / 2) + currentAxesOffset.y
            )
        }
    }
    
    // Use prepareForSegue to load the program into the graphViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showStatistics" {
            if let svc = segue.destinationViewController as? StatisticsViewController {
                svc.valueRange = graphView.valueRange
                if let svcPopup = svc.popoverPresentationController {
                    svcPopup.delegate = self
                    svc.preferredContentSize = CGSize(width: CGFloat(150), height: CGFloat(150))
                }
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    
    
    // graphView datasource implementation.
    
    
    
    
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
}
