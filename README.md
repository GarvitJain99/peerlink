# PeerLink: Offline Peer-to-Peer File Sharing

*PeerLink* is an offline, secure, and high-speed file sharing application built with *Flutter, designed for seamless peer-to-peer communication **without needing an internet connection*.

PeerLink leverages *Wi-Fi Direct technology* to enable users to discover, connect, and share files with nearby devices. It features a robust authentication system, a persistent library for downloaded files, and an in-app PDF viewer with annotation capabilities.

-----

## Key Features

### Authentication

  - *Secure Sign-Up & Login* – With email verification and password reset.
  - *Email Validation* – Restricts sign-ups to the mnnit.ac.in domain.

-----

### Peer Discovery & Connection

  - *Offline P2P Networking* – Uses Wi-Fi Direct to discover and connect to nearby peers without internet.
  - *Real-time List* – Auto-updating list of available users with formatted names.
  - *One-to-One Connections* – Enforces a single connection at a time, marking other users as "Busy."

-----

### File Transfer

  - *High-Speed Transfers* – Powered by Wi-Fi Direct for fast sharing.
  - *Large File Support* – Streams files directly using Payload.FILE, avoiding memory overload.
  - *Real-time Progress Tracking* – Both sender and receiver can view progress bars for active transfers.
  - *Cancelable Transfers* – Cancel transfers anytime.
  - *Local Saving* – Received files are stored temporarily, then moved to a permanent *PeerLink* folder.

-----

### File Library & Management

  - *Persistent History* – Complete file history retained across app restarts.
  - *Full Featured Management* – Sort and filter files by type, name, date, or size.
  - *File Actions* – Open, Rename, or Delete directly from the app.

-----

### In-App PDF Viewer & Annotator

  - *Integrated PDF Viewing* – View PDFs directly using syncfusion_flutter_pdfviewer.
  - *Annotation Tools* – Draw, highlight, and add notes.
  - *Save Changes* – Permanently store changes within the PDF file.

-----

## Architecture

PeerLink follows a *modern MVVM (Model-View-ViewModel) architecture* .

```bash
lib/
│
├── main.dart                  # Entry point
├── firebase_options.dart       # Firebase config file
│
├── app/
│   ├── data/
│   │   ├── models/             # Core data models
│   │   │   ├── peer_device_model.dart
│   │   │   ├── user_model.dart
│   │   │   ├── transfer_update_model.dart
│   │   │   └── saved_file_model.dart
│   │   └── services/           # Business logic & external services
│   │       ├── auth_service.dart
│   │       ├── p2p_service.dart
│   │       └── library_service.dart
│   │
│   └── presentation/
│       ├── auth/               # Login, Register, Verify Email
│       ├── discovery/          # Peer scanning UI
│       ├── transfer/           # File transfer screens
│       ├── library/            # Library management screens
│       └── pdf_viewer/         # Document viewer
```

-----

## Technology Stack & Key Packages

| Category              | Tools / Packages                               |
| --------------------- | ---------------------------------------------- |
| *Framework* | Flutter                                        |
| *Authentication* | firebase\_auth                        |
| *P2P Communication* | nearby\_connections, permission\_handler                             |
| *State Management* | provider                                       |
| *File System* | file\_picker, path\_provider, open\_file     |
| *PDF Viewing* | syncfusion\_flutter\_pdfviewer                   |
| *Local Storage* | shared\_preferences                             |
| *UI & Utilities* | intl, uuid                                     |

-----

## Team Members
  - Garvit Jain (https://github.com/GarvitJain99)
  - Kunal Gulrajani (https://github.com/joylock)
  - Ayush Jain (https://github.com/AYUSH-NIT)
