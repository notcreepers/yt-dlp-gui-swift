import SwiftUI

struct ContentView: View {
    // defaults for all inputs
    @State private var url: String = ""
    @State private var folderPath: String = ""
    @State private var outputLog: String = "Waiting for user...\n\n"
    @State private var format: String = "bestvideo+bestaudio"
    @State private var audioOnly: Bool = false
    @State private var recodetoMP4: Bool = false
    @State private var queue: [DownloadItem] = []
    @State private var isDownloading = false
    @State private var audioFormat = "mp3"
    
    let audioFormatOptions = ["mp3", "wav", "m4a", "flac"]
    
    // queue system
    struct DownloadItem: Identifiable {
        let id = UUID()
        let url: String
        let folder: String
        let isAudioOnly: Bool
        let recodeToMP4: Bool
        let format: String
        let audioFormat: String
    }
    
    // set paths for yt-dlp and ffmpeg
    let ytDLPPath = Bundle.main.path(forResource: "yt-dlp", ofType: nil) ?? ""
    let ffmpegPath = Bundle.main.path(forResource: "ffmpeg", ofType: nil) ?? ""
    
    // download complete alert function
    func showCompletionAlert(for url: String) {
        DispatchQueue.main.async {
            guard let window = NSApplication.shared.windows.first else { return }
            
            let alert = NSAlert()
            alert.messageText = "Video Downloaded"
            alert.informativeText = "\(url)\nhas finished downloading."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            
            alert.beginSheetModal(for: window) { _ in
            }
        }
    }
    
    
//    func showCompletionAlert(for url: String) {
//        let alert = NSAlert()
//        alert.messageText = "Video Downloaded"
//        alert.informativeText = "\(url)\nhas finished downloading."
//        alert.alertStyle = .informational
//        alert.addButton(withTitle: "OK")
//        alert.runModal()
//    }
    // general window shit
    var body: some View {
        VStack(alignment: .leading, spacing:20) {
            Text("yt-dlp GUI")
                .font(.title)
            
            
            TextField("Video URL", text: $url)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: .infinity)
            
            HStack {
                TextField("Download Folder", text: $folderPath)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(true)
                    .frame(maxWidth: .infinity)
                
                Button("Browse..") {
                    selectFolder()
                }
                /* deprecated - old download system with no queue. kept behind in case something breaks.
                 Button("Download") {
                 runYTDLP()
                 }
                 .buttonStyle(.borderedProminent)
                 */
                Button("Add to Queue") {
                    if !url.isEmpty && !folderPath.isEmpty {
                        let item = DownloadItem(url: url, folder: folderPath, isAudioOnly: audioOnly, recodeToMP4: recodetoMP4, format: format, audioFormat: audioFormat)
                        queue.append(item)
                        url = ""
                        outputLog += "Queued: \(item.url)\n"
                        if !isDownloading {
                            runNextInQueue()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(url.isEmpty || folderPath.isEmpty)
                
                // todo: add different options. mp4 makes no sense when user can pick best and recode to mp4
                if !audioOnly {
                    Picker("", selection: $format) {
                        Text("Best").tag("bestvideo+bestaudio")
                        Text("MP4").tag("mp4")
                    }
                    .pickerStyle(.segmented)
                }
                
                if audioOnly {
                    Picker("", selection: $audioFormat) {
                        ForEach(audioFormatOptions, id: \.self) {
                            format in Text (format.uppercased()).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // allow the user to extract the audio from their url - disabled if recode to mp4 is checked
                Toggle("Audio only", isOn:Binding(
                    get: { audioOnly },
                    set: { newValue in
                        withAnimation {
                            audioOnly = newValue
                            if newValue { recodetoMP4 = false }
                        }}
                ))
                .disabled(recodetoMP4)
                
                // allow the user to recode their video to mp4 since all downloads over 720p are usually webm - disabled if audio only is checked
                Toggle("Recode to MP4", isOn: Binding(
                    get: { recodetoMP4 },
                    set: { newValue in
                        withAnimation {
                            recodetoMP4 = newValue
                            if newValue { audioOnly = false }
                        }
                    }
                ))
                .disabled(audioOnly)
                
            }
        // general log output
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading) {
                    Text(outputLog)
                        .frame(maxWidth: . infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .font(.system(.body, design: .monospaced))
                        .padding(.bottom)
                    
                    Text("")
                        .id("bottom")
                }
                .padding()
                
            }

            .onChange(of: outputLog) {
                DispatchQueue.main.async {
                    withAnimation {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }
            
        }
            .frame(height: 300)
            .background(Color(.secondarySystemFill))
            .cornerRadius(8)
            Spacer()
        }
        
        
        .padding()
        .frame(width:800, height:500)
    }
    // browse for directory
    func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK {
            folderPath = panel.url?.path ?? ""
        }
    }
    /* deprecated download system - used before queue (and before the binaries were stored in the app bundle)
     func runYTDLP() {
     guard !url.isEmpty, !folderPath.isEmpty else {
     outputLog = "URL or folder path is empty."
     return
     }
     
     
     let process = Process()
     let pipe = Pipe()
     let ffmpegPath = "/Users/gianni/Downloads/ffmpeg"
     
     process.executableURL = URL(fileURLWithPath: "/Users/gianni/Downloads/yt-dlp")
     var args : [String] = [
     "--ffmpeg-location", ffmpegPath, "-P", folderPath
     ]
     
     if audioOnly {
     args += ["-x", "--audio-format", "mp3"]
     } else {
     args += ["-f", format]
     }
     if recodetoMP4 {
     args += ["--recode-video", "mp4"]
     }
     args.append(url)
     process.arguments = args
     //process.arguments = ["-P",  folderPath, "--ffmpeg-location", ffmpegPath, url]
     process.standardOutput = pipe
     process.standardError = pipe
     
     outputLog = "Running yt-dlp...\n\n"
     
     let handle = pipe.fileHandleForReading
     handle.readabilityHandler = { fileHandle in
     let data = fileHandle.availableData
     if data.isEmpty {
     handle.readabilityHandler = nil
     return
     }
     
     if let chunk = String(data: data, encoding: .utf8) {
     DispatchQueue.main.async {
     outputLog += chunk
     }
     }
     }
     */
    // queue download function
    func runNextInQueue() {
        guard !queue.isEmpty else {
            isDownloading = false
            outputLog += "Queue complete.\n"
            return
        }
        
        isDownloading = true
        let item = queue.removeFirst()
        
        outputLog += "\nStarting: \(item.url)\n"
        
        let process = Process()
        let pipe = Pipe()
       // let ffmpegPath = "/Users/gianni/Downloads/ffmpeg"
        
        process.executableURL = URL(fileURLWithPath: ytDLPPath)
        var args : [String] = [
            "--ffmpeg-location", ffmpegPath, "-P", item.folder
        ]
        // can probably find a cleaner way to do this, but it works
        if item.isAudioOnly {
            args += ["-x", "--audio-format", item.audioFormat]
        } else {
            args += ["-f", item.format]
        }
        if item.recodeToMP4 {
            args += ["--recode-video", "mp4"]
        }
        args.append(item.url)
        process.arguments = args
        //process.arguments = ["-P",  folderPath, "--ffmpeg-location", ffmpegPath, url]
        process.standardOutput = pipe
        process.standardError = pipe
        
        process.terminationHandler = { _ in
            DispatchQueue.main.async {
                outputLog += "\nFinished: \(item.url)\n"
                showCompletionAlert(for: item.url)
                runNextInQueue()
            }
        }
        
        process.standardOutput = pipe
        process.standardError = pipe
        
        let handle = pipe.fileHandleForReading
        handle.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            if let chunk = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    outputLog += chunk
                }
            }
            
            
        }
        
        
        do {
            
            try process.run()
            
        } catch {
            outputLog = "error: \(error.localizedDescription)\n"
            runNextInQueue()
        }
    }
    
    
}
