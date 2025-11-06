//
//  WelcomeView.swift
//  Vlarm
//
//  Created by Daksh Bahl on 10/28/25.
//

import SwiftUI

// MARK: - Welcome Screen
// First page users see when opening the app
struct WelcomeView: View {
    @State private var showContentView = false
    @State private var animationOffset: CGFloat = 50
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Beautiful gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.6),
                    Color.purple.opacity(0.4),
                    Color.pink.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated background circles for visual interest
            GeometryReader { geometry in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .offset(x: -100, y: -100)
                
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .offset(x: geometry.size.width - 50, y: geometry.size.height * 0.7)
                
                Circle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: 150, height: 150)
                    .offset(x: geometry.size.width * 0.5, y: geometry.size.height - 100)
            }
            
            ScrollView {
                VStack(spacing: 30) {
                    // Stay tuned for launch banner
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Stay Tuned for Launch")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.8))
                        )
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .offset(y: animationOffset)
                    .opacity(opacity)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    // App Icon/Logo placeholder
                    Image(systemName: "alarm.fill")
                        .font(.system(size: 80, weight: .light))
                        .foregroundColor(.black)
                        .padding()
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 140, height: 140)
                        )
                        .offset(y: animationOffset)
                        .opacity(opacity)
                    
                    // Welcome Title
                    Text("Welcome to Vlarm")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .offset(y: animationOffset)
                        .opacity(opacity)
                    
                    // Founded by
                    VStack(spacing: 8) {
                        Text("Founded by")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black.opacity(0.8))
                        
                        Text("Daksh Bahl and AgentFlow AI")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    .offset(y: animationOffset)
                    .opacity(opacity)
                    
                    // App Description
                    VStack(alignment: .leading, spacing: 20) {
                        Text("About Vlarm")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.bottom, 8)
                        
                        Text("The Voice-Driven Productivity Alarm App is a conversational alarm system designed to help users stay accountable to their goals, tasks, and daily priorities. Instead of a traditional alarm that simply rings and is easily dismissed, this app uses a natural, friendly AI voice interaction to ensure the user actually completes what they intended to do.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.black.opacity(0.9))
                            .lineSpacing(6)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("The user simply speaks naturally to set an alarm, for example:")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black.opacity(0.9))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• \"Remind me in 20 minutes to finish my homework.\"")
                                Text("• \"Wake me up at 6:30 AM and tell me to go to the gym.\"")
                                Text("• \"In 45 minutes remind me to switch my laundry.\"")
                            }
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.black.opacity(0.8))
                            .padding(.leading, 8)
                        }
                        
                        Text("There is no typing required. The app listens, understands, and sets the alarm automatically.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.black.opacity(0.9))
                            .lineSpacing(6)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("When the alarm goes off, it doesn't just ring — it speaks directly to the user, reminding them of the task they committed to:")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black.opacity(0.9))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• \"Hey — time to finish your homework.\"")
                                Text("• \"Alright — gym time. Let's get moving.\"")
                                Text("• \"Laundry's ready — go change it out.\"")
                            }
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.black.opacity(0.8))
                            .padding(.leading, 8)
                        }
                        
                        Text("This makes the alarm purpose-driven, not just time-based.")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.top, 8)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.9))
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.7))
                                    .blur(radius: 10)
                            )
                    )
                    .padding(.horizontal, 20)
                    .offset(y: animationOffset)
                    .opacity(opacity)
                    
                    // Accountability Feature Idea (Coming Soon)
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.blue)
                            
                            Text("Coming Soon: Accountability Feature")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .padding(.bottom, 8)
                        
                        Text("Stay accountable and motivated with video proof! When you set an alarm, you can request accountability by saying something like:")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.black.opacity(0.9))
                            .lineSpacing(6)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("\"When I wake up, make sure I send you a video of me doing 15 pushups to make sure I'm getting the work done.\"")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.blue)
                                .italic()
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue.opacity(0.1))
                                )
                        }
                        .padding(.leading, 8)
                        
                        Text("When your alarm goes off, the camera will automatically open, allowing you to record video proof of completing your task. This feature helps you stay accountable and work harder toward your goals.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.black.opacity(0.9))
                            .lineSpacing(6)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.9))
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.7))
                                    .blur(radius: 10)
                            )
                    )
                    .padding(.horizontal, 20)
                    .offset(y: animationOffset)
                    .opacity(opacity)
                    
                    // Get Started Button
                    Button {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showContentView = true
                        }
                    } label: {
                        HStack {
                            Text("Get Started")
                                .font(.system(size: 20, weight: .semibold))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                    .offset(y: animationOffset)
                    .opacity(opacity)
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
        }
        .fullScreenCover(isPresented: $showContentView) {
            ContentView(onBackToWelcome: {
                showContentView = false
            })
        }
        .onAppear {
            // Animate content appearance
            withAnimation(.easeOut(duration: 0.8)) {
                animationOffset = 0
                opacity = 1
            }
        }
    }
}

#Preview {
    WelcomeView()
}

