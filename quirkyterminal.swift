#!/usr/bin/env swift
import Foundation


// MARK: - 1. Utilities & Configuration

/// Handles ANSI color formatting
enum Style: String {
    case reset = "\u{001B}[0m"
    case red = "\u{001B}[31m"
    case green = "\u{001B}[32m"
    case yellow = "\u{001B}[33m"
    case blue = "\u{001B}[34m"
    case magenta = "\u{001B}[35m"
    case cyan = "\u{001B}[36m"
    case white = "\u{001B}[37m"
    case bold = "\u{001B}[1m"

    static func colorize(_ text: String, with color: Style) -> String {
        return "\(color.rawValue)\(text)\(Style.reset.rawValue)"
    }
}

/// Helper to execute shell commands cleanly
struct Shell {
    static func run(_ command: String, arguments: [String] = []) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return nil
        }
    }
}

// MARK: - 2. Data Providers

/// A generic item of system information
struct InfoItem {
    let key: String
    let value: String
}

/// Protocol that all data fetchers must adhere to
protocol SystemModule {
    func fetch() -> [InfoItem]
}

// --- Specific Implementations ---

struct UserHostModule: SystemModule {
    func fetch() -> [InfoItem] {
        let user = NSUserName()
        let host = ProcessInfo.processInfo.hostName
        // We combine these into a header-style item, or return them essentially to be formatted later
        return [InfoItem(key: "Header", value: "\(Style.colorize("\(user)@\(host)", with: .green))")]
    }
}

struct SoftwareModule: SystemModule {
    func fetch() -> [InfoItem] {
        var items: [InfoItem] = []
        
        // OS Version
        let osString = ProcessInfo.processInfo.operatingSystemVersionString
        items.append(InfoItem(key: "OS", value: osString))
        
        // Kernel
        if let kernel = Shell.run("/usr/bin/uname", arguments: ["-r"]) {
            items.append(InfoItem(key: "Kernel", value: kernel))
        }
        
        // Uptime
        if let uptimeRaw = Shell.run("/usr/bin/uptime"),
           let range = uptimeRaw.range(of: "up\\s+(.+?),", options: .regularExpression) {
            let uptime = String(uptimeRaw[range]).replacingOccurrences(of: "up ", with: "").replacingOccurrences(of: ",", with: "")
            items.append(InfoItem(key: "Uptime", value: uptime))
        }
        
        return items
    }
}

struct HardwareModule: SystemModule {
    func fetch() -> [InfoItem] {
        var items: [InfoItem] = []
        
        // CPU
        if let cpu = Shell.run("/usr/sbin/sysctl", arguments: ["-n", "machdep.cpu.brand_string"]) {
            items.append(InfoItem(key: "CPU", value: cpu))
        }
        
        // Memory
        if let memStr = Shell.run("/usr/sbin/sysctl", arguments: ["-n", "hw.memsize"]),
           let memBytes = Int64(memStr) {
            let memGB = Double(memBytes) / 1024.0 / 1024.0 / 1024.0
            items.append(InfoItem(key: "Memory", value: String(format: "%.2f GB", memGB)))
        }
        
        return items
    }
}

struct EnvironmentModule: SystemModule {
    func fetch() -> [InfoItem] {
        var items: [InfoItem] = []
        let env = ProcessInfo.processInfo.environment
        
        if let shellPath = env["SHELL"] {
            items.append(InfoItem(key: "Shell", value: URL(fileURLWithPath: shellPath).lastPathComponent))
        }
        
        if let term = env["TERM_PROGRAM"] ?? env["TERM"] {
            items.append(InfoItem(key: "Terminal", value: term))
        }
        
        return items
    }
}

// MARK: - 3. Presentation Layer

final class Renderer {
    private let modules: [SystemModule]
    private let asciiArt: String
    
    init(asciiArt: String, modules: [SystemModule]) {
        self.asciiArt = asciiArt
        self.modules = modules
    }
    
    func draw() {
        // 1. Collect all data
        var linesToPrint: [String] = []
        
        for module in modules {
            let items = module.fetch()
            for item in items {
                if item.key == "Header" {
                    linesToPrint.append("\(Style.bold.rawValue)\(item.value)\(Style.reset.rawValue)")
                    // Fixed the magic number for the underline using the raw string count
                    let rawHeader = item.value.replacingOccurrences(of: "\u{001B}\\[[0-9;]*m", with: "", options: .regularExpression)
                    linesToPrint.append(String(repeating: "-", count: rawHeader.count))
                } else {
                    let key = Style.colorize("\(item.key):", with: .cyan)
                    linesToPrint.append("\(key) \(item.value)")
                }
            }
        }
        
        // Add color palette at the bottom
        linesToPrint.append("") // spacer
        let palette = [Style.red, .green, .yellow, .blue, .magenta, .cyan]
            .map { "\($0.rawValue)●\(Style.reset.rawValue)" }
            .joined(separator: " ")
        linesToPrint.append(palette)

        // 2. Align with Logo
        let logoLines = asciiArt.components(separatedBy: .newlines)
        let maxLines = max(logoLines.count, linesToPrint.count)
        
        // DYNAMIC WIDTH: Find the widest line in the ASCII art
        let maxLogoWidth = logoLines.map { $0.count }.max() ?? 0
        
        print("\n") // Top Margin
        
        for i in 0..<maxLines {
            let logoSegment = i < logoLines.count ? logoLines[i] : ""
            let infoSegment = i < linesToPrint.count ? linesToPrint[i] : ""
            
            // Color the logo green
            let coloredLogo = Style.colorize(logoSegment, with: .green)
            
            // Dynamic padding based on the widest art line + 5 spaces buffer
            let paddingCount = max(0, (maxLogoWidth + 5) - logoSegment.count)
            let padding = String(repeating: " ", count: paddingCount)
            
            print("\(coloredLogo)\(padding)\(infoSegment)")
        }
        print("\n") // Bottom Margin
    }
}

// MARK: - 4. Main Execution

let nightOut = #"""
|\_____/|     ////\
|/// \\\|    /// \\\
 |/O O\|     |/o o\|
 d  ^ .b     C  )  D    "A Night Out On The Town"
  \\m//      | \_/ |
   \_/        \___/
 __ooo__    _/<|_|>\_
/_     _\  / |/\_/\| \
| \_v_/ | |    |\|    |
|| _/ _/\\| |  |\|  | |
||)    ( \| |  |\|  | |
||      \ | \\ |\|  | |
||  --  |  (())\_/  | |
((      |   |___|___|_|
 |______|   |   Y   |))
  |-||-|    |   |   |
  | || |    |   |   |
  | || |    |   |   |
  | || |    |___|___|prs
 /u\||/u\   /qp| |qp\
(_/\||/\_) (___/ \___)
"""#

let thirtyYearsLater = #"""
    -(|)-      /\\ \
   /\|||/\    /     \
   |-O_O-|    |-o-o-|
   d  ^  b    C  V  D         "30 Years Later"
   O\-=-/O    | ___ |
     \_/       \___/
   __| |__   _/<|_|>\_
  /  \_/  \ / |/\_/\| \
 /  o   o  |    |\|    |
|/ __o__ \| |   |\|  | |
|\ o   o /| |   |\|  | |
||)=====( \ \\  |\|  | |
|| o   o \ (())\_/__| |
((   o   |  |   |   |_|
 | o   o |  |   Y   |))\
 |   o   |  |   |   | ||
 | o   o |  |   |   | ||
 |_______|  |   |   | ||
prs|_|_|    |___|___| ||
    /X|X\    /qp| |qp\ ||
   (__|__)  (___/ \___)||
"""#

/// Stitches two multiline ASCII art strings side-by-side
func combineArt(left: String, right: String, gap: Int = 4) -> String {
    let leftLines = left.components(separatedBy: .newlines)
    let rightLines = right.components(separatedBy: .newlines)
    
    let maxLeftWidth = leftLines.map { $0.count }.max() ?? 0
    let maxLines = max(leftLines.count, rightLines.count)
    
    var combinedLines: [String] = []
    
    for i in 0..<maxLines {
        let l = i < leftLines.count ? leftLines[i] : ""
        let r = i < rightLines.count ? rightLines[i] : ""
        
        let paddingNeeded = maxLeftWidth - l.count + gap
        let padding = String(repeating: " ", count: max(0, paddingNeeded))
        
        combinedLines.append(l + padding + r)
    }
    
    return combinedLines.joined(separator: "\n")
}

// Configure the fetcher with desired modules
let systemModules: [SystemModule] = [
    UserHostModule(),
    SoftwareModule(),
    EnvironmentModule(),
    HardwareModule()
]

// Combine the two scenes with a 5-space gap between them
let combinedScene = combineArt(left: nightOut, right: thirtyYearsLater, gap: 5)

// Render the output with our dynamically resizing renderer
let renderer = Renderer(asciiArt: combinedScene, modules: systemModules)
renderer.draw()

