import XCTest

@testable import Atoms

@MainActor
final class ObservableObjectAtomTests: XCTestCase {
    final class TestObject: ObservableObject {
        @Published
        var value: Int

        init(value: Int) {
            self.value = value
        }
    }

    struct TestAtom: ObservableObjectAtom, Hashable {
        let value: Int

        func object(context: Context) -> TestObject {
            TestObject(value: value)
        }
    }

    func test() {
        let atom = TestAtom(value: 100)
        let context = AtomTestContext()
        let object = context.watch(atom)
        let expectation = expectation(description: "test")
        var updatedValue: Int?

        context.onUpdate = {
            updatedValue = object.value
            expectation.fulfill()
        }

        object.value = 200

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(updatedValue, 200)
    }
}
