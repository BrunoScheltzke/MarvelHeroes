//
//  ComicViewModelTests.swift
//  MarvelHeroesTests
//
//  Created by Bruno Scheltzke on 04/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import XCTest
@testable import MarvelHeroes

class ComicViewModelTests: XCTestCase {
    var marvelService: MarvelAPIServiceMock!
    var viewModel: ComicViewModel!
    
    override func setUp() {
        let comic = Comic(id: 1, title: "test", imageURL: "")
        marvelService = MarvelAPIServiceMock()
        viewModel = ComicViewModel(marvelService: marvelService, comic: comic)
    }
    
    override func tearDown() {
        viewModel = nil
        marvelService = nil
    }
    
    func testHeroTitleUnavailable() {
        let comic = Comic(id: 1, title: nil, imageURL: nil)
        viewModel = ComicViewModel(marvelService: marvelService, comic: comic)
        XCTAssertEqual("Title unavailable", viewModel.title)
    }
    
    func testHeroTitleEmpty() {
        let comic = Comic(id: 1, title: "", imageURL: nil)
        viewModel = ComicViewModel(marvelService: marvelService, comic: comic)
        XCTAssertEqual("Title unavailable", viewModel.title)
    }
    
    func testFetchImage() {
        let expectation = self.expectation(description: "TestImageFetch")
        var result: UIImage = #imageLiteral(resourceName: "marvellogo")
        
        viewModel.fetchComicImage {
            result = $0
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertNotNil(result)
    }
    
    func testNilHeroImage() {
        let comic = Comic(id: 1, title: "", imageURL: nil)
        viewModel = ComicViewModel(marvelService: marvelService, comic: comic)
        
        let expectation = self.expectation(description: "testNilHeroImage")
        var result: UIImage = #imageLiteral(resourceName: "marvellogo")
        let placeholder: UIImage = #imageLiteral(resourceName: "marvellogo")
        
        viewModel.fetchComicImage {
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
        viewModel.fetchComicImage {
            result = $0
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(result, placeholder)
    }
}
