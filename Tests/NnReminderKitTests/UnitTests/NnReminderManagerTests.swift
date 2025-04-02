//
//  NnReminderManagerTests.swift
//  NnReminderKit
//
//  Created by Nikolai Nobadi on 4/1/25.
//

import Testing
import UserNotifications
@testable import NnReminderKit

struct NnReminderManagerTests {
    @Test("Starting values are empty")
    func emptyStartingValues() {
        let (_, center) = makeSUT()
        
        #expect(center.delegate == nil)
        #expect(center.idsToRemove.isEmpty)
        #expect(center.addedRequests.isEmpty)
        #expect(!center.didRemoveAllPendingRequests)
        #expect(center.authStatusCompletion == nil)
        #expect(center.pendingRequestsCompletion == nil)
    }
}


// MARK: - Setup & Auth
extension NnReminderManagerTests {
    @Test("Sets notification delegate")
    func setsNotifDelegate() async {
        let (sut, center) = makeSUT()
        
        await sut.setNotificationDelegate(DelegateStub())
        
        #expect(center.delegate != nil)
    }
}


// MARK: - SUT
private extension NnReminderManagerTests {
    func makeSUT(throwError: Bool = false, isAuthorized: Bool = false) -> (sut: NnReminderManager, center: MockCenter) {
        let center = MockCenter(throwError: throwError, isAuthorized: isAuthorized)
        let sut = NnReminderManager(notifCenter: center)
        
        return (sut, center)
    }
}


// MARK: - Helpers
private extension NnReminderManagerTests {
    final class DelegateStub: NSObject, UNUserNotificationCenterDelegate { }
    final class MockCenter: NotifCenter, @unchecked Sendable {
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
        
        func add(_ request: UNNotificationRequest) async throws {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            addedRequests.insert(request)
        }
        
        func add(_ request: UNNotificationRequest, completion: ((Error?) -> Void)?) {
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
        
        func complete(authStatus: UNAuthorizationStatus) throws {
            let authStatusCompletion = try #require(authStatusCompletion)

            authStatusCompletion(authStatus)
        }
        
        func complete(requests: [UNNotificationRequest]) throws {
            let pendingRequestsCompletion = try #require(pendingRequestsCompletion)

            pendingRequestsCompletion(requests)
        }
    }
}
