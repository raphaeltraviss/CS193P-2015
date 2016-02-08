//
//  GraphView.swift
//  NegaCalc
//
//  Created by Raphael on 2/7/16.
//  Copyright © 2016 Skyleaf Design LLC. All rights reserved.
//

import UIKit

protocol GraphViewDataSource {
    func points(sender: GraphView, points: [CGPoint]) -> Void
}

class GraphView: UIView {
    
    var dataSource: GraphViewDataSource?
    
    var axesOrigin: CGPoint?
    
    // Pan gesture should move the origin, redraw the axes, and redraw
    // the graph, but only after the gesture ends.  WHile the gesture is
    // happening, we can make a copy of this view, and animate it within
    // this view.
    
    override func drawRect(rect: CGRect) {
        let axes = AxesDrawer(color: UIColor.blackColor(), contentScaleFactor: self.contentScaleFactor)
        axes.drawAxesInRect(self.bounds, origin: self.center, pointsPerUnit: 50)
    }
}
