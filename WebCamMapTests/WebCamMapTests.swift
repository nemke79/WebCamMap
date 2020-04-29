//
//  WebCamMapTests.swift
//  WebCamMapTests
//
//  Created by Nemanja Petrovic on 15/04/2020.
//  Copyright © 2020 Nemanja Petrovic. All rights reserved.
//

import XCTest
@testable import WebCamMap

class WebCamMapTests: XCTestCase {
    
    var sut: URLSession!
    
    var vc: WebCamMapViewController!
    
    var infoVC: WebCamInfoTableViewController!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = URLSession(configuration: .default)
        
        vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "WebCamMapViewController") as? WebCamMapViewController
        vc.loadViewIfNeeded()
        
        infoVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "WebCamInfoTableViewController") as? WebCamInfoTableViewController
        infoVC.loadViewIfNeeded()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        sut = nil
        vc = nil
        infoVC = nil
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
    
    func testWebCamMapViewControllerHasTableView() {
        XCTAssertNotNil(vc.citiesTableView, "Controller should have citiesTableView.")
    }
    
    func testCitiesTableViewHasCells() {
        let cell = vc.citiesTableView.dequeueReusableCell(withIdentifier: "cityName")
        
        XCTAssertNotNil(cell, "TableView should be able to dequeue cell with identifier: 'cityName'")
    }
    
    func testCitiesTableViewCellValue() {
        
        // One way for testing cell value.
        let cell = vc.tableView(vc.citiesTableView, cellForRowAt: IndexPath(row: 0, section: 0))
        
        let vcCell = cell as? CityNameCell
        
        vcCell?.cityName.text = "Belgrade"
        
        vcCell?.favouriteButton.setImage(UIImage(systemName: "video.circle"), for: .normal)
        
        XCTAssertEqual(vcCell?.cityName.text, "Belgrade", "Not good input in textLabel of cell.")
        
        XCTAssertNotNil(vcCell?.favouriteButton.imageView?.image, "No image in cell - nil value.")
    }
    
    func testWebCamInfoCellValue() {
        
        // Another way for testing cell value.
        let cell = infoVC.tableView.dequeueReusableCell(withIdentifier: "WebCamInfoCell", for: IndexPath(row: 0, section: 0))
        
        cell.textLabel?.text = "Belgrade"
        
        XCTAssertEqual(cell.textLabel?.text, "Belgrade", "Not good input in textLabel of cell.")
        
        cell.imageView?.image = UIImage(systemName: "video.circle")
        
        XCTAssertNotNil(cell.imageView?.image, "No image in cell - nil value.")
    }
    
    func testWebCamInfoTableViewControllerHasCells() {
        let cell = infoVC.tableView.dequeueReusableCell(withIdentifier: "WebCamInfoCell")
        
        XCTAssertNotNil(cell, "TableView should be able to dequeue cell with identifier: 'WebCamInfoCell'")
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
