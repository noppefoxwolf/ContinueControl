import Testing
import UIKit
@testable import ContinueControl

@MainActor
struct ContinueControlTests {
    @Test
    func `Action can finish continuing synchronously`() {
        let control = ContinueControl()
        var didTrigger = false

        control.addAction(UIAction { [weak control] _ in
            didTrigger = true
            #expect(control?.isContinuing == true)
            control?.finishContinuing()
        }, for: .primaryActionTriggered)

        control.startContinuing()

        #expect(didTrigger)
        #expect(!control.isContinuing)
    }

    @Test
    func `Moving control preserves each scroll view's bottom inset`() {
        let first = UIScrollView()
        let second = UIScrollView()
        second.contentInset.bottom = 20
        let control = ContinueControl()

        first.continueControl = control
        #expect(first.contentInset.bottom == control.height)

        second.continueControl = control
        #expect(first.contentInset.bottom == 0)
        #expect(second.contentInset.bottom == 20 + control.height)

        second.continueControl = nil
        #expect(second.contentInset.bottom == 20)
    }
}
