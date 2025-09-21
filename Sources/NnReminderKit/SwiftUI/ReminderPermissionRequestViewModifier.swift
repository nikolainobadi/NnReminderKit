//
//  ReminderPermissionRequestViewModifier.swift
//
//
//  Created by Nikolai Nobadi on 3/6/25.
//

import SwiftUI
import UserNotifications

public extension View {
    /// A view modifier that requests notification permissions when necessary.
    ///
    /// This modifier presents different views based on the user's current notification permission status:
    /// - If permissions are granted (`.authorized` or `.provisional`), the original content is shown.
    /// - If permissions are not determined, `detailView` is displayed to prompt the user.
    /// - If permissions are denied, `deniedView` is displayed with an option to open settings.
    ///
    /// - Parameters:
    ///   - options: The notification authorization options (default: `.alert`, `.badge`, `.sound`).
    ///   - detailView: A closure returning a view that explains why permissions are needed, with a callback to request them.
    ///   - deniedView: A closure returning a view that informs the user permissions were denied, with an optional settings link.
    ///
    /// - Returns: A modified view that handles notification permission requests.
    @available(*, deprecated, message: "Use optionalNotificationPermissionsRequest or requiredNotificationPermissionsRequest instead. Use requiredNotificationPermissionsRequest for the same behavior as this modifier.")
    func requestReminderPermissions<DetailView: View, DeniedView: View>(
        options: UNAuthorizationOptions = [.alert, .badge, .sound],
        @ViewBuilder detailView: @escaping (@escaping () -> Void) -> DetailView,
        @ViewBuilder deniedView: @escaping (URL?) -> DeniedView
    ) -> some View {
        requiredNotificationPermissionsRequest(
            options: options,
            detailView: detailView,
            deniedView: deniedView
        )
    }
}