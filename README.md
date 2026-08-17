# smux

A native terminal multiplexer for macOS built for AI agents.

**Run agents in parallel across split terminals and get notified when they finish.**


## Features

- **Split terminals, run agents in parallel** — Split horizontally or vertically and manage everything at once.
- **Get notified when agents need you** — Turn on watch mode for any terminal. When an agent finishes its task, you get notified (with ring, sound or native push).
- **Workspaces** — Group related terminals into workspaces and switch between them.
- **Keyboard-driven** — Split, navigate, zoom, close, switch — everything is one shortcut away.
- **Session persistence** — Layout, terminals, and everything are saved and restored automatically.
- **Native and fast** — Written in Swift for macOS.

## Install

Requires macOS 14 or later. Free and open source.

[Download the latest release](https://github.com/gergomiklos/smux/releases/latest/download/smux-macos-universal.dmg)

<img width="1374" height="1019" alt="Screenshot 2026-03-06 at 12 15 49" src="https://github.com/user-attachments/assets/ab2322c8-1d00-4e45-95f9-bf7b64a34109" />

## Keyboard Shortcuts

| Action | Shortcut |
|---|---|
| Split right | `Cmd + Right` |
| Split down | `Cmd + Down` |
| Close | `Cmd + W` |
| Zoom | `Cmd + Shift + Enter` |
| Toggle notifications (off/on/silent) | `Cmd + B` |
| Toggle Light/Dark theme | `Cmd + Shift + L` |
| Navigate | `Option + Arrow keys` |
| Switch workspace | `Option + Shift + Arrow keys` |
| New workspace | `Cmd + Shift + T` |
| Show all shortcuts | `Cmd + /` |

## Theme

smux supports both **dark** and **light** themes. Toggle with `Cmd + Shift + L` or via the View menu.

The light theme uses a carefully tuned ANSI color palette — all 16 terminal colors are darkened to remain clearly readable on a white background. Your preference is saved automatically.

## Build from source

Open `smux.xcodeproj` in Xcode 15+.

## License

MIT
