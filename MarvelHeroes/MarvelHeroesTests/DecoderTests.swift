//
//  DecoderTests.swift
//  MarvelHeroesTests
//
//  Created by Bruno Scheltzke on 04/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import XCTest
@testable import MarvelHeroes

class DecoderTests: XCTestCase {
    var decoder: JSONDecoder!

    override func setUp() {
        decoder = JSONDecoder()
    }

    override func tearDown() {
        decoder = nil
    }
    
    func testDecodeHeroesFromMarvel() {
        var heroes: [Hero] = []
        
        do {
            let result = try decoder.decode(MarvelResponse<[Hero]>.self, from: heroData)
            heroes = result.results
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        XCTAssertEqual(heroes.count, 1)
        
        XCTAssertNotNil(heroes[0].name)
        XCTAssertNotNil(heroes[0].description)
        XCTAssertNotNil(heroes[0].imageURL)
    }
    
    func testDecodeComicsFromMarvel() {
        var comics: [Comic] = []
        
        do {
            let result = try decoder.decode(MarvelResponse<[Comic]>.self, from: comicData)
            comics = result.results
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        XCTAssertEqual(comics.count, 1)
        
        XCTAssertNotNil(comics[0].title)
        XCTAssertNotNil(comics[0].imageURL)
    }
}

private let heroData = """
{
    "data": {
        "total": 1,
        "results": [
            {
                "id": 1017100,
                "name": "A-Bomb (HAS)",
                "description": "Hulk's Friend",
                "thumbnail":
                    {
                        "path": "thepath",
                        "extension": "jpg"
                    }
            }
        ]
    }
}
""".data(using: .utf8)!

private let comicData = """
{
    "data": {
        "total": 1,
        "results": [
            {
                "id": 40628,
                "title": "Hulk (2008) #55",
                "thumbnail": {
                    "path": "http://i.annihil.us/u/prod/marvel/i/mg/6/60/5ba3d0869c543",
                    "extension": "jpg"
                }
            }
        ]
    }
}
""".data(using: .utf8)!
