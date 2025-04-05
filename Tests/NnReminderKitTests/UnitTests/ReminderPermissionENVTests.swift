//
//  ReminderPermissionENVTests.swift
//  NnReminderKit
//
//  Created by Nikolai Nobadi on 4/5/25.
//

import Testing
import UserNotifications
@testable import NnReminderKit

@MainActor
struct ReminderPermissionENVTests {
    @Test("Starts with .notDetermined status")
    func startsWithNotDetermined() {
        let sut = makeSUT().sut
        #expect(sut.status == .notDetermined)
    }
}


// MARK: - Permission Checks
extension ReminderPermissionENVTests {
    @Test("checkPermissionStatus sets the status correctly")
    func checkPermissionStatus() async {
        let expectedStatus = UNAuthorizationStatus.provisional
        let sut = makeSUT(authStatus: expectedStatus).sut
        
        await sut.checkPermissionStatus()
        
        #expect(sut.status == expectedStatus)
    }
    
    @Test("requestPermission sets .authorized if granted")
    func requestPermissionAuthorized() async {
        let sut = makeSUT(isAuthorized: true).sut
        
        await sut.requestPermission()
        
        #expect(sut.status == .authorized)
    }
    
    @Test("requestPermission sets .denied if not granted")
    func requestPermissionDenied() async {
        let sut = makeSUT(isAuthorized: false).sut
        
        await sut.requestPermission()
        
        #expect(sut.status == .denied)
    }
}


// MARK: - SUT
private extension ReminderPermissionENVTests {
    func makeSUT(
        isAuthorized: Bool = false,
        authStatus: UNAuthorizationStatus = .notDetermined
    ) -> (sut: ReminderPermissionENV, delegate: MockPermissionDelegate) {
        let delegate = MockPermissionDelegate(
            isAuthorized: isAuthorized,
            authStatus: authStatus
        )
        
        let sut = ReminderPermissionENV(delegate: delegate, options: [])
        return (sut, delegate)
    }
}


// MARK: - Helper Classes
private extension ReminderPermissionENVTests {
    final class MockPermissionDelegate: PermissionDelegate, @unchecked Sendable {
        private let isAuthorized: Bool
        private let authStatus: UNAuthorizationStatus
        
        init(isAuthorized: Bool, authStatus: UNAuthorizationStatus) {
            self.isAuthorized = isAuthorized
            self.authStatus = authStatus
        }
        
        func checkForPermissionsWithoutRequest() async -> UNAuthorizationStatus {
            return authStatus
        }
        
        func requestAuthPermission(options: UNAuthorizationOptions) async -> Bool {
            return isAuthorized
        }
    }
}
