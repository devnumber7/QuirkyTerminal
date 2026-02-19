import Foundation

struct Art {
    static let nightOut = #"""
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

    static let thirtyYearsLater = #"""
        -(|)-      /\\ \
       /\|||/\    /     \
       |-O_O-|    |-o-o-|
       d  ^  b    C  V  D        "30 Years Later"
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

    static func combineArt(left: String, right: String, gap: Int = 4) -> String {
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
}
