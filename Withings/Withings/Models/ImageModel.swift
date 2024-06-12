//
//  ImageModel.swift
//  Withings
//
//  Created by Paul Erny on 10/06/2024.
//

import Foundation
import UIKit

struct ImageModel: Decodable, Equatable {
    var id : Int?
//    var previewImage: UIImage?
    var image: UIImage?
    var pageURL : String?
    var type : String?
    var tags : String?
    var previewURL : URL?
    var previewWidth : Int?
    var previewHeight : Int?
    var webformatURL : URL?
    var webformatWidth : Int?
    var webformatHeight : Int?
    var largeImageURL : URL?
    var imageWidth : Int?
    var imageHeight : Int?
    var imageSize : Int?
    var views : Int?
    var downloads : Int?
    var collections : Int?
    var likes : Int?
    var comments : Int?
    var user_id : Int?
    var user : String?
    var userImageURL : URL?

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
        let _webformatURL = try values.decode(String.self, forKey: .webformatURL)
        webformatURL = URL(string: _webformatURL)
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
        let _userImageURL = try values.decode(String.self, forKey: .userImageURL)
        userImageURL = URL(string: _userImageURL)
        
        image = nil
    }

    func createPreviewImage(completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let previewData = NSData(contentsOf: previewURL!)
            let image = UIImage(data: previewData! as Data)
            completion(image)
        }
    }
    
    func createLargeImage(completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let previewData = NSData(contentsOf: largeImageURL!)
            let image = UIImage(data: previewData! as Data)
            completion(image)
        }
    }
}

extension ImageModel {
    private init() {}
    
    static var debugSample: ImageModel { // first query hit for q = "cat"
        var sample = ImageModel()
        sample.id = 8618301
        sample.pageURL = "https://pixabay.com/photos/simba-cat-portrait-cat-photography-8618301/"
        sample.type = "photo"
        sample.tags = "simba, pet, cat"
        sample.previewURL = URL(string: "https://cdn.pixabay.com/photo/2024/03/07/10/38/simba-8618301_150.jpg")
        sample.previewWidth = 150
        sample.previewHeight = 100
        sample.webformatURL = URL( string: "https://pixabay.com/get/gcd652f1b6e394aa101e1501a6d2459b7420103c22bce5b65b753a37ccc08d5a72d0ae186e237feb3975023c93614e65bc0a9cdb8ce13065154e7b685cef405a1_640.jpg")
        sample.webformatWidth = 640
        sample.webformatHeight = 426
        sample.largeImageURL = URL( string: "https://pixabay.com/get/gc3bccec25e857ae9a569a2fe9b2005dbdd7c41f0bbe6df788f9a4ea5221fac8b46957a02e9fcd50e22acb4ee2499f474de95f7a773945aff1e3f2f5c29ef18a0_1280.jpg")
        sample.imageWidth = 6016
        sample.imageHeight = 4000
        sample.imageSize = 6194350
        sample.views = 28632
        sample.downloads = 23587
        sample.collections = 80
        sample.likes = 130
        sample.comments = 18
        sample.user_id = 5211440
        sample.user = "Jill-Schafer-Creative-Lab"
        sample.userImageURL = URL(string: "https://cdn.pixabay.com/user/2022/09/07/09-11-48-369_250x250.png")
        return sample
    }
}
