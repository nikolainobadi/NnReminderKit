//
//  ShowNotificationSettingsButton.swift
//
//
//  Created by Nikolai Nobadi on 3/6/25.
//

import SwiftUI

/// A reusable button that opens the system notification settings.
///
/// This button provides a convenient way for users to navigate to notification settings
/// when they need to modify permission preferences.
public struct ShowNotificationSettingsButton<Label: View>: View {
    private let label: () -> Label

    public init(@ViewBuilder label: @escaping () -> Label) {
        self.label = label
    }

    public var body: some View {
        Button(action: openNotificationSettings) {
            label()
        }
    }

    private func openNotificationSettings() {
        #if canImport(UIKit)
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
        #else
        // TODO: - Determine macOS equivalent for notification settings
        // For now, this is a no-op on macOS
        #endif
    }
}

public extension ShowNotificationSettingsButton where Label == Text {
    /// Creates a button with default "Open Settings" text.
    init() {
        self.init {
            Text("Open Settings")
        }
    }
}