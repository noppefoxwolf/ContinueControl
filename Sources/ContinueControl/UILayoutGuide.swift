import UIKit
import Combine

final class ScrollContentLayoutGuide: UILayoutGuide {
    override var owningView: UIView? {
        didSet { didSetOwningView(owningView) }
    }
    
    var contentSizeObserver: AnyCancellable? = nil
    var contentOffsetObserver: AnyCancellable? = nil
    
    var topConstraint: NSLayoutConstraint? = nil
    var heightConstraint: NSLayoutConstraint? = nil
    
    func didSetOwningView(_ owningView: UIView?) {
        if let scrollView = owningView as? UIScrollView {
            topConstraint = topAnchor.constraint(
                equalTo: scrollView.topAnchor
            )
            heightConstraint = heightAnchor.constraint(
                equalToConstant: 0
            )
            NSLayoutConstraint.activate([
                topConstraint!,
                heightConstraint!,
                leadingAnchor.constraint(
                    equalTo: scrollView.frameLayoutGuide.leadingAnchor
                ),
                trailingAnchor.constraint(
                    equalTo: scrollView.frameLayoutGuide.trailingAnchor
                ),
            ])
            
            contentSizeObserver = scrollView
                .publisher(for: \.contentSize)
                .sink { [unowned self] contentSize in
                    heightConstraint?.constant = contentSize.height
                }
            contentOffsetObserver = scrollView
                .publisher(for: \.contentOffset)
                .sink { [unowned self] contentOffset in
                    topConstraint?.constant = -contentOffset.y
                }
        } else {
            contentSizeObserver = nil
            contentOffsetObserver = nil
            topConstraint?.isActive = false
            topConstraint = nil
            heightConstraint?.isActive = false
            heightConstraint = nil
        }
    }
}
