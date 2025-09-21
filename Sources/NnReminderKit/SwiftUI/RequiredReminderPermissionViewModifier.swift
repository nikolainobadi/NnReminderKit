//
//  RequiredReminderPermissionViewModifier.swift
//
//
//  Created by Nikolai Nobadi on 3/6/25.
//

import SwiftUI
import UserNotifications

struct RequiredReminderPermissionViewModifier<DetailView: View, DeniedView: View>: ViewModifier {
    @StateObject var permissionENV: ReminderPermissionENV

    let deniedView: (URL?) -> DeniedView
    let detailView: (@escaping () -> Void) -> DetailView

    func body(content: Content) -> some View {
        switch permissionENV.status {
        case .authorized, .provisional:
            content
        case .notDetermined:
            detailView {
                Task {
                    await permissionENV.requestPermission()
                }
            }
            .task {
                await permissionENV.checkPermissionStatus()
            }
        default:
            #if canImport(UIKit)
                deniedView(URL(string: UIApplication.openSettingsURLString))
            #else
            // TODO: - not sure if there is a mac equivalent for notification settings
                deniedView(nil)
            #endif
        }
    }
}

public extension View {
    /// A view modifier that requires notification permissions before showing content.
    ///
    /// This modifier blocks access to the original content until notification permissions are granted.
    /// It presents different views based on the user's current notification permission status:
    /// - If permissions are granted (`.authorized` or `.provisional`), the original content is shown.
    /// - If permissions are not determined, `detailView` is displayed to prompt the user.
    /// - If permissions are denied, `deniedView` is displayed with an option to open settings.
    ///
    /// Use this modifier when notifications are essential for your app's core functionality.
    ///
    /// - Parameters:
    ///   - options: The notification authorization options (default: `.alert`, `.badge`, `.sound`).
    ///   - detailView: A closure returning a view that explains why permissions are needed, with a callback to request them.
    ///   - deniedView: A closure returning a view that informs the user permissions were denied, with an optional settings link.
    ///
    /// - Returns: A modified view that requires notification permissions before showing content.
    func requiredNotificationPermissionsRequest<DetailView: View, DeniedView: View>(
        options: UNAuthorizationOptions = [.alert, .badge, .sound],
        @ViewBuilder detailView: @escaping (@escaping () -> Void) -> DetailView,
        @ViewBuilder deniedView: @escaping (URL?) -> DeniedView
    ) -> some View {
        modifier(
            RequiredReminderPermissionViewModifier(
                permissionENV: .init(delegate: NnReminderManager(), options: options),
                deniedView: deniedView,
                detailView: detailView
            )
        )
    }
}