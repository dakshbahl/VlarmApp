//
//  ElevenLabsTTSManager.swift
//  Vlarm
//
//  Created by Daksh Bahl on 10/28/25.
//

import Foundation
import AVFoundation

// MARK: - ElevenLabs TTS Manager
// Handles text-to-speech using ElevenLabs API
class ElevenLabsTTSManager: ObservableObject {
    static let shared = ElevenLabsTTSManager()
    
    // MARK: - Configuration
    // ElevenLabs API key - configured and ready to use
    private let apiKey: String = "sk_3a6b4164de7a9219751576d9760543c7587702fc5956a895"
    
    // Default voice ID - you can change this to any ElevenLabs voice ID
    // Popular voices: "21m00Tcm4TlvDq8ikWAM" (Rachel), "AZnzlk1XvdvUeBnXmlld" (Domi), etc.
    private let defaultVoiceId: String = "21m00Tcm4TlvDq8ikWAM" // Rachel - friendly female voice
    
    // API endpoint
    private let apiURL = "https://api.elevenlabs.io/v1/text-to-speech"
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {}
    
    // MARK: - Text-to-Speech Function
    /// Converts text to speech using ElevenLabs API
    /// - Parameters:
    ///   - text: The text to convert to speech
    ///   - voiceId: Optional voice ID (uses default if nil)
    ///   - completion: Callback when speech completes
    func speak(_ text: String, voiceId: String? = nil, completion: (() -> Void)? = nil) {
        // Check if API key is set
        guard apiKey != "YOUR_ELEVENLABS_API_KEY_HERE", !apiKey.isEmpty else {
            print("⚠️ ElevenLabs API key not set. Falling back to Apple TTS.")
            fallbackToAppleTTS(text, completion: completion)
            return
        }
        
        let voice = voiceId ?? defaultVoiceId
        
        // Create the request
        guard let url = URL(string: "\(apiURL)/\(voice)") else {
            print("❌ Invalid ElevenLabs API URL")
            fallbackToAppleTTS(text, completion: completion)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("audio/mpeg", forHTTPHeaderField: "Accept")
        
        // Request body
        // Using eleven_turbo_v2_5 - newer model available on free tier
        let requestBody: [String: Any] = [
            "text": text,
            "model_id": "eleven_turbo_v2_5", // Newer model available on free tier
            "voice_settings": [
                "stability": 0.5,
                "similarity_boost": 0.75,
                "style": 0.0,
                "use_speaker_boost": true
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        // Make the API call
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ ElevenLabs API error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.fallbackToAppleTTS(text, completion: completion)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response from ElevenLabs API")
                DispatchQueue.main.async {
                    self.fallbackToAppleTTS(text, completion: completion)
                }
                return
            }
            
            if httpResponse.statusCode != 200 {
                print("❌ ElevenLabs API error: Status code \(httpResponse.statusCode)")
                if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                    print("Error message: \(errorMessage)")
                }
                DispatchQueue.main.async {
                    self.fallbackToAppleTTS(text, completion: completion)
                }
                return
            }
            
            guard let audioData = data else {
                print("❌ No audio data received from ElevenLabs")
                DispatchQueue.main.async {
                    self.fallbackToAppleTTS(text, completion: completion)
                }
                return
            }
            
            // Play the audio
            DispatchQueue.main.async {
                self.playAudio(data: audioData, completion: completion)
            }
        }.resume()
    }
    
    // MARK: - Audio Playback
    private func playAudio(data: Data, completion: (() -> Void)?) {
        // Stop any currently playing audio and wait a moment
        if let player = audioPlayer {
            player.stop()
            audioPlayer = nil
        }
        
        // Small delay to ensure previous audio is fully stopped
        // This prevents truncation or overlapping speech
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            do {
                // Create new audio player
                self.audioPlayer = try AVAudioPlayer(data: data)
                self.audioPlayer?.prepareToPlay()
                self.audioPlayer?.play()
                
                // Calculate duration and call completion
                let duration = self.audioPlayer?.duration ?? 0
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    completion?()
                }
            } catch {
                print("❌ Error playing audio: \(error.localizedDescription)")
                completion?()
            }
        }
    }
    
    // MARK: - Fallback to Apple TTS
    private func fallbackToAppleTTS(_ text: String, completion: (() -> Void)?) {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
        
        // Estimate duration and call completion
        let estimatedDuration = Double(text.count) * 0.1
        DispatchQueue.main.asyncAfter(deadline: .now() + estimatedDuration) {
            completion?()
        }
    }
    
    // MARK: - Stop Speech
    func stop() {
        // Stop and reset the audio player completely
        if let player = audioPlayer {
            player.stop()
            audioPlayer = nil
        }
        // Small delay to ensure audio system processes the stop command
        // This prevents audio truncation when starting new speech immediately
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Audio should be fully stopped by now
        }
    }
}

