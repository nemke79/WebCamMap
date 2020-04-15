//
//  WebCamMapTests.swift
//  WebCamMapTests
//
//  Created by Nemanja Petrovic on 15/04/2020.
//  Copyright © 2020 Nemanja Petrovic. All rights reserved.
//

import XCTest

class WebCamMapTests: XCTestCase {
    
    var sut: URLSession!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = URLSession(configuration: .default)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        sut = nil
    }
    
    func testCallToApiWindyCompletes() {
      // given
      let url =
        URL(string: "https://api.windy.com/api/webcams/v2/list/nearby=44.77376875895725,20.49074368731553,20/orderby=distance/limit=50?show=webcams:player,image&key=BWCdRgohrnZPoVqrPYWcyU7N1sbR4ko4")
      let promise = expectation(description: "Completion handler invoked")
      var statusCode: Int?
      var responseError: Error?

      // when
      let dataTask = sut.dataTask(with: url!) { data, response, error in
        statusCode = (response as? HTTPURLResponse)?.statusCode
        responseError = error
        promise.fulfill()
      }
      dataTask.resume()
      wait(for: [promise], timeout: 5)

      // then
      XCTAssertNil(responseError)
      XCTAssertEqual(statusCode, 200)
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
