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
    /// Fetches characters from the Marvel API
    ///
    /// - Parameters:
    ///   - offset: the start point from where to get the amount of heroes
    ///   - amount: the amount of heroes to retrive
    ///   - completion: returns an array of the heroes and a boolean that informs if it has reached the maximum amount of heroes
    func requestCharacters(offset: Int?, amount: Int, completion: @escaping(Result<([Hero], totalAmount: Int)>) -> Void)
    
    /// Fetches Comics of a specific hero from the Marvel API
    ///
    /// - Parameters:
    ///   - hero: the hero from whom to fetch the comics
    ///   - offset: the start point from where to get the amount of comics
    ///   - amount: the amount of comics to retrieve
    ///   - completion: returns an array of the comics and a boolean that informs if it has reached the maximum amount of comics of the given hero
    func requestComics(of hero: Hero, offset: Int?, amount: Int, completion: @escaping(Result<([Comic], totalAmount: Int)>) -> Void)
    func fetchImage(imgURL: String, with size: MarvelImageSize, completion: @escaping(Result<UIImage>) -> Void)
}

final class MarvelAPIService: MarvelAPIServiceProtocol {
    private let basePath = MarvelKeys.baseUrl
    private lazy var charactersPath = "\(basePath)\(MarvelKeys.characters)"
    private lazy var comicsPath = "\(basePath)\(MarvelKeys.characters)/%@\(MarvelKeys.comics)"
    
    // Every request has to be authenticated with public and private keys
    // Defines default parameters with authentication to make it available for every request
    private lazy var defaultParams: [String: Any] = {
        let ts = "\(Date().timeIntervalSinceNow)"
        let hash = "\(ts)\(MarvelKeys.marvelPrivateKey)\(MarvelKeys.marvelPublicKey)".md5()
        return [
            MarvelKeys.timestamp: ts,
            MarvelKeys.hash: hash,
            MarvelKeys.publicKey: MarvelKeys.marvelPublicKey
        ]
    }()
    
    // Handles image caching
    private let imageCache = AutoPurgingImageCache()
    
    func requestCharacters(offset: Int? = 0, amount: Int, completion: @escaping(Result<([Hero], totalAmount: Int)>) -> Void) {
        performGenericRequest(withPath: charactersPath, offset: offset!, amount: amount, completion: completion)
    }
    
    func requestComics(of hero: Hero, offset: Int? = 0, amount: Int, completion: @escaping(Result<([Comic], totalAmount: Int)>) -> Void) {
        let path = String(format: comicsPath, "\(hero.id)")
        performGenericRequest(withPath: path, offset: offset!, amount: amount, completion: completion)
    }
    
    func fetchImage(imgURL: String, with size: MarvelImageSize, completion: @escaping(Result<UIImage>) -> Void) {
        let imgPath = String(format: imgURL, size.rawValue)
        if let cachedImg = imageCache.image(withIdentifier: imgPath) {
            completion(.success(cachedImg))
            return
        }
        
        Alamofire.request(imgPath,
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
    
    /// Results returned by the API endpoints have the same general format, no matter which entity type the endpoint returns. Every successful call will return a wrapper object, which contains metadata about the call and a container object, which displays pagination information and an array of the results returned by this call. The MarvelResponse helper struct was created to deal with that general response. It decodes the data(wrapper object) from the request and then gets the results which will be an array of some entity.
    ///
    /// - Parameters:
    ///   - path: the path url
    ///   - offset: the start point from where to get the amount of data
    ///   - amount: the amount of data to retrive
    ///   - completion: returns an array of the model requested and a boolean that informs if has reached the maximum amount of data of that model
    private func performGenericRequest<T: Decodable>(withPath path: String, offset: Int, amount: Int, completion: @escaping(Result<(T, totalAmount: Int)>) -> Void) {
        var params = defaultParams
        params[MarvelKeys.limit] = amount
        params[MarvelKeys.offset] = offset
        
        Alamofire.request(path,
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
                        let result = try JSONDecoder().decode(MarvelResponse<T>.self, from: data)
                        
//                        let hasReachedMaxAmount = result.total <= offset + amount
                        
                        completion(.success((result.results, result.total)))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
}

enum Result<T> {
    case success(T)
    case failure(Error)
}

enum CustomError: Error {
    case invalidData
}

enum MarvelImageSize: String {
    case comicList = "portrait_medium"
    case heroList = "portrait_xlarge"
    case heroDetail = "landscape_xlarge"
}
