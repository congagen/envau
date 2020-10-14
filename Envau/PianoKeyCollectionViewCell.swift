import UIKit
import Foundation


class PianoKeyCollectionViewCell: UICollectionViewCell {
    
    var keyValue = 0
    var currentSelection = [Int]()
    var colViewController: PianoRollCollectionViewController? = nil
    
    @IBOutlet var keyValueLabel: UILabel!
    
    override func prepareForReuse() {
        if colViewController != nil {
            if (colViewController?.selectedAnoKeyValues.contains(keyValue))! {
                keyValueLabel.backgroundColor = colViewController?.selectedCellBgColor
            } else {
                keyValueLabel.backgroundColor = colViewController?.deseltedCellBgColor
            }
        }
    }
    
    
}
