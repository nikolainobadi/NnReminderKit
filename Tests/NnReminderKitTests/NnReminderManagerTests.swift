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
    
    func test_sets_notification_delegate() {
        let (sut, center) = makeSUT()
        
        sut.setNotificationDelegate(DelegateStub())
        
        assertProperty(center.delegate)
    }
    
    func test_requests_auth_permission() {
        // TODO: -
    }
    
    func test_checks_auth_status_asyncronously() async {
        // TODO: -
    }
    
    func test_checks_auth_status() {
        // TODO: -
    }
    
    func test_schedules_daily_reminder() {
        // TODO: -
    }
    
    func test_schedules_single_weekly_reminder_when_only_one_day_is_included() {
        // TODO: -
    }
    
    func test_schedules_multiple_weekly_reminders_when_more_than_one_day_is_included() {
        let (sut, center) = makeSUT()
        let weeklyReminder = makeWeeklyReminder(daysOfWeek: [.monday, .wednesday, .friday])
        
        sut.scheduleRecurringReminder(weeklyReminder)
        
        assertPropertyEquality(center.addedRequests.count, expectedProperty: 3)
    }
    
    func test_cancels_all_reminders() {
        // TODO: -
    }
    
    func test_cancels_daily_reminder() {
        // TODO: -
    }
    
    func test_cancels_single_weekly_reminder_when_only_one_day_is_included() {
        // TODO: -
    }
    
    func test_cancels_all_recurring_reminders_when_more_than_one_day_is_included() {
        // TODO: -
    }
    
    func test_asyncronously_loads_single_pending_weekly_reminder_when_only_one_day_is_included() async {
        // TODO: -
    }
    
    func test_loads_single_pending_weekly_reminder_when_only_one_day_is_included() {
        // TODO: -
    }
    
    func test_asyncronously_loads_pending_weekly_reminder_with_multiple_days_when_original_reminder_included_more_than_one_day() async {
        // TODO: - 
    }
    
    func test_loads_pending_weekly_reminder_with_multiple_days_when_original_reminder_included_more_than_one_day() {
        // TODO: -
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
    
    func makeWeeklyReminder(id: String = "WeeklyReminder", title: String = "Reminder", message: String = "test message", hour: Int = 8, minute: Int = 30, daysOfWeek: [DayOfWeek] = []) -> DefaultRecurringReminder {
        return .init(id: id, title: title, message: message, time: .hourAndMinute(.init(hour: hour, minute: minute)), recurringType: daysOfWeek.isEmpty ? .daily : .weekly(daysOfWeek))
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
