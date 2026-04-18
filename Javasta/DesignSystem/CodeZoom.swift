import Foundation

enum CodeZoom {
    static let levels: [Double] = [1.0, 1.15, 0.85, 0.7]
    static let `default`: Double = 1.0

    static func next(after current: Double) -> Double {
        let idx = levels.firstIndex(where: { abs($0 - current) < 0.01 }) ?? 0
        return levels[(idx + 1) % levels.count]
    }

    static func percent(_ zoom: Double) -> Int {
        Int((zoom * 100).rounded())
    }
}
