//
//  ImagesResonse.swift
//  Withings
//
//  Created by Paul Erny on 10/06/2024.
//

import Foundation

struct ImagesResonse: Decodable {
    var total: Int
    var totalHits: Int
    var hits: [ImageModel]
}
