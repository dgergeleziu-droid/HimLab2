import Foundation
import SwiftUI

enum LabOutcome {
    case experiment(LabExperiment)
    case unsupported
}

final class LabService {
    static let shared = LabService()
    
    // Всегда берём актуальные данные из ContentLoader
    private var experiments: [LabExperiment] {
        ContentLoader.shared.labExperiments
    }
    
    func find(a: String, b: String) -> LabOutcome {
        let pair = Set([a, b])
        if let exp = experiments.first(where: { Set([$0.reagentA, $0.reagentB]) == pair }) {
            return .experiment(exp)
        }
        return .unsupported
    }
    
    var allReagents: [LabReagent] {
        let names = experiments.flatMap { [$0.reagentA, $0.reagentB] }
        let uniq = Array(Set(names)).sorted()
        return uniq.map { id in
            LabReagent(id: id, name: Self.name(for: id), symbol: id, colorHex: Self.color(for: id))
        }
    }
    
    static func name(for id: String) -> String {
        let dict = [
            "HCl": "Соляная кислота", "NaOH": "Гидроксид натрия",
            "H2O": "Вода", "NaCl": "Хлорид натрия",
            "AgNO3": "Нитрат серебра", "CuSO4": "Сульфат меди(II)",
            "Na2CO3": "Карбонат натрия", "BaCl2": "Хлорид бария",
            "Na2SO4": "Сульфат натрия", "фенолфталеин": "Фенолфталеин",
            "лакмус": "Лакмус", "Fe": "Железо", "Zn": "Цинк",
            "Mg": "Магний", "O2": "Кислород", "электрический ток": "Ток"
        ]
        return dict[id] ?? id
    }
    
    static func color(for id: String) -> String {
        switch id {
        case "CuSO4": return "blue"
        case "Fe": return "gray"
        case "Zn": return "gray"
        case "Mg": return "gray"
        case "фенолфталеин": return "clear"
        default: return "clear"
        }
    }
}
