import Foundation

enum CodeZoom {
    static let levels: [Double] = [1.0, 1.15, 0.85, 0.7]
    static let `default`: Double = 1.0
    static let min: Double = 0.5
    static let max: Double = 2.5

    static func next(after current: Double) -> Double {
        let idx = levels.firstIndex(where: { abs($0 - current) < 0.01 })
            ?? levels.enumerated().min(by: { abs($0.element - current) < abs($1.element - current) })?.offset
            ?? 0
        return levels[(idx + 1) % levels.count]
    }

    static func clamped(_ zoom: Double) -> Double {
        Swift.min(Swift.max(zoom, Self.min), Self.max)
    }

    static func rounded(_ zoom: Double) -> Double {
        (clamped(zoom) * 100).rounded() / 100
    }

    static func percent(_ zoom: Double) -> Int {
        Int((zoom * 100).rounded())
    }
}
