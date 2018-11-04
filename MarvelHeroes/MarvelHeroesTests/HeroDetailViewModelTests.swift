//
//  HeroDetailViewModelTests.swift
//  MarvelHeroesTests
//
//  Created by Bruno Scheltzke on 04/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import XCTest
@testable import MarvelHeroes

class HeroDetailViewModelTests: XCTestCase {
    var viewModel: HeroDetailViewModel!
    var marvelService: MarvelAPIServiceMock!

    override func setUp() {
        let hero = Hero(id: 1, name: "test", description: "testing", imageURL: "")
        marvelService = MarvelAPIServiceMock()
        viewModel = HeroDetailViewModel(marvelService: marvelService, hero: hero)
    }

    override func tearDown() {
        marvelService = nil
        viewModel = nil
    }
    
    func testHeroNameUnavailable() {
        let hero = Hero(id: 1, name: nil, description: nil, imageURL: nil)
        viewModel = HeroDetailViewModel(marvelService: marvelService, hero: hero)
        XCTAssertEqual("Name unavailable", viewModel.name)
    }
    
    func testHeroNameEmpty() {
        let hero = Hero(id: 1, name: "", description: nil, imageURL: nil)
        viewModel = HeroDetailViewModel(marvelService: marvelService, hero: hero)
        XCTAssertEqual("Name unavailable", viewModel.name)
    }
    
    func testHeroDescriptionUnavailable() {
        let hero = Hero(id: 1, name: nil, description: nil, imageURL: nil)
        viewModel = HeroDetailViewModel(marvelService: marvelService, hero: hero)
        XCTAssertEqual("Description unavailable", viewModel.description)
    }
    
    func testHeroDescriptionEmpty() {
        let hero = Hero(id: 1, name: nil, description: "", imageURL: nil)
        viewModel = HeroDetailViewModel(marvelService: marvelService, hero: hero)
        XCTAssertEqual("Description unavailable", viewModel.description)
    }
    
    func testReachingMaxAmountOfComics() {
        marvelService.shouldSimulateMaxAmountRequest = true
        
        let expectation = self.expectation(description: "testReachingMaxAmountOfComics")
        var result: Result<[IndexPath]> = .failure(CustomError.invalidData)
        viewModel.fetchHeroComics {
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
    
    func testSuccessFetchOfComics() {
        let expectation = self.expectation(description: "testSuccessFetchOfComics")
        var result: Result<[IndexPath]> = .failure(CustomError.invalidData)
        viewModel.fetchHeroComics {
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
    
    func testFailFetchOfComics() {
        marvelService.shouldFailRequest = true
        
        let expectation = self.expectation(description: "testFailFetchOfComics")
        var result: Result<[IndexPath]> = .success([])
        viewModel.fetchHeroComics {
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
    
    func testFetchImage() {
        let expectation = self.expectation(description: "TestImageFetch")
        var result: UIImage = #imageLiteral(resourceName: "marvellogo")
        
        viewModel.fetchHeroDetailImage {
            result = $0
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertNotNil(result)
    }
    
    func testNilHeroImage() {
        let hero = Hero(id: 1, name: "", description: "", imageURL: nil)
        viewModel = HeroDetailViewModel(marvelService: marvelService, hero: hero)
        
        let expectation = self.expectation(description: "testNilHeroImage")
        var result: UIImage = #imageLiteral(resourceName: "marvellogo")
        let placeholder: UIImage = #imageLiteral(resourceName: "marvellogo")
        
        viewModel.fetchHeroDetailImage {
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
        viewModel.fetchHeroDetailImage {
            result = $0
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(result, placeholder)
    }
}
