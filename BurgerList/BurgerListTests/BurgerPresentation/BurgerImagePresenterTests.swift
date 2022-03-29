//
//  BurgerImagePresenterTests.swift
//  BurgerListTests
//
//  Created by Gustavo on 29/03/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList

struct BurgerImageViewModel<Image> {
    var name: String
    var description: String?
    var image: Image?
    var isLoading: Bool
    var shouldRetry: Bool
    
    var hasDescription: Bool {
        return description != nil
    }
}

protocol BurgerImageView {
    associatedtype Image
    
    func display(_ model: BurgerImageViewModel<Image>)
}

final class BurgerImagePresenter<View: BurgerImageView, Image> where View.Image == Image {
    private let view: View
    
    init(view: View) {
        self.view =  view
    }
    
    func cellDidLoad(for model: Burger) {
        view.display(BurgerImageViewModel(name: model.name,
                                          description: model.description,
                                          image: nil,
                                          isLoading: false,
                                          shouldRetry: false))
    }
    
    func didStartLoadingImageData(for model: Burger) {
        view.display(BurgerImageViewModel(name: model.name,
                                          description: model.description,
                                          image: nil,
                                          isLoading: true,
                                          shouldRetry: false))
    }
}

class BurgerImagePresenterTests: XCTestCase {
    
    func test_init_doesNoteMessageView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.models.isEmpty, "Expected No messages, got \(view.models) instead")
    }
    
    func test_cellDidLoad_displayLoadedData() {
        let (sut, view) = makeSUT()
        let uniqueBurger = uniqueBurger
        
        sut.cellDidLoad(for: uniqueBurger)
        
        let message = view.models.first
        XCTAssertEqual(view.models.count, 1)
        XCTAssertEqual(message?.name, uniqueBurger.name)
        XCTAssertEqual(message?.description, uniqueBurger.description)
        XCTAssertEqual(message?.image, nil)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
    }
    
    func test_didStartLoadingImageData_displayIsLoadingData() {
        let (sut, view) = makeSUT()
        let uniqueBurger = uniqueBurger
        
        sut.didStartLoadingImageData(for: uniqueBurger)
        
        let message = view.models.first
        XCTAssertEqual(view.models.count, 1)
        XCTAssertEqual(message?.name, uniqueBurger.name)
        XCTAssertEqual(message?.description, uniqueBurger.description)
        XCTAssertEqual(message?.image, nil)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file,
                         line: UInt = #line)
    -> (sut: BurgerImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = BurgerImagePresenter(view: view)
        
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut: sut, view: view)
    }
    
    private struct AnyImage: Equatable {}
    
    private class ViewSpy: BurgerImageView {
        private(set) var models = [BurgerImageViewModel<AnyImage>]()
        
        func display(_ model: BurgerImageViewModel<AnyImage>) {
            models.append(model)
        }
    }
}
