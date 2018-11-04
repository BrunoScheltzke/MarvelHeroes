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
    static let marvelPublicKey = "e22382bc6094f500ef3b016d73d76e07"
    static let marvelPrivateKey = "eac21dd5d969623818261c2e5edb39b66e13ee9c"
}
