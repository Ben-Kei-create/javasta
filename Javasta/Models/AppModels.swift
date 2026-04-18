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
    case overloadResolution = "overload-resolution"
    case exceptionHandling  = "exception-handling"
    case collections        = "collections"
    case generics           = "generics"
    case lambdaStreams       = "lambda-streams"
    case inheritance        = "inheritance"
    case controlFlow        = "control-flow"
    case dataTypes          = "data-types"

    var displayName: String {
        switch self {
        case .overloadResolution: return "オーバーロード解決"
        case .exceptionHandling:  return "例外処理"
        case .collections:        return "コレクション"
        case .generics:           return "ジェネリクス"
        case .lambdaStreams:      return "ラムダ・ストリーム"
        case .inheritance:        return "継承・ポリモーフィズム"
        case .controlFlow:        return "制御フロー"
        case .dataTypes:          return "データ型・演算子"
        }
    }
}
