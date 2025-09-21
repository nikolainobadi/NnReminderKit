//
//  OptionalReminderPermissionViewModifier.swift
//
//
//  Created by Nikolai Nobadi on 3/6/25.
//

import SwiftUI
import UserNotifications

struct OptionalReminderPermissionViewModifier<DetailView: View>: ViewModifier {
    @Binding private var permissionGranted: Bool
    @StateObject private var permissionENV: ReminderPermissionENV

    private let detailView: (@escaping () -> Void) -> DetailView
    
    init(permissionGranted: Binding<Bool>, permissionENV: @autoclosure @escaping () -> ReminderPermissionENV, @ViewBuilder detailView: @escaping (@escaping () -> Void) -> DetailView) {
        self.detailView = detailView
        self._permissionGranted = permissionGranted
        self._permissionENV = .init(wrappedValue: permissionENV())
    }

    func body(content: Content) -> some View {
        Group {
            switch permissionENV.status {
            case .notDetermined:
                detailView {
                    Task {
                        await permissionENV.requestPermission()
                    }
                }
            default:
                content
            }
        }
        .task {
            await permissionENV.checkPermissionStatus()
        }
        .onChange(of: permissionENV.status) { _, newStatus in
            switch newStatus {
            case .authorized, .provisional:
                permissionGranted = true
            default:
                permissionGranted = false
            }
        }
    }
}

public extension View {
    /// A view modifier that requests notification permissions before showing content.
    ///
    /// This modifier prompts for permission when not yet determined, then shows the original content
    /// regardless of whether permission was granted or denied. Unlike the required modifier, this doesn't
    /// show a separate denied view - content is accessible after any permission decision.
    ///
    /// Use this modifier when notifications enhance your app but aren't essential for core functionality.
    ///
    /// - Parameters:
    ///   - permissionGranted: A binding to track whether permissions are granted (true) or not granted (false).
    ///   - options: The notification authorization options (default: `.alert`, `.badge`, `.sound`).
    ///   - detailView: A closure returning a view that explains why permissions are beneficial, with a callback to request them.
    ///
    /// - Returns: A modified view that handles optional notification permission requests.
    func optionalNotificationPermissionsRequest<DetailView: View>(
        permissionGranted: Binding<Bool>,
        options: UNAuthorizationOptions = [.alert, .badge, .sound],
        @ViewBuilder detailView: @escaping (@escaping () -> Void) -> DetailView
    ) -> some View {
        modifier(
            OptionalReminderPermissionViewModifier(
                permissionGranted: permissionGranted,
                permissionENV: .init(delegate: NnReminderManager(), options: options),
                detailView: detailView
            )
        )
    }
}
