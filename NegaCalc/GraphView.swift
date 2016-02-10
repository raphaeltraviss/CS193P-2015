//
//  GraphView.swift
//  NegaCalc
//
//  Created by Raphael on 2/7/16.
//  Copyright © 2016 Skyleaf Design LLC. All rights reserved.
//

import UIKit

protocol GraphViewDataSource {
    func pointsToPlot(sender: GraphView) -> [CGPoint]
}

class GraphView: UIView {
    
    var dataSource: GraphViewDataSource?
    
    var graphScale: CGFloat = 50 { didSet { setNeedsDisplay() } }
    
    var axesOrigin: CGPoint! { didSet { setNeedsDisplay() } }
    
    var axes: AxesDrawer!
    
    func adjustScale(pinch: UIPinchGestureRecognizer) {
        if pinch.state == .Changed {
            graphScale *= pinch.scale
            pinch.scale = 1
        }
    }
    
    func adjustOrigin(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = pan.translationInView(self)
            let newOrigin = CGPoint(x: translation.x + axesOrigin.x, y: translation.y + axesOrigin.y)
            axesOrigin = newOrigin
            pan.setTranslation(CGPointZero, inView: self)
            print(translation)
        default: break
        }
    }
    
    override func drawRect(rect: CGRect) {
        axes.drawAxesInRect(self.bounds, origin: axesOrigin, pointsPerUnit: graphScale)
    }
}
