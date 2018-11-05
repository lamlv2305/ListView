//
//  Mutable.swift
//  ListView
//
//  Created by Luong Van Lam on 11/4/18.
//

import Foundation

protocol Mutable {}

extension Mutable {
  func mutate(_ transform: (inout Self) -> Void) -> Self {
    var mutableSelf = self
    transform(&mutableSelf)
    return mutableSelf
  }
}
