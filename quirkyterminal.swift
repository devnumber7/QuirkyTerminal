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

class Renderer {
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
                    linesToPrint.append(String(repeating: "-", count: item.value.count - 10)) // rough adj for color codes
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
        let logoLines = asciiArt.split(separator: "\n").map(String.init)
        let maxLines = max(logoLines.count, linesToPrint.count)
        
        print("\n") // Top Margin
        
        for i in 0..<maxLines {
            let logoSegment = i < logoLines.count ? logoLines[i] : ""
            let infoSegment = i < linesToPrint.count ? linesToPrint[i] : ""
            
            // Color the logo green
            let coloredLogo = Style.colorize(logoSegment, with: .green)
            
            // Calculate padding dynamic to logo width (approx 40 chars)
            let paddingCount = max(0, 45 - logoSegment.count)
            let padding = String(repeating: " ", count: paddingCount)
            
            print("\(coloredLogo)\(padding)\(infoSegment)")
        }
        print("\n") // Bottom Margin
    }
}

// MARK: - 4. Main Execution

let appleLogo = """
             ###
           ####
          #####
          ######
         #######
        ########  ###
       #########  ####
    ###      ##########  #####
  #####      #####################
 ######      ######################
 #######    ########################
 ##################################
 ##################################
 ##################################
  ################################
  ################################
   ##############################
    ############################
      ########################
        ####################
"""

// Configure the fetcher with desired modules
let systemModules: [SystemModule] = [
    UserHostModule(),
    SoftwareModule(),
    EnvironmentModule(),
    HardwareModule()
]

// Render the output
let renderer = Renderer(asciiArt: appleLogo, modules: systemModules)
renderer.draw()
