//
//  CategoriesList.swift
//  NEWs
//
//  Created by imac on 2/13/19.
//  Copyright © 2019 Артем Рябцев. All rights reserved.
//

import Foundation

enum Categories: String {
    case business = "Business"
    case entertainment = "Bntertainment"
    case general = "General"
    case health = "Health"
    case science = "Science"
    case sports = "Sports"
    case technology = "Technology"
    static let list = [Categories.business.rawValue,
                               Categories.entertainment.rawValue,
                               Categories.general.rawValue,
                               Categories.health.rawValue,
                               Categories.science.rawValue,
                               Categories.sports.rawValue,
                               Categories.technology.rawValue]
}
