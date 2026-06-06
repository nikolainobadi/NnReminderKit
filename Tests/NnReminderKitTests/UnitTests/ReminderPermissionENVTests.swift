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
    @Test
    func `Starts with .notDetermined status`() {
        let sut = makeSUT()
        #expect(sut.status == .notDetermined)
    }
}


// MARK: - Permission Checks
extension ReminderPermissionENVTests {
    @Test
    func `Updates status to the current authorization status when checking permissions`() async {
        let expectedStatus = UNAuthorizationStatus.provisional
        let sut = makeSUT(authStatus: expectedStatus)
        
        await sut.checkPermissionStatus()
        
        #expect(sut.status == expectedStatus)
    }
    
    @Test
    func `Status becomes authorized when permission is granted`() async {
        let sut = makeSUT(isAuthorized: true)
        
        await sut.requestPermission()
        
        #expect(sut.status == .authorized)
    }
    
    @Test
    func `Status becomes denied when permission is not granted`() async {
        let sut = makeSUT(isAuthorized: false)
        
        await sut.requestPermission()
        
        #expect(sut.status == .denied)
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


// MARK: - SUT
private extension ReminderPermissionENVTests {
    func makeSUT(
        isAuthorized: Bool = false,
        authStatus: UNAuthorizationStatus = .notDetermined
    ) -> ReminderPermissionENV {
        let delegate = MockPermissionDelegate(
            isAuthorized: isAuthorized,
            authStatus: authStatus
        )

        return ReminderPermissionENV(delegate: delegate, options: [])
    }
}
