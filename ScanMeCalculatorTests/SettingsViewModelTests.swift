//
//  SettingsViewModelTests.swift
//  ScanMeCalculatorTests
//
//  Created by Alfin on 13/03/23.
//


import XCTest
@testable import ScanMeCalculator

final class SettingsViewModelTests: XCTestCase {
    var sut: SettingsViewModel!
    
    override func setUpWithError() throws {
        sut = .init()
        
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        
        try super.tearDownWithError()
    }
    
    func test_setStorageEngine() throws {
        sut.setStorageEngine(.file)
        XCTAssertEqual(sut.settings.storageEngine, StorageEngine.file)
    }
}
