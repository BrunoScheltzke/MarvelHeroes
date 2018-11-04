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
    func requestComics(of hero: Hero, offset: Int?, amount: Int, completion: @escaping(Result<[Comic]>) -> Void)
    func fetchImage(imgURL: String, with size: MarvelImageSize, completion: @escaping(Result<UIImage>) -> Void)
}

enum MarvelImageSize: String {
    case comicList = "portrait_medium"
    case heroList = "portrait_xlarge"
    case heroDetail = "landscape_xlarge"
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
    private lazy var comicsPath = "\(basePath)\(MarvelKeys.characters)/%@\(MarvelKeys.comics)"
    
    private func genericCollectionRequest<T: Decodable>(withPath path: String, offset: Int, amount: Int, completion: @escaping(Result<T>) -> Void) {
        var params = defaultParams
        params[MarvelKeys.limit] = amount
        params[MarvelKeys.offset] = offset
        
        completion(.failure(CustomError.invalidData))
//        Alamofire.request(path,
//                          method: .get,
//                          parameters: params,
//                          encoding: URLEncoding(destination: .queryString),
//                          headers: nil)
//            .validate()
//            .responseJSON { response in
//                switch response.result {
//                case .success:
//                    do {
//                        guard let data = response.data else {
//                            completion(.failure(CustomError.invalidData))
//                            return
//                        }
//                        let result = try JSONDecoder().decode(MarvelResponse<T>.self, from: data)
//                        completion(.success(result.results))
//                    } catch {
//                        completion(.failure(error))
//                    }
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//        }
    }
    
    func requestComics(of hero: Hero, offset: Int? = 0, amount: Int, completion: @escaping(Result<[Comic]>) -> Void) {
        let path = String(format: comicsPath, "\(hero.id)")
        genericCollectionRequest(withPath: path, offset: offset!, amount: amount, completion: completion)
    }
    
    func requestCharacters(offset: Int? = 0, amount: Int, completion: @escaping(Result<[Hero]>) -> Void) {
        genericCollectionRequest(withPath: charactersPath, offset: offset!, amount: amount, completion: completion)
    }
    
    //MARK: Image
    private let imageCache = AutoPurgingImageCache()
    
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
}

enum CustomError: Error {
    case invalidData
}

struct MarvelResponse<T: Decodable>: Decodable {
    let results: T
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    enum AdditionalInfoKeys: String, CodingKey {
        case results
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let additionalInfo = try values.nestedContainer(keyedBy: AdditionalInfoKeys.self, forKey: .data)
        results = try additionalInfo.decode(T.self, forKey: .results)
    }
}
