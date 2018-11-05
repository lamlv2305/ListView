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
  func isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
    return self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
  }
  
  func loadNextPageTrigger<T>(state: Driver<ListViewState<T>>) -> Signal<()> {
    return self.rx.contentOffset.asDriver()
      .filter { [weak self] _ -> Bool in
        guard let this = self else { return false }
        return this.contentSize.height > 0
      }
      .withLatestFrom(state)
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

open class ListViewController<T: ListDiffable, ViewModel: ListViewModel<T>>: UIViewController {
  /**
   *  Rx Variables
   */
  public let disposeBag = DisposeBag()
  
  public let reloadData = PublishSubject<ListViewStateOrder<T>>()
  
  /**
   *  UI Variables
   */
  public lazy var refreshControl = UIRefreshControl()
  
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
  
  public func prepareWith(scrollView: UIScrollView) {
    scrollView.addSubview(refreshControl)
    
    let refreshCommand = refreshControl.rx.controlEvent(.valueChanged)
      .flatMap { [weak self] _ -> Observable<ListViewCommand> in
        guard
          let refreshing = self?.refreshControl.isRefreshing,
          refreshing
        else { return Observable.never() }
        
        return Observable.just(ListViewCommand.refresh)
      }
    
    let loadMoreCommand = scrollView.loadNextPageTrigger(state: viewModel.viewState.asDriver())
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
      .bind(to: reloadData)
      .disposed(by: viewModel.disposeBag)
  }
}
