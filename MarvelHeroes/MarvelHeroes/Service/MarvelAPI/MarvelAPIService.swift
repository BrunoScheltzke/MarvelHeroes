//
//  MarvelAPIService.swift
//  MarvelHeroes
//
//  Created by Bruno Scheltzke on 02/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import Foundation
import CryptoSwift
import Alamofire

protocol MarvelAPIServiceProtocol {
    func requestCharacters(offset: Int?, amount: Int, completion: @escaping(Result<[Hero]>) -> Void)
}

class MarvelAPIService: MarvelAPIServiceProtocol {
    private lazy var defaultParams: [String: Any] = {
        let ts = "\(Date().timeIntervalSinceNow)"
        let hash = "\(ts)\(MarvelKeys.marvelPrivateKey)\(MarvelKeys.marvelPublicKey)".md5()
        
        return [
            MarvelKeys.timestamp: ts,
            MarvelKeys.hash: hash,
            MarvelKeys.publicKey: MarvelKeys.marvelPublicKey
        ]
    }()
    
    private let basePath = MarvelKeys.baseUrl
    private lazy var charactersPath = "\(basePath)\(MarvelKeys.characters)"
    
    func requestCharacters(offset: Int? = 0, amount: Int, completion: @escaping(Result<[Hero]>) -> Void) {
        var params = defaultParams
        params[MarvelKeys.limit] = amount
        params[MarvelKeys.offset] = offset
        
        Alamofire.request(charactersPath,
                          method: .get,
                          parameters: params,
                          encoding: URLEncoding(destination: .queryString),
                          headers: nil)
            .responseJSON { json in
                do {
                    guard let data = json.data else {
                        completion(.failure(CustomError.invalidData))
                        return
                    }
                    let result = try JSONDecoder().decode(MarvelResponse.self, from: data)
                    completion(.success(result.heroes))
                } catch {
                    completion(.failure(error))
                }
        }
    }
}
