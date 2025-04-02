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
    
    @Test("Requests auth permission", arguments: [true, false])
    func test_requests_auth_permission(isAuthorized: Bool) async {
        let sut = makeSUT(isAuthorized: isAuthorized).sut
        let granted = await sut.requestAuthPermission(options: [])
        
        #expect(granted == isAuthorized)
    }
    
    @Test("Not authorized if error is thrown during permission request")
    func test_not_authorized_if_error_is_thrown_during_permission_request() async {
        let sut = makeSUT(throwError: true, isAuthorized: true).sut
        let granted = await sut.requestAuthPermission(options: [])
        
        #expect(!granted)
    }
    
    @Test("Checks auth status")
    func test_checks_auth_status() async {
        let expectedStatus = UNAuthorizationStatus.authorized
        let sut = makeSUT(authStatus: expectedStatus).sut
        let status = await sut.checkForPermissionsWithoutRequest()
        
        #expect(status == expectedStatus)
    }
}


// MARK: - Countdown Reminders
extension NnReminderManagerTests {
    @Test("Schedules countdown reminder")
    func test_schedules_countdown_reminder() async throws {
        let (sut, center) = makeSUT()
        let countdownReminder = makeCountdownReminder(timeInterval: 3600)
        
        try await sut.scheduleCountdownReminder(countdownReminder)
        
        #expect(center.addedRequests.count == 1)
    }
    
    @Test("Cancels countdown reminder")
    func test_cancels_countdown_reminder() async {
        let (sut, center) = makeSUT()
        let countdownReminder = makeCountdownReminder()
        
        await sut.cancelCountdownReminder(countdownReminder)
        
        #expect(center.idsToRemove.count == 1)
    }
    
    @Test("Loads countdown remidners")
    func test_loads_countdown_reminders() async throws {
        let pendingReminder = makeCountdownReminder(id: "countdown_1", timeInterval: 3600)
        let request = NotificationRequestFactory.makeCountdownReminderRequest(for: pendingReminder)
        let sut = makeSUT(pendingRequests: [request]).sut
        let reminders = await sut.loadAllCountdownReminders()
        let loadedReminder = try #require(reminders.first)
        
        #expect(reminders.count == 1)
        #expect(loadedReminder.timeInterval == pendingReminder.timeInterval)
    }
}


// MARK: - Calendar Reminders
extension NnReminderManagerTests {
    @Test("Schedules a calendar reminder for a single day")
    func test_schedules_calendar_reminder_for_single_day() async throws {
        let (sut, center) = makeSUT()
        let calendarReminder = makeCalendarReminder(daysOfWeek: [.monday])
        
        try await sut.scheduleRecurringReminder(calendarReminder)
        
        #expect(center.addedRequests.count == 1)
    }
    
    @Test("Schedules a calendar reminder for a multiple days")
    func test_schedules_calendar_reminder_for_multiple_days() async throws {
        let (sut, center) = makeSUT()
        let calendarReminder = makeCalendarReminder(daysOfWeek: [.monday, .wednesday, .friday])
        
        try await sut.scheduleRecurringReminder(calendarReminder)
        
        #expect(center.addedRequests.count == 3)
    }
    
    @Test("Cancels a calendar reminder")
    func test_cancels_calendar_reminder() async {
        let (sut, center) = makeSUT()
        let calendarReminder = makeCalendarReminder(daysOfWeek: [.monday, .wednesday, .friday])
        
        await sut.cancelCalendarReminder(calendarReminder)
        
        #expect(center.idsToRemove.count == 3)
    }
    
    @Test("Loads pending calendar reminders")
    func test_loads_calendar_reminders() async throws {
        let daysOfWeek: [DayOfWeek] = [.monday, .wednesday, .friday]
        let pendingReminder = makeCalendarReminder(id: "first", daysOfWeek: daysOfWeek)
        let requests = NotificationRequestFactory.makeRecurringReminderRequests(for: pendingReminder)
        let sut = makeSUT(pendingRequests: requests).sut
        let loadedReminders = await sut.loadAllCalendarReminders()
        let reminder = try #require(loadedReminders.first)
        
        #expect(requests.count == daysOfWeek.count)
        #expect(loadedReminders.count == 1)
        #expect(reminder.daysOfWeek.count == daysOfWeek.count)
    }
}


// MARK: - SUT
private extension NnReminderManagerTests {
    func makeSUT(throwError: Bool = false, isAuthorized: Bool = false, authStatus: UNAuthorizationStatus = .notDetermined, pendingRequests: [UNNotificationRequest] = []) -> (sut: NnReminderManager, center: MockCenter) {
        let center = MockCenter(throwError: throwError, isAuthorized: isAuthorized, authStatus: authStatus, pendingRequests: pendingRequests)
        let sut = NnReminderManager(notifCenter: center)
        
        return (sut, center)
    }
    
    func makeCountdownReminder(id: String = "CountdownReminder", title: String = "Reminder", message: String = "test message", repeating: Bool = false, timeInterval: TimeInterval = 3600) -> CountdownReminder {
        return .init(id: id, title: title, message: message, repeating: repeating, timeInterval: timeInterval)
    }
    
    func makeCalendarReminder(id: String = "WeeklyReminder", title: String = "Reminder", message: String = "test message", hour: Int = 8, minute: Int = 30, repeating: Bool = true, daysOfWeek: [DayOfWeek] = []) -> CalendarReminder {
        return .init(id: id, title: title, message: message, time: .createReminderTime(hour: hour, minute: minute), repeating: repeating, daysOfWeek: daysOfWeek)
    }
}


// MARK: - Helpers
private extension NnReminderManagerTests {
    final class DelegateStub: NSObject, UNUserNotificationCenterDelegate { }
    final class MockCenter: NotifCenter, @unchecked Sendable {
        private let throwError: Bool
        private let isAuthorized: Bool
        private let authStatus: UNAuthorizationStatus
        private let pendingRequests: [UNNotificationRequest]
        
        private(set) var delegate: UNUserNotificationCenterDelegate?
        private(set) var idsToRemove: [String] = []
        private(set) var didRemoveAllPendingRequests = false
        private(set) var addedRequests: Set<UNNotificationRequest> = []
        
        init(throwError: Bool, isAuthorized: Bool, authStatus: UNAuthorizationStatus, pendingRequests: [UNNotificationRequest]) {
            self.throwError = throwError
            self.isAuthorized = isAuthorized
            self.authStatus = authStatus
            self.pendingRequests = pendingRequests
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
            completion(authStatus)
        }
        
        func getPendingNotificationRequests(completion: @escaping ([UNNotificationRequest]) -> Void) {
            completion(pendingRequests)
        }
    }
}
