import Foundation// MARK: - 2. Native Data Fetchers (The Modular Functions)
import IOKit.ps
import AppKit





// MARK: - 1. Utilities & Configuration

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

/// A collection of pure, native functions to fetch system stats instantly.
struct NativeStats {
    
    static func getUserAndHost() -> String {
        let user = NSUserName()
        let host = ProcessInfo.processInfo.hostName.replacingOccurrences(of: ".local", with: "")
        return "\(user)@\(host)"
    }
    
    static func getOSVersion() -> String {
        return ProcessInfo.processInfo.operatingSystemVersionString
    }
    
    static func getKernel() -> String {
        var size = 0
        sysctlbyname("kern.osrelease", nil, &size, nil, 0)
        var release = [CChar](repeating: 0, count: size)
        sysctlbyname("kern.osrelease", &release, &size, nil, 0)
        return String(cString: release).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func getUptime() -> String {
        let uptimeSeconds = ProcessInfo.processInfo.systemUptime
        let days = Int(uptimeSeconds / 86400)
        let hours = Int((uptimeSeconds.truncatingRemainder(dividingBy: 86400)) / 3600)
        let minutes = Int((uptimeSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        
        var parts: [String] = []
        if days > 0 { parts.append("\(days)d") }
        if hours > 0 { parts.append("\(hours)h") }
        if minutes > 0 { parts.append("\(minutes)m") }
        if parts.isEmpty { parts.append("< 1m") }
        
        return parts.joined(separator: ", ")
    }
    
    static func getCPU() -> String {
        var size = 0
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("machdep.cpu.brand_string", &machine, &size, nil, 0)
        return String(cString: machine).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
 

    static func getProcessorCoreUsage() -> String {
    	
        let totalCores = ProcessInfo.processInfo.processorCount
		
    	let activeCores = ProcessInfo.processInfo.activeProcessorCount
    	return "\(activeCores) / \(totalCores)"
    }


   
    
    static func getDiskSpace() -> String {
        let path = NSHomeDirectory()
        let attrs = try? FileManager.default.attributesOfFileSystem(forPath: path)
        if let total = attrs?[.systemSize] as? Int64,
           let free = attrs?[.systemFreeSize] as? Int64 {
            let usedGB = (total - free) / 1024 / 1024 / 1024
            let totalGB = total / 1024 / 1024 / 1024
            return "\(usedGB)GB / \(totalGB)GB"
        }
        return "Unknown"
    }
    
    static func getMemory() -> String {
        let totalBytes = ProcessInfo.processInfo.physicalMemory
        let totalGB = Double(totalBytes) / 1024.0 / 1024.0 / 1024.0
        return String(format: "%.2f GB", totalGB)
    }
    
    static func getThermalState() -> String {
        let state = ProcessInfo.processInfo.thermalState

        switch state {
        
       	case .nominal :
       		return "Nominal"
                	
        case .fair : 
        	return "Fair"	

       	case .serious :
       		return "Serious"

        case .critical :
        	return "Critical"
      

        @unknown default :
        	return "Unknown idk lmao needs an update"
        }     
                
    }

	static func getResolution() -> String {
	    // We use .main to get the primary monitor
	    guard let screen = NSScreen.main else {
	        return "N/A"
	    }
	    
	    // 'deviceDescription' contains the dictionary of hardware specs
	    let description = screen.deviceDescription
	    
	    // We look for the .size key specifically
	    if let size = description[.size] as? NSSize {
	        // Screen sizes are floating point, so we convert to Int for a cleaner look
	        return "\(Int(size.width))x\(Int(size.height))"
	    }
	    
	    return "N/A"
	}
    
    static func getBattery() -> String {
        // Using IOKit.ps to get hardware battery info cleanly
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        
        for ps in sources {
            let info = IOPSGetPowerSourceDescription(snapshot, ps).takeUnretainedValue() as! [String: Any]
            if let capacity = info[kIOPSCurrentCapacityKey] as? Int {
                let isCharging = info[kIOPSIsChargingKey] as? Bool ?? false
                let status = isCharging ? " (Charging)" : ""
                return "\(capacity)%\(status)"
            }
        }
        return "N/A (Desktop?)"
    }


    static func getLastBoot() -> String {
        var tv = timeval()
        var size = MemoryLayout<timeval>.size
        sysctlbyname("kern.boottime", &tv, &size, nil, 0)
        let bootDate = Date(timeIntervalSince1970: TimeInterval(tv.tv_sec))
        let formatter = RelativeDateTimeFormatter()
        return "Booted " + formatter.localizedString(for: bootDate, relativeTo: Date())
    }
    
    static func getLowPowerMode() -> String {
        let isLowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
        return isLowPower ? "Saving Energy 🔋" : "Full Send ⚡️"
    }
    
    static func getEnvironmentInfo() -> (shell: String, terminal: String) {
        let env = ProcessInfo.processInfo.environment
        let shell = URL(fileURLWithPath: env["SHELL"] ?? "").lastPathComponent
        let term = env["TERM_PROGRAM"] ?? env["TERM"] ?? "Unknown"
        return (shell, term)
    }
}

// MARK: - 3. Module Adapters

struct InfoItem {
    let key: String
    let value: String
}

protocol SystemModule {
    func fetch() -> [InfoItem]
}

struct UserHostModule: SystemModule {
    func fetch() -> [InfoItem] {
        return [InfoItem(key: "Header", value: Style.colorize(NativeStats.getUserAndHost(), with: .green))]
    }
}

struct SoftwareModule: SystemModule {
    func fetch() -> [InfoItem] {
        return [
            InfoItem(key: "OS", value: NativeStats.getOSVersion()),
            InfoItem(key: "Kernel", value: NativeStats.getKernel()),
            InfoItem(key: "Uptime", value: NativeStats.getUptime()),
            InfoItem(key: "Last Boot", value: NativeStats.getLastBoot())
        ]
    }
}

struct HardwareModule: SystemModule {
    func fetch() -> [InfoItem] {
        return[
            InfoItem(key: "CPU", value: NativeStats.getCPU()),
            InfoItem(key: "Memory", value: NativeStats.getMemory()),
            InfoItem(key: "Disk Space", value: NativeStats.getDiskSpace()),
            InfoItem(key: "Battery", value: NativeStats.getBattery()),
            InfoItem(key: "Low Power Mode", value: NativeStats.getLowPowerMode()),
            InfoItem(key: "Thermal State", value: NativeStats.getThermalState()),
            InfoItem(key: "Processor Usage", value: NativeStats.getProcessorCoreUsage()),
   
        ]
    }
}

struct EnvironmentModule: SystemModule {
    func fetch() -> [InfoItem] {
        let env = NativeStats.getEnvironmentInfo()
        return [
            InfoItem(key: "Shell", value: env.shell),
            InfoItem(key: "Terminal", value: env.terminal),
            InfoItem(key: "Resolution", value: NativeStats.getResolution())        ]
    }
}

// MARK: - 4. Presentation Layer

final class Renderer {
    private let modules: [SystemModule]
    private let asciiArt: String
    
    init(asciiArt: String, modules: [SystemModule]) {
        self.asciiArt = asciiArt
        self.modules = modules
    }
    
    func draw() {
        var linesToPrint: [String] = []
        
        for module in modules {
            let items = module.fetch()
            for item in items {
                if item.key == "Header" {
                    linesToPrint.append("\(Style.bold.rawValue)\(item.value)\(Style.reset.rawValue)")
                    let rawHeader = item.value.replacingOccurrences(of: "\u{001B}\\[[0-9;]*m", with: "", options: .regularExpression)
                    linesToPrint.append(String(repeating: "-", count: rawHeader.count))
                } else {
                    let key = Style.colorize("\(item.key):", with: .cyan)
                    linesToPrint.append("\(key) \(item.value)")
                }
            }
        }
        
        linesToPrint.append("")
        let palette = [Style.red, .green, .yellow, .blue, .magenta, .cyan]
            .map { "\($0.rawValue)●\(Style.reset.rawValue)" }
            .joined(separator: " ")
        linesToPrint.append(palette)

        let logoLines = asciiArt.components(separatedBy: .newlines)
        let maxLines = max(logoLines.count, linesToPrint.count)
        let maxLogoWidth = logoLines.map { $0.count }.max() ?? 0
        
        print("\n")
        for i in 0..<maxLines {
            let logoSegment = i < logoLines.count ? logoLines[i] : ""
            let infoSegment = i < linesToPrint.count ? linesToPrint[i] : ""
            let coloredLogo = Style.colorize(logoSegment, with: .green)
            
            let paddingCount = max(0, (maxLogoWidth + 5) - logoSegment.count)
            let padding = String(repeating: " ", count: paddingCount)
            
            print("\(coloredLogo)\(padding)\(infoSegment)")
        }
        print("\n")
    }
}
