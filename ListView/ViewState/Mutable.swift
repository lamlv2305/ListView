//
//  Mutable.swift
//  ListView
//
//  Created by Luong Van Lam on 11/4/18.
//  Copyright © 2018 lamlv. All rights reserved.
//

import Foundation

public protocol Mutable {}

public extension Mutable {
  public func mutate(_ transform: (inout Self) -> Void) -> Self {
    var mutableSelf = self
    transform(&mutableSelf)
    return mutableSelf
  }
}
