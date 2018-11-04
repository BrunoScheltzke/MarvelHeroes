//
//  HeroCellViewModelTests.swift
//  MarvelHeroesTests
//
//  Created by Bruno Scheltzke on 04/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import XCTest
@testable import MarvelHeroes

class HeroCellViewModelTests: XCTestCase {
    var viewModel: HeroCellViewModel!
    var marvelService: MarvelAPIServiceMock!
    
    override func setUp() {
        let hero = Hero(id: 1, name: "", description: "", imageURL: "")
        marvelService = MarvelAPIServiceMock()
        viewModel = HeroCellViewModel(marvelService: marvelService, hero: hero)
    }

    override func tearDown() {
        viewModel = nil
        marvelService = nil
    }
    
    func testFetchImage() {
        let expectation = self.expectation(description: "TestImageFetch")
        var result: UIImage = #imageLiteral(resourceName: "marvellogo")
        
        viewModel.fetchImage {
            result = $0
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertNotNil(result)
    }
    
    func testNilHeroImage() {
        let hero = Hero(id: 1, name: "", description: "", imageURL: nil)
        viewModel = HeroCellViewModel(marvelService: marvelService, hero: hero)
        
        let expectation = self.expectation(description: "testNilHeroImage")
        var result: UIImage = #imageLiteral(resourceName: "marvellogo")
        let placeholder: UIImage = #imageLiteral(resourceName: "marvellogo")
        
        viewModel.fetchImage {
            result = $0
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(result, placeholder)
    }
    
    func testFailImageFetch() {
        let expectation = self.expectation(description: "testFailImageFetch")
        var result: UIImage = #imageLiteral(resourceName: "marvellogo")
        let placeholder: UIImage = #imageLiteral(resourceName: "marvellogo")
        
        marvelService.shouldFailRequest = true
        viewModel.fetchImage {
            result = $0
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(result, placeholder)
    }
    
    func testHeroNameUnavailable() {
        let hero = Hero(id: 1, name: nil, description: nil, imageURL: nil)
        viewModel = HeroCellViewModel(marvelService: marvelService, hero: hero)
        XCTAssertEqual("Name unavailable", viewModel.name)
    }
    
    func testHeroNameEmpty() {
        let hero = Hero(id: 1, name: "", description: nil, imageURL: nil)
        viewModel = HeroCellViewModel(marvelService: marvelService, hero: hero)
        XCTAssertEqual("Name unavailable", viewModel.name)
    }
}
