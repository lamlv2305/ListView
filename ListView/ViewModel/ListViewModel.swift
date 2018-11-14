//
//  ListViewModel.swift
//  ListView
//
//  Created by Luong Van Lam on 11/4/18.
//  Copyright © 2018 lamlv. All rights reserved.
//

import Foundation
import IGListKit
import RxCocoa
import RxSwift

open class ListViewModel<T: ListDiffable> {
  /**
   *  Rx Variables
   */
  private var apiBag = DisposeBag()
  
  public let disposeBag = DisposeBag()
  
  public let viewState = BehaviorRelay<ListViewState<T>>(value: ListViewState(state: .loading))
  
  public let command = PublishRelay<ListViewCommand>()
  
  /**
   *  Internal
   */
  public let itemPerPage: Int
  public let firstPageIndex: Int
  
  // MARK: - Body functions
  
  public init(firstPageIndex: Int = 1, itemPerPage: Int = 10) {
    self.firstPageIndex = firstPageIndex
    self.itemPerPage = itemPerPage
    
    renewSubscription()
  }
  
  public func item(at index: Int) -> T {
    guard viewState.value.items.count > index else {
      fatalError("Out of range. We have \(viewState.value.items.count) items")
    }
    return viewState.value.items[index]
  }
  
  private func renewSubscription() {
    apiBag = DisposeBag()
    
    var currentRequestPage = -1
    
    command
      .withLatestFrom(viewState) { (command: $0, state: $1) }
      .distinctUntilChanged { (first, second) -> Bool in
        if second.command == .refresh { return false }
        return first.command == second.command && first.state.items.isEqual(to: second.state.items)
      }
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
      .flatMapLatest { [weak self] fetching -> Observable<ListViewState<T>> in
        guard
          let this = self,
          let pageSize = self?.itemPerPage,
          let firstIndex = self?.firstPageIndex
        else { return Observable.never() }
        
        let page = fetching.command.nextPage(
          items: fetching.state.items.count,
          pageSize: pageSize,
          firstPageIndex: firstIndex
        )
        
        if currentRequestPage == page, fetching.command == .loadMoreItems {
          return Observable.never()
        }
        
        currentRequestPage = page
        let request = this.getData(page: page, pageSize: pageSize)
        return fetching.state.reduce(command: fetching.command, request: request, itemPerPage: pageSize)
      }
      .bind(to: viewState)
      .disposed(by: apiBag)
  }
  
  open func getData(page: Int, pageSize: Int) -> Observable<[T]> {
    fatalError("Error on implements fetching data at page: \(page) | paegSize: \(pageSize)")
  }
}
