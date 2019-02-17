//
//  NewsClient.swift
//  NEWs
//
//  Created by Артем Рябцев on 2/10/19.
//  Copyright © 2019 Артем Рябцев. All rights reserved.
//

import Foundation

class NewsClient: APIClient {
    static let apiKey = "2c3edbd58b444b60920a2ceb19639e0e"//"ae5a58c0f9724925ab7a61380fdcff62"
    
    func getSources(endpoint: NewsEndpoint, completion: @escaping (Either<SourceObj>) -> Void) {
        let request = endpoint.request
        get(request: request, completion: completion)
    }
    func getNews(endpoint: NewsEndpoint, completion: @escaping (Either<ResultObj>) -> Void) {
        let request = endpoint.request
        get(request: request, completion: completion)
    }
    func getNewsByCountry(endpoint: NewsEndpoint, completion: @escaping (Either<ResultObj>) -> Void) {
        let request = endpoint.request
        get(request: request, completion: completion)
    }
    func getNewsBySource(endpoint: NewsEndpoint, completion: @escaping (Either<ResultObj>) -> Void) {
        let request = endpoint.request
        get(request: request, completion: completion)
    }
    func getNewsByCategory(endpoint: NewsEndpoint, completion: @escaping (Either<ResultObj>) -> Void) {
        let request = endpoint.request
        get(request: request, completion: completion)
    }
}
