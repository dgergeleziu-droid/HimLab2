import XCTest
@testable import HimLab

final class ChemistryTests: XCTestCase {

    func testTotalAtoms() {
        let atoms = [["H": 2], ["O": 2]]
        let coeffs = [2, 1]
        let total = ChemistryParser.totalAtoms(atoms: atoms, coeffs: coeffs)
        XCTAssertEqual(total["H"], 4)
        XCTAssertEqual(total["O"], 2)
    }

    func testBalanceMinimal() {
        // H₂ + O₂ → H₂O верные коэффициенты 2,1,2
        let left = ChemistryParser.totalAtoms(atoms: [["H":2],["O":2]], coeffs: [2,1])
        let right = ChemistryParser.totalAtoms(atoms: [["H":2,"O":1]], coeffs: [2])
        XCTAssertTrue(ChemistryParser.isBalanced(left: left, right: right))
    }

    func testNotMinimal() {
        XCTAssertFalse(ChemistryParser.isMinimal([2, 2, 4]))
        XCTAssertTrue(ChemistryParser.isMinimal([2, 1, 2]))
    }

    func testNumericWithComma() {
        XCTAssertTrue(ChemistryParser.checkNumeric("22,4", expected: 22.4))
        XCTAssertTrue(ChemistryParser.checkNumeric("22.4", expected: 22.4))
        XCTAssertFalse(ChemistryParser.checkNumeric("22.5", expected: 22.4, tolerance: 0.01))
    }

    func testProgressPersistence() {
        let store = ProgressStore.shared
        store.setGrade(9)
        XCTAssertEqual(store.data.selectedGrade, 9)
    }

    func testContentLoad() {
        let c = ContentLoader.shared
        XCTAssertGreaterThanOrEqual(c.articles.count, 24)
        XCTAssertGreaterThanOrEqual(c.balanceTasks.count, 12)
        XCTAssertGreaterThanOrEqual(c.formulaTasks.count, 12)
        XCTAssertGreaterThanOrEqual(c.detectiveTasks.count, 8)
        XCTAssertGreaterThanOrEqual(c.fixErrorTasks.count, 8)
        XCTAssertEqual(c.elements.count, 118)
        XCTAssertGreaterThanOrEqual(c.labExperiments.count, 8)
    }
}
