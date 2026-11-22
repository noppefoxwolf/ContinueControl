import XCTest
import UIKit
@testable import ContinueControl

final class ContinueControlTests: XCTestCase {
    @MainActor
    func testActionCanFinishContinuingSynchronously() {
        let control = ContinueControl()
        var didTrigger = false

        control.addAction(UIAction { [weak control] _ in
            didTrigger = true
            XCTAssertEqual(control?.isContinuing, true)
            control?.finishContinuing()
        }, for: .primaryActionTriggered)

        control.startContinuing()

        XCTAssertTrue(didTrigger)
        XCTAssertFalse(control.isContinuing)
    }

    @MainActor
    func testMovingControlPreservesEachScrollViewsBottomInset() {
        let first = UIScrollView()
        let second = UIScrollView()
        second.contentInset.bottom = 20
        let control = ContinueControl()

        first.continueControl = control
        XCTAssertEqual(first.contentInset.bottom, control.height)

        second.continueControl = control
        XCTAssertEqual(first.contentInset.bottom, 0)
        XCTAssertEqual(second.contentInset.bottom, 20 + control.height)

        second.continueControl = nil
        XCTAssertEqual(second.contentInset.bottom, 20)
    }
}
