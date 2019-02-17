//
//  Sources.swift
//  NEWs
//
//  Created by Артем Рябцев on 2/10/19.
//  Copyright © 2019 Артем Рябцев. All rights reserved.
//

import Foundation

struct SourceObj: Codable {
    let status: String
    let sources: [Sources]
}

struct Sources: Codable {
    let id: String
    let name: String
    let description: String
    let url: String
    let category: String
    let language: String
    let country: String
}
