# 📸 PhotoAI

**PhotoAI** is an iOS camera app built entirely in Swift using SwiftUI and AVFoundation (for now). This project is currently **a work in progress** as I explore native camera development and lay the groundwork for future AI-powered photography assistance.


---

## Environment Setup

This project is built using Swift and SwiftUI as a **native iOS app**, relying on Apple Vision frameworks. It is designed and compiled within **Xcode on macOS**.

### ❌ No Docker (Phase 1)

After some research, Docker will not be used at this stage because:

- The app is **macOS/iOS-native** and depends on Apple's SDKs and the iOS simulator.
- Xcode and SwiftUI require a macOS environment and cannot run or compile within Docker.

### ✅ Docker (Phase 2)

When the project expands to include:
- A custom machine learning backend
- Image preprocessing pipelines
- API services for analytics or model inference

…then Dockerisation will be used to support reproducibility and backend modularity.

---

## 🚧 Phase 1 Capabilities

-	📷 Built a custom camera interface using AVCaptureSession, recreating the iOS Camera experience without relying on built-in components
-	🔍 Implemented a real-time zoom slider (1x–3x), mimicking the native pinch-to-zoom feature
-	🧭 Added a rule-of-thirds grid overlay to assist users with visual composition
-	📸 Designed a responsive capture button that saves images directly to the photo library
-	🧼 Structured using a clean SwiftUI layout with a modular architecture (MVVM) — no AI used at this stage, purely native frameworks


---

## 🧠 Future Plans (AI-Powered Direction)

I'm working toward building a personalised AI photography coach with features like:

- 🤖 Real-time **pose and framing suggestions** using CoreML + Vision
- 🌅 Automatic **scene classification** and style-based overlay generation
- 💡 Contextual **tips and coaching** based on user habits and preferences
- 📈 Skill progression tracking with guided shooting challenges

---

## 🎯 Goals

- Learn and apply advanced camera APIs and CoreML integration
- Build a product that bridges casual mobile photography and professional coaching
- Demonstrate initiative, real-world Swift skills, and AI enthusiasm to future employers

---

## 🛠️ Tech Stack

- SwiftUI, Combine, UIKit (where needed)
- AVFoundation, Vision, CoreImage
- CoreML (planned)
- GitHub for version control

---

## 🤝 Contributing / Feedback

I'm building this solo as a learning project, but if you're a recruiter, developer, or ML enthusiast who’d like to collaborate or chat — feel free to reach out!

---

## 📌 Note

This app does **not** currently publish to the App Store. All camera access and photo handling is local and privacy-conscious.

---

> Created by Edward Goh — 2025
