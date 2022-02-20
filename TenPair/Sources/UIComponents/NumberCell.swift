import UIKit

public enum NumberMarker: String {
    case standard
    case selection
    case success
    case failure
}

public  class NumberCell: UICollectionViewCell {
    private static var numbers = [Int: String]()
    
    @IBOutlet private var number: UILabel!
    @IBOutlet private var container: UIView!
    private lazy var defaultBG = TileDefaultBackground()
    private lazy var noNumberBG = TileNoNumberBackground()
    private lazy var selectedBG = TileSelectedBackground()
    private lazy var successBG = TileSuccessBackground()
    private lazy var failureBG = TileFailureBackground()
    private var showing = 0
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        [defaultBG, noNumberBG, selectedBG, successBG, failureBG].forEach() {
            view in
            
            container.addSubview(view)
            view.isOpaque = true
            view.translatesAutoresizingMaskIntoConstraints = false
            let padding = CGFloat(1)
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding).isActive = true
            view.topAnchor.constraint(equalTo: container.topAnchor, constant: padding).isActive = true
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding).isActive = true
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -padding).isActive = true
        }
    }
        
    public func show(number: Int, marker: NumberMarker) {
        noNumberBG.isHidden = number != 0
        defaultBG.isHidden = marker != .standard
        selectedBG.isHidden = marker != .selection
        successBG.isHidden = marker != .success
        failureBG.isHidden = marker != .failure

        if showing == number {
            return
        }

        let shown: String
        if number == 0 {
            shown = ""
        } else if let existing = NumberCell.numbers[number] {
            shown = existing
        } else {
            shown = String(describing: number)
            NumberCell.numbers[number] = shown
        }

        self.number.text = shown
        showing = number
    }
}
