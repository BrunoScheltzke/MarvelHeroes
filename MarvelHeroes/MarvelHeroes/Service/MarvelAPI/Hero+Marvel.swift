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
        case thumbnail
    }
    
    enum ThumbnailInfo: String, CodingKey {
        case path
        case imgExtension = "extension"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        description = try values.decode(String.self, forKey: .description)
        
        let thumbnailInfo = try values.nestedContainer(keyedBy: ThumbnailInfo.self, forKey: .thumbnail)
        let pathToImage = try thumbnailInfo.decode(String.self, forKey: .path)
        let imgExtenstion = try thumbnailInfo.decode(String.self, forKey: .imgExtension)
        imageURL = pathToImage + "/%@." + imgExtenstion
    }
}
