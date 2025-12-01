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
        
        sut.setNotificationDelegate(DelegateStub())
        
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
        
        sut.cancelCountdownReminder(countdownReminder)
        
        #expect(center.idsToRemove.count == 1)
    }
    
    @Test("Loads countdown remidners")
    func loadsCountdownReminders() async throws {
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
    @Test("Schedules a WeekdayReminder for a single day")
    func schedulesSingleDayWeekdayReminder() async throws {
        let (sut, center) = makeSUT()
        let calendarReminder = makeWeekdayReminder(daysOfWeek: [.monday])
        
        try await sut.scheduleWeekdayReminder(calendarReminder)
        
        #expect(center.addedRequests.count == 1)
    }
    
    @Test("Schedules a WeekdayReminder for a multiple days")
    func schedulesMultipleDayWeekdayReminder() async throws {
        let (sut, center) = makeSUT()
        let calendarReminder = makeWeekdayReminder(daysOfWeek: [.monday, .wednesday, .friday])
        
        try await sut.scheduleWeekdayReminder(calendarReminder)
        
        #expect(center.addedRequests.count == 3)
    }
    
    @Test("Cancels a WeekdayReminder")
    func cancelWeekdayReminder() async {
        let (sut, center) = makeSUT()
        let calendarReminder = makeWeekdayReminder(daysOfWeek: [.monday, .wednesday, .friday])
        
        sut.cancelWeekdayReminder(calendarReminder)
        
        #expect(center.idsToRemove.count == 3)
    }
    
    @Test("Loads pending WeekdayReminders")
    func loadWeekdayReminders() async throws {
        let daysOfWeek: [DayOfWeek] = [.monday, .wednesday, .friday]
        let pendingReminder = makeWeekdayReminder(daysOfWeek: daysOfWeek)
        let requests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: pendingReminder)
        let sut = makeSUT(pendingRequests: requests).sut
        let loadedReminders = await sut.loadAllWeekdayReminders()
        let reminder = try #require(loadedReminders.first)

        #expect(requests.count == daysOfWeek.count)
        #expect(loadedReminders.count == 1)
        #expect(reminder.daysOfWeek.count == daysOfWeek.count)
    }
}


// MARK: - WeekdayReminder (Daily Reminders)
extension NnReminderManagerTests {
    @Test("Schedules daily reminder with empty daysOfWeek array")
    func schedulesDailyReminderWithEmptyArray() async throws {
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

    @Test("Schedules one-time reminder with empty daysOfWeek and repeating false")
    func schedulesOneTimeReminderWithEmptyArray() async throws {
        let (sut, center) = makeSUT()
        let oneTimeReminder = makeWeekdayReminder(repeating: false, daysOfWeek: [])

        try await sut.scheduleWeekdayReminder(oneTimeReminder)

        #expect(center.addedRequests.count == 1)
        let request = try #require(center.addedRequests.first)
        let trigger = try #require(request.trigger as? UNCalendarNotificationTrigger)
        #expect(!trigger.repeats)
    }

    @Test("Loads daily reminder with empty daysOfWeek")
    func loadsDailyReminderWithEmptyArray() async throws {
        let pendingReminder = makeWeekdayReminder(daysOfWeek: [])
        let requests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: pendingReminder)
        let sut = makeSUT(pendingRequests: requests).sut

        let loadedReminders = await sut.loadAllWeekdayReminders()
        let reminder = try #require(loadedReminders.first)

        #expect(requests.count == 1)
        #expect(loadedReminders.count == 1)
        #expect(reminder.daysOfWeek.isEmpty)
        #expect(reminder.repeating)
    }

    @Test("Convenience factory: WeekdayReminder.daily creates daily reminder")
    func dailyFactoryMethodCreatesCorrectReminder() async throws {
        let (sut, center) = makeSUT()
        let dailyReminder = WeekdayReminder.daily(title: "Daily Reminder", message: "Every day", time: Date.createReminderTime(hour: 9, minute: 0))

        try await sut.scheduleWeekdayReminder(dailyReminder)

        #expect(center.addedRequests.count == 1)
        #expect(dailyReminder.daysOfWeek.isEmpty)
        #expect(dailyReminder.repeating)
    }

    @Test("Convenience factory: WeekdayReminder.oneTime creates non-repeating reminder")
    func oneTimeFactoryMethodCreatesCorrectReminder() async throws {
        let (sut, center) = makeSUT()
        let oneTimeReminder = WeekdayReminder.oneTime(title: "One Time", message: "Fires once", time: Date.createReminderTime(hour: 14, minute: 30))

        try await sut.scheduleWeekdayReminder(oneTimeReminder)

        #expect(center.addedRequests.count == 1)
        #expect(oneTimeReminder.daysOfWeek.isEmpty)
        #expect(!oneTimeReminder.repeating)
    }

    @Test("Loads only daily reminders using loadAllDailyReminders")
    func loadsOnlyDailyReminders() async throws {
        let dailyReminder = makeWeekdayReminder(repeating: true, daysOfWeek: [])
        let oneTimeReminder = makeWeekdayReminder(repeating: false, daysOfWeek: [])
        let weeklyReminder = makeWeekdayReminder(repeating: true, daysOfWeek: [.monday, .wednesday])

        let dailyRequests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: dailyReminder)
        let oneTimeRequests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: oneTimeReminder)
        let weeklyRequests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: weeklyReminder)

        let allRequests = dailyRequests + oneTimeRequests + weeklyRequests
        let sut = makeSUT(pendingRequests: allRequests).sut

        let loadedDailyReminders = await sut.loadAllDailyReminders()

        #expect(loadedDailyReminders.count == 1)
        #expect(loadedDailyReminders.first?.daysOfWeek.isEmpty == true)
        #expect(loadedDailyReminders.first?.repeating == true)
    }

    @Test("Loads only one-time reminders using loadAllOneTimeReminders")
    func loadsOnlyOneTimeReminders() async throws {
        let dailyReminder = makeWeekdayReminder(repeating: true, daysOfWeek: [])
        let oneTimeReminder = makeWeekdayReminder(repeating: false, daysOfWeek: [])
        let weeklyReminder = makeWeekdayReminder(repeating: true, daysOfWeek: [.monday, .wednesday])

        let dailyRequests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: dailyReminder)
        let oneTimeRequests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: oneTimeReminder)
        let weeklyRequests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: weeklyReminder)

        let allRequests = dailyRequests + oneTimeRequests + weeklyRequests
        let sut = makeSUT(pendingRequests: allRequests).sut

        let loadedOneTimeReminders = await sut.loadAllOneTimeReminders()

        #expect(loadedOneTimeReminders.count == 1)
        #expect(loadedOneTimeReminders.first?.daysOfWeek.isEmpty == true)
        #expect(loadedOneTimeReminders.first?.repeating == false)
    }

    @Test("Loads only weekly reminders using loadAllWeeklyReminders")
    func loadsOnlyWeeklyReminders() async throws {
        let dailyReminder = makeWeekdayReminder(repeating: true, daysOfWeek: [])
        let oneTimeReminder = makeWeekdayReminder(repeating: false, daysOfWeek: [])
        let weeklyReminder = makeWeekdayReminder(repeating: true, daysOfWeek: [.monday, .wednesday])

        let dailyRequests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: dailyReminder)
        let oneTimeRequests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: oneTimeReminder)
        let weeklyRequests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: weeklyReminder)

        let allRequests = dailyRequests + oneTimeRequests + weeklyRequests
        let sut = makeSUT(pendingRequests: allRequests).sut

        let loadedWeeklyReminders = await sut.loadAllWeeklyReminders()

        #expect(loadedWeeklyReminders.count == 1)
        #expect(loadedWeeklyReminders.first?.daysOfWeek.isEmpty == false)
        #expect(loadedWeeklyReminders.first?.daysOfWeek.count == 2)
    }
}


// MARK: - FutureDateReminder
extension NnReminderManagerTests {
    @Test("Schedules a FutureDateReminder with multiple dates")
    func schedulesFutureDateReminder() async throws {
        let (sut, center) = makeSUT()
        let reminder = makeFutureDateReminder(additionalDates: [
            Date.createReminderTime(hour: 10),
            Date.createReminderTime(hour: 12)
        ])

        try await sut.scheduleFutureDateReminder(reminder)

        #expect(center.addedRequests.count == 3)
    }

    @Test("Cancels a FutureDateReminder")
    func cancelsFutureDateReminder() async {
        let (sut, center) = makeSUT()
        let reminder = makeFutureDateReminder(additionalDates: [
            Date.createReminderTime(hour: 10),
            Date.createReminderTime(hour: 12)
        ])

        sut.cancelFutureDateReminder(reminder)

        #expect(center.idsToRemove.count == 3)
    }

    @Test("Loads pending FutureDateReminders")
    func loadsFutureDateReminders() async throws {
        let primary = Date.createReminderTime(hour: 9)
        let additional = [
            Date.createReminderTime(hour: 10),
            Date.createReminderTime(hour: 12)
        ]

        let pendingReminder = makeFutureDateReminder(additionalDates: additional)
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
    @Test("Cancels all countdown reminders matching base ID")
    func cancelsCountdownRemindersWithBaseID() async {
        let id = UUID()
        let reminder = makeCountdownReminder(id: id)
        let request = NotificationRequestFactory.makeCountdownReminderRequest(for: reminder)
        let (sut, center) = makeSUT(pendingRequests: [request])
        
        await sut.cancelReminders(identifiers: [id])
        
        #expect(center.idsToRemove == [id.uuidString])
    }

    @Test("Cancels all weekday reminders matching base ID")
    func cancelsWeekdayRemindersWithBaseID() async {
        let id = UUID()
        let reminder = makeWeekdayReminder(id: id, daysOfWeek: [.monday, .friday])
        let requests = NotificationRequestFactory.makeMultiTriggerReminderRequests(for: reminder)
        let (sut, center) = makeSUT(pendingRequests: requests)

        await sut.cancelReminders(identifiers: [id])

        #expect(center.idsToRemove == requests.map({ $0.identifier }))
    }

    @Test("Cancels all future date reminders matching base ID")
    func cancelsFutureDateRemindersWithBaseID() async {
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
    
    @Test("Cancels reminders for multiple base IDs")
    func cancelsRemindersForMultipleBaseIDs() async {
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
    
    @Test("Does not cancel reminders if no base IDs match")
    func doesNotCancelIfNoBaseIDsMatch() async {
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
    @Test("Schedules a LocationReminder")
    func schedulesLocationReminder() async throws {
        let (sut, center) = makeSUT()
        let reminder = makeLocationReminder()
        
        try await sut.scheduleLocationReminder(reminder)
        
        #expect(center.addedRequests.count == 1)
    }
    
    @Test("Cancels a LocationReminder")
    func cancelsLocationReminder() async {
        let (sut, center) = makeSUT()
        let reminder = makeLocationReminder()
        
        sut.cancelLocationReminder(reminder)
        
        #expect(center.idsToRemove == [reminder.id.uuidString])
    }
    
    @Test("Loads pending LocationReminders")
    func loadsLocationReminders() async throws {
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
        
        func getAuthorizationStatus() async -> UNAuthorizationStatus {
            return authStatus
        }
        
        func getPendingNotificationRequests() async -> [UNNotificationRequest] {
            return pendingRequests
        }
    }
}
