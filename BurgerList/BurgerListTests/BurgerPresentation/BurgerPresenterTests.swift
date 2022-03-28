//
//  BurgerPresenterTests.swift
//  BurgerListTests
//
//  Created by Gustavo on 28/03/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import XCTest

final class BurgersPresenter {
    private let view: Any
    
    init(view: Any) {
        self.view = view
    }
}

class BurgerPresenterTests: XCTestCase {
    
    func test_init_doesNotMessageView() {
        let view = ViewSpy()
        
        _ = BurgersPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages on init, got \(view.messages) instead")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file,
                         line: UInt = #line) -> (sut: BurgersPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = BurgersPresenter(view: view)
        
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut: sut, view: view)
    }
    
    private class ViewSpy{
        var messages = [Message]()
        
        enum Message: Equatable {
        }
    }
}
