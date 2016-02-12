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
            let tapGesture = UITapGestureRecognizer(target: graphView, action: "moveOrigin:")
            tapGesture.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(scaleGesture)
            graphView.addGestureRecognizer(panGesture)
            graphView.addGestureRecognizer(tapGesture)
        }
    }
}
