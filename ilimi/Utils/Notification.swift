//
//  Notification.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/28.
//

import Foundation
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    func pushInstantNotification(title: String, subtitle: String, body: String, sound: Bool) {
        userNotificationCenter.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                return
            }
            let content = UNMutableNotificationContent()
            content.title = title
            content.subtitle = subtitle
            content.body = body
            if sound {
                content.sound = UNNotificationSound.default
            }
            // 使用uuid做為identifier
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            self.userNotificationCenter.add(request) {_ in}
        }
    }
}
