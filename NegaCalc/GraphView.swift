import UIKit

protocol GraphViewDataSource: class {
    func pointsToGraph(sender: GraphView) -> [(x: Double, y: Double)]
}

protocol GraphViewMemory: class {
    func rememberOrigin(origin: CGPoint)
    func rememberScale(scale: CGFloat)
}


@IBDesignable class GraphView: UIView {
    
    weak var dataSource: GraphViewDataSource?
    weak var memory: GraphViewMemory?
    
    @IBInspectable var graphScale: CGFloat = 50 { didSet { setNeedsDisplay() } }
    @IBInspectable var graphColor: UIColor = UIColor.redColor() { didSet { setNeedsDisplay() } }
    @IBInspectable var samplePointsPerView: Int = 50
    
    // Returns an array of sample values along the x axis, based on the part of the axes
    // we are currently viewing.
    var sampleValues: [Double] {
        var values: [Double] = []
        let valueRange = bounds.width / graphScale
        let valueOffset = (axesOrigin.x - bounds.width / 2) / graphScale
        
        let startValue = -(Double(valueOffset + (valueRange / 2)))
        let sampleIncrementValue = valueRange / CGFloat(samplePointsPerView)
            
        for increment in 0...samplePointsPerView {
            values.append(startValue + Double(increment)*Double(sampleIncrementValue))
        }
 
        return values
    }
    
    var valueRange: (minPoint: CGPoint, maxPoint: CGPoint) {
        let xRange = bounds.width / graphScale
        let yRange = bounds.height / graphScale
        let xOffset = (axesOrigin.x - viewCenter.x) / graphScale
        let yOffset = (axesOrigin.y - viewCenter.y) / graphScale
        
        let minX = -Double(xOffset + (xRange / 2))
        let minY = Double(yOffset - (yRange / 2))
        
        let maxX = -Double(xOffset - (xRange / 2))
        let maxY = Double(yOffset + (yRange / 2))
        
        return (CGPoint(x: minX, y: minY), CGPoint(x: maxX, y: maxY))
    }
    
    // The axes origin defaults to the center of the view.  This is an optional, simply
    // because this view is initialized before its geometry is set.
    var storedAxesOrigin: CGPoint? { didSet { setNeedsDisplay() } }
    
    var axesOrigin: CGPoint {
        get {
            return storedAxesOrigin ?? viewCenter
        }
        set {
            storedAxesOrigin = newValue
        }
    }
    
    var viewCenter: CGPoint {
        return CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }
    
    var axesOffset: CGPoint! {
        return CGPoint(x: axesOrigin.x - viewCenter.x, y: axesOrigin.y - viewCenter.y)
    }
    
    private var axes: AxesDrawer!
    
    func adjustScale(pinch: UIPinchGestureRecognizer) {
        if pinch.state == .Changed {
            graphScale *= pinch.scale
            memory?.rememberScale(graphScale)
            pinch.scale = 1
        }
    }
    
    func adjustOrigin(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = pan.translationInView(self)
            let newOrigin = CGPoint(x: translation.x + axesOrigin.x, y: translation.y + axesOrigin.y)
            self.axesOrigin = newOrigin
            pan.setTranslation(CGPointZero, inView: self)
            memory?.rememberOrigin(newOrigin)
        default: break
        }
    }
    
    func moveOrigin(tap: UITapGestureRecognizer) {
        switch tap.state {
        case .Ended: fallthrough
        case .Changed:
            let newOrigin = tap.locationInView(self)
            axesOrigin = newOrigin
            memory?.rememberOrigin(newOrigin)
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
        // Initialize properties if they are not already set.
        let axes = self.axes ?? AxesDrawer(color: UIColor.blackColor(), contentScaleFactor: contentScaleFactor)

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