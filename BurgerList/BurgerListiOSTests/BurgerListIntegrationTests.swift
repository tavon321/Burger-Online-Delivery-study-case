//
//  BurgerListIntegrationTests.swift
//  BurgerListiOSTests
//
//  Created by Gustavo on 9/08/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList
import BurgerListiOS

class BurgerListIntegrationTests: XCTestCase {
    
    func test_burgerList_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, localized("BURGERLIST_VIEW_TITLE"))
    }
    
    func test_loadBurgerActions_requestBurgerListFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.burgerRequestCallCount, 0, "Expected NO loading request when the view isn't loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.burgerRequestCallCount, 1, "Expected loading request when the view did load")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.burgerRequestCallCount, 2, "Expected a request when the user initiates a load")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.burgerRequestCallCount, 3, "Expected a 2nd request when the user initiates a load")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingBurgerList() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once the view is loaded")
        
        loader.completeBurgerLoading(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once the view loading is completed successfully")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once the user initiates a refresh")
        
        loader.completeBurgerLoading(with: anyError, at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicater once user initiated refresh ended with error")
    }
    
    func test_loadBurgerListCompletion_renderCellView() {
        let burger0 = makeBurger(name: "a name", description: "a description")
        let burger1 = makeBurger(name: "a name")
        let burger2 = makeBurger(name: "a name", imageURL: anyURL)
        let burger3 = makeBurger(name: "a name", description: "a description", imageURL: anyURL)
        
        let (sut, loader) = makeSUT()
        
        assertThat(sut, isRendering: [])
        
        sut.loadViewIfNeeded()
        loader.completeBurgerLoading(with: [burger0])
        assertThat(sut, isRendering: [burger0])
        
        let burgers = [burger0, burger1, burger2, burger3]
        sut.simulateUserInitiatedReload()
        loader.completeBurgerLoading(with: burgers, at: 1)
        assertThat(sut, isRendering: burgers)
    }
    
    func test_loadBurgerCompletion_doesNotAlterCurrentRenderingState() {
        let burger0 = makeBurger(name: "a name", description: "a description")
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBurgerLoading(with: [burger0])
        assertThat(sut, isRendering: [burger0])
        
        sut.simulateUserInitiatedReload()
        loader.completeBurgerLoading(with: anyError)
        assertThat(sut, isRendering: [burger0])
    }
    
    func test_loadBurgerCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeBurgerLoading(with: anyError)
        XCTAssertEqual(sut.errorMessage, localized("BURGER_VIEW_CONNECTION_ERROR"))
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_burgerView_loadsImageURLWhenVisible() {
        let burger0 = makeBurger(name: "a name", imageURL: URL(string:"http://url-0.com")!)
        let burger1 = makeBurger(name: "a name", imageURL: URL(string:"http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBurgerLoading(with: [burger0, burger1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expecte no image URL reques until views became visible")
        
        sut.simulateBurgerViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [burger0.imageURL],
                       "Expected first image URL Requested once the view is visible")
        
        sut.simulateBurgerViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [burger0.imageURL, burger1.imageURL],
                       "Expected first and second image URL Requested once the view is visible")
    }
    
    func test_burgerView_cancelsLoadsImageURLWhenNotVisible() {
        let burger0 = makeBurger(name: "a name", imageURL: URL(string:"http://url-0.com")!)
        let burger1 = makeBurger(name: "a name", imageURL: URL(string:"http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBurgerLoading(with: [burger0, burger1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expecte no cancelled image URL until the image is not visible")
        
        sut.simulateBurgerViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [burger0.imageURL],
                       "Expected one image to be cancelled once the image is not visible")
        
        sut.simulateBurgerViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [burger0.imageURL, burger1.imageURL],
                       "Expected all the images to be cancelled once the second image is not visiblle")
    }
    
    
    func test_burgerViewLoadingIndicator_isVisibleWhenLoadingImage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBurgerLoading(with: [makeBurger(imageURL: anyURL),
                                            makeBurger(imageURL: anyURL)])
        
        let view0 = sut.simulateBurgerViewVisible(at: 0)
        let view1 = sut.simulateBurgerViewVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
    }
    
    func test_burgerView_rendersImageFromUrl() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBurgerLoading(with: [makeBurger(imageURL: anyURL),
                                            makeBurger(imageURL: anyURL)])
        
        let view0 = sut.simulateBurgerViewVisible(at: 0)
        let view1 = sut.simulateBurgerViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
    }
    
    func test_burgerViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBurgerLoading(with: [makeBurger(imageURL: anyURL),
                                            makeBurger(imageURL: anyURL)])
        
        let view0 = sut.simulateBurgerViewVisible(at: 0)
        let view1 = sut.simulateBurgerViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once second image loading completes with error")
    }
    
    func test_burgerRetryButton_isVisibleOnInvalidData() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBurgerLoading(with: [makeBurger(imageURL: anyURL)])
        
        let view = sut.simulateBurgerViewVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
        
        let invalidImageData = Data("invalid data".utf8)
        loader.completeImageLoading(with: invalidImageData)
        
        XCTAssertEqual(view?.isShowingRetryAction, true, "Expected retry button on successful load with invalid data")
    }
    
    func test_burgerViewRetryAction_retriesImageLoad() {
        let burger0 = makeBurger(imageURL: URL(string: "http://url-0.com")!)
        let burger1 = makeBurger(imageURL: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBurgerLoading(with: [burger0,
                                            burger1])
        
        let view0 = sut.simulateBurgerViewVisible(at: 0)
        let view1 = sut.simulateBurgerViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [burger0.imageURL, burger1.imageURL], "Expected two image URL request for the two visible views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [burger0.imageURL, burger1.imageURL], "Expected only two image URL requests before retry action")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [burger0.imageURL, burger1.imageURL, burger0.imageURL], "Expected third imageURL request after first view retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [burger0.imageURL, burger1.imageURL, burger0.imageURL, burger1.imageURL], "Expected fourth imageURL request after second view retry action")
    }
    
    func test_burgerView_preloadsImageURLWhenNearVisible() {
        let burger0 = makeBurger(imageURL: URL(string: "http://url-0.com")!)
        let burger1 = makeBurger(imageURL: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBurgerLoading(with: [burger0, burger1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")
        
        sut.simulateBurgerViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [burger0.imageURL], "Expected first image URL request once first image is near visible")
        
        sut.simulateBurgerViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [burger0.imageURL, burger1.imageURL], "Expected second image URL request once second image is near visible")
    }
    
    func test_burgerView_cancelImageURLPreloadingWhenNotNearVisibleAnymore() {
        let burger0 = makeBurger(imageURL: URL(string: "http://url-0.com")!)
        let burger1 = makeBurger(imageURL: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBurgerLoading(with: [burger0, burger1])
        XCTAssertEqual(loader.loadedImageURLs, [],
                       "Expected no cancelled image URL requests until image is near visible")
        
        sut.simulateBurgerViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [burger0.imageURL], "Expected first cancelled image URL once the image is no visible anymore")
        
        sut.simulateBurgerViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [burger0.imageURL, burger1.imageURL], "Expected second cancelled image URL request once second image not visible anymore")
    }
    
    func test_burgerImageView_doesNotRenderLoadeImageWhenIsNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeBurgerLoading(with: [makeBurger(imageURL: URL(string: "http://url-0.com")!)], at: 0)
        
        let view = sut.simulateBurgerViewNotVisible(at: 0)
        loader.completeImageLoading(with: UIImage.make(withColor: .red).pngData()!, at: 0)
        
        XCTAssertNil(view?.renderedImage)
    }
    
    func test_completeBurgerLoading_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "Wait for backgroud queue")
        DispatchQueue.global(qos: .background).async {
            loader.completeBurgerLoading()
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_completeImageLoading_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBurgerLoading(with: [makeBurger(imageURL: URL(string: "http://url-0.com")!)])
        _ = sut.simulateBurgerViewVisible(at: 0)
        
        let exp = expectation(description: "Wait for backgroud queue")
        DispatchQueue.global(qos: .background).async {
            loader.completeImageLoading()
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    private func assertThat(_ sut: BurgerListController,
                            isRendering burgers: [Burger],
                            file: StaticString = #file,
                            line: UInt = #line) {
        guard sut.numberOfRenderedBurgerListViews() == burgers.count else {
            return XCTFail("Expected \(burgers.count), got \(sut.numberOfRenderedBurgerListViews()) instead",
                           file: file,
                           line: line)
        }
        
        burgers.enumerated()
            .forEach({ assert(sut,
                              hasViewCofiguredFor: $1,
                              at: $0,
                              file: file,
                              line: line) })
    }
    
    private func assert(_ sut: BurgerListController,
                        hasViewCofiguredFor burger: Burger,
                        at index: Int,
                        file: StaticString = #file,
                        line: UInt = #line) {
        guard let view = sut.burgerImageView(at: index) else {
            XCTFail("Expected \(BurgerCell.self) instance",
                    file: file,
                    line: line)
            return
        }
        
        let isShowingburgerDescription = burger.description != nil
        XCTAssertEqual(view.isShowingDescription, isShowingburgerDescription,
                       "Expected 'isShowingDescription' to be \(isShowingburgerDescription) on burger at index: \(index)",
                       file: file,
                       line: line)
        
        XCTAssertEqual(view.descriptionText, burger.description,
                       "Expected 'descriptionText' to be \(String(describing: burger.description)), got \(String(describing: view.descriptionText))",
                       file: file,
                       line: line)
        
        XCTAssertEqual(view.nameText, burger.name,
                       "Expected 'nameText' to be \(burger.name), got \(String(describing: view.nameText))",
                       file: file,
                       line: line)
    }
    
    private func makeSUT(file: StaticString = #file,
                         line: UInt = #line)
    -> (sut: BurgerListController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = BurgerUIComposer.compose(burgerLoader: loader, imageLoader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut: sut, loader: loader)
    }
    
    private func makeBurger(name: String = "any name",
                            description: String? = nil,
                            imageURL: URL? = nil)
    -> Burger {
        Burger(id: UUID(), name: name, description: description, imageURL: imageURL)
    }
    
    class LoaderSpy: BurgerLoader, BurgerImageLoader {
        
        private(set) var burgerRequest = [(BurgerLoader.Result) -> Void]()
        
        var burgerRequestCallCount: Int {
            burgerRequest.count
        }
        
        // MARK: BurgerLoader
        func load(completion: @escaping (BurgerLoader.Result) -> Void) {
            burgerRequest.append(completion)
        }
        
        func completeBurgerLoading(with burgers: [Burger] = [], at index: Int = 0) {
            burgerRequest[index](.success(burgers))
        }
        
        func completeBurgerLoading(with error: Error, at index: Int = 0) {
            burgerRequest[index](.failure(error))
        }
        
        private struct TaskSpy: BurgerImageDataLoadTask {
            let cancelCallback: () -> Void
            
            func cancel() {
                cancelCallback()
            }
        }
        
        // MARK: BurgerImageLoader
        private var imageRequests = [(url: URL, completion: (BurgerImageLoader.Result) -> Void)]()
        
        var loadedImageURLs: [URL] {
            imageRequests.map { $0.url }
        }
        
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (BurgerImageLoader.Result) -> Void) -> BurgerImageDataLoadTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            imageRequests[index].completion(.failure(anyError))
        }
    }
}

private extension BurgerListController {
    
    @discardableResult
    func simulateBurgerViewVisible(at index: Int) -> BurgerCell? {
        return burgerImageView(at: index)
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateBurgerViewNotVisible(at row: Int) -> BurgerCell? {
        guard let view = simulateBurgerViewVisible(at: row) else { return nil }
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: burgerImageSection)
        
        delegate?.tableView?(tableView, didEndDisplaying: view, forRowAt: index)
        
        return view
    }
    
    func simulateBurgerViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: burgerImageSection)
        
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateBurgerViewNotNearVisible(at row: Int) {
        simulateBurgerViewNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: burgerImageSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    var isShowingLoadingIndicator: Bool? {
        refreshControl?.isRefreshing
    }
    
    func numberOfRenderedBurgerListViews() -> Int {
        tableView.numberOfRows(inSection: burgerImageSection)
    }
    
    func burgerImageView(at row: Int) -> BurgerCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: burgerImageSection)
        
        return ds?.tableView(tableView, cellForRowAt: index) as? BurgerCell
    }
    
    private var burgerImageSection: Int { 0 }
    
    var errorMessage: String? {
        return errorView?.message
    }
}

private extension BurgerCell {
    func simulateRetryAction() {
        burgerImageRetryButton.simulateTap()
    }
    
    var isShowingDescription: Bool {
        !descriptionLabel.isHidden
    }
    
    var isShowingImageLoadingIndicator: Bool {
        imageContainer.isShimmering
    }
    
    var isShowingRetryAction: Bool {
        return !burgerImageRetryButton.isHidden
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var nameText: String? {
        nameLabel.text
    }
    
    var renderedImage: Data? {
        return burgerImageView.image?.pngData()
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        }
    }
}

private extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        }
    }
}

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
