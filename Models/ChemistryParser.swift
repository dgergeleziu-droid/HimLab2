import Foundation

// Утилита для подсчёта атомов из структурированных словарей.
// Парсер строковых формул не нужен — состав берётся из JSON.

enum ChemistryParser {

    /// Суммарный состав по всем веществам с коэффициентами.
    /// atoms = [["H":2,"O":1], ["H":2]]; coeffs = [2, 1]
    /// => ["H": 6, "O": 2]
    static func totalAtoms(atoms: [[String: Int]], coeffs: [Int]) -> [String: Int] {
        guard atoms.count == coeffs.count else { return [:] }
        var total: [String: Int] = [:]
        for (i, comp) in atoms.enumerated() {
            let c = max(0, coeffs[i])
            for (el, n) in comp {
                total[el, default: 0] += n * c
            }
        }
        return total
    }

    /// Сравнить баланс левой и правой части.
    static func isBalanced(left: [String: Int], right: [String: Int]) -> Bool {
        left == right
    }

    /// Проверка, что коэффициенты — наименьшие положительные целые.
    static func isMinimal(_ coeffs: [Int]) -> Bool {
        let positives = coeffs.filter { $0 > 0 }
        guard positives.count == coeffs.count, !positives.isEmpty else { return false }
        var g = positives[0]
        for n in positives.dropFirst() { g = gcd(g, n) }
        return g == 1
    }

    static func gcd(_ a: Int, _ b: Int) -> Int {
        var a = abs(a), b = abs(b)
        while b != 0 { (a, b) = (b, a % b) }
        return a == 0 ? 1 : a
    }

    /// Проверка числового ответа с запятой/точкой и погрешностью.
    static func checkNumeric(_ input: String, expected: Double, tolerance: Double = 0.01) -> Bool {
        let normalized = input
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized) else { return false }
        return abs(value - expected) <= tolerance
    }
}
