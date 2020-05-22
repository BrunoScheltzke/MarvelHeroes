//
//  MarvelAPIServiceMock.swift
//  MarvelHeroes
//
//  Created by Bruno Scheltzke on 04/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

final class MarvelAPIServiceMock: MarvelAPIServiceProtocol {
    var shouldFailRequest: Bool = false
    var totalAmount: Int = 0
    var shouldSimulateMaxAmountRequest: Bool = false
    
    func requestCharacters(offset: Int?, amount: Int, completion: @escaping (Result<([Hero], totalAmount: Int)>) -> Void) {
        if shouldFailRequest {
            completion(.failure((CustomError.invalidData)))
        } else {
            let hero = Hero.init(id: 1, name: "TestHero", description: "This is a mock hero", imageURL: nil)
            
            let heroes = shouldSimulateMaxAmountRequest ? [] : [hero]
            
            completion(.success((heroes, totalAmount)))
        }
    }
    
    func requestComics(of hero: Hero, offset: Int?, amount: Int, completion: @escaping (Result<([Comic], totalAmount: Int)>) -> Void) {
        if shouldFailRequest {
            completion(.failure((CustomError.invalidData)))
        } else {
            let comic = Comic.init(id: 1, title: "TestComic", imageURL: nil, prices: [], description: "TestDescription")
            let comics = shouldSimulateMaxAmountRequest ? [] : [comic]
            completion(.success((comics, totalAmount)))
        }
    }
    
    func fetchImage(imgURL: String, with size: MarvelImageSize, completion: @escaping (Result<UIImage>) -> Void) {
        if shouldFailRequest {
            completion(.failure((CustomError.invalidData)))
        } else {
            completion(.success(#imageLiteral(resourceName: "marvellogo")))
        }
    }
}
