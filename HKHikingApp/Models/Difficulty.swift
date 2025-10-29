import Foundation
import SwiftUI

enum Difficulty: Int, Codable, CaseIterable {
    case easy = 1
    case moderate = 2
    case medium = 3
    case hard = 4
    case extreme = 5
    
    var displayName: String {
        switch self {
        case .easy: return "輕鬆"
        case .moderate: return "容易"
        case .medium: return "中等"
        case .hard: return "困難"
        case .extreme: return "極難"
        }
    }
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .moderate: return .blue
        case .medium: return .orange
        case .hard: return .red
        case .extreme: return .purple
        }
    }
    
    var starDisplay: String {
        return String(repeating: "⭐", count: rawValue)
    }
}

