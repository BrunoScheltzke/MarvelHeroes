//
//  MarvelResponse.swift
//  MarvelHeroes
//
//  Created by Bruno Scheltzke on 04/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import Foundation

// Helper struct created to deal with general response from Marvel API
struct MarvelResponse<T: Decodable>: Decodable {
    let results: T
    let total: Int
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    enum AdditionalInfoKeys: String, CodingKey {
        case results
        case total
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let additionalInfo = try values.nestedContainer(keyedBy: AdditionalInfoKeys.self, forKey: .data)
        results = try additionalInfo.decode(T.self, forKey: .results)
        total = try additionalInfo.decode(Int.self, forKey: .total)
    }
}
