import Foundation

enum JavaLevel: String, Codable, CaseIterable, Equatable {
    case silver = "silver"
    case gold   = "gold"

    var displayName: String {
        switch self {
        case .silver: return "Java Silver"
        case .gold:   return "Java Gold"
        }
    }

    var badgeColor: String {
        switch self {
        case .silver: return "6E7681"
        case .gold:   return "9A6700"
        }
    }
}

enum QuizCategory: String, Codable {
    case javaBasics         = "java-basics"
    case classes            = "classes"
    case overloadResolution = "overload-resolution"
    case exceptionHandling  = "exception-handling"
    case collections        = "collections"
    case generics           = "generics"
    case lambdaStreams       = "lambda-streams"
    case inheritance        = "inheritance"
    case controlFlow        = "control-flow"
    case dataTypes          = "data-types"
    case dateTime           = "date-time"
    case string             = "string"
    case optionalApi        = "optional-api"
    case moduleSystem       = "module-system"
    case concurrency        = "concurrency"
    case io                 = "io"
    case jdbc               = "jdbc"
    case localization       = "localization"
    case annotations        = "annotations"
    case secureCoding       = "secure-coding"

    var displayName: String {
        switch self {
        case .javaBasics:        return "Java基礎"
        case .classes:           return "クラス・メソッド"
        case .overloadResolution: return "オーバーロード解決"
        case .exceptionHandling:  return "例外処理"
        case .collections:        return "コレクション"
        case .generics:           return "ジェネリクス"
        case .lambdaStreams:      return "ラムダ・ストリーム"
        case .inheritance:        return "継承・ポリモーフィズム"
        case .controlFlow:        return "制御フロー"
        case .dataTypes:          return "データ型・演算子"
        case .dateTime:           return "日付・時刻"
        case .string:             return "文字列"
        case .optionalApi:        return "Optional"
        case .moduleSystem:       return "モジュール"
        case .concurrency:        return "並列処理"
        case .io:                 return "I/O"
        case .jdbc:               return "JDBC"
        case .localization:       return "ローカライズ"
        case .annotations:        return "アノテーション"
        case .secureCoding:       return "セキュアコーディング"
        }
    }

    static func canonical(rawValue: String) -> QuizCategory? {
        if let category = QuizCategory(rawValue: rawValue) {
            return category
        }

        switch rawValue {
        case "arrays":
            return .dataTypes
        case "strings":
            return .string
        case "exceptions":
            return .exceptionHandling
        case "lambda", "streams":
            return .lambdaStreams
        case "optional":
            return .optionalApi
        case "collections-generics":
            return .collections
        case "io-nio":
            return .io
        case "localization-formatting":
            return .localization
        case "overload-overwrite":
            return .overloadResolution
        default:
            return nil
        }
    }
}
