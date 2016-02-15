//
//  GraphView.swift
//  NegaCalc
//
//  Created by Raphael on 2/7/16.
//  Copyright © 2016 Skyleaf Design LLC. All rights reserved.
//

import UIKit

protocol GraphViewDataSource {
    func pointsToGraph(sender: GraphView) -> [(x: Double, y: Double)]
}


@IBDesignable class GraphView: UIView {
    
    var dataSource: GraphViewDataSource?
    
    @IBInspectable var graphScale: CGFloat = 50 { didSet { setNeedsDisplay() } }
    @IBInspectable var graphColor: UIColor = UIColor.redColor() { didSet { setNeedsDisplay() } }
    @IBInspectable var samplePointsPerView: Int = 50
    
    // Returns an array of sample values along the x axis, based on the part of the axes
    // we are currently viewing.
    var sampleValues: [Double] {
        let valueRange = bounds.width / graphScale
        let valueOffset = (axesOrigin.x - center.x) / graphScale
        
        let startValue = -(Double(valueOffset + (valueRange / 2)))
        //let maxValue = Double(valueOffset + (valueRange / 2))
        let sampleIncrementValue = valueRange / CGFloat(samplePointsPerView)
        
        var values: [Double] = []
        for increment in 0...samplePointsPerView {
            values.append(startValue + Double(increment)*Double(sampleIncrementValue))
        }
        return values
    }
    
    
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
        default: break
        }
    }
    
    func moveOrigin(tap: UITapGestureRecognizer) {
        switch tap.state {
        case .Ended: fallthrough
        case .Changed:
            let newOrigin = tap.locationInView(self)
            axesOrigin = newOrigin
        default: break
        }
    }
    
    // Converts point of double values to the actual view's cordinate system.
    private func convertAxesPoint(axesPoint: (x: Double, y: Double)) -> CGPoint {
        let coordinates = (x: CGFloat(axesPoint.x), y: CGFloat(axesPoint.y))
        let scaledCoordinates = (x:coordinates.x * graphScale, y: coordinates.y * graphScale)
        let scaledAndTranslatedCoordinates = (x: scaledCoordinates.x + axesOrigin.x, y:-scaledCoordinates.y + axesOrigin.y)
        let graphPoint = CGPoint(x: scaledAndTranslatedCoordinates.x, y: scaledAndTranslatedCoordinates.y)
        return graphPoint
    }
    
    override func drawRect(rect: CGRect) {
        // Initializing properties here, because I don't know how to work initializers.
        if axesOrigin == nil {
            axesOrigin = convertPoint(center, fromCoordinateSpace: superview!)
        }
        if axes == nil {
            axes = AxesDrawer(color: UIColor.blackColor(), contentScaleFactor: contentScaleFactor)
        }
        
        axes.drawAxesInRect(self.bounds, origin: axesOrigin, pointsPerUnit: graphScale)
        
        // Graph the points from our data source.  We need at least two.
        if let points = dataSource?.pointsToGraph(self) {
            if let (head, tail) = points.decompose {
                let graphLine = UIBezierPath()
                graphLine.moveToPoint(convertAxesPoint(head))
                for point in tail {
                    graphLine.addLineToPoint(convertAxesPoint(point))
                }
                graphColor.setStroke()
                graphLine.lineWidth = 10.0
                graphLine.stroke()
            }
        }
    }
}

// Allows us to break an array into a head and a tail, without mutating it.
extension Array {
    var decompose : (head: Element, tail: [Element])? {
        return (count > 0) ? (self[0], Array(self[1..<count])) : nil
    }
}