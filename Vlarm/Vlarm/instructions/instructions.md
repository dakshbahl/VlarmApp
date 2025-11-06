# 💤 Vlarm — Requirements Document  

## 1. App Overview  
Vlarm is a friendly voice-controlled alarm app.  
Instead of typing, the user talks to an AI agent that sets alarms by listening.  
The agent also talks back using a calm, human-sounding voice.  
When the alarm goes off, the agent reminds the user what they said — like “Hey, complete your homework now!”  
It’s for anyone who wants a smarter, more personal way to stay on track.

---

## 2. Main Goals  
1. Let users set alarms just by talking.  
2. Make the agent talk back in a friendly, human way.  
3. Play the agent’s voice when the alarm rings with the user’s reminder.  
4. Show current, past, and upcoming alarms on the home screen.  
5. Allow editing, deleting, and snoozing alarms easily.

---

## 3. User Stories  

- **US-001**: As a user, I want to press one microphone button so I can tell Vlarm when to set an alarm.  
- **US-002**: As a user, I want the agent to speak to me first so it feels like a real person.  
- **US-003**: As a user, I want Vlarm to understand natural sentences like “In 15 minutes remind me to do homework.”  
- **US-004**: As a user, I want the agent to confirm my alarm by talking back to me.  
- **US-005**: As a user, I want to hear the reminder message when the alarm rings.  
- **US-006**: As a user, I want to snooze the alarm for 5 minutes if I need more time.  
- **US-007**: As a user, I want to see all my alarms on the home screen.  
- **US-008**: As a user, I want to edit or delete alarms anytime.  
- **US-009**: As a user, I want to make alarms repeat daily if I choose.  
- **US-010**: As a user, I want the alarms to work even if the app is closed.

---

## 4. Features  

- **F-001 — Voice Input Button**  
  - What it does: Starts the agent’s conversation.  
  - When: User presses the mic button.  
  - What happens if it fails: Show a message like “Couldn’t hear you — try again.”  

- **F-002 — Talking Agent (AI Voice)**  
  - What it does: Speaks first ("Hey! When do you want to set the alarm?") and replies to user answers.  
  - Uses ElevenLabs TTS for realistic, natural speech.  
  - If TTS fails: Fall back to Apple's built-in voice.  

- **F-003 — Speech Recognition**  
  - What it does: Understands what the user says and turns it into text.  
  - Handles natural phrases like “in 20 minutes” or “at 7 AM.”  
  - If it fails: Agent says “Sorry, I didn’t catch that. Could you repeat?”  

- **F-004 — Smart Time Parser**  
  - What it does: Figures out alarm time from user phrases.  
  - “In 15 minutes” → adds 15 minutes to current time.  
  - “At 8 AM” → sets alarm to that time.  

- **F-005 — Reminder Message Detection**  
  - What it does: Saves the message part (like “do homework”) to play later.  

- **F-006 — Alarm Storage and List View**  
  - What it does: Shows all alarms (active, past, upcoming) on the main screen.  
  - Includes edit, delete, and repeat toggles.  
  - If no alarms exist: Show text “No alarms yet — try setting one!”  

- **F-007 — Alarm Sound (Agent Voice)**  
  - What it does: Plays the agent's voice when time is up.  
  - Example: "Hey, complete your homework now!"  
  - Uses ElevenLabs TTS voice for playback.  

- **F-008 — Snooze**  
  - What it does: Gives 5 extra minutes when the user taps “Snooze.”  

- **F-009 — Manual Time Picker (Backup)**  
  - What it does: Lets users scroll through hours and minutes manually.  
  - Shown like Apple’s built-in alarm picker (the screenshot example).  

---

## 5. Screens  

- **S-000 — Welcome Screen**  
  - Shows:  
    - "Welcome to Vlarm" title.  
    - "Founded by Daksh Bahl and AgentFlow AI" text.  
    - Full app description explaining the voice-driven productivity alarm system.  
    - "Get Started" button.  
  - Navigation:  
    - Tap "Get Started" → goes to **S-001 Home Screen.**  
    - This is the first screen users see when opening the app.

- **S-001 — Home Screen**  
  - Shows:  
    - "Set Alarm" button (microphone icon).  
    - List of current, past, and upcoming alarms.  
    - Back button to return to **S-000 Welcome Screen.**  
  - Navigation:  
    - Tap mic → goes to **S-002 Voice Agent Screen.**  
    - Tap alarm → edit/delete on **S-003 Alarm Detail Screen.**  
    - Tap back → returns to **S-000 Welcome Screen.**

- **S-002 — Voice Agent Screen**  
  - Shows agent animation and text subtitles (“What’s up? When do you want to set the alarm?”).  
  - User speaks here.  
  - After voice recognition, app confirms aloud and returns to **S-001.**

- **S-003 — Alarm Detail Screen**  
  - Shows time picker, repeat toggle, snooze button, and “Save” option.  
  - Navigation:  
    - From home screen when editing.  
    - “Save” returns to home.

---

## 6. Data  

- **D-001:** List of alarms with:
  - Time (e.g., 7:30 AM)  
  - Reminder text (e.g., “do homework”)  
  - Repeat option (true/false)  
  - Snooze state (active or off)  
  - Status (past, active, upcoming)

- **D-002:** Agent voice choice (stores the default ElevenLabs voice ID).  
- **D-003:** System settings (notification permission, background permission).  

All data is saved **locally on the device**.

---

## 7. Extra Details  

- Needs **internet** for ElevenLabs TTS and smart speech understanding.  
- Works **offline** for simple local alarms (without speech).  
- Uses **local storage** to remember alarms and messages.  
- Needs these iPhone permissions:
  1. Microphone (for voice input)  
  2. Notifications (for alerts)  
  3. Background activity (so alarms ring even when closed)  
- Dark modern theme: white-to-blue gradient.  
- Optional dark mode support.

---

## 8. Build Steps  

- **B-000:** Build **S-000 Welcome Screen** with app introduction, branding, and "Get Started" button.  
- **B-001:** Build **S-001 Home Screen** layout with "Set Alarm" button and list (F-006).  
- **B-002:** Add **S-002 Voice Agent Screen** (F-001, F-002, F-003).  
- **B-003:** Add **speech recognition** logic and connect to alarm creation (F-004, F-005).  
- **B-004:** Use **ElevenLabs TTS** to make the agent talk (F-002, F-007). ✅ **COMPLETED**  
- **B-005:** Build **S-003 Alarm Detail Screen** for editing/deleting (F-006).  
- **B-006:** Add **snooze feature** (F-008).  
- **B-007:** Add **manual time picker** as backup (F-009).  
- **B-008:** Save alarm data on device (D-001).  
- **B-009:** Request microphone, background, and notification permissions (D-003).  
- **B-010:** Test voice flow:
  - Press mic → Agent asks question → User answers → Alarm set → Alarm rings → Agent speaks message.  

---

### ✅ Done
This document is ready to give to **Cursor**.  
It describes **Vlarm’s behavior, features, and build order** in plain, easy language — no technical jargon, just clear steps.