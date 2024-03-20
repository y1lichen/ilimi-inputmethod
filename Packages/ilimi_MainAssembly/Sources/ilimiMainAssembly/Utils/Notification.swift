// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import Foundation
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    // 推送系統通知
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
            self.userNotificationCenter.add(request) { _ in }
        }
    }
}
