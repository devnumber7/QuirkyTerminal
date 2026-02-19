# QuirkyTerminal

A high-performance, system-fetch tool for macOS built with Swift. It gives you a snapshot of your system stats alongside some retro ASCII art.

## Features

**Native & Fast:** Compiled machine code ensures your stats appear instantly when you open a tab.

**Modular Architecture:** Easily add new stats in `Stats.swift` or new art in `Art.swift`.

**macOS Deep-Dive:** Pulls real-time battery health, thermal states, and Apple Silicon core counts using native APIs.

## Getting Started

### 1. Prerequisites

A Mac (obviously).

Xcode Command Line Tools: Required for the Swift compiler.
```bash
xcode-select --install
```

### 2. Installation

Clone this repository and build the production-ready binary:
```bash
git clone https://github.com/your-username/QuirkyTerminal.git
cd QuirkyTerminal

# Build the release version
swift build -c release

# Move it to your local bin
mkdir -p ~/.local/bin
cp .build/release/QuirkyTerminal ~/.local/bin/quirkyterminal
```

### 3. Run on Startup

To see the art and stats every time you open a new terminal tab, add the following line to the end of your `~/.zshrc` (or `~/.bash_profile`):
```bash
# Run the quirky fetch tool
~/.local/bin/quirkyterminal
```

## Development

This project uses the Swift Package Manager. To make changes:

**Edit Art:** Modify `Sources/QuirkyTerminal/Art.swift` to add your own ASCII scenes.

**Edit Stats:** Add new fetchers to `Sources/QuirkyTerminal/Stats.swift` using Foundation or IOKit.

**Run in Dev Mode:**
```bash
swift run
```

## Credits

Inspired by [neofetch](https://github.com/dylanaraps/neofetch) and similar system information tools.
