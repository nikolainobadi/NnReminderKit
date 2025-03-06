//
//  NnReminderManagerTests.swift
//
//
//  Created by Nikolai Nobadi on 3/5/25.
//

import XCTest
import NnTestHelpers
import UserNotifications
@testable import NnReminderKit

final class NnReminderManagerTests: XCTestCase {
    func test_starting_values_are_empty() {
        let (_, center) = makeSUT()
        
        XCTAssertNil(center.delegate)
        XCTAssert(center.idsToRemove.isEmpty)
        XCTAssert(center.addedRequests.isEmpty)
        XCTAssertFalse(center.didRemoveAllPendingRequests)
        XCTAssertNil(center.authStatusCompletion)
        XCTAssertNil(center.pendingRequestsCompletion)
    }
}


// MARK: - SUT
extension NnReminderManagerTests {
    func makeSUT(throwError: Bool = false, isAuthorized: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> (sut: NnReminderManager, center: MockCenter) {
        let center = MockCenter(throwError: throwError, isAuthorized: isAuthorized)
        let sut = NnReminderManager(notifCenter: center)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, center)
    }
}


// MARK: - Helper Classes
extension NnReminderManagerTests {
    class MockCenter: NotifCenter {
        private let throwError: Bool
        private let isAuthorized: Bool
        
        private(set) var delegate: UNUserNotificationCenterDelegate?
        private(set) var idsToRemove: [String] = []
        private(set) var didRemoveAllPendingRequests = false
        private(set) var addedRequests: Set<UNNotificationRequest> = []
        private(set) var authStatusCompletion: ((UNAuthorizationStatus) -> Void)?
        private(set) var pendingRequestsCompletion: (([UNNotificationRequest]) -> Void)?
        
        init(throwError: Bool, isAuthorized: Bool) {
            self.throwError = throwError
            self.isAuthorized = isAuthorized
        }
        
        func add(_ request: UNNotificationRequest) {
            addedRequests.insert(request)
        }
        
        func removeAllPendingNotificationRequests() {
            didRemoveAllPendingRequests = true
        }
        
        func removePendingNotificationRequests(identifiers: [String]) {
            idsToRemove.append(contentsOf: identifiers)
        }
        
        func setNotificationDelegate(_ delegate: UNUserNotificationCenterDelegate) {
            self.delegate = delegate
        }
        
        func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            return isAuthorized
        }
        
        func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
            authStatusCompletion = completion
        }
        
        func getPendingNotificationRequests(completion: @escaping ([UNNotificationRequest]) -> Void) {
            pendingRequestsCompletion = completion
        }
        
        func complete(authStatus: UNAuthorizationStatus, file: StaticString = #filePath, line: UInt = #line) {
            guard let authStatusCompletion else {
                return XCTFail("authStatus request never made", file: file, line: line)
            }

            authStatusCompletion(authStatus)
        }
        
        func complete(requests: [UNNotificationRequest], file: StaticString = #filePath, line: UInt = #line) {
            guard let pendingRequestsCompletion else {
                return XCTFail("authStatus request never made", file: file, line: line)
            }

            pendingRequestsCompletion(requests)
        }
    }
}
