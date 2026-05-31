# Requirements Document

## Introduction

The Social Layer feature transforms the Mindfulness Garden app's existing basic social infrastructure into a living, breathing community experience. Rather than competition-first mechanics, this feature is built around belonging, shared calm, and collective presence. It introduces three interconnected pillars: **Shared Gardens** (visit and nurture friends' gardens), **Global Meditation Events** (real-time worldwide presence indicators), and **Co-op Meditation** (synchronised group sessions with shared visual effects). All three pillars integrate with the existing garden engine, Firebase backend, Provider state management, and the app's economy system.

## Glossary

- **Social_Layer**: The collective set of features described in this document that enable multi-user interaction within the Mindfulness Garden app.
- **Shared_Garden**: A read-only or limited-interaction view of another user's garden world, rendered using the existing garden engine.
- **Garden_Visitor**: A user who is currently viewing or interacting with another user's Shared_Garden.
- **Calm_Energy**: A non-competitive gift action a Garden_Visitor can leave on a friend's plant or tile, represented visually as a soft glow particle effect.
- **Water_Gift**: An action a Garden_Visitor performs to water a plant in a friend's Shared_Garden, consuming the visitor's own water resource.
- **Global_Meditation_Count**: The real-time count of users currently in an active meditation session across the entire app.
- **Global_Aura**: A visual brightness and colour overlay applied to the garden world that intensifies as the Global_Meditation_Count increases.
- **Co-op_Session**: A real-time synchronised meditation session shared by 2 to 5 users simultaneously.
- **Shared_Aura**: A visual particle and glow effect rendered in each participant's garden during a Co-op_Session, reflecting the collective energy of all participants.
- **Session_Host**: The user who creates and initiates a Co-op_Session.
- **Session_Participant**: Any user who joins a Co-op_Session created by a Session_Host.
- **Presence_Service**: The Firebase Realtime Database service responsible for tracking and broadcasting real-time user presence and meditation state.
- **Social_Service**: The Dart service class that encapsulates all Social_Layer business logic and Firebase interactions.
- **Friendship**: A mutual connection between two users established through the existing friends system.
- **Mindfulness_Token**: The premium in-app currency already present in the economy system, used for certain social interactions.

---

## Requirements

### Requirement 1: Shared Garden Visits

**User Story:** As a user, I want to visit my friends' gardens, so that I can feel connected to their mindfulness journey and show I care about their progress.

#### Acceptance Criteria

1. WHEN a user selects a friend from the friends list, THE Social_Layer SHALL display a "Visit Garden" entry point alongside the existing friend profile options.
2. WHEN a user initiates a garden visit, THE Social_Layer SHALL load the friend's Shared_Garden using the existing garden engine renderer within 3 seconds on a standard network connection.
3. WHILE a user is viewing a Shared_Garden, THE Social_Layer SHALL display a visual indicator showing the Garden_Visitor's avatar overlaid on the garden world.
4. WHILE a user is viewing a Shared_Garden, THE Social_Layer SHALL restrict the Garden_Visitor to read-only camera navigation (pan and zoom) and the Water_Gift and Calm_Energy actions only.
5. WHEN a Garden_Visitor taps a plant in a Shared_Garden, THE Social_Layer SHALL present a contextual action sheet offering the Water_Gift action if the plant's hydration is below 0.8.
6. WHEN a Garden_Visitor performs a Water_Gift action, THE Social_Layer SHALL deduct the water cost from the visitor's own water resource and increment the target plant's hydration by 0.15.
7. WHEN a Garden_Visitor performs a Water_Gift action, THE Social_Layer SHALL send a push notification to the garden owner containing the visitor's name and the plant type that was watered.
8. WHEN a Garden_Visitor taps any tile or plant in a Shared_Garden, THE Social_Layer SHALL present the option to leave Calm_Energy, which costs 1 Mindfulness_Token from the visitor's wallet.
9. WHEN Calm_Energy is left on a tile or plant, THE Social_Layer SHALL render a soft golden glow particle effect at that location visible to the garden owner on their next garden load.
10. THE Social_Layer SHALL limit each Garden_Visitor to a maximum of 3 Water_Gift actions and 5 Calm_Energy actions per friend's garden per calendar day.
11. IF a user attempts a Water_Gift action but has insufficient water resource, THEN THE Social_Layer SHALL display an informational message explaining the shortfall and SHALL NOT deduct any resource.
12. IF a user attempts a Calm_Energy action but has insufficient Mindfulness_Tokens, THEN THE Social_Layer SHALL display an informational message and SHALL NOT deduct any resource.

---

### Requirement 2: Friend Garden Notification and Activity Feed

**User Story:** As a user, I want to know when friends visit my garden and interact with my plants, so that I feel a sense of shared presence even when I'm not online.

#### Acceptance Criteria

1. WHEN a friend visits the user's garden, THE Social_Layer SHALL record the visit event with a timestamp and the visitor's display name.
2. WHEN a friend performs a Water_Gift or Calm_Energy action in the user's garden, THE Social_Layer SHALL add an entry to the user's social activity feed within 5 seconds of the action occurring.
3. THE Social_Layer SHALL display the social activity feed as a scrollable list within the existing Community screen, showing the visitor name, action type, plant or tile affected, and relative timestamp.
4. WHEN the user opens the Community screen, THE Social_Layer SHALL display an unread badge count on the activity feed section if new social events have occurred since the user's last visit.
5. IF a push notification for a garden interaction is received while the app is in the foreground, THEN THE Social_Layer SHALL display an in-app toast notification instead of a system push notification.

---

### Requirement 3: Global Meditation Count Display

**User Story:** As a user, I want to see how many people around the world are meditating right now, so that I feel part of something larger than myself during my own sessions.

#### Acceptance Criteria

1. WHEN a user begins any meditation session, THE Presence_Service SHALL register the user as actively meditating in the global presence store.
2. WHEN a user ends or exits a meditation session, THE Presence_Service SHALL deregister the user from the global presence store within 10 seconds.
3. THE Social_Layer SHALL display the Global_Meditation_Count as a live-updating number on the meditation session screen, refreshing at most every 5 seconds.
4. WHILE the Global_Meditation_Count is between 1 and 99, THE Social_Layer SHALL display the count with the label "people meditating now".
5. WHILE the Global_Meditation_Count is 100 or greater, THE Social_Layer SHALL display the count formatted with thousands separators (e.g. "1,247 people meditating now").
6. THE Social_Layer SHALL also display the Global_Meditation_Count as a subtle ambient indicator on the main garden screen, visible without entering a session.
7. IF the Presence_Service cannot reach Firebase within 10 seconds, THEN THE Social_Layer SHALL display the last known count with a "~" prefix to indicate it may be approximate.

---

### Requirement 4: Global Aura — Garden World Brightness

**User Story:** As a user, I want my garden world to visually brighten when more people are meditating globally, so that collective mindfulness feels tangible and alive in my personal space.

#### Acceptance Criteria

1. THE Social_Layer SHALL define five Global_Aura intensity levels: None (0 meditators), Faint (1–99), Soft (100–999), Warm (1,000–9,999), and Radiant (10,000+).
2. WHEN the Global_Meditation_Count transitions between intensity levels, THE Social_Layer SHALL animate the Global_Aura change over a duration of 2 seconds using an ease-in-out curve.
3. WHILE the Global_Aura intensity is Faint, THE Social_Layer SHALL apply a subtle warm-white overlay at 5% opacity to the garden world canvas.
4. WHILE the Global_Aura intensity is Soft, THE Social_Layer SHALL apply a warm-golden overlay at 12% opacity and render soft light-ray particle effects at the garden edges.
5. WHILE the Global_Aura intensity is Warm, THE Social_Layer SHALL apply a warm-golden overlay at 22% opacity, render light-ray particles, and increase the brightness of all plant glow effects by 30%.
6. WHILE the Global_Aura intensity is Radiant, THE Social_Layer SHALL apply a warm-golden overlay at 35% opacity, render prominent light-ray particles, increase plant glow by 60%, and display a "The world is meditating together 🌍" ambient label in the garden.
7. THE Social_Layer SHALL ensure Global_Aura effects do not reduce the frame rate below 30 FPS on a mid-range device (equivalent to a 2019 Android device with 3 GB RAM).

---

### Requirement 5: Co-op Meditation Sessions

**User Story:** As a user, I want to meditate in real-time with 1 to 4 friends simultaneously, so that we can share a moment of calm and feel each other's presence even at a distance.

#### Acceptance Criteria

1. THE Social_Layer SHALL allow a Session_Host to create a Co-op_Session and invite between 1 and 4 friends, for a total session size of 2 to 5 participants.
2. WHEN a Session_Host creates a Co-op_Session, THE Social_Layer SHALL generate a unique session invite link or code that can be shared via the device's native share sheet.
3. WHEN an invited user receives a Co-op_Session invite, THE Social_Layer SHALL display an in-app notification with the Session_Host's name, the proposed session duration, and Accept and Decline actions.
4. WHEN all invited participants have accepted or the Session_Host starts the session manually, THE Social_Layer SHALL synchronise the session start time across all participants' devices within a 2-second tolerance.
5. WHILE a Co-op_Session is active, THE Social_Layer SHALL display each participant's avatar and a live breathing-phase indicator (inhale/hold/exhale) on the session screen.
6. WHILE a Co-op_Session is active, THE Social_Layer SHALL render the Shared_Aura effect in each participant's garden, with the aura intensity proportional to the number of participants who are currently in the active breathing phase.
7. WHEN a participant's device loses network connectivity during a Co-op_Session, THE Social_Layer SHALL allow that participant to continue the session locally and SHALL attempt to reconnect for up to 60 seconds before marking the participant as disconnected.
8. WHEN a participant disconnects from a Co-op_Session, THE Social_Layer SHALL notify remaining participants with a brief in-app message and SHALL reduce the Shared_Aura intensity accordingly.
9. WHEN a Co-op_Session ends, THE Social_Layer SHALL display a shared completion screen showing all participants' names, the total combined meditation minutes, and a collective garden reward.
10. WHEN a Co-op_Session ends, THE Social_Layer SHALL award each participant a Co-op bonus of 10 Mindfulness_Tokens multiplied by the number of participants who completed the session.
11. IF a Co-op_Session has fewer than 2 participants remaining (all others disconnected), THEN THE Social_Layer SHALL offer the remaining participant the option to continue as a solo session or end the session.
12. THE Social_Layer SHALL support Co-op_Sessions for any existing meditation type available in the app (guided, breathing, audio).

---

### Requirement 6: Shared Aura Visual Effect

**User Story:** As a user in a Co-op session, I want to see a beautiful shared aura effect in my garden that reflects everyone meditating together, so that the collective experience feels visually meaningful.

#### Acceptance Criteria

1. THE Social_Layer SHALL render the Shared_Aura as a pulsing radial gradient overlay centred on the garden viewport, using colours derived from each participant's avatar colour palette.
2. WHEN a Co-op_Session has 2 participants, THE Social_Layer SHALL render the Shared_Aura at base intensity with a pulse frequency of 0.3 Hz matching the guided breathing rhythm.
3. WHEN a Co-op_Session has 3 or 4 participants, THE Social_Layer SHALL render the Shared_Aura at medium intensity with additional floating light-orb particles (one per extra participant beyond 2).
4. WHEN a Co-op_Session has 5 participants, THE Social_Layer SHALL render the Shared_Aura at full intensity with a golden outer ring effect and 3 floating light-orb particles.
5. THE Social_Layer SHALL ensure the Shared_Aura pulse animation is synchronised across all participants' devices within a 500-millisecond tolerance using the session's shared start timestamp as the animation clock reference.
6. THE Social_Layer SHALL ensure Shared_Aura rendering does not reduce the frame rate below 30 FPS on a mid-range device.

---

### Requirement 7: Privacy and Consent Controls

**User Story:** As a user, I want control over who can visit my garden and interact with my plants, so that my personal mindfulness space feels safe and respected.

#### Acceptance Criteria

1. THE Social_Layer SHALL provide a garden privacy setting with three options: Open (any friend can visit), Friends Only (only mutual friends can visit), and Private (no visits allowed).
2. WHEN a user sets their garden to Private, THE Social_Layer SHALL prevent all Garden_Visitor actions and SHALL display a "This garden is private" message to any friend who attempts to visit.
3. WHEN a user sets their garden to Friends Only, THE Social_Layer SHALL only permit visits from users with a confirmed mutual Friendship.
4. THE Social_Layer SHALL default all new users' garden privacy setting to Friends Only.
5. WHEN a user receives a Co-op_Session invite from a non-friend, THE Social_Layer SHALL display the inviter's username and a warning that the inviter is not in the user's friends list before presenting Accept and Decline actions.
6. THE Social_Layer SHALL allow a user to block another user, which SHALL prevent that user from visiting the blocker's garden, sending Co-op invites, or appearing in the blocker's social activity feed.
7. WHEN a user is blocked, THE Social_Layer SHALL not notify the blocked user that they have been blocked.

---

### Requirement 8: Social Layer Data Persistence and Sync

**User Story:** As a user, I want my social interactions and garden state to be consistent across devices and sessions, so that gifts and visits are never lost.

#### Acceptance Criteria

1. THE Social_Service SHALL persist all Water_Gift and Calm_Energy actions to Firebase Firestore with the visitor's user ID, target user ID, target entity ID, action type, and UTC timestamp.
2. THE Social_Service SHALL use Firebase Realtime Database for all real-time presence data (Global_Meditation_Count, Co-op_Session state, participant breathing phases).
3. WHEN the app is offline, THE Social_Service SHALL queue outgoing social actions locally using Hive and SHALL sync the queue to Firebase when connectivity is restored.
4. THE Social_Service SHALL resolve conflicts for the daily action limit (Water_Gift and Calm_Energy caps) using server-side Firestore transaction writes to prevent race conditions.
5. THE Social_Service SHALL ensure that Calm_Energy glow effects persisted to a friend's garden are loaded and rendered within 2 seconds of the garden owner opening their garden.
6. IF a Firebase write fails after 3 retry attempts, THEN THE Social_Service SHALL surface an error state to the UI and SHALL NOT silently discard the action.

---

### Requirement 9: Parser and Serialisation for Social Data Models

**User Story:** As a developer, I want all social data models to be reliably serialised and deserialised, so that data integrity is maintained across Firebase, local storage, and the UI layer.

#### Acceptance Criteria

1. WHEN a social action event is serialised to JSON, THE Social_Service SHALL produce a JSON object containing all required fields (userId, targetUserId, actionType, entityId, timestamp, metadata).
2. WHEN a JSON object representing a social action event is deserialised, THE Social_Service SHALL produce a SocialActionEvent object with all fields correctly typed and populated.
3. THE Social_Service SHALL format SocialActionEvent objects back into valid JSON strings that can be re-parsed without data loss (round-trip property).
4. FOR ALL valid SocialActionEvent objects, parsing then serialising then parsing SHALL produce an equivalent object (round-trip property).
5. WHEN a malformed or incomplete JSON object is provided for deserialisation, THE Social_Service SHALL return a descriptive error rather than throwing an unhandled exception.
6. WHEN a Co-op_Session state object is serialised and deserialised, THE Social_Service SHALL preserve all participant states, session timing data, and aura intensity values without precision loss.
