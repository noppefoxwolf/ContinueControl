import UIKit

extension UITableViewController {
    public var continueControl: ContinueControl? {
        get { tableView.continueControl }
        set { tableView.continueControl = newValue }
    }
}

extension UIScrollView {
    public var continueControl: ContinueControl? {
        get { subviews.compactMap({ $0 as? ContinueControl }).first }
        set {
            continueControl?.removeFromSuperview()
            if let newValue {
                addSubview(newValue)
            }
        }
    }
}

