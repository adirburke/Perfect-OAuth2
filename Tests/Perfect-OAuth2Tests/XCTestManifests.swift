import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Perfect_OAuth2Tests.allTests),
    ]
}
#endif
