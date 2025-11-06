//
//  Alarm.swift
//  Vlarm
//
//  Created by Daksh Bahl on 10/28/25.
//

import Foundation

// MARK: - Alarm Model
// D-001: Alarm data structure with all required fields
struct Alarm: Identifiable, Codable, Equatable {
    var id: UUID
    var time: Date
    var isEnabled: Bool
    var reminderText: String // The message to play when alarm rings
    var repeatDaily: Bool // F-009: Repeat option
    var snoozeState: Bool // F-008: Snooze state (active or off)
    
    init(
        id: UUID = UUID(),
        time: Date,
        isEnabled: Bool = true,
        reminderText: String = "",
        repeatDaily: Bool = false,
        snoozeState: Bool = false
    ) {
        self.id = id
        self.time = time
        self.isEnabled = isEnabled
        self.reminderText = reminderText
        self.repeatDaily = repeatDaily
        self.snoozeState = snoozeState
    }
    
    // MARK: - Alarm Status Helper
    // Determines if alarm is past, active (upcoming today), or upcoming (future days)
    func status(relativeTo currentTime: Date) -> AlarmStatus {
        let calendar = Calendar.current
        
        // Compare just the time components (ignore date)
        let alarmComponents = calendar.dateComponents([.hour, .minute], from: time)
        let currentComponents = calendar.dateComponents([.hour, .minute], from: currentTime)
        
        guard let alarmHour = alarmComponents.hour,
              let alarmMinute = alarmComponents.minute,
              let currentHour = currentComponents.hour,
              let currentMinute = currentComponents.minute else {
            return .upcoming
        }
        
        // Check if alarm time has passed today
        let alarmMinutes = alarmHour * 60 + alarmMinute
        let currentMinutes = currentHour * 60 + currentMinute
        
        if alarmMinutes < currentMinutes {
            return .past
        } else if alarmMinutes == currentMinutes {
            return .active
        } else {
            return .upcoming
        }
    }
}

enum AlarmStatus {
    case past
    case active
    case upcoming
}

