import SwiftUI

@main
struct yt_dlpGUIApp: App {
    var body: some Scene {
        Window("yt-dlp GUI", id: "main") {
            ContentView()
                .frame(width: 900, height: 500)
        }
        .defaultSize(width: 900, height: 500)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About yt-dlp GUI") {
                    showAbout()
                }
            }
        }
    }
    // cool ass about box
    func showAbout() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
            )
        panel.title = "About yt-dlp GUI"
        panel.isFloatingPanel = true
        panel.center()
        
        panel.contentView = NSHostingView(rootView:
                                            VStack {
            HStack(alignment: .top, spacing:20) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 128, height: 128)
                    .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("yt-dlp GUI")
                        .font(.largeTitle)
                    Text("Version 1.0")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Text("Made by Creepers")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Report an Issue on GitHub") {
                    NSWorkspace.shared.open(URL(string:"https://github.com/notcreepers/yt-dlp-gui-swift/issues/new")!)
                }
                
                Button("OK") {
                    panel.close()
                }
                .buttonStyle(.borderedProminent)
               
            }
        }
            .padding(20)
            .frame(width:500, height: 200))
        
        panel.makeKeyAndOrderFront(nil)
    }
}



class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
