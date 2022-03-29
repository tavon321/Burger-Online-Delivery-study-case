//
//  BurgerImagePresenterTests.swift
//  BurgerListTests
//
//  Created by Gustavo on 29/03/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList

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
    
    func test_didFinishLoadingImageDataWithImageData_displayDataWithImage() {
        let uniqueBurger = uniqueBurger
        let expectedImage = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in expectedImage })
        
        sut.didFinishLoadingImageData(with: anyData, for: uniqueBurger)
        
        let message = view.models.first
        XCTAssertEqual(view.models.count, 1)
        XCTAssertEqual(message?.name, uniqueBurger.name)
        XCTAssertEqual(message?.description, uniqueBurger.description)
        XCTAssertEqual(message?.image, expectedImage)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
    }
    
    func test_didFinishLoadingImageDataWithError_displayDataWithRetry() {
        let uniqueBurger = uniqueBurger
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingImageData(with: anyError, for: uniqueBurger)
        
        let message = view.models.first
        XCTAssertEqual(view.models.count, 1)
        XCTAssertEqual(message?.name, uniqueBurger.name)
        XCTAssertEqual(message?.description, uniqueBurger.description)
        XCTAssertEqual(message?.image, nil)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
    }
    
    func test_didFinishLoadingImageDataWithInvalidImage_displayDataWithRetry() {
        let uniqueBurger = uniqueBurger
        let (sut, view) = makeSUT(imageTransformer: fail)
        
        sut.didFinishLoadingImageData(with: anyData, for: uniqueBurger)
        
        let message = view.models.first
        XCTAssertEqual(view.models.count, 1)
        XCTAssertEqual(message?.name, uniqueBurger.name)
        XCTAssertEqual(message?.description, uniqueBurger.description)
        XCTAssertEqual(message?.image, nil)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
    }
    
    // MARK: - Helpers
    private func makeSUT(imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil },
                         file: StaticString = #file,
                         line: UInt = #line)
    -> (sut: BurgerImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = BurgerImagePresenter(view: view, imageTransformer: imageTransformer)
        
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut: sut, view: view)
    }
    
    private struct AnyImage: Equatable {}
    
    private var fail: (Data) -> AnyImage? {
        return { _ in nil }
    }
    
    private class ViewSpy: BurgerImageView {
        private(set) var models = [BurgerImageViewModel<AnyImage>]()
        
        func display(_ model: BurgerImageViewModel<AnyImage>) {
            models.append(model)
        }
    }
}
