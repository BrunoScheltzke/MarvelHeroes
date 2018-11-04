//
//  MarvelHeroesTests.swift
//  MarvelHeroesTests
//
//  Created by Bruno Scheltzke on 02/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import XCTest
@testable import MarvelHeroes

class HeroListViewModelTests: XCTestCase {
    var viewModel: HeroListViewModel!
    var marvelService: MarvelAPIServiceMock!

    override func setUp() {
        marvelService = MarvelAPIServiceMock()
        viewModel = HeroListViewModel(marvelService: marvelService)
    }

    override func tearDown() {
        marvelService = nil
        viewModel = nil
    }
    
    func testSuccessFetchOfHeroes() {
        let expectation = self.expectation(description: "TestHeroesFetch")
        var result: Result<[IndexPath]> = .failure(CustomError.invalidData)
        viewModel.fetchHeroes {
            result = $0
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        if case .failure(let error) = result {
           XCTFail(error.localizedDescription)
        } else {
            XCTAssert(true)
        }
    }
    
    func testFailFetchOfHeroes() {
        marvelService.shouldFailRequest = true
        
        let expectation = self.expectation(description: "TestHeroesFailFetch")
        var result: Result<[IndexPath]> = .success([])
        viewModel.fetchHeroes {
            result = $0
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        if case .success(let indexPaths) = result {
            XCTFail("Should return error but got \(indexPaths) instead")
        } else {
            XCTAssert(true)
        }
    }
    
    func testReachingMaxAmountOfHeroes() {
        marvelService.shouldSimulateMaxAmountRequest = true
        
        let expectation = self.expectation(description: "TestHeroesMaxAmount")
        var result: Result<[IndexPath]> = .failure(CustomError.invalidData)
        viewModel.fetchHeroes {
            result = $0
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        switch result {
        case .success(let indexPaths):
            XCTAssertEqual(indexPaths.count, 0)
        case.failure(let error):
            XCTFail("Returned \(error), when should return empty index paths.")
        }
    }
}
