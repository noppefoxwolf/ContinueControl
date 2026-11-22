import Accelerate
import Combine
import UIKit
import os

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

@MainActor
open class ContinueControl: UIControl {
    #if os(iOS)
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    #endif
    let indicatorView = UIActivityIndicatorView(style: .medium)
    let height: CGFloat = 60
    let layoutGuide = ScrollContentLayoutGuide()
    var startContinuingObserver: AnyCancellable? = nil
    private var addedBottomInset: CGFloat = 0
    var scrollView: UIScrollView? { superview as? UIScrollView }
    open private(set) var isContinuing: Bool = false

    public init() {
        super.init(frame: .null)
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerYAnchor.constraint(equalTo: indicatorView.centerYAnchor),
        ])
    }

    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        startContinuingObserver = nil
        if let oldScrollView = scrollView {
            oldScrollView.removeLayoutGuide(layoutGuide)
            if addedBottomInset != 0 {
                oldScrollView.contentInset.bottom -= addedBottomInset
                addedBottomInset = 0
            }
        }
        
        if let newScrollView = newSuperview as? UIScrollView {
            newScrollView.addLayoutGuide(layoutGuide)
            
            if newScrollView.contentInset.bottom.isFinite {
                addedBottomInset = height
                newScrollView.contentInset.bottom += height
            }
        }
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let scrollView {
            let height = self.height
            NSLayoutConstraint.activate([
                topAnchor.constraint(
                    equalTo: layoutGuide.bottomAnchor
                ),
                leadingAnchor.constraint(
                    equalTo: layoutGuide.leadingAnchor
                ),
                trailingAnchor.constraint(
                    equalTo: layoutGuide.trailingAnchor
                ),
                heightAnchor.constraint(
                    equalToConstant: height
                )
            ])
            
            startContinuingObserver = scrollView.continueVisibilityPublisher(height: height)
            .removeDuplicates()
            .sink { [weak self] (isVisible) in
                if isVisible {
                    self?.startContinuing()
                }
            }
        } else {
            startContinuingObserver = nil
        }
    }
    
    /// beginContinuing when not isContinuing and trigger action.
    public func startContinuing() {
        guard !isContinuing else { return }
        beginContinuing()
        triggerPrimaryAction()
    }
    
    func triggerPrimaryAction() {
#if os(iOS)
        feedbackGenerator.impactOccurred()
        #endif
        sendActions(for: .primaryActionTriggered)
    }
    
    open func beginContinuing() {
        isContinuing = true
        indicatorView.startAnimating()
    }
    
    open func endContinuing() {
        isContinuing = false
        indicatorView.stopAnimating()
    }
    
    /// endContinuing when isContinuing
    public func finishContinuing() {
        guard isContinuing else { return }
        endContinuing()
    }
}

extension UIScrollView {
    /// contentOffset from bottom
    var inversedContentOffset: CGPoint {
        var point: CGPoint = .zero
        point.y += contentOffset.y.rounded()
        point.y -= contentSize.height.rounded()
        point.y += bounds.height.rounded()
        point.y -= safeAreaInsets.bottom.rounded()
        point.y -= contentInset.bottom.rounded()
        return point
    }
    
    /// contentSize bigger than visible contentSize
    var needsScrollContentSize: Bool {
        var visibleContentSize: CGSize = .zero
        visibleContentSize.height = bounds.height.rounded()
        guard visibleContentSize.height > 0 else { return false }
        visibleContentSize.height -= safeAreaInsets.top.rounded()
        visibleContentSize.height -= safeAreaInsets.bottom.rounded()
        return contentSize.height.rounded() > visibleContentSize.height.rounded()
    }
    
    func continueVisibilityPublisher(height: CGFloat) -> AnyPublisher<Bool, Never> {
        Publishers.CombineLatest4(
            publisher(for: \.contentSize),
            publisher(for: \.contentOffset),
            publisher(for: \.contentInset),
            publisher(for: \.safeAreaInsets)
        )
        .combineLatest(
            publisher(for: \.bounds).map(\.size).removeDuplicates()
        )
        .compactMap({ [weak self] _ in
            guard let self else { return nil }
            return needsScrollContentSize && inversedContentOffset.y >= -height
        })
        .eraseToAnyPublisher()
    }
}
