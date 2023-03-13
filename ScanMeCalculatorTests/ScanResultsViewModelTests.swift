//
//  ScanMeCalculatorTests.swift
//  ScanMeCalculatorTests
//
//  Created by Alfin on 12/03/23.
//

import XCTest
@testable import ScanMeCalculator

final class ScanResultsViewModelTests: XCTestCase {
    var sut: ScanResultsViewModel!
    
    override func setUpWithError() throws {
        sut = .init(moc: PersistenceController.testing.container.viewContext)
        sut.storageEngine = .database
        
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        
        try super.tearDownWithError()
    }
    
    func test_isValidExpression() throws {
        let isValid = sut.isValidExpression(text: "1+1")
        XCTAssertTrue(isValid)
    }
    
    func test_scanTextInImage() throws {
        sut.scanTextInImage(UIImage(named: "sample")!) { text in
            XCTAssertEqual(text, "1+1")
        }
    }
    
    func test_didReceiveImage() throws {
        sut.didReceiveImage(UIImage(named: "sample")!)
        _ = XCTWaiter.wait(for: [XCTestExpectation(description: "test_didReceiveImage")], timeout: 3)
        XCTAssertEqual(sut.results.count, 1)
    }

    func test_delete() throws {
        sut.results.append(ScanResult(input: "1+1", output: 2))
        XCTAssertEqual(sut.results.count, 1)
        sut.delete([0] as IndexSet)
        _ = XCTWaiter.wait(for: [XCTestExpectation(description: "test_delete")], timeout: 1)
        XCTAssertEqual(sut.results.count, 0)
    }
    
    func test_showAlert() throws {
        sut.showAlert(Errors.failedToSaveData)
        _ = XCTWaiter.wait(for: [XCTestExpectation(description: "test_showAlert")], timeout: 1)
        XCTAssertEqual(sut.alert.isShow, true)
        XCTAssertEqual(sut.alert.message, Errors.failedToSaveData)
    }
}
