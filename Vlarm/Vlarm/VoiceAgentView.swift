//
//  VoiceAgentView.swift
//  Vlarm
//
//  Created by Daksh Bahl on 10/28/25.
//

import SwiftUI
import AVFoundation
import Speech

// Alarm model is defined in Alarm.swift
// MARK: - S-002: Voice Agent Screen
// B-002: Implements F-001, F-002, F-003
struct VoiceAgentView: View {
    @Binding var alarms: [Alarm]
    let onAlarmCreated: () -> Void
    @Environment(\.dismiss) var dismiss
    
    // Explicit initializer to ensure accessibility
    init(alarms: Binding<[Alarm]>, onAlarmCreated: @escaping () -> Void) {
        self._alarms = alarms
        self.onAlarmCreated = onAlarmCreated
    }
    
    // MARK: - State Management
    @State private var agentMessage: String = "Hey, when do you want to set the alarm?"
    @State private var userSpeechText: String = ""
    @State private var isListening: Bool = false
    @State private var isProcessing: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var agentAnimationScale: CGFloat = 1.0
    @State private var pulseAnimation: Bool = false
    
    // MARK: - Speech Recognition
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State private var audioEngine: AVAudioEngine?
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient matching app theme
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.9),
                        Color.blue.opacity(0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // MARK: - Agent Animation Area
                    // F-002: Visual representation of the talking agent
                    VStack(spacing: 20) {
                        // Agent icon with animation - clickable to repeat message
                        Button {
                            // Repeat the greeting message when icon is tapped
                            // Stop any existing speech first
                            ElevenLabsTTSManager.shared.stop()
                            
                            // Add delay to ensure previous audio is fully stopped
                            // This prevents truncation or overlapping speech
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                let greetingMessage = "Hey, when do you want to set the alarm?"
                                agentMessage = greetingMessage
                                speakAgentMessage(greetingMessage)
                            }
                        } label: {
                            ZStack {
                                // Pulse animation when agent is speaking
                                Circle()
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: 200, height: 200)
                                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                                    .opacity(pulseAnimation ? 0.5 : 0.8)
                                    .animation(
                                        Animation.easeInOut(duration: 1.5)
                                            .repeatForever(autoreverses: true),
                                        value: pulseAnimation
                                    )
                                
                                // Main agent icon
                                Image(systemName: "waveform.circle.fill")
                                    .font(.system(size: 100, weight: .light))
                                    .foregroundColor(.blue)
                                    .scaleEffect(agentAnimationScale)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom, 20)
                        
                        // MARK: - Agent Text Subtitles
                        // F-002: Shows what the agent is saying
                        VStack(spacing: 12) {
                            Text(agentMessage)
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.8))
                                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                )
                            
                            // User speech text display
                            if !userSpeechText.isEmpty {
                                Text("\"\(userSpeechText)\"")
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(.black.opacity(0.7))
                                    .italic()
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue.opacity(0.1))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // MARK: - Voice Input Button
                    // F-001: Button to start conversation
                    Button {
                        // Crash protection: Check state before proceeding
                        if isListening {
                            // Stop listening and process the speech
                            stopListeningAndProcess()
                        } else {
                            // Start listening with error protection
                            startListening()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(isListening ? Color.red : Color.blue)
                                .frame(width: 80, height: 80)
                                .shadow(color: (isListening ? Color.red : Color.blue).opacity(0.5), radius: 15, x: 0, y: 5)
                            
                            Image(systemName: isListening ? "stop.fill" : "mic.fill")
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .disabled(isProcessing)
                    .padding(.bottom, 40)
                    
                    // Error message display
                    // F-001, F-003: Error handling
                    if showError {
                        Text(errorMessage)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.red)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.red.opacity(0.1))
                            )
                            .padding(.horizontal, 30)
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Voice Agent")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        stopListening()
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
                #endif
            }
            .task {
                // F-002: Agent speaks first when screen appears
                // Using .task instead of .onAppear ensures it runs every time the view appears
                // Reset state and stop any existing speech
                ElevenLabsTTSManager.shared.stop()
                userSpeechText = ""
                isListening = false
                showError = false
                
                // Small delay to ensure view is fully loaded and audio is ready
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                
                // Speak the greeting message
                let greetingMessage = "Hey, when do you want to set the alarm?"
                agentMessage = greetingMessage
                speakAgentMessage(greetingMessage)
            }
            .onDisappear {
                stopListening()
                // Stop any ongoing speech when view disappears
                ElevenLabsTTSManager.shared.stop()
            }
        }
    }
    
    // MARK: - Speech Recognition Functions
    // F-003: Speech Recognition implementation
    
    private func startListening() {
        // Crash protection: Prevent multiple simultaneous starts
        guard !isListening && !isProcessing else {
            print("⚠️ Already listening or processing, ignoring request")
            return
        }
        
        // Set processing state on main thread
        isProcessing = true
        
        // Check permissions with error handling
        checkSpeechPermissions { granted in
            DispatchQueue.main.async {
                if granted {
                    // Start recognition directly without delay
                    startSpeechRecognition()
                } else {
                    showErrorMessage("Microphone permission is required. Please enable it in Settings.")
                    isProcessing = false
                }
            }
        }
    }
    
    private func checkSpeechPermissions(completion: @escaping (Bool) -> Void) {
        // Check microphone permission (iOS 17+ compatible)
        if #available(iOS 17.0, *) {
            switch AVAudioApplication.shared.recordPermission {
            case .granted:
                // Check speech recognition permission
                SFSpeechRecognizer.requestAuthorization { status in
                    DispatchQueue.main.async {
                        completion(status == .authorized)
                    }
                }
            case .denied, .undetermined:
                AVAudioApplication.requestRecordPermission { granted in
                    if granted {
                        SFSpeechRecognizer.requestAuthorization { status in
                            DispatchQueue.main.async {
                                completion(status == .authorized)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }
            @unknown default:
                completion(false)
            }
        } else {
            // Fallback for iOS < 17
            #if os(iOS)
            switch AVAudioSession.sharedInstance().recordPermission {
            case .granted:
                // Check speech recognition permission
                SFSpeechRecognizer.requestAuthorization { status in
                    DispatchQueue.main.async {
                        completion(status == .authorized)
                    }
                }
            case .denied, .undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    if granted {
                        SFSpeechRecognizer.requestAuthorization { status in
                            DispatchQueue.main.async {
                                completion(status == .authorized)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }
            @unknown default:
                completion(false)
            }
            #else
            completion(false)
            #endif
        }
    }
    
    private func startSpeechRecognition() {
        // Crash protection: Stop any existing recognition first
        stopListening()
        
        // Double-check permissions before starting
        guard let speechRecognizer = speechRecognizer else {
            showErrorMessage("Speech recognizer is not available.")
            isProcessing = false
            return
        }
        
        guard speechRecognizer.isAvailable else {
            showErrorMessage("Speech recognition is not available. Please check your internet connection.")
            isProcessing = false
            return
        }
        
        // Small delay to ensure previous audio session is fully stopped
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Continue with audio setup
            setupAudioEngineAndStartRecognition(speechRecognizer: speechRecognizer)
        }
    }
    
    private func setupAudioEngineAndStartRecognition(speechRecognizer: SFSpeechRecognizer) {
        // Configure audio session with crash protection
        #if os(iOS)
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Deactivate first to ensure clean state
            try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            
            // Set category before activating
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("❌ Audio session error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                showErrorMessage("Failed to configure audio session: \(error.localizedDescription)")
                isProcessing = false
            }
            return
        }
        #endif
        
        // Create a new audio engine instance
        let newAudioEngine = AVAudioEngine()
        
        // Create recognition request
        let newRequest = SFSpeechAudioBufferRecognitionRequest()
        newRequest.shouldReportPartialResults = true
        
        // Set up audio engine with crash protection
        let inputNode = newAudioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Remove any existing tap first (safety)
        // Note: removeTap is safe to call even if no tap exists
        inputNode.removeTap(onBus: 0)
        
        // Install tap on input node
        // Note: installTap doesn't throw, but we need to ensure audio session is ready
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            newRequest.append(buffer)
        }
        
        // Prepare audio engine
        newAudioEngine.prepare()
        
        // Start audio engine with error handling
        do {
            try newAudioEngine.start()
            
            // Store the audio engine after successful start
            audioEngine = newAudioEngine
            
            DispatchQueue.main.async {
                isListening = true
                isProcessing = false
                userSpeechText = ""
                showError = false
            }
        } catch {
            // Clean up on failure
            newAudioEngine.stop()
            inputNode.removeTap(onBus: 0)
            
            print("❌ Audio engine error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                showErrorMessage("Audio engine failed to start: \(error.localizedDescription)")
                isProcessing = false
            }
            return
        }
        
        // Store the request before starting task
        recognitionRequest = newRequest
        
        // Start recognition task
        // Note: No need for [weak self] in struct - structs are value types
        let task = speechRecognizer.recognitionTask(with: newRequest) { result, error in
            DispatchQueue.main.async {
                if let result = result {
                    // Update user speech text as it's being recognized
                    userSpeechText = result.bestTranscription.formattedString
                    
                    // If this is the final result, process it
                    if result.isFinal {
                        processUserSpeech(result.bestTranscription.formattedString)
                    }
                }
                
                if let error = error {
                    stopListening()
                    // Don't show error for cancellation or normal completion
                    let errorDesc = error.localizedDescription.lowercased()
                    if !errorDesc.contains("canceled") && 
                       !errorDesc.contains("recognition task was cancelled") &&
                       !errorDesc.contains("success") {
                        showErrorMessage("Speech recognition error: \(error.localizedDescription)")
                    }
                    isProcessing = false
                }
            }
        }
        
        // Store task reference
        recognitionTask = task
    }
    
    private func stopListeningAndProcess() {
        // Capture the speech text before stopping
        let capturedText = userSpeechText
        
        // Stop listening first
        stopListening()
        
        // If we have speech text, process it even if not final
        if !capturedText.isEmpty {
            // Then process the speech after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                processUserSpeech(capturedText)
            }
        } else {
            // No speech captured, just reset processing state
            DispatchQueue.main.async {
                isProcessing = false
            }
        }
    }
    
    private func stopListening() {
        // Stop audio engine safely
        if let engine = audioEngine {
            if engine.isRunning {
                engine.stop()
            }
            // Remove tap safely (removeTap is safe to call even if no tap exists)
            engine.inputNode.removeTap(onBus: 0)
            audioEngine = nil
        }
        
        // End recognition request safely
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        // Cancel recognition task safely
        recognitionTask?.cancel()
        recognitionTask = nil
        
        DispatchQueue.main.async {
            isListening = false
        }
        
        // Reset audio session with delay to avoid conflicts
        #if os(iOS)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            do {
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                // Ignore errors when deactivating audio session
            }
        }
        #endif
    }
    
    // MARK: - Speech Processing
    // F-004, F-005: Smart Time Parser and Reminder Detection
    
    private func processUserSpeech(_ text: String) {
        isProcessing = true
        stopListening()
        
        // F-004: Parse time from user speech
        // F-005: Extract reminder message
        
        // Simple parsing logic (will be enhanced with NLP later)
        let parsedResult = parseAlarmTimeAndMessage(from: text)
        
        if let alarmTime = parsedResult.time, !parsedResult.message.isEmpty {
            // Create alarm
            let newAlarm = Alarm(
                time: alarmTime,
                isEnabled: true,
                reminderText: parsedResult.message,
                repeatDaily: false,
                snoozeState: false
            )
            
            alarms.append(newAlarm)
            alarms.sort { $0.time < $1.time }
            
            // F-002: Agent confirms aloud
            let confirmationMessage = "Got it! I'll remind you to \(parsedResult.message) at \(alarmTime.formatted(date: .omitted, time: .shortened))."
            speakAgentMessage(confirmationMessage) {
                // Return to home screen after confirmation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onAlarmCreated()
                }
            }
        } else {
            // F-003: Agent asks to repeat if parsing fails
            let errorMessage = "Sorry, I didn't catch that. Could you repeat? For example, say 'Remind me in 20 minutes to finish my homework.'"
            speakAgentMessage(errorMessage)
            isProcessing = false
        }
    }
    
    // MARK: - Time Parsing Logic
    // F-004: Smart Time Parser - Enhanced with multiple patterns
    
    private func parseAlarmTimeAndMessage(from text: String) -> (time: Date?, message: String) {
        let lowercaseText = text.lowercased().trimmingCharacters(in: .whitespaces)
        let calendar = Calendar.current
        let now = Date()
        
        // Debug: Log the input text for easier debugging
        print("🔍 Parsing speech: '\(text)'")
        
        // F-005: Extract reminder message first (more reliable)
        let reminderMessage = extractReminderMessage(from: lowercaseText)
        
        // Pattern 1: "in X minutes/hours" or "in X min/hrs" or "X minutes from now"
        // Extract regex pattern to constant to avoid parser issues
        let pattern1 = "(?:in|for)\\s+(\\d+)\\s+(minute|minutes|min|mins|hour|hours|hr|hrs)(?:\\s+from\\s+now)?"
        if let minutesMatch = lowercaseText.range(of: pattern1, options: .regularExpression) {
            let matchedText = String(lowercaseText[minutesMatch])
            let numbers = matchedText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if let value = Int(numbers), value > 0 {
                let isHours = matchedText.contains("hour") || matchedText.contains("hr")
                let minutesToAdd = isHours ? value * 60 : value
                
                if let alarmTime = calendar.date(byAdding: .minute, value: minutesToAdd, to: now) {
                    print("✅ Parsed time: \(minutesToAdd) minutes from now")
                    return (alarmTime, reminderMessage.isEmpty ? "Complete your task" : reminderMessage)
                }
            }
        }
        
        // Pattern 2: "at X:XX AM/PM" or "at X AM/PM" or "X o'clock"
        // Extract regex pattern to constant to avoid parser issues
        let pattern2 = "at\\s+(\\d{1,2})(?::(\\d{2}))?\\s*(am|pm|oclock)"
        if let timeMatch = lowercaseText.range(of: pattern2, options: .regularExpression) {
            let timeString = String(lowercaseText[timeMatch])
            let components = timeString.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
            
            if let hourStr = components.first, let hour = Int(hourStr), hour >= 1 && hour <= 12 {
                let minute = components.count > 1 ? (Int(components[1]) ?? 0) : 0
                var finalHour = hour
                
                // Handle AM/PM
                if timeString.contains("pm") && hour != 12 {
                    finalHour = hour + 12
                } else if timeString.contains("am") && hour == 12 {
                    finalHour = 0
                } else if timeString.contains("oclock") || timeString.contains("o'clock") {
                    // Default to AM if no AM/PM specified and it's before noon
                    if hour < 12 && calendar.component(.hour, from: now) >= 12 {
                        finalHour = hour + 12
                    }
                }
                
                if let alarmTime = calendar.date(bySettingHour: finalHour, minute: minute, second: 0, of: now) {
                    // If time has passed today, set for tomorrow
                    let finalTime = alarmTime < now ? calendar.date(byAdding: .day, value: 1, to: alarmTime) ?? alarmTime : alarmTime
                    print("✅ Parsed time: \(finalHour):\(String(format: "%02d", minute))")
                    return (finalTime, reminderMessage.isEmpty ? "Complete your task" : reminderMessage)
                }
            }
        }
        
        // Pattern 3: "wake me up at X" or "set alarm for X"
        // Extract regex pattern to constant to avoid parser issues
        let pattern3 = "(?:wake\\s+me\\s+up|set\\s+alarm|alarm)\\s+(?:at|for)\\s+(\\d{1,2})(?::(\\d{2}))?\\s*(am|pm)?"
        if let wakeMatch = lowercaseText.range(of: pattern3, options: .regularExpression) {
            let timeString = String(lowercaseText[wakeMatch])
            let components = timeString.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
            
            if let hourStr = components.first, let hour = Int(hourStr), hour >= 1 && hour <= 12 {
                let minute = components.count > 1 ? (Int(components[1]) ?? 0) : 0
                var finalHour = hour
                
                // Check if PM is mentioned anywhere in the text
                if lowercaseText.contains("pm") && hour != 12 {
                    finalHour = hour + 12
                } else if lowercaseText.contains("am") && hour == 12 {
                    finalHour = 0
                } else if hour < 12 && calendar.component(.hour, from: now) >= 12 {
                    // Default to PM if current time is afternoon
                    finalHour = hour + 12
                }
                
                if let alarmTime = calendar.date(bySettingHour: finalHour, minute: minute, second: 0, of: now) {
                    let finalTime = alarmTime < now ? calendar.date(byAdding: .day, value: 1, to: alarmTime) ?? alarmTime : alarmTime
                    print("✅ Parsed time from wake/set pattern: \(finalHour):\(String(format: "%02d", minute))")
                    return (finalTime, reminderMessage.isEmpty ? "Wake up" : reminderMessage)
                }
            }
        }
        
        // Pattern 4: If we have a reminder but no time, default to 15 minutes
        if !reminderMessage.isEmpty {
            if let defaultTime = calendar.date(byAdding: .minute, value: 15, to: now) {
                print("✅ No time specified, defaulting to 15 minutes from now")
                return (defaultTime, reminderMessage)
            }
        }
        
        print("❌ Could not parse time or message from: '\(text)'")
        return (nil, reminderMessage)
    }
    
    // MARK: - Reminder Message Extraction
    // F-005: Reminder Message Detection - Enhanced extraction
    
    private func extractReminderMessage(from text: String) -> String {
        let lowercaseText = text.lowercased()
        var message = ""
        
        // Common patterns to extract reminder messages
        let patterns = [
            "remind me to",
            "tell me to",
            "to",
            "that",
            "about",
            "for",
            "wake me up and tell me to",
            "set alarm and tell me to"
        ]
        
        // Try each pattern to find the reminder message
        for pattern in patterns {
            if let range = lowercaseText.range(of: pattern) {
                let afterPattern = String(lowercaseText[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                
                // Remove time-related words that might be at the end
                let timeWords = ["in", "at", "for", "minutes", "hours", "am", "pm", "oclock"]
                var cleanedMessage = afterPattern
                
                // Remove trailing time phrases
                for timeWord in timeWords {
                    // Escape special regex characters in timeWord
                    let escapedTimeWord = NSRegularExpression.escapedPattern(for: timeWord)
                    if let timeRange = cleanedMessage.range(of: "\\s+\(escapedTimeWord)\\b", options: .regularExpression) {
                        cleanedMessage = String(cleanedMessage[..<timeRange.lowerBound])
                    }
                }
                
                cleanedMessage = cleanedMessage.trimmingCharacters(in: .whitespaces)
                
                // If we found a meaningful message (more than 2 words or contains common action words)
                if cleanedMessage.count > 3 && !cleanedMessage.isEmpty {
                    message = cleanedMessage
                    break
                }
            }
        }
        
        // If no pattern matched, try to extract meaningful text after common phrases
        if message.isEmpty {
            // Look for action words that might indicate a task
            let actionWords = ["do", "finish", "complete", "go", "call", "pick", "buy", "study", "work", "exercise"]
            for actionWord in actionWords {
                if let range = lowercaseText.range(of: actionWord) {
                    let afterAction = String(lowercaseText[range.lowerBound...]).trimmingCharacters(in: .whitespaces)
                    // Take up to 10 words after the action
                    let words = afterAction.components(separatedBy: .whitespaces).prefix(10)
                    message = words.joined(separator: " ")
                    break
                }
            }
        }
        
        // Capitalize first letter and clean up
        if !message.isEmpty {
            message = message.capitalized
            // Remove trailing punctuation if it's just a period
            if message.hasSuffix(".") {
                message = String(message.dropLast())
            }
        }
        
        print("📝 Extracted reminder message: '\(message)'")
        return message
    }
    
    // MARK: - Agent Voice Functions
    // F-002: Talking Agent (AI Voice) - Now using ElevenLabs TTS
    
    private func speakAgentMessage(_ message: String, completion: (() -> Void)? = nil) {
        // Update agent message display
        agentMessage = message
        
        // Start pulse animation
        withAnimation {
            pulseAnimation = true
        }
        
        // Stop any current speech first
        ElevenLabsTTSManager.shared.stop()
        
        // Use ElevenLabs TTS (falls back to Apple TTS if API key not set)
        ElevenLabsTTSManager.shared.speak(message) {
            // Stop animation after speech completes
            withAnimation {
                pulseAnimation = false
            }
            completion?()
        }
    }
    
    // MARK: - Error Handling
    // F-001, F-003: Error handling
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
        
        // Auto-hide error after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            showError = false
        }
    }
}

// Preview removed - view is accessible from ContentView
// #Preview {
//     struct PreviewWrapper: View {
//         @State private var alarms: [Alarm] = []
//         
//         var body: some View {
//             VoiceAgentView(
//                 alarms: Binding(
//                     get: { alarms },
//                     set: { alarms = $0 }
//                 ),
//                 onAlarmCreated: {}
//             )
//         }
//     }
//     
//     return PreviewWrapper()
// }


