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
    func requestsAuthPermission(isAuthorized: Bool) async {
        let sut = makeSUT(isAuthorized: isAuthorized).sut
        let granted = await sut.requestAuthPermission(options: [])
        
        #expect(granted == isAuthorized)
    }
    
    @Test("Not authorized if error is thrown during permission request")
    func notAuthorizedWhenErrorsThrown() async {
        let sut = makeSUT(throwError: true, isAuthorized: true).sut
        let granted = await sut.requestAuthPermission(options: [])
        
        #expect(!granted)
    }
    
    @Test("Checks auth status")
    func checksAuthStatus() async {
        let expectedStatus = UNAuthorizationStatus.authorized
        let sut = makeSUT(authStatus: expectedStatus).sut
        let status = await sut.checkForPermissionsWithoutRequest()
        
        #expect(status == expectedStatus)
    }
}


// MARK: - Countdown Reminders
extension NnReminderManagerTests {
    @Test("Schedules countdown reminder")
    func schedulesCountdownReminder() async throws {
        let (sut, center) = makeSUT()
        let countdownReminder = makeCountdownReminder(timeInterval: 3600)
        
        try await sut.scheduleCountdownReminder(countdownReminder)
        
        #expect(center.addedRequests.count == 1)
    }
    
    @Test("Cancels countdown reminder")
    func cancelsCountdownReminder() async {
        let (sut, center) = makeSUT()
        let countdownReminder = makeCountdownReminder()
        
        await sut.cancelCountdownReminder(countdownReminder)
        
        #expect(center.idsToRemove.count == 1)
    }
    
    @Test("Loads countdown remidners")
    func loadsCountdownReminders() async throws {
        let pendingReminder = makeCountdownReminder(id: "countdown_1", timeInterval: 3600)
        let request = NotificationRequestFactory.makeCountdownReminderRequest(for: pendingReminder)
        let sut = makeSUT(pendingRequests: [request]).sut
        let reminders = await sut.loadAllCountdownReminders()
        let loadedReminder = try #require(reminders.first)
        
        #expect(reminders.count == 1)
        #expect(loadedReminder.timeInterval == pendingReminder.timeInterval)
    }
}


// MARK: - WeekdayReminder
extension NnReminderManagerTests {
    @Test("Schedules a WeekdayReminder for a single day")
    func schedulesSingleDayWeekdayReminder() async throws {
        let (sut, center) = makeSUT()
        let calendarReminder = makeWeekdayReminder(daysOfWeek: [.monday])
        
        try await sut.scheduleRecurringReminder(calendarReminder)
        
        #expect(center.addedRequests.count == 1)
    }
    
    @Test("Schedules a WeekdayReminder for a multiple days")
    func schedulesMultipleDayWeekdayReminder() async throws {
        let (sut, center) = makeSUT()
        let calendarReminder = makeWeekdayReminder(daysOfWeek: [.monday, .wednesday, .friday])
        
        try await sut.scheduleRecurringReminder(calendarReminder)
        
        #expect(center.addedRequests.count == 3)
    }
    
    @Test("Cancels a WeekdayReminder")
    func cancelWeekdayReminder() async {
        let (sut, center) = makeSUT()
        let calendarReminder = makeWeekdayReminder(daysOfWeek: [.monday, .wednesday, .friday])
        
        await sut.cancelCalendarReminder(calendarReminder)
        
        #expect(center.idsToRemove.count == 3)
    }
    
    @Test("Loads pending WeekdayReminders")
    func loadWeekdayReminders() async throws {
        let daysOfWeek: [DayOfWeek] = [.monday, .wednesday, .friday]
        let pendingReminder = makeWeekdayReminder(id: "first", daysOfWeek: daysOfWeek)
        let requests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: pendingReminder)
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
