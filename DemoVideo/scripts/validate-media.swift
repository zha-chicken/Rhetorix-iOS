import AVFoundation
import CoreMedia
import Foundation

guard CommandLine.arguments.count == 2 else {
    fputs("usage: validate-media.swift <movie>\n", stderr)
    exit(2)
}

let url = URL(fileURLWithPath: CommandLine.arguments[1])
let asset = AVURLAsset(url: url)
let duration = CMTimeGetSeconds(try await asset.load(.duration))
let videoTracks = try await asset.loadTracks(withMediaType: .video)
let audioTracks = try await asset.loadTracks(withMediaType: .audio)

func fourCC(_ value: FourCharCode) -> String {
    let bytes: [UInt8] = [
        UInt8((value >> 24) & 0xff),
        UInt8((value >> 16) & 0xff),
        UInt8((value >> 8) & 0xff),
        UInt8(value & 0xff),
    ]
    return String(bytes: bytes, encoding: .ascii) ?? String(value)
}

func validate(track: AVAssetTrack) throws -> Int {
    let reader = try AVAssetReader(asset: asset)
    let output = AVAssetReaderTrackOutput(track: track, outputSettings: nil)
    guard reader.canAdd(output) else {
        throw NSError(domain: "RhetorixMediaValidation", code: 1)
    }
    reader.add(output)
    guard reader.startReading() else {
        throw reader.error ?? NSError(domain: "RhetorixMediaValidation", code: 2)
    }

    var samples = 0
    while output.copyNextSampleBuffer() != nil {
        samples += 1
    }
    guard reader.status == .completed else {
        throw reader.error ?? NSError(domain: "RhetorixMediaValidation", code: 3)
    }
    return samples
}

print(String(format: "duration=%.3fs videoTracks=%d audioTracks=%d", duration, videoTracks.count, audioTracks.count))

for (index, track) in videoTracks.enumerated() {
    let naturalSize = try await track.load(.naturalSize)
    let preferredTransform = try await track.load(.preferredTransform)
    let transformed = naturalSize.applying(preferredTransform)
    let width = abs(transformed.width)
    let height = abs(transformed.height)
    let formatDescriptions = try await track.load(.formatDescriptions)
    let codec = formatDescriptions.first
        .map { fourCC(CMFormatDescriptionGetMediaSubType($0)) } ?? "unknown"
    let frameRate = try await track.load(.nominalFrameRate)
    let timeRange = try await track.load(.timeRange)
    let samples = try validate(track: track)
    print(String(format: "video[%d]=%@ %.0fx%.0f %.3ffps %.3fs samples=%d", index, codec, width, height, frameRate, CMTimeGetSeconds(timeRange.duration), samples))
}

for (index, track) in audioTracks.enumerated() {
    let formatDescriptions = try await track.load(.formatDescriptions)
    let format = formatDescriptions.first
    let stream = format.flatMap { CMAudioFormatDescriptionGetStreamBasicDescription($0)?.pointee }
    let codec = format.map { fourCC(CMFormatDescriptionGetMediaSubType($0)) } ?? "unknown"
    let sampleRate = stream?.mSampleRate ?? 0
    let channels = stream?.mChannelsPerFrame ?? 0
    let timeRange = try await track.load(.timeRange)
    let samples = try validate(track: track)
    print(String(format: "audio[%d]=%@ %.0fHz %dch %.3fs samples=%d", index, codec, sampleRate, channels, CMTimeGetSeconds(timeRange.duration), samples))
}

guard videoTracks.count == 1, audioTracks.count == 1 else {
    fputs("expected exactly one video and one audio track\n", stderr)
    exit(1)
}

print("validation=passed")
