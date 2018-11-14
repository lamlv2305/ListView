//
//  ListViewController.swift
//  ListView
//
//  Created by Luong Van Lam on 11/4/18.
//  Copyright © 2018 lamlv. All rights reserved.
//

import IGListKit
import RxCocoa
import RxSwift
import UIKit

fileprivate extension UIScrollView {
  func isNearBottomEdge(edgeOffset: CGFloat = 44.0) -> Bool {
    return self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
  }
  
  func loadNextPageTrigger<T>(state: Driver<ListViewState<T>>) -> Signal<()> {
    return self.rx.contentOffset.asDriver()
      .withLatestFrom(state)
      .filter { state -> Bool in
        let displayType: [ListViewDisplayType] = [.loadmore, .complete]
        return state.shouldLoadNextPage && displayType.contains(state.displayType)
      }
      .flatMap { [weak self] currentState -> Signal<()> in
        guard let this = self else { return Signal.never() }
        let shouldLoad = currentState.shouldLoadNextPage
        let isNearBottom = this.isNearBottomEdge(edgeOffset: 20.0)
        
        return shouldLoad && isNearBottom
          ? Signal.just(())
          : Signal.never()
      }
  }
}

open class ListViewController<T: ListDiffable, ViewModel: ListViewModel<T>>: UIViewController, ListAdapterDataSource {
  /**
   *  Rx Variables
   */
  public let disposeBag = DisposeBag()
  
  /**
   *  UI Variables
   */
  public lazy var refreshControl = UIRefreshControl()
  
  public lazy var adapter: ListAdapter = {
    let adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    adapter.dataSource = self
    return adapter
  }()
  
  /**
   *  Internal
   */
  
  public let viewModel: ViewModel
  
  // MARK: - Body functions
  
  public init(viewModel: ViewModel, nibName: String?, bundle: Bundle? = nil) {
    self.viewModel = viewModel
    super.init(nibName: nibName, bundle: bundle)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  public func prepareWith(_ collectionView: UICollectionView) {
    adapter.collectionView = collectionView
    
    collectionView.addSubview(refreshControl)
    
    let refreshCommand = refreshControl.rx.controlEvent(.valueChanged)
      .flatMap { [weak self] _ -> Observable<ListViewCommand> in
        guard
          let refreshing = self?.refreshControl.isRefreshing,
          refreshing
        else { return Observable.never() }
        
        return Observable.just(ListViewCommand.refresh)
      }
    
    let loadMoreCommand = collectionView.loadNextPageTrigger(state: viewModel.viewState.asDriver())
      .flatMapLatest { _ -> Signal<ListViewCommand> in
        Signal.just(ListViewCommand.loadMoreItems)
      }
    
    Observable.merge(refreshCommand, loadMoreCommand.asObservable())
      .bind(to: viewModel.command)
      .disposed(by: disposeBag)
    
    viewModel.viewState
      .do(onNext: { _ in
        DispatchQueue.main.async { [weak self] in
          if let refresh = self?.refreshControl, refresh.isRefreshing {
            refresh.endRefreshing()
          }
        }
      })
      .distinctUntilChanged()
      .scan(ListViewStateOrder<T>(), accumulator: { result, newValue -> ListViewStateOrder<T> in
        result.mutate { $0.old = $0.new; $0.new = newValue }
      })
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] _ in
        self?.adapter.performUpdates(animated: true, completion: nil)
      })
      .disposed(by: viewModel.disposeBag)
  }
  
  open func sectionController(for object: T) -> ListSectionController {
    fatalError("You do not `override` this function yet.")
  }
  
  open func sectionController(for loadmore: LoadMoreListDiffable) -> ListSectionController {
    fatalError("You do not `override` this function yet.")
  }
  
  open func emptyView(for displayType: ListViewDisplayType, frame: CGRect) -> UIView? {
    return nil
  }
  
  // MARK: - ListAdapterDataSource
  
  /*
   
   We should make this ListAdapterDataSource to a separate file or some kind of this.
   But we can't extension generic swift class with @objc object, so just follow up with this way.
   
   */
  
  public final func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
    let availaleType: [ListViewDisplayType] = [.complete, .loadmore]
    let viewState = viewModel.viewState.value
    
    guard
      availaleType.contains(viewState.displayType),
      viewState.items.count > 0
    else { return [] }
    
    var current: [ListDiffable] = viewState.items
    
    if viewState.shouldLoadNextPage {
      current.append(LoadMoreListDiffable())
    }
    
    return current
  }
  
  public final func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
    if let obj = object as? LoadMoreListDiffable {
      return sectionController(for: obj)
    }
    
    if let obj = object as? T {
      return sectionController(for: obj)
    }
    
    fatalError("Check your object type. It does not valid: \(object)")
  }
  
  public final func emptyView(for listAdapter: ListAdapter) -> UIView? {
    guard let collectionView = listAdapter.collectionView else { return nil }
    
    return emptyView(for: viewModel.viewState.value.displayType, frame: collectionView.frame)
  }
}
