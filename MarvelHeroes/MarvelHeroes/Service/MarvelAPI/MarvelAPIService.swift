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
import AlamofireImage

protocol MarvelAPIServiceProtocol {
    func requestCharacters(offset: Int?, amount: Int, completion: @escaping(Result<[Hero]>) -> Void)
    func fetchImage(imgURL: String, completion: @escaping(Result<UIImage>) -> Void)
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
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    do {
                        guard let data = response.data else {
                            completion(.failure(CustomError.invalidData))
                            return
                        }
                        let result = try JSONDecoder().decode(MarvelResponse.self, from: data)
                        completion(.success(result.heroes))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
    
    //MARK: Image
    private let imageCache = AutoPurgingImageCache()
    
    func fetchImage(imgURL: String, completion: @escaping(Result<UIImage>) -> Void) {
        if let cachedImg = imageCache.image(withIdentifier: imgURL) {
            completion(.success(cachedImg))
            return
        }
        
        Alamofire.request(imgURL,
                     method: .get,
                     parameters: defaultParams,
                     encoding: URLEncoding(destination: .queryString),
                     headers: nil)
            .validate()
            .responseImage { [unowned self] response in
                switch response.result {
                case .success(let img):
                    self.imageCache.add(img, withIdentifier: imgURL)
                    completion(.success(img))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
}

enum CustomError: Error {
    case invalidData
}
