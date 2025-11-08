#  8Club Onboarding Flow — Flutter Project

An interactive and visually polished **onboarding experience** built using **Flutter** and **Riverpod**, featuring smooth animations, media recording (audio/video), and responsive keyboard-aware transitions.

This project showcases advanced Flutter UI design, multimedia integration, and state management best practices.

---

## Features Implemented

###  1. Onboarding Flow
- **Experience Selection Screen**
  - Displays dynamic experience cards.
  - Allows **multi-select** and **animated reordering** (selected cards slide to the front).
  - Includes **fade-in entry** and **scale animations** for visual feedback.
  - Display the experience card using image_url as background.
  - The unselected state should have a grayscale version on the image.


- **Onboarding Question Screen**
  - Text input area for collecting user motivations.
  - Integrated **audio recording** using `record` and `audio_waveforms`.
  - Integrated **video recording** using `image_picker` and `video_player`.
  - **Auto-generated video thumbnail** using `video_thumbnail`.
  - Dynamic **Next button animation** (expands/contracts with media buttons).
  - Fully responsive — smooth upward/downward motion on keyboard open/close.

---

## 🪄 Brownie Point Items Implemented

 **Keyboard-aware bottom sheet animation**
> The layout begins anchored at the bottom and smoothly slides up or down when the keyboard or media recorder appears/dismisses.

 **Custom UI animations**
> Used `AnimatedAlign`, `AnimatedPadding`, and `Curves.easeOutCubic` for smooth transitions between states.

 **Audio & Video Integration**
> Audio recorder with waveform visualization, and video capture with thumbnail preview and duration display.

 **Card selection animation**
> Selected experience cards scale slightly and reorder with an elastic-out animation curve.

 **Page transition animation**
> Implemented `SlideTransition` for smooth navigation between screens.

 **Theming & Consistency**
> Unified design language with `AppColors` and `AppTextStyles` for cohesive visuals across all components.

 **State management with Riverpod**
> Global state maintained for selections, inputs, and recorded file paths, ensuring a reactive and efficient architecture.

 **Implemented a success screen with animations**
---

## ✨ Additional Enhancements

- **Modern bottom-sheet style design** — Rounded corners, shadows, and adaptive background blur.  
- **Progress indicator** — Shows onboarding step (e.g., Step 1 of 2).  
- **Error and loading handling** — Graceful fallbacks using Riverpod’s `AsyncValue`.  
- **Optimized rebuilds** — Efficient state updates using `AnimatedBuilder` and scoped providers.  
- **Fully responsive** — Works seamlessly across screen sizes on Android & iOS.  
- **Temporary file storage** — Uses `path_provider` to save recorded media.  
- **Reusable Widgets** — Modular architecture with `ExperienceCard`, `AudioRecorderWidget`, and `ProgressIndicatorWidget`.

---

## 🧠 Architecture Overview

| Layer | Technology | Description |
|-------|-------------|-------------|
| **UI & Animation** | Flutter Animation APIs | Smooth motion and transitions across screens. |
| **State Management** | Riverpod | Centralized management for app states and selections. |
| **Media Handling** | record, video_player, video_thumbnail, path_provider | Recording, playback, and preview generation. |
| **Navigation** | PageRouteBuilder | Slide animations between screens. |
| **Theming** | Custom theme files | Consistent colors, typography, and spacing. |

---

## 🧾 Permissions Required

| Platform | Permissions |
|-----------|-------------|
| **Android** | `CAMERA`, `RECORD_AUDIO`, `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE` |
| **iOS** | `NSCameraUsageDescription`, `NSMicrophoneUsageDescription` |

---


## 🖼 Screenshots

| Success Screen | Onboarding screen | Audio Recorder | Experience Screen |
|:--------------------:|:----------------:|:----------------:|:----------------:|
| ![Screen1](https://github.com/user-attachments/assets/d753485d-380a-479c-b820-86b01137c80b) | ![Screen2](https://github.com/user-attachments/assets/6c480907-8e64-48ce-a958-bfe9ea9299f7) | ![Screen3](https://github.com/user-attachments/assets/8d32bc98-abf3-4781-9141-c5c5e0f8e67e) | ![Screen4](https://github.com/user-attachments/assets/4f8f0aa5-a1e1-4ffc-8476-4a8d774cff1c) |

---

## 🧰 Tech Stack

- **Flutter SDK:** 3.32
- **State Management:** Riverpod  
- **Media Packages:** record, video_player, video_thumbnail  
- **Utilities:** path_provider, image_picker  
- **Animation:** AnimationController, Tween, Curves.easeOutCubic  
- **IDE:** Android Studio / VS Code  

---




