import AVFoundation
import AppKit
import Foundation

struct Still {
    let name: String
    let seconds: Double
}

let stills: [Still] = [
    .init(name: "live-clean", seconds: 18.40),
    .init(name: "analysis-clean", seconds: 66.00),
    .init(name: "rebuttal-argument-clean", seconds: 90.00),
    .init(name: "rebuttal-response-clean", seconds: 135.00),
    .init(name: "home", seconds: 0.7),
    .init(name: "guided", seconds: 13.5),
    .init(name: "live", seconds: 18.8),
    .init(name: "setup", seconds: 25.2),
    .init(name: "analysis-input", seconds: 49.0),
    .init(name: "analysis-result", seconds: 64.0),
    .init(name: "rebuttal-argument", seconds: 92.0),
    .init(name: "rebuttal-response", seconds: 134.0),
    .init(name: "rebuttal-result", seconds: 136.0),
    .init(name: "coach-score", seconds: 144.0),
    .init(name: "fallacy-input", seconds: 156.0),
    .init(name: "fallacy-result", seconds: 162.0),
    .init(name: "history", seconds: 166.0),
    .init(name: "tools", seconds: 168.0),
    .init(name: "settings", seconds: 176.0),
    .init(name: "voice", seconds: 184.0),
    .init(name: "providers", seconds: 190.0),
]

guard CommandLine.arguments.count == 3 else {
    fputs("usage: extract-stills.swift <source.mov> <output-dir>\n", stderr)
    exit(2)
}

let source = URL(fileURLWithPath: CommandLine.arguments[1])
let output = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: true)
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

let asset = AVURLAsset(url: source)
let generator = AVAssetImageGenerator(asset: asset)
generator.appliesPreferredTrackTransform = true
generator.requestedTimeToleranceBefore = .zero
generator.requestedTimeToleranceAfter = .zero

for still in stills {
    let time = CMTime(seconds: still.seconds, preferredTimescale: 600)
    let image = try generator.copyCGImage(at: time, actualTime: nil)
    let bitmap = NSBitmapImageRep(cgImage: image)
    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "RhetorixStillExporter", code: 1)
    }
    try data.write(to: output.appendingPathComponent("\(still.name).png"))
    print("\(still.name).png @ \(still.seconds)s")
}
