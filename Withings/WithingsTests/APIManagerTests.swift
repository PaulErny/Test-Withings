//
//  APIManagerTests.swift
//  WithingsTests
//
//  Created by Paul Erny on 12/06/2024.
//

import XCTest
@testable import Withings

final class APIManagerTests: XCTestCase {
    private var sampleData: ImagesResonse!
    private var manager: APIManager! = nil
    
    override func setUpWithError() throws {
        sampleData = ImagesResonse(total: 1, totalHits: 1, hits: [
            ImageModel.debugSample
        ])
        
        manager = APIManager.shared
    }
    
    func testFetchImages() throws {
        // Given
        let searchText = "cat"
        let page = 1
        var firstImage: ImageModel?
        let expectation = self.expectation(description: "queryResponse")
        
        // Do
        manager.fetchImages(search: searchText, page: page, completion: { response in
            switch response {
            case .failure(let error):
                print(error) // !
            case .success(let data):
                firstImage = data.hits.first
            }
            expectation.fulfill()
        })
        
        // Assert
        waitForExpectations(timeout: 5)
        // the api generates new image urls for every query so can't test XCTAssertEqual(firstImage, ImageModel.debugSample)
        XCTAssertNotNil(firstImage)
        XCTAssertEqual(firstImage!.id, ImageModel.debugSample.id)
        XCTAssertEqual(firstImage!.tags, ImageModel.debugSample.tags)
        XCTAssertEqual(firstImage!.user_id, ImageModel.debugSample.user_id)
        XCTAssertEqual(firstImage!.imageSize, ImageModel.debugSample.imageSize)
    }
}
