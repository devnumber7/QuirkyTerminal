import Foundation

/// QuirkyTerminal provides an entry point to render the ASCII art + system modules
/// without using top-level executable statements (which are disallowed in most targets).
///
/// Call `QuirkyTerminal.run()` from your app's entry point or wherever appropriate.
public enum QuirkyTerminal {
    @MainActor
    public static func run() {
        // 1. Setup Modules
        let systemModules: [any SystemModule] = [
            UserHostModule(),
            EnvironmentModule(),
            SoftwareModule(),
            HardwareModule()
        ]

        // 2. Prepare Art
        let combinedScene = Art.combineArt(left: Art.nightOut, right: Art.thirtyYearsLater, gap: 5)

        // 3. Render
        let renderer = Renderer(asciiArt: combinedScene, modules: systemModules)
        renderer.draw()
    }
}


QuirkyTerminal.run()
