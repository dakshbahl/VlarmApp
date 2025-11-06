//
//  ContentView.swift
//  Vlarm
//
//  Created by Daksh Bahl on 10/28/25.
//

import SwiftUI

// Alarm model is now in Alarm.swift

// MARK: - S-001: Home Screen
struct ContentView: View {
    @State private var alarms: [Alarm] = []
    @State private var showingVoiceAgent = false // Navigation to S-002
    @State private var selectedAlarm: Alarm? // For navigation to S-003
    @State private var showingAlarmDetail = false
    @State private var currentTime = Date()
    
    // Optional callback to navigate back to WelcomeView
    var onBackToWelcome: (() -> Void)?
    
    // Timer to update current time and alarm status
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Initialize with optional back navigation callback
    init(onBackToWelcome: (() -> Void)? = nil) {
        self.onBackToWelcome = onBackToWelcome
    }
    
    // MARK: - Computed Properties
    // F-006: Categorize alarms by status
    private var pastAlarms: [Alarm] {
        alarms.filter { $0.status(relativeTo: currentTime) == .past && $0.isEnabled }
    }
    
    private var activeAlarms: [Alarm] {
        alarms.filter { $0.status(relativeTo: currentTime) == .active && $0.isEnabled }
    }
    
    private var upcomingAlarms: [Alarm] {
        alarms.filter { $0.status(relativeTo: currentTime) == .upcoming && $0.isEnabled }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Section 7: Light modern theme with white-to-blue gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.9),
                        Color.blue.opacity(0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Current time display
                    VStack(spacing: 8) {
                        Text(currentTime, style: .time)
                            .font(.system(size: 64, weight: .thin, design: .rounded))
                            .foregroundColor(.black)
                        
                        Text(currentTime, style: .date)
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.black.opacity(0.7))
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 30)
                    
                    Divider()
                        .background(Color.black.opacity(0.2))
                        .padding(.horizontal)
                    
                    // F-006: Alarm List View
                    if alarms.isEmpty {
                        // Empty state message from requirements
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "alarm")
                                .font(.system(size: 60))
                                .foregroundColor(.black.opacity(0.5))
                            Text("No alarms yet — try setting one!")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.black.opacity(0.7))
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                // Active alarms (current)
                                if !activeAlarms.isEmpty {
                                    AlarmSection(
                                        title: "Active",
                                        alarms: activeAlarms,
                                        currentTime: currentTime,
                                        onAlarmTap: { alarm in
                                            selectedAlarm = alarm
                                            showingAlarmDetail = true
                                        }
                                    )
                                }
                                
                                // Upcoming alarms
                                if !upcomingAlarms.isEmpty {
                                    AlarmSection(
                                        title: "Upcoming",
                                        alarms: upcomingAlarms,
                                        currentTime: currentTime,
                                        onAlarmTap: { alarm in
                                            selectedAlarm = alarm
                                            showingAlarmDetail = true
                                        }
                                    )
                                }
                                
                                // Past alarms
                                if !pastAlarms.isEmpty {
                                    AlarmSection(
                                        title: "Past",
                                        alarms: pastAlarms,
                                        currentTime: currentTime,
                                        onAlarmTap: { alarm in
                                            selectedAlarm = alarm
                                            showingAlarmDetail = true
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100) // Space for floating button
                        }
                    }
                }
                
                // S-001: "Set Alarm" button with microphone icon
                // F-001: Voice Input Button
        VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            // Navigation: Tap mic → goes to S-002 Voice Agent Screen
                            showingVoiceAgent = true
                        } label: {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 70, height: 70)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Vlarm")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                // Back button to return to WelcomeView
                if onBackToWelcome != nil {
                    #if os(iOS)
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            onBackToWelcome?()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 17, weight: .regular))
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    #endif
                }
            }
            .sheet(isPresented: $showingVoiceAgent) {
                // S-002: Voice Agent Screen
                // Use id modifier to force recreation of the view each time
                VoiceAgentView(
                    alarms: $alarms,
                    onAlarmCreated: {
                        showingVoiceAgent = false
                    }
                )
                .id(showingVoiceAgent) // Force recreation when sheet opens
            }
            .sheet(isPresented: $showingAlarmDetail) {
                if let alarm = selectedAlarm {
                    // S-003: Alarm Detail Screen (placeholder for now)
                    AlarmDetailView(
                        alarm: binding(for: alarm),
                        onSave: {
                            showingAlarmDetail = false
                        },
                        onDelete: {
                            if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
                                alarms.remove(at: index)
                            }
                            showingAlarmDetail = false
                        }
                    )
                }
            }
            .onReceive(timer) { _ in
                currentTime = Date()
            }
        }
    }
    
    // MARK: - Helper Methods
    private func binding(for alarm: Alarm) -> Binding<Alarm> {
        guard let index = alarms.firstIndex(where: { $0.id == alarm.id }) else {
            fatalError("Alarm not found")
        }
        return $alarms[index]
    }
}

// MARK: - Alarm Section View
// Groups alarms by status (Active, Upcoming, Past)
struct AlarmSection: View {
    let title: String
    let alarms: [Alarm]
    let currentTime: Date
    let onAlarmTap: (Alarm) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black.opacity(0.8))
                .padding(.horizontal, 4)
            
            ForEach(alarms) { alarm in
                AlarmRow(alarm: alarm, currentTime: currentTime) {
                    onAlarmTap(alarm)
                }
            }
        }
    }
}

// MARK: - Alarm Row View
// F-006: Shows alarm with edit/delete capability
struct AlarmRow: View {
    let alarm: Alarm
    let currentTime: Date
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    // Time display
                    Text(alarm.time, style: .time)
                        .font(.system(size: 32, weight: .light, design: .rounded))
                        .foregroundColor(.black)
                    
                    // Reminder text or default label
                    if !alarm.reminderText.isEmpty {
                        Text(alarm.reminderText)
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.7))
                            .lineLimit(2)
                    } else {
                        Text("Alarm")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.6))
                    }
                    
                    // Repeat indicator
                    if alarm.repeatDaily {
                        HStack(spacing: 4) {
                            Image(systemName: "repeat")
                                .font(.system(size: 10))
                            Text("Daily")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.blue.opacity(0.7))
                        .padding(.top, 2)
                    }
                }
                
                Spacer()
                
                // Status indicator
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var statusColor: Color {
        switch alarm.status(relativeTo: currentTime) {
        case .active:
            return .green
        case .upcoming:
            return .blue
        case .past:
            return .gray
        }
    }
}

// VoiceAgentView is now in its own file: VoiceAgentView.swift

// MARK: - S-003: Alarm Detail Screen (Placeholder)
// Will be fully implemented in B-005
struct AlarmDetailView: View {
    @Binding var alarm: Alarm
    let onSave: () -> Void
    let onDelete: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTime: Date
    @State private var reminderText: String
    @State private var repeatDaily: Bool
    
    init(alarm: Binding<Alarm>, onSave: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self._alarm = alarm
        self.onSave = onSave
        self.onDelete = onDelete
        _selectedTime = State(initialValue: alarm.wrappedValue.time)
        _reminderText = State(initialValue: alarm.wrappedValue.reminderText)
        _repeatDaily = State(initialValue: alarm.wrappedValue.repeatDaily)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.1),
                        Color.blue.opacity(0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Time picker
                    DatePicker(
                        "Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    #if os(iOS)
                    .datePickerStyle(.wheel)
                    #endif
                    .labelsHidden()
                    .colorScheme(.dark)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .padding()
                    
                    // Reminder text input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reminder")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black.opacity(0.8))
                        
                        TextField("What should I remind you?", text: $reminderText)
        .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                            .accentColor(.blue)
                    }
                    .padding(.horizontal)
                    
                    // Repeat toggle
                    Toggle("Repeat Daily", isOn: $repeatDaily)
                        .padding(.horizontal)
                        .tint(.blue)
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Edit Alarm")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        alarm.time = selectedTime
                        alarm.reminderText = reminderText
                        alarm.repeatDaily = repeatDaily
                        onSave()
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
                #endif
            }
        }
    }
}

#Preview {
    ContentView()
}
