//
//  DemoTest.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 13/03/22.
//

import XCTest
import EssentialFeed

struct LoginModel {
    let name: String?
    let age: Int?
}

class LoginViewModel {
    private let model: LoginModel?
    
    init(model: LoginModel) {
        self.model = model
    }
    
    func getName() -> String? {
        return model?.name
    }
    
    func getDiscountOnAge() -> Int {
        guard let age = model?.age else { return 10 }
        if age > 10 {
            return 20
        } else {
            return 30
        }
    }
}

class DemoTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func test_nameNotNullWhenUserEnterData() {
        // Arrange
        let model = LoginModel(name: "Anil", age: nil)
        let viewModel = LoginViewModel(model: model)
        
        // Act
        
   
        // Assert
        XCTAssertNotNil(viewModel.getName())
        XCTAssertEqual(viewModel.getName(), "Anil")
        
    }
    
    func test_getDiscountOnAge() {
        let model = LoginModel(name: "Anil", age: 12)
        let viewModel = LoginViewModel(model: model)
        
        XCTAssertEqual(viewModel.getDiscountOnAge(), 20)
    }
    
}
