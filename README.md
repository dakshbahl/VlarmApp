# 💤 Vlarm — Voice-Based Accountability Alarm

Vlarm is a voice-controlled alarm app designed to help people stay disciplined, present, and productive.  
Instead of typing, users simply **speak** their reminder like:

“In 15 minutes remind me to finish my homework.”

Vlarm sets the alarm automatically and, when it goes off, the agent **speaks back** with the exact reminder in a friendly, human-sounding voice.

Vlarm is the alarm that holds you accountable — not just wakes you up.

---

## ✨ Core Idea

Vlarm isn't just about remembering things.  
It’s about following through.

When your alarm rings, the agent says your reminder aloud — like a real person nudging you to take action:

> “Hey, time to complete your homework now.”

You *hear yourself* again — and that creates accountability.

---

## 🎯 Main Goals

1. **Voice-controlled alarm creation** (no typing).
2. **Friendly AI agent** that speaks naturally to the user.
3. **Alarm rings using the agent’s voice** including your reminder.
4. **Simple interface** with all alarms listed on one screen.
5. **Edit, delete, repeat, and snooze** alarms easily.
6. **Motivation & accountability built-in**, including an optional **proof-of-action feature**.

---

## 🧠 Key Features

### 🎙 Voice Input
Press one microphone button → Tell Vlarm when to set the alarm.

### 🗣 Talking Agent
The agent speaks first:
> “Hey! When do you want to set the alarm?”

Then confirms the alarm afterward.

### 🕒 Smart Time Understanding
Vlarm interprets natural phrases:
- “In 20 minutes”
- “At 7 AM”
- “Every day at 6:30”

### 🔊 Alarm Rings in Agent’s Voice
When the alarm triggers, it uses the voice AI to say your reminder back to you.

### ⏱ Snooze
Tap **Snooze** for +5 minutes when needed.

### 📝 Alarm List & Editing
See all alarms on the home screen:
- Upcoming
- Past
- Active

---

## 💪 NEW: Accountability Proof Feature (Anti-Snooze Discipline Mode)

If enabled, the alarm **will NOT stop ringing** until the user **proves they did the task**.

Example:
> User says: “In 15 minutes remind me to do 15 jumping jacks.”

When the alarm goes off:
1. AI voice says: **“Time for jumping jacks!”**
2. A short follow-along video can play (optional).
3. The user must **record themselves completing the task**.
4. Only then does the alarm **turn off**.

This turns Vlarm into a *self-discipline coach*, not just a reminder app.

---

## 🧱 Screens

| Screen | Purpose |
|-------|---------|
| **Welcome Screen** | App intro + “Get Started” |
| **Home Screen** | Mic button + list of alarms |
| **Voice Agent Screen** | Conversation to set alarms |
| **Alarm Detail Screen** | Edit/delete/alarm settings |
| **Proof Submission Screen (NEW)** | Capture video to stop alarm |

---

## 🗂 Data Stored

- Alarm time (e.g., 7:30 AM)
- Reminder text (e.g., “do homework”)
- Repeat toggle
- Snooze state
- **Accountability mode** (on/off)
- Local video proof (temporary, auto-deleted)

All data is stored **locally on device**.

---

## 🔧 Tech Stack

| Component | Tech |
|----------|------|
| UI Layer | Swift / SwiftUI |
| Voice Recognition | OpenAI Whisper |
| Text-to-Speech | OpenAI TTS (or ElevenLabs) |
| Alarm Scheduling | iOS Local Notification / Background Tasks |
| Local Storage | UserDefaults / CoreData |

---

## 📱 Permissions Needed

- Microphone (voice input)
- Camera (proof videos)
- Notifications (alarm alerts)
- Background activity (alarm triggering)

---

## 🚀 Future Roadmap

- Cloud sync between devices
- Personal motivational voice styles
- AI productivity accountability dashboard
- Social accountability partner mode

---

## 👤 Created By

Built by **Daksh Bahl**  
Part of the **AgentFlow AI LLC** productivity ecosystem.

---

