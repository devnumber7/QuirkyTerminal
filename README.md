# QuirkyTerminal 🍎

A beautiful macOS system information display tool that shows an ASCII Apple logo alongside your system details every time you open Terminal.


## Installation

### Quick Install

1. Download or clone these files to your Mac
2. Open Terminal and navigate to the folder containing the files
3. Run the installation script:

```bash
chmod +x install.sh
./install.sh
```

4. Open a new Terminal window to see MacFetch in action!

### Manual Installation

1. Copy `quirkyterminal.swift` to `~/.local/bin/quirkyterminal`
2. Make it executable:
   ```bash
   chmod +x ~/.local/bin/quirkyterminal
   ```
3. Add to your shell configuration file:
   - For **zsh** (default on macOS): Add to `~/.zshrc`
   - For **bash**: Add to `~/.bash_profile` or `~/.bashrc`
   
   Add this line:
   ```bash
   ~/.local/bin/quirkyterminal
   ```

## Usage

QuirkyTerminal will automatically run every time you open a new Terminal window.

To run it manually at any time:
```bash
~/.local/bin/quirkyterminal
```

## Customization

You can edit `~/.local/bin/quirkyterminal` to customize:
- Colors (modify the `Colors` struct)
- Which information is displayed
- The ASCII logo design
- Layout and formatting

## Requirements

- macOS (tested on macOS 10.15+)
- Swift (comes pre-installed on macOS)

## Uninstallation

To remove QuirkyTerminal:

1. Delete the executable:
   ```bash
   rm ~/.local/bin/quirkyterminal
   ```

2. Remove the line from your shell configuration file:
   - Edit `~/.zshrc` or `~/.bash_profile`
   - Remove the line: `~/.local/bin/quirkyterminal`

## Troubleshooting


**Permission denied error:**
```bash
chmod +x ~/.local/bin/quirkyterminal
```

**Swift not found:**
- Swift comes with Xcode Command Line Tools. Install with:
  ```bash
  xcode-select --install
  ```

## Credits

Inspired by neofetch and similar system information tools.

