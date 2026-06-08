import Flutter
import UIKit
import XCTest

@testable import zendesk_sdk

class RunnerTests: XCTestCase {
  func testIsInitialized_returnsFalseBeforeInitialize() {
    let plugin = ZendeskSdkPlugin()
    let call = FlutterMethodCall(methodName: ZendeskSdkChannel.Method.isInitialized, arguments: nil)

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertEqual(result as? Bool, false)
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }
}
