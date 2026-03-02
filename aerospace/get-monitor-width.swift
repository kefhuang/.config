import AppKit
let name = CommandLine.arguments[1]
if let screen = NSScreen.screens.first(where: { $0.localizedName == name }) {
    print(Int(screen.frame.width))
}
