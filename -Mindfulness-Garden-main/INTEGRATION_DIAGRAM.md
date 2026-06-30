# Integration Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                     MINDFULNESS GARDEN APP                          │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
                    ▼                           ▼
      ┌─────────────────────────┐   ┌──────────────────────────┐
      │   GARDEN SCREEN         │   │  MEDITATION SCENE        │
      │   (garden_screen.dart)  │   │  (meditation_scene_      │
      │                         │   │   widget.dart)           │
      └─────────────────────────┘   └──────────────────────────┘
                  │                              │
                  │                              │
         ┌────────┴────────┐           ┌────────┴─────────┐
         │ Season Detector  │           │ Environment      │
         │   (_season)      │           │   Selector       │
         └────────┬────────┘           └────────┬─────────┘
                  │                              │
                  ▼                              ▼
         ┌────────────────┐            ┌────────────────────┐
         │  _startAudio() │            │ _getBackgroundImage│
         │                │            │      Path()         │
         └────────┬───────┘            └────────┬───────────┘
                  │                              │
                  │                              │
       ┌──────────┴──────────────┐    ┌────────┴──────────────┐
       │   SEASON → MUSIC MAP    │    │  ENVIRONMENT → IMAGE  │
       │                         │    │        MAP            │
       │ Spring   → spring.mp3   │    │ Forest  → spring.jpeg │
       │ Summer   → summer.mp3   │    │ Ocean   → summer.jpeg │
       │ Monsoon  → rainny.mp3   │    │ Mountain→ winter.jpeg │
       │ Autumn   → spring.mp3   │    │ Desert  → summer.jpeg │
       │ Winter   → winter.mp3   │    │ Temple  → autumn.jpeg │
       │ Snowfall → winter.mp3   │    │ Garden  → moonsoon.jpeg│
       └──────────┬──────────────┘    │ Cosmic  → (none)      │
                  │                    └────────┬──────────────┘
                  ▼                             ▼
         ┌─────────────────┐          ┌──────────────────┐
         │  AudioService   │          │  Image.asset()   │
         │   .playSound()  │          │   with Stack     │
         │                 │          │                  │
         │ • Volume: 30%   │          │ • Opacity: 70%   │
         │ • Loop: true    │          │ • Fit: cover     │
         └────────┬────────┘          └────────┬─────────┘
                  │                             │
                  ▼                             ▼
         ┌─────────────────┐          ┌───────────────────┐
         │  assets/music/  │          │  assets/images/   │
         │                 │          │                   │
         │  📁 spring.mp3  │          │  🖼️  spring.jpeg  │
         │  📁 summer.mp3  │          │  🖼️  summer.jpeg  │
         │  📁 rainny.mp3  │          │  🖼️  winter.jpeg  │
         │  📁 winter.mp3  │          │  🖼️  autumn.jpeg  │
         └─────────────────┘          │  🖼️  moonsoon.jpeg│
                                      └───────────────────┘
```

## Data Flow

### 1. Garden Music Flow
```
User Opens Garden
       │
       ▼
GardenScreen.initState()
       │
       ▼
_startAudio() called
       │
       ▼
Reads current _season
       │
       ▼
Switch statement maps season → music file
       │
       ▼
AudioService.playSound(path, loop: true)
       │
       ▼
Music plays at 30% volume in loop
```

### 2. Meditation Background Flow
```
User Opens Meditation/Teacher Screen
       │
       ▼
MeditationSceneWidget.build()
       │
       ▼
_getBackgroundImagePath(environment)
       │
       ▼
Switch statement maps environment → image path
       │
       ▼
Stack widget created with layers:
   1. Background Image (70% opacity)
   2. Sky Gradient (50% opacity)
   3. Animated Scene Elements
       │
       ▼
Image.asset() loads background
       │
       ▼
CustomPaint draws scene on top
       │
       ▼
User sees teacher with seasonal background
```

## Layer Architecture (Meditation Scene)

```
┌────────────────────────────────────────────┐
│         User Sees This View                │
├────────────────────────────────────────────┤
│                                            │
│  🧘 Teacher Character (100% opacity)       │
│  💬 Speech Bubble                          │
│  ✨ Particles & Creatures                  │
│                                            │
├────────────────────────────────────────────┤
│  🌅 Sky Gradient (50% opacity)             │
│     - Blends with background               │
│     - Provides atmospheric color           │
├────────────────────────────────────────────┤
│  🖼️  Background Image (70% opacity)        │
│     - Season-appropriate scene             │
│     - Provides visual context              │
├────────────────────────────────────────────┤
│  ⬛ Base Surface                           │
└────────────────────────────────────────────┘
```

## Component Interaction

```
┌─────────────────────┐
│  GardenScreen       │
│                     │
│  Properties:        │
│  • _season          │──┐
│  • _audio (service) │  │
│                     │  │
│  Methods:           │  │
│  • _startAudio()    │◄─┘ Reads season
│  • _changeSeason()  │──► Triggers new audio
└─────────────────────┘

┌─────────────────────┐
│ MeditationScene     │
│ Widget              │
│                     │
│  Properties:        │
│  • environment      │──┐
│  • teacher          │  │
│                     │  │
│  Helpers:           │  │
│  • _getBackground   │◄─┘ Reads environment
│    ImagePath()      │──► Returns image path
│                     │
│  Widget:            │
│  • Stack with       │
│    - Image layer    │
│    - CustomPaint    │
└─────────────────────┘
```

## File Structure

```
pranaverse/
│
├── lib/
│   ├── features/
│   │   └── garden/
│   │       └── garden_screen.dart ✅ MODIFIED
│   │
│   └── core/
│       └── widgets/
│           └── meditation_scene_widget.dart ✅ MODIFIED
│
└── assets/
    ├── music/ ✅ NEW FILES ADDED
    │   ├── spring.mp3
    │   ├── summer.mp3
    │   ├── rainny.mp3
    │   └── winter.mp3
    │
    └── images/ ✅ NEW FILES ADDED
        ├── spring.jpeg
        ├── summer.jpeg
        ├── winter.jpeg
        ├── autumn.jpeg
        └── moonsoon.jpeg
```

## Integration Points

### 1. Garden Screen → Audio Service
- **Trigger:** Screen initialization or season change
- **Input:** Current season enum value
- **Process:** Map season to audio file path
- **Output:** Looping background music at 30% volume

### 2. Meditation Widget → Image Asset
- **Trigger:** Widget build
- **Input:** Environment enum value
- **Process:** Map environment to image path
- **Output:** Background image with 70% opacity

### 3. Error Handling
```
Audio Missing → Silent fallback (no crash)
Image Missing → Empty SizedBox (no crash)
Invalid Path  → Error builder catches
```

## User Experience Flow

```
GARDEN EXPERIENCE:
1. User enters garden ───► Season detected
2. Appropriate music plays ───► Ambient atmosphere
3. User changes season ───► Music smoothly transitions
4. User exits garden ───► Music stops

MEDITATION EXPERIENCE:
1. User selects environment ───► Background image loads
2. Teacher appears on top ───► Clear visibility maintained
3. Particles & sky animate ───► Dynamic scene
4. Image provides context ───► Enhanced immersion
```

## Configuration Matrix

| Season    | Music File    | Status |
|-----------|---------------|--------|
| Spring    | spring.mp3    | ✅     |
| Summer    | summer.mp3    | ✅     |
| Monsoon   | rainny.mp3    | ✅     |
| Autumn    | spring.mp3    | ✅ (fallback) |
| Winter    | winter.mp3    | ✅     |
| Snowfall  | winter.mp3    | ✅     |

| Environment | Background Image | Status |
|-------------|------------------|--------|
| Forest      | spring.jpeg      | ✅     |
| Ocean       | summer.jpeg      | ✅     |
| Mountain    | winter.jpeg      | ✅     |
| Desert      | summer.jpeg      | ✅     |
| Zen Temple  | autumn.jpeg      | ✅     |
| Garden      | moonsoon.jpeg    | ✅     |
| Cosmic      | (none)           | ✅     |

---

**Status:** ✅ All integrations complete and tested
**Version:** 1.0.0
**Date:** 2026-06-28
