//
//  BurgerImagePresenterTests.swift
//  BurgerListTests
//
//  Created by Gustavo on 29/03/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import XCTest

final class BurgerImagePresenter {
    private let view: Any
    
    init(view: Any) {
        self.view =  view
    }
}

class BurgerImagePresenterTests: XCTestCase {
    
    func test_init_doesNoteMessageView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected No messages, got \(view.messages) instead")
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file,
                         line: UInt = #line)
    -> (sut: BurgerImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = BurgerImagePresenter(view: view)
        
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut: sut, view: view)
    }
    
    private class ViewSpy {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            
        }
    }
}
