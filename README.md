# QuirkyTerminal 🍎

A beautiful macOS system information display tool that shows an ASCII Apple logo alongside your system details every time you open Terminal.

## Features

- 🎨 Colorful ASCII Apple logo
- 💻 System information display including:
  - Username and hostname
  - macOS version
  - Kernel version
  - System uptime
  - Shell and terminal
  - CPU information
  - Memory (RAM)
- 🌈 Color-coded output
- ⚡ Fast and lightweight
- 🔄 Automatically runs on terminal startup

## Preview

When you open Terminal, you'll see something like this:

```
                    ###
                  ####                 user@MacBook-Pro
                 #####                 ----------------------------------------
                 ######                OS:       14.2
                #######                Kernel:   23.2.0
               ########  ###           Uptime:   2 days, 5:23
              #########  ####          Shell:    zsh
    ###      ##########  #####         Terminal: Apple_Terminal
  #####     #####################      CPU:      Apple M1 Pro
 ######     ######################     Memory:   16.00 GB
 #######   ########################
 ##################################    ● ● ● ● ● ●
 ##################################
 ##################################
  ################################
  ################################
   ##############################
    ############################
      ########################
        ####################
```

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

**QuirkyTerminal doesn't run on new terminals:**
- Make sure you opened a *new* terminal window after installation
- Check that the line was added to the correct config file (`~/.zshrc` for zsh)
- Verify the script is executable: `ls -l ~/.local/bin/quirkyterminal`

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

## License

Free to use and modify as you wish!
