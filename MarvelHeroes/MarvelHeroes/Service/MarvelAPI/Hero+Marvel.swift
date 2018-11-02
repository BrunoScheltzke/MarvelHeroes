//
//  Hero+Marvel.swift
//  MarvelHeroes
//
//  Created by Bruno Scheltzke on 02/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import Foundation

extension Hero {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case comics
    }
    
    enum AdditionalInfo: String, CodingKey {
        case items
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        description = try values.decode(String.self, forKey: .description)
        
        let additionalInfo = try values.nestedContainer(keyedBy: AdditionalInfo.self, forKey: .comics)
        comics = try additionalInfo.decode([Comic].self, forKey: .items)
    }
}

struct MarvelResponse: Decodable {
    let heroes: [Hero]
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    enum AdditionalInfoKeys: String, CodingKey {
        case results
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let additionalInfo = try values.nestedContainer(keyedBy: AdditionalInfoKeys.self, forKey: .data)
        heroes = try additionalInfo.decode([Hero].self, forKey: .results)
    }
}
