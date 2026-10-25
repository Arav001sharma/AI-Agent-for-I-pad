# Lil Agents for iPad Pro (M1) Installation Guide

This port adapts [lil-agents](https://github.com/ryanstephen/lil-agents) specifically for your **iPad Pro 11-inch (3rd Gen, M1, iPadOS 16.7.1)**.

Because iPadOS does not allow desktop-style floating window overlays over the system SpringBoard dock (unlike macOS AppKit), this port gives you **two ways** to experience Bruce and Jazz on your iPad:

---

## Method 1: iPad Dock Web App (Recommended — Instant Setup)

Your iPad PWA is already built and running on your local network.

### Steps:
1. Make sure your iPad and Mac are connected to the **same Wi-Fi network**.
2. Open **Safari** on your iPad.
3. In the address bar, go to:
   ```text
   http://192.168.0.102:8080
   ```
4. **Add to your iPad Dock**:
   - Tap the **Share** button in Safari (square icon with an arrow pointing up at the top right).
   - Scroll down and tap **"Add to Home Screen"**.
   - Tap **"Add"**.
   - On your iPad Home Screen, touch and hold the new **Lil Agents** icon, then **drag it down into your iPad Dock**.
5. Tap the Lil Agents icon in your iPad Dock! It will launch in standalone fullscreen.
6. **With Stage Manager (iPadOS 16.7.1)**:
   - Turn on Stage Manager from the iPad Control Center.
   - You can resize Lil Agents and dock it at the bottom of your screen as a floating companion while using any other app!

---

## Method 2: Native Swift Playgrounds App (`LilAgents.swiftpm`)

If you want a 100% native SwiftUI / AVFoundation app that compiles directly on your iPad with no Mac Xcode needed:

### Steps:
1. Install **Swift Playgrounds** from the App Store on your iPad (free from Apple).
2. AirDrop or copy the folder:
   ```text
   /Users/arav/Desktop/lil Agent for IPAD/LilAgents.swiftpm
   ```
   to your iPad's **Files** app (or iCloud Drive).
3. On your iPad, tap `LilAgents.swiftpm` — it will open inside Swift Playgrounds.
4. Tap **Run My Code** at the top right!
5. Swift Playgrounds also lets you export and install it directly to your iPad Home Screen.

---

## Features on iPad
- **Transparent HEVC Video Loops**: Bruce and Jazz walking back and forth with custom pacing and flip animations.
- **Audio Chimes**: Random selection from 8 chime variations upon completion.
- **Thinking Bubbles**: Live phrases while the agent works ("cooking...", "vibing...", "connecting dots").
- **Interactive Terminal**: Tap either character to chat with Gemini, Claude, or OpenAI, or test in local Demo mode.
- **Themes**: Switch between **Midnight**, **Peach**, **Cloud**, and **Moss** directly from the top bar.
- **Slash Commands**: `/clear`, `/copy`, `/theme`, and `/help`.
