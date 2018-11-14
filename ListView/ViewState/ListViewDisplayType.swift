//
//  ListViewDisplayType.swift
//  ListView
//
//  Created by Luong Van Lam on 11/4/18.
//  Copyright © 2018 lamlv. All rights reserved.
//

import Foundation

public enum ListViewDisplayType: Equatable {
  case loading
  case loadmore
  case empty
  case error(msg: String)
  case complete
  
  public static func == (lhs: ListViewDisplayType, rhs: ListViewDisplayType) -> Bool {
    switch (lhs, rhs) {
    case (.loading, .loading): return true
    case (.loadmore, .loadmore): return true
    case (.empty, .empty): return true
    case (.complete, .complete): return true
    case (.error(let first), .error(let second)): return first == second
    default: return false
    }
  }
}

public enum ListViewCommand: Int {
  case initial
  case loadMoreItems
  case refresh
  
  func nextPage(items: Int, pageSize: Int, firstPageIndex: Int) -> Int {
    guard self == .loadMoreItems else { return firstPageIndex }
    
    return items / pageSize + firstPageIndex
  }
}
