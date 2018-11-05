//
//  ListViewState.swift
//  ListView
//
//  Created by Luong Van Lam on 11/4/18.
//  Copyright © 2018 lamlv. All rights reserved.
//

import Foundation
import IGListKit
import RxCocoa
import RxSwift

public struct ListViewState<T: ListDiffable>: CustomStringConvertible {
  public var items: [T] = []
  
  public var shouldLoadNextPage: Bool = true
  public var error: Error?
  public var displayType: ListViewDisplayType
  
  public var description: String {
    let dict: [String: Any] = [
      "shouldLoadNextPage": shouldLoadNextPage,
      "error": String(describing: error),
      "viewState": displayType,
      "items": items.count
    ]
    return dict.map { "\($0.key) = \($0.value)" }.joined(separator: " | ")
  }
  
  public init(state: ListViewDisplayType) {
    self.displayType = state
  }
  
  func reduce(
    command: ListViewCommand,
    request: Observable<[T]>,
    itemPerPage: Int
  ) -> Observable<ListViewState<T>> {
    switch command {
    case .initial, .refresh:
      return request
        .flatMap { result -> Observable<ListViewState<T>> in
          Observable.just(self.mutate { current in
            current.items = result
            current.shouldLoadNextPage = result.count >= itemPerPage
            
            if result.count == 0 {
              current.displayType = .empty
            } else {
              current.displayType = current.shouldLoadNextPage ? .loadmore : .complete
            }
          })
        }
        .catchError { error -> Observable<ListViewState<T>> in
          Observable.just(self.mutate { current in
            current.displayType = ListViewDisplayType.error(msg: error.localizedDescription)
            current.shouldLoadNextPage = false
            current.items = []
          })
        }
      
    case .loadMoreItems:
      return request
        .flatMap { result -> Observable<ListViewState<T>> in
          Observable.just(self.mutate { current in
            current.items.append(contentsOf: result)
            current.shouldLoadNextPage = result.count >= itemPerPage
            current.displayType = result.count >= itemPerPage ? .loadmore : .complete
          })
        }
        .catchError { _ -> Observable<ListViewState<T>> in
          Observable.just(self.mutate { current in
            current.shouldLoadNextPage = false
            current.displayType = .complete
          })
        }
    }
  }
}

extension ListViewState: Mutable where T: ListDiffable {}

extension ListViewState: Equatable where T: ListDiffable {
  public static func == (lhs: ListViewState<T>, rhs: ListViewState<T>) -> Bool {
    let isEqualError: () -> Bool = {
      if lhs.error == nil, rhs.error == nil {
        return true
      }
      
      guard
        let leftError = lhs.error,
        let rightError = rhs.error
      else { return false }
      
      return (leftError as NSError).isEqual((rightError as NSError))
    }
    
    return lhs.items.isEqual(to: rhs.items)
      && isEqualError()
      && lhs.shouldLoadNextPage == rhs.shouldLoadNextPage
      && lhs.displayType == rhs.displayType
  }
}

extension Sequence where Iterator.Element: ListDiffable {
  func isEqual(to another: [ListDiffable]) -> Bool {
    let current = Array(self)
    
    guard current.count == another.count else { return false }
    
    return current.enumerated()
      .reduce(true) { result, data -> Bool in
        let rhsItem = another[data.offset]
        let isEqual = rhsItem.isEqual(toDiffableObject: data.element)
        return result && isEqual
      }
  }
}

public struct ListViewStateOrder<T: ListDiffable> {
  var old: ListViewState<T>?
  var new: ListViewState<T>?
  
  init() {}
}

extension ListViewStateOrder: Mutable where T: ListDiffable { }
