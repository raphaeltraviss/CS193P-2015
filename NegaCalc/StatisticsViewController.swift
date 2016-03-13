import UIKit

class StatisticsViewController: UIViewController {

    var valueRange: (minPoint: CGPoint, maxPoint: CGPoint)!
    
    @IBOutlet weak var labelMinX: UILabel! { didSet {
        labelMinX.text = "Min X: \(valueRange.minPoint.x)"
    }}
    
    @IBOutlet weak var labelMinY: UILabel! { didSet {
        labelMinY.text = "Min Y: \(valueRange.minPoint.y)"
    }}
    
    @IBOutlet weak var labelMaxX: UILabel! { didSet {
        labelMaxX.text = "Min X: \(valueRange.maxPoint.x)"
    }}
    
    @IBOutlet weak var labelMaxY: UILabel! { didSet {
        labelMaxY.text = "Max Y: \(valueRange.maxPoint.y)"
    }}

}
