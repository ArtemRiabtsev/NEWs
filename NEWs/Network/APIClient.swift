//
//  APIClient.swift
//  NEWs
//
//  Created by Артем Рябцев on 2/10/19.
//  Copyright © 2019 Артем Рябцев. All rights reserved.
//

import Foundation

enum Either<T> {
    case success(T)
    case error(Error)
}

enum APIError: Error {
    case badResponse
    case jsonDecoder
}

protocol APIClient {
    var session: URLSession { get }
    func get<T: Codable>(request: URLRequest, completion: @escaping (Either<T>) -> Void )
}
extension APIClient {
    var session: URLSession {
        return URLSession.shared
    }
    func get<T: Codable>(request: URLRequest, completion: @escaping (Either<T>) -> Void ) {
        print(request)
        let task = self.session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(.error(error!))
                return
            }
            guard let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode else {
                completion(.error(APIError.badResponse))
                return
            }
            do {

                let value = try JSONDecoder().decode(T.self, from: data!)
                DispatchQueue.main.async {
                    completion(Either.success(value))
                }
            } catch let error {
                completion(.error(APIError.jsonDecoder))
            }
        }
        task.resume()
    }
    
}
