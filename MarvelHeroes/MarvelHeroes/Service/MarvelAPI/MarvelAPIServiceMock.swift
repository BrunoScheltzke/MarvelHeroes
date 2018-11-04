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
    var shouldSimulateMaxAmountRequest = false
    
    func requestCharacters(offset: Int?, amount: Int, completion: @escaping (Result<([Hero], hasReachedMaxAmount: Bool)>) -> Void) {
        if shouldFailRequest {
            completion(.failure((CustomError.invalidData)))
        } else {
            let hero = Hero.init(id: 1, name: "TestHero", description: "This is a mock hero", imageURL: nil)
            
            let heroes = shouldSimulateMaxAmountRequest ? [] : [hero]
            
            completion(.success((heroes, shouldSimulateMaxAmountRequest)))
        }
    }
    
    func requestComics(of hero: Hero, offset: Int?, amount: Int, completion: @escaping (Result<([Comic], hasReachedMaxAmount: Bool)>) -> Void) {
        if shouldFailRequest {
            completion(.failure((CustomError.invalidData)))
        } else {
            let comic = Comic.init(id: 1, title: "TestComic", imageURL: nil)
            let comics = shouldSimulateMaxAmountRequest ? [] : [comic]
            completion(.success((comics, shouldSimulateMaxAmountRequest)))
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
