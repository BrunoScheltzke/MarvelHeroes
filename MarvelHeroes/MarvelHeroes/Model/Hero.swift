//
//  Hero.swift
//  MarvelHeroes
//
//  Created by Bruno Scheltzke on 02/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import Foundation

struct Hero: Decodable {
    let id: Int
    let name: String?
    let description: String?
    let comics: [Comic]
    let imageURL: String?
}
