import Foundation

enum LabOutcome {
    case experiment(LabExperiment)
    case unsupported
}

final class LabService {
    static let shared = LabService()

    private let experiments = ContentLoader.shared.labExperiments

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
            LabReagent(id: id, name: Self.name(for: id), symbol: id, color: Self.color(for: id))
        }
    }

    static func name(for id: String) -> String {
        switch id {
        case "HCl": return "Соляная кислота"
        case "NaOH": return "Гидроксид натрия"
        case "H2O": return "Вода"
        case "NaCl": return "Хлорид натрия"
        case "AgNO3": return "Нитрат серебра"
        case "CuSO4": return "Сульфат меди(II)"
        case "Na2CO3": return "Карбонат натрия"
        case "CaCl2": return "Хлорид кальция"
        case "H2SO4": return "Серная кислота"
        case "BaCl2": return "Хлорид бария"
        case "Na2SO4": return "Сульфат натрия"
        case "KOH": return "Гидроксид калия"
        case "фенолфталеин": return "Фенолфталеин"
        case "лакмус": return "Лакмус"
        case "метилранж": return "Метилоранж"
        default: return id
        }
    }

    static func color(for id: String) -> String {
        switch id {
        case "CuSO4": return "blue"
        case "AgNO3": return "white"
        case "фенолфталеин": return "clear"
        case "HCl", "H2SO4": return "clear"
        default: return "clear"
        }
    }
}
