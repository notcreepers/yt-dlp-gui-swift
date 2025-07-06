# yt-dlp-gui-swift
fucked around for two days and ended up with a functional frontend for yt-dlp built in Swift.

## Features
- yt-dlp and ffmpeg are bundled so no setup is required
- built-in queue system allowing you to start multiple downloads and leave to do something else
- output log so you can see exactly what yt-dlp is doing
- "search", more so a yt-dlp feature but if you type ytsearch:"query" you can search and it will download the first available option
- support to extract and save audio in any of the supported formats (mp3, wav, m4a, flac)

## Backstory
i've been working on a [yt-dlp gui](https://github.com/notcreepers/basic-gui-for-yt-dlp) in Python for a little while now. i recently picked up a more capable macbook and decided to try to bring it over to macOS. i ended up having to drop some functionality and as a whole it was a lot worse. so with the power of the internet and some knowledge i mashed a whole bunch of shit together in Swift and made this. an all in one tool for using yt-dlp.

## Screenshots
![main-gui](https://github.com/notcreepers/yt-dlp-gui-swift/blob/main/Screenshots/main-gui.png?raw=true)
![main-gui-with-audio](https://github.com/notcreepers/yt-dlp-gui-swift/blob/main/Screenshots/main-gui-with-audio.png?raw=true)
![main-gui-with-download-complete](https://github.com/notcreepers/yt-dlp-gui-swift/blob/main/Screenshots/main-gui-with-download-complete.png?raw=true)
