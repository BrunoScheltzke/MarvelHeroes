//
//  MarvelKeys.swift
//  MarvelHeroes
//
//  Created by Bruno Scheltzke on 02/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import Foundation

struct MarvelKeys {
    //URL Paths
    static let baseUrl = "https://gateway.marvel.com/v1/public"
    static let characters = "/characters"
    static let comics = "/comics"
    
    //Amount of info on a request
    static let limit = "limit"
    static let offset = "offset"
    
    //Request identification
    static let timestamp = "ts"
    static let hash = "hash"
    static let publicKey = "apikey"
    static let marvelPublicKey = "d3e088896f979b05e097c83ba10f37c5"
    static let marvelPrivateKey = "683b3c9d67c1bc920f58f414c991817fdcd1bd87"
}
