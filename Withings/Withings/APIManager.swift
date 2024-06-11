//
//  APIManager.swift
//  Withings
//
//  Created by Paul Erny on 10/06/2024.
//

import Foundation

enum DataError: Error {
    case invalidURL
    case invalidData
    case invalidResponse
    case message(_ error: Error?)
}

class APIManager {
    static let shared = APIManager()
    private var components = URLComponents(string: "https://pixabay.com/api/")!
    
    private init() {
        components.queryItems = [
            URLQueryItem(name: "key", value: ProcessInfo.processInfo.environment["API_KEY"])
        ]
    }
    
    func fetchImages(search: String, page: Int = 1, completion: @escaping (Result<ImagesResonse, Error>) -> Void) {
        components.queryItems?.append( URLQueryItem(name: "q", value: search) )
        components.queryItems?.append( URLQueryItem(name: "page", value: "\(page)") )
        components.queryItems?.append( URLQueryItem(name: "per_page", value: "\(36)") )
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")

        guard let url = components.url else {
            completion(.failure(DataError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data else {
                completion(.failure(DataError.invalidData))
                return
            }
            guard let response = response as? HTTPURLResponse, 200 ... 299  ~= response.statusCode else {
                completion(.failure(DataError.invalidResponse))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(ImagesResonse.self, from: data)
                completion(.success(decodedResponse))
            }
            catch {
                completion(.failure(DataError.message(error)))
            }
        }.resume()
        components.queryItems?.removeAll(where: { $0.name == "q" })

    }
}
