//
//  Comic.swift
//  MarvelHeroes
//
//  Created by Bruno Scheltzke on 02/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import Foundation

struct Comic: Decodable {
    let id: Int
    let title: String?
    let imageURL: String?
    let prices: [ComicPrice]?
    let description: String?
    
    func getMostExpensivePrice() -> Double? {
        return prices?.map({ $0.price ?? 0 }).max()
    }
}

struct ComicPrice: Decodable {
    let type: String?
    let price: Double?
}
