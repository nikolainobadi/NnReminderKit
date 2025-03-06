//
//  File.swift
//  
//
//  Created by Nikolai Nobadi on 3/6/25.
//

import SwiftUI
import UserNotifications

struct ReminderPermissionRequestViewModifier<DetailView: View, DeniedView: View>: ViewModifier {
    @StateObject var permissionENV: ReminderPermissionENV
    
    let deniedView: (URL?) -> DeniedView
    let detailView: (@escaping () -> Void) -> DetailView
    
    func body(content: Content) -> some View {
        switch permissionENV.status {
        case .authorized, .provisional:
            content
        case .notDetermined:
            detailView(permissionENV.requestPermission)
                .onAppear {
                    permissionENV.checkPermissionStatus()
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
    func requestReminderPermissions<DetailView: View, DeniedView: View>(options: UNAuthorizationOptions = [.alert, .badge, .sound], @ViewBuilder detailView: @escaping (@escaping () -> Void) -> DetailView, @ViewBuilder deniedView: @escaping (URL?) -> DeniedView) -> some View {
        modifier(ReminderPermissionRequestViewModifier(permissionENV: .init(manager: .init(), options: options), deniedView: deniedView, detailView: detailView))
    }
}


