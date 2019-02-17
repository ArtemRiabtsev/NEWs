//
//  EndpointObj.swift
//  NEWs
//
//  Created by Артем Рябцев on 2/10/19.
//  Copyright © 2019 Артем Рябцев. All rights reserved.
//

import UIKit

protocol Endpoint {
    
    var baseURL: String { get }
    
    var path: String { get }
    
    var urlParameters: [URLQueryItem] { get }
}
extension Endpoint {
    
    var urlComponents: URLComponents {
        
        var urlComponents = URLComponents(string: self.baseURL)
        
        urlComponents?.path = self.path
        
        urlComponents?.queryItems = self.urlParameters
        
        return urlComponents!
    }
    
    var request: URLRequest {
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        return request
    }
}
enum NewsEndpoint : Endpoint {
    
    case news(clientID: String, page: Int)
    case newsByCountry(clientID: String, countryCode: String, page: Int)
    case newsBySource(clientID: String, source: String, page: Int)
    case newsByCategory(clientID: String, category: String, page: Int)
    case sources(clientID: String)
    case search(clientID: String, query: String, page: Int)
    
    var baseURL: String {
        switch self {
        case .news, .newsByCountry, .newsBySource, .newsByCategory, .sources, .search:
            return "https://newsapi.org"
        }
    }
    
    var path: String {
        switch self {
        case .sources:
            return "/v2/sources"
        case .news, .newsByCountry, .newsByCategory:
            return "/v2/top-headlines"
        case .newsBySource, .search:
            return "/v2/everything"
        }
    }
    
    var urlParameters: [URLQueryItem] {
        switch self {
        case .news(let id, let page):
            return [
                URLQueryItem(name: "country", value: "ua"),//pageSize
                URLQueryItem(name: "pageSize", value: "20"),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "apiKey", value: id)
            ]
        case .sources(let id):
            return [
                URLQueryItem(name: "apiKey", value: id)
            ]
        case .newsByCountry(let id, let code, let page):
            return [
                URLQueryItem(name: "country", value: code),
                URLQueryItem(name: "pageSize", value: "20"),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "apiKey", value: id)
            ]
        case .newsBySource(let id, let sources, let page):
            return [
                URLQueryItem(name: "sources", value: sources),
                URLQueryItem(name: "pageSize", value: "20"),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "apiKey", value: id)
            ]
        case .newsByCategory(let id, let category, let page):
            return [
                URLQueryItem(name: "category", value: category),
                URLQueryItem(name: "pageSize", value: "20"),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "apiKey", value: id)
            ]
        case .search(let id, let query, let page):
            return [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "pageSize", value: "20"),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "apiKey", value: id)
            ]
        }
    }
}
