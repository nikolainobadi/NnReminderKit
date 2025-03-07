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


// MARK: - Setup & Auth
extension NnReminderManagerTests {
    func test_sets_notification_delegate() {
        let (sut, center) = makeSUT()
        
        sut.setNotificationDelegate(DelegateStub())
        
        assertProperty(center.delegate)
    }
    
    func test_requests_auth_permission() async {
        for isAuthorized in [true, false] {
            let sut = makeSUT(isAuthorized: isAuthorized).sut
            let granted = await sut.requestAuthPermission(options: [])
            
            XCTAssertEqual(granted, isAuthorized)
        }
    }
    
    func test_not_authorized_if_error_is_thrown_during_permission_request() async {
        let sut = makeSUT(throwError: true, isAuthorized: true).sut
        let granted = await sut.requestAuthPermission(options: [])
        
        XCTAssertFalse(granted)
    }
    
    func test_checks_auth_status() {
        let (sut, center) = makeSUT()
        let exp = expectation(description: "waiting for status")
        let expectedStatus = UNAuthorizationStatus.authorized
        
        var fetchedStatus: UNAuthorizationStatus?
        
        sut.checkForPermissionsWithoutRequest { status in
            fetchedStatus = status
            exp.fulfill()
        }
        
        center.complete(authStatus: expectedStatus)
        waitForExpectations(timeout: 0.1)
        
        assertPropertyEquality(fetchedStatus, expectedProperty: expectedStatus)
    }
}


// MARK: - Countdown Reminders
extension NnReminderManagerTests {
    func test_schedules_countdown_reminder() async throws {
        let (sut, center) = makeSUT()
        let countdownReminder = makeCountdownReminder(timeInterval: 3600)
        
        try await sut.scheduleCountdownReminder(countdownReminder)
        
        assertPropertyEquality(center.addedRequests.count, expectedProperty: 1)
    }
    
    func test_cancels_countdown_reminder() {
        let (sut, center) = makeSUT()
        let countdownReminder = makeCountdownReminder()
        
        sut.cancelCountdownReminder(countdownReminder)
        
        assertPropertyEquality(center.idsToRemove.count, expectedProperty: 1)
    }
    
    func test_loads_countdown_reminders() {
        let (sut, center) = makeSUT()
        let exp = expectation(description: "waiting for reminders")
        let pendingReminder = makeCountdownReminder(id: "countdown_1", timeInterval: 3600)
        let request = NotificationRequestFactory.makeCountdownReminderRequest(for: pendingReminder)
        
        var loadedReminders: [CountdownReminder] = []
        
        sut.loadAllCountdownReminders { reminders in
            loadedReminders = reminders
            exp.fulfill()
        }
        
        center.complete(requests: [request])
        waitForExpectations(timeout: 0.1)
        
        assertPropertyEquality(loadedReminders.count, expectedProperty: 1)
        assertPropertyEquality(loadedReminders.first?.timeInterval, expectedProperty: pendingReminder.timeInterval)
    }

}


// MARK: - Calendar Reminders
extension NnReminderManagerTests {
    func test_schedules_calendar_reminder_for_single_day() async throws {
        let (sut, center) = makeSUT()
        let calendarReminder = makeCalendarReminder(daysOfWeek: [.monday])
        
        try await sut.scheduleRecurringReminder(calendarReminder)
        
        assertPropertyEquality(center.addedRequests.count, expectedProperty: 1)
    }
    
    func test_schedules_calendar_reminder_for_multiple_days() async throws {
        let (sut, center) = makeSUT()
        let calendarReminder = makeCalendarReminder(daysOfWeek: [.monday, .wednesday, .friday])
        
        try await sut.scheduleRecurringReminder(calendarReminder)
        
        assertPropertyEquality(center.addedRequests.count, expectedProperty: 3)
    }
    
    func test_cancels_calendar_reminder() {
        let (sut, center) = makeSUT()
        let calendarReminder = makeCalendarReminder(daysOfWeek: [.monday, .wednesday, .friday])
        
        sut.cancelCalendarReminder(calendarReminder)
        
        assertPropertyEquality(center.idsToRemove.count, expectedProperty: 3)
    }
    
    func test_loads_calendar_reminders() {
        let (sut, center) = makeSUT()
        let exp = expectation(description: "waiting for reminders")
        let daysOfWeek: [DayOfWeek] = [.monday, .wednesday, .friday]
        let pendingReminder = makeCalendarReminder(id: "first", daysOfWeek: daysOfWeek)
        let requests = NotificationRequestFactory.makeRecurringReminderRequests(for: pendingReminder)
        
        var loadedReminders: [CalendarReminder] = []
        
        assertPropertyEquality(requests.count, expectedProperty: daysOfWeek.count)
        sut.loadAllCalendarReminders { reminders in
            loadedReminders = reminders
            exp.fulfill()
        }
        
        center.complete(requests: requests)
        waitForExpectations(timeout: 0.1)
        
        assertPropertyEquality(loadedReminders.count, expectedProperty: 1)
        assertPropertyEquality(loadedReminders.first?.daysOfWeek.count, expectedProperty: daysOfWeek.count)
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
    
    func makeCalendarReminder(id: String = "WeeklyReminder", title: String = "Reminder", message: String = "test message", hour: Int = 8, minute: Int = 30, repeating: Bool = true, daysOfWeek: [DayOfWeek] = []) -> CalendarReminder {
        return .init(id: id, title: title, message: message, time: .createReminderTime(hour: hour, minute: minute), repeating: repeating, daysOfWeek: daysOfWeek)
    }
    
    func makeCountdownReminder(id: String = "CountdownReminder", title: String = "Reminder", message: String = "test message", repeating: Bool = false, timeInterval: TimeInterval = 3600) -> CountdownReminder {
        return .init(id: id, title: title, message: message, repeating: repeating, timeInterval: timeInterval)
    }
}


// MARK: - Helper Classes
extension NnReminderManagerTests {
    class DelegateStub: NSObject, UNUserNotificationCenterDelegate { }
    
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
