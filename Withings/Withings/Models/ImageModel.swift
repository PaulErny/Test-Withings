//
//  ImageModel.swift
//  Withings
//
//  Created by Paul Erny on 10/06/2024.
//

import Foundation
import UIKit

struct ImageModel: Decodable {
    let id : Int?
    let previewImage: UIImage?
    let image: UIImage?
    let pageURL : String?
    let type : String?
    let tags : String?
    let previewURL : URL?
    let previewWidth : Int?
    let previewHeight : Int?
    let webformatURL : String?
    let webformatWidth : Int?
    let webformatHeight : Int?
    let largeImageURL : URL?
    let imageWidth : Int?
    let imageHeight : Int?
    let imageSize : Int?
    let views : Int?
    let downloads : Int?
    let collections : Int?
    let likes : Int?
    let comments : Int?
    let user_id : Int?
    let user : String?
    let userImageURL : String?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case pageURL = "pageURL"
        case type = "type"
        case tags = "tags"
        case previewURL = "previewURL"
        case previewWidth = "previewWidth"
        case previewHeight = "previewHeight"
        case webformatURL = "webformatURL"
        case webformatWidth = "webformatWidth"
        case webformatHeight = "webformatHeight"
        case largeImageURL = "largeImageURL"
        case imageWidth = "imageWidth"
        case imageHeight = "imageHeight"
        case imageSize = "imageSize"
        case views = "views"
        case downloads = "downloads"
        case collections = "collections"
        case likes = "likes"
        case comments = "comments"
        case user_id = "user_id"
        case user = "user"
        case userImageURL = "userImageURL"
    }

    /// do not call on main thread bcs UIImages are created here
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        pageURL = try values.decodeIfPresent(String.self, forKey: .pageURL)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        tags = try values.decodeIfPresent(String.self, forKey: .tags)
        let _previewURL = try values.decode(String.self, forKey: .previewURL)
        previewURL = URL(string: _previewURL)
        previewWidth = try values.decodeIfPresent(Int.self, forKey: .previewWidth)
        previewHeight = try values.decodeIfPresent(Int.self, forKey: .previewHeight)
        webformatURL = try values.decodeIfPresent(String.self, forKey: .webformatURL)
        webformatWidth = try values.decodeIfPresent(Int.self, forKey: .webformatWidth)
        webformatHeight = try values.decodeIfPresent(Int.self, forKey: .webformatHeight)
        let _largeImageURL = try values.decode(String.self, forKey: .largeImageURL)
        largeImageURL = URL(string: _largeImageURL)
        imageWidth = try values.decodeIfPresent(Int.self, forKey: .imageWidth)
        imageHeight = try values.decodeIfPresent(Int.self, forKey: .imageHeight)
        imageSize = try values.decodeIfPresent(Int.self, forKey: .imageSize)
        views = try values.decodeIfPresent(Int.self, forKey: .views)
        downloads = try values.decodeIfPresent(Int.self, forKey: .downloads)
        collections = try values.decodeIfPresent(Int.self, forKey: .collections)
        likes = try values.decodeIfPresent(Int.self, forKey: .likes)
        comments = try values.decodeIfPresent(Int.self, forKey: .comments)
        user_id = try values.decodeIfPresent(Int.self, forKey: .user_id)
        user = try values.decodeIfPresent(String.self, forKey: .user)
        userImageURL = try values.decodeIfPresent(String.self, forKey: .userImageURL)
        
        // --- ok for now since its only called in background threads by APIManager ---

        let previewData = NSData(contentsOf: previewURL!)
        previewImage = UIImage(data: previewData! as Data)
        let imageData = NSData(contentsOf: largeImageURL!)
        image = UIImage(data: imageData! as Data)
    }
}
