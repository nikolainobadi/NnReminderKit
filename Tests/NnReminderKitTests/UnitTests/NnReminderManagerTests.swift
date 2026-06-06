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
    @Test
    func `Starting values are empty`() {
        let center = makeSUT().center
        
        #expect(center.delegate == nil)
        #expect(center.idsToRemove.isEmpty)
        #expect(center.addedRequests.isEmpty)
        #expect(!center.didRemoveAllPendingRequests)
    }
}


// MARK: - Setup & Auth
extension NnReminderManagerTests {
    @Test
    func `Registers a notification delegate with the notification center`() {
        let (sut, center) = makeSUT()

        sut.setNotificationDelegate(makeDelegateStub())

        #expect(center.delegate != nil)
    }
    
    @Test(arguments: [true, false])
    func `Permission request result reflects authorization grant`(isAuthorized: Bool) async {
        let sut = makeSUT(isAuthorized: isAuthorized).sut
        let granted = await sut.requestAuthPermission(options: [])
        
        #expect(granted == isAuthorized)
    }
    
    @Test
    func `Not authorized if error is thrown during permission request`() async {
        let sut = makeSUT(throwError: true, isAuthorized: true).sut
        let granted = await sut.requestAuthPermission(options: [])
        
        #expect(!granted)
    }
    
    @Test
    func `Checks auth status`() async {
        let expectedStatus = UNAuthorizationStatus.authorized
        let sut = makeSUT(authStatus: expectedStatus).sut
        let status = await sut.checkForPermissionsWithoutRequest()
        
        #expect(status == expectedStatus)
    }
}


// MARK: - Countdown Reminders
extension NnReminderManagerTests {
    @Test
    func `Schedules countdown reminder`() async throws {
        let (sut, center) = makeSUT()
        let countdownReminder = makeCountdownReminder(timeInterval: 3600)
        
        try await sut.scheduleCountdownReminder(countdownReminder)
        
        #expect(center.addedRequests.count == 1)
    }
    
    @Test
    func `Cancels countdown reminder`() {
        let (sut, center) = makeSUT()
        let countdownReminder = makeCountdownReminder()
        
        sut.cancelCountdownReminder(countdownReminder)
        
        #expect(center.idsToRemove.count == 1)
    }
    
    @Test
    func `Loads countdown reminders`() async throws {
        let pendingReminder = makeCountdownReminder(timeInterval: 3600)
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
    @Test
    func `Schedules a WeekdayReminder for a single day`() async throws {
        let (sut, center) = makeSUT()
        let calendarReminder = makeWeekdayReminder(daysOfWeek: [.monday])
        
        try await sut.scheduleWeekdayReminder(calendarReminder)
        
        #expect(center.addedRequests.count == 1)
    }
    
    @Test
    func `Schedules a WeekdayReminder for multiple days`() async throws {
        let (sut, center) = makeSUT()
        let calendarReminder = makeWeekdayReminder(daysOfWeek: [.monday, .wednesday, .friday])
        
        try await sut.scheduleWeekdayReminder(calendarReminder)
        
        #expect(center.addedRequests.count == 3)
    }
    
    @Test
    func `Cancels a WeekdayReminder`() {
        let (sut, center) = makeSUT()
        let calendarReminder = makeWeekdayReminder(daysOfWeek: [.monday, .wednesday, .friday])
        
        sut.cancelWeekdayReminder(calendarReminder)
        
        #expect(center.idsToRemove.count == 3)
    }
    
    @Test
    func `Loads pending WeekdayReminders`() async throws {
        let daysOfWeek: [DayOfWeek] = [.monday, .wednesday, .friday]
        let pendingReminder = makeWeekdayReminder(daysOfWeek: daysOfWeek)
        let requests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: pendingReminder)
        let sut = makeSUT(pendingRequests: requests).sut
        let loadedReminders = await sut.loadAllWeekdayReminders()
        let reminder = try #require(loadedReminders.first)

        #expect(loadedReminders.count == 1)
        #expect(reminder.daysOfWeek.count == daysOfWeek.count)
    }
}


// MARK: - WeekdayReminder (Daily Reminders)
extension NnReminderManagerTests {
    @Test
    func `Schedules daily reminder with empty daysOfWeek array`() async throws {
        let (sut, center) = makeSUT()
        let dailyReminder = makeWeekdayReminder(daysOfWeek: [])

        try await sut.scheduleWeekdayReminder(dailyReminder)

        #expect(center.addedRequests.count == 1)
        let request = try #require(center.addedRequests.first)
        let trigger = try #require(request.trigger as? UNCalendarNotificationTrigger)
        #expect(trigger.repeats)

        let components = trigger.dateComponents
        #expect(components.weekday == nil)
        #expect(components.hour != nil)
        #expect(components.minute != nil)
    }

    @Test
    func `Schedules one-time reminder with empty daysOfWeek and repeating false`() async throws {
        let (sut, center) = makeSUT()
        let oneTimeReminder = makeWeekdayReminder(repeating: false, daysOfWeek: [])

        try await sut.scheduleWeekdayReminder(oneTimeReminder)

        #expect(center.addedRequests.count == 1)
        let request = try #require(center.addedRequests.first)
        let trigger = try #require(request.trigger as? UNCalendarNotificationTrigger)
        #expect(!trigger.repeats)
    }

    @Test
    func `Loads daily reminder with empty daysOfWeek`() async throws {
        let pendingReminder = makeWeekdayReminder(daysOfWeek: [])
        let requests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: pendingReminder)
        let sut = makeSUT(pendingRequests: requests).sut

        let loadedReminders = await sut.loadAllWeekdayReminders()
        let reminder = try #require(loadedReminders.first)

        #expect(loadedReminders.count == 1)
        #expect(reminder.daysOfWeek.isEmpty)
        #expect(reminder.repeating)
    }

    @Test
    func `Daily convenience reminder repeats with no specific weekdays`() async throws {
        let (sut, center) = makeSUT()
        let dailyReminder = WeekdayReminder.daily(title: "Daily Reminder", message: "Every day", time: Date.createReminderTime(hour: 9, minute: 0))

        try await sut.scheduleWeekdayReminder(dailyReminder)

        #expect(center.addedRequests.count == 1)
        #expect(dailyReminder.daysOfWeek.isEmpty)
        #expect(dailyReminder.repeating)
    }

    @Test
    func `One-time convenience reminder schedules a single non-repeating request`() async throws {
        let (sut, center) = makeSUT()
        let oneTimeReminder = WeekdayReminder.oneTime(title: "One Time", message: "Fires once", time: Date.createReminderTime(hour: 14, minute: 30))

        try await sut.scheduleWeekdayReminder(oneTimeReminder)

        #expect(center.addedRequests.count == 1)
        #expect(oneTimeReminder.daysOfWeek.isEmpty)
        #expect(!oneTimeReminder.repeating)
    }

    @Test
    func `Loads only daily reminders when mixed reminder types are pending`() async throws {
        let dailyReminder = makeWeekdayReminder(repeating: true, daysOfWeek: [])
        let oneTimeReminder = makeWeekdayReminder(repeating: false, daysOfWeek: [])
        let weeklyReminder = makeWeekdayReminder(repeating: true, daysOfWeek: [.monday, .wednesday])

        let dailyRequests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: dailyReminder)
        let oneTimeRequests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: oneTimeReminder)
        let weeklyRequests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: weeklyReminder)

        let allRequests = dailyRequests + oneTimeRequests + weeklyRequests
        let sut = makeSUT(pendingRequests: allRequests).sut

        let loadedDailyReminders = await sut.loadAllDailyReminders()
        let reminder = try #require(loadedDailyReminders.first)

        #expect(loadedDailyReminders.count == 1)
        #expect(reminder.daysOfWeek.isEmpty)
        #expect(reminder.repeating)
    }

    @Test
    func `Loads only one-time reminders when mixed reminder types are pending`() async throws {
        let dailyReminder = makeWeekdayReminder(repeating: true, daysOfWeek: [])
        let oneTimeReminder = makeWeekdayReminder(repeating: false, daysOfWeek: [])
        let weeklyReminder = makeWeekdayReminder(repeating: true, daysOfWeek: [.monday, .wednesday])

        let dailyRequests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: dailyReminder)
        let oneTimeRequests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: oneTimeReminder)
        let weeklyRequests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: weeklyReminder)

        let allRequests = dailyRequests + oneTimeRequests + weeklyRequests
        let sut = makeSUT(pendingRequests: allRequests).sut

        let loadedOneTimeReminders = await sut.loadAllOneTimeReminders()
        let reminder = try #require(loadedOneTimeReminders.first)

        #expect(loadedOneTimeReminders.count == 1)
        #expect(reminder.daysOfWeek.isEmpty)
        #expect(!reminder.repeating)
    }

    @Test
    func `Loads only weekly reminders when mixed reminder types are pending`() async throws {
        let dailyReminder = makeWeekdayReminder(repeating: true, daysOfWeek: [])
        let oneTimeReminder = makeWeekdayReminder(repeating: false, daysOfWeek: [])
        let weeklyReminder = makeWeekdayReminder(repeating: true, daysOfWeek: [.monday, .wednesday])

        let dailyRequests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: dailyReminder)
        let oneTimeRequests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: oneTimeReminder)
        let weeklyRequests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: weeklyReminder)

        let allRequests = dailyRequests + oneTimeRequests + weeklyRequests
        let sut = makeSUT(pendingRequests: allRequests).sut

        let loadedWeeklyReminders = await sut.loadAllWeeklyReminders()
        let reminder = try #require(loadedWeeklyReminders.first)

        #expect(loadedWeeklyReminders.count == 1)
        #expect(!reminder.daysOfWeek.isEmpty)
        #expect(reminder.daysOfWeek.count == 2)
    }
}


// MARK: - FutureDateReminder
extension NnReminderManagerTests {
    @Test
    func `Schedules a FutureDateReminder with multiple dates`() async throws {
        let (sut, center) = makeSUT()
        let reminder = makeFutureDateReminder(additionalDates: [
            Date.createReminderTime(hour: 10),
            Date.createReminderTime(hour: 12)
        ])

        try await sut.scheduleFutureDateReminder(reminder)

        #expect(center.addedRequests.count == 3)
    }

    @Test
    func `Cancels a FutureDateReminder`() {
        let (sut, center) = makeSUT()
        let reminder = makeFutureDateReminder(additionalDates: [
            Date.createReminderTime(hour: 10),
            Date.createReminderTime(hour: 12)
        ])

        sut.cancelFutureDateReminder(reminder)

        #expect(center.idsToRemove.count == 3)
    }

    @Test
    func `Loads pending FutureDateReminders`() async throws {
        let primary = Date.createReminderTime(hour: 9)
        let additional = [
            Date.createReminderTime(hour: 10),
            Date.createReminderTime(hour: 12)
        ]

        let pendingReminder = makeFutureDateReminder(primaryDate: primary, additionalDates: additional)
        let requests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: pendingReminder)
        let sut = makeSUT(pendingRequests: requests).sut
        let reminders = await sut.loadAllFutureDateReminders()
        let loadedReminder = try #require(reminders.first)

        #expect(reminders.count == 1)
        #expect(loadedReminder.primaryDate.displayableDate == primary.displayableDate)
        #expect(loadedReminder.additionalDates.count == 2)
    }
}

// MARK: - Cancel by Base ID
extension NnReminderManagerTests {
    @Test
    func `Cancels all countdown reminders matching base ID`() async {
        let id = UUID()
        let reminder = makeCountdownReminder(id: id)
        let request = NotificationRequestFactory.makeCountdownReminderRequest(for: reminder)
        let (sut, center) = makeSUT(pendingRequests: [request])
        
        await sut.cancelReminders(identifiers: [id])
        
        #expect(center.idsToRemove == [id.uuidString])
    }

    @Test
    func `Cancels all weekday reminders matching base ID`() async {
        let id = UUID()
        let reminder = makeWeekdayReminder(id: id, daysOfWeek: [.monday, .friday])
        let requests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: reminder)
        let (sut, center) = makeSUT(pendingRequests: requests)

        await sut.cancelReminders(identifiers: [id])

        #expect(center.idsToRemove == requests.map({ $0.identifier }))
    }

    @Test
    func `Cancels all future date reminders matching base ID`() async {
        let id = UUID()
        let reminder = makeFutureDateReminder(id: id, additionalDates: [
            Date.createReminderTime(hour: 10),
            Date.createReminderTime(hour: 12)
        ])
        let requests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: reminder)
        let (sut, center) = makeSUT(pendingRequests: requests)

        await sut.cancelReminders(identifiers: [id])

        #expect(center.idsToRemove.allSatisfy { $0.hasPrefix(id.uuidString) })
        #expect(center.idsToRemove.count == 3)
    }
    
    @Test
    func `Cancels reminders for multiple base IDs`() async {
        let id1 = UUID()
        let id2 = UUID()
        
        let reminder1 = makeWeekdayReminder(id: id1, daysOfWeek: [.tuesday])
        let reminder2 = makeCountdownReminder(id: id2)
        
        let requests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: reminder1)
        + [NotificationRequestFactory.makeCountdownReminderRequest(for: reminder2)]
        
        let (sut, center) = makeSUT(pendingRequests: requests)
        
        await sut.cancelReminders(identifiers: [id1, id2])
        
        #expect(center.idsToRemove.contains(where: { $0.hasPrefix(id1.uuidString) }))
        #expect(center.idsToRemove.contains(where: { $0.hasPrefix(id2.uuidString) }))
        #expect(center.idsToRemove.count == requests.count)
    }
    
    @Test
    func `Does not cancel reminders if no base IDs match`() async {
        let id = UUID()
        let unrelatedReminder = makeCountdownReminder(id: UUID())
        let unrelatedRequest = NotificationRequestFactory.makeCountdownReminderRequest(for: unrelatedReminder)
        let (sut, center) = makeSUT(pendingRequests: [unrelatedRequest])
        
        await sut.cancelReminders(identifiers: [id])
        
        #expect(center.idsToRemove.isEmpty)
    }
}


// MARK: - LocationReminder
#if os(iOS)
extension NnReminderManagerTests {
    @Test
    func `Schedules a LocationReminder`() async throws {
        let (sut, center) = makeSUT()
        let reminder = makeLocationReminder()
        
        try await sut.scheduleLocationReminder(reminder)
        
        #expect(center.addedRequests.count == 1)
    }
    
    @Test
    func `Cancels a LocationReminder`() {
        let (sut, center) = makeSUT()
        let reminder = makeLocationReminder()
        
        sut.cancelLocationReminder(reminder)
        
        #expect(center.idsToRemove == [reminder.id.uuidString])
    }
    
    @Test
    func `Loads pending LocationReminders`() async throws {
        let pendingReminder = makeLocationReminder()
        let request = NotificationRequestFactory.makeLocationReminderRequest(for: pendingReminder)
        let sut = makeSUT(pendingRequests: [request]).sut
        let reminders = await sut.loadAllLocationReminders()
        let loadedReminder = try #require(reminders.first)
        
        #expect(reminders.count == 1)
        #expect(loadedReminder.locationRegion.latitude == pendingReminder.locationRegion.latitude)
        #expect(loadedReminder.locationRegion.longitude == pendingReminder.locationRegion.longitude)
        #expect(loadedReminder.locationRegion.radius == pendingReminder.locationRegion.radius)
    }
}
#endif

// MARK: - Helpers
private extension NnReminderManagerTests {
    func makeDelegateStub() -> DelegateStub {
        return DelegateStub()
    }

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
        
        func add(_ request: UNNotificationRequest, completion: (@Sendable (Error?) -> Void)?) {
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
        
        func getAuthorizationStatus() async -> UNAuthorizationStatus {
            return authStatus
        }
        
        func getPendingNotificationRequests() async -> [UNNotificationRequest] {
            return pendingRequests
        }
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
