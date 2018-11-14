//
//  LoadMoreListDiffable.swift
//  ListView
//
//  Created by Luong Van Lam on 11/5/18.
//  Copyright © 2018 lamlv. All rights reserved.
//

import Foundation
import IGListKit

public class LoadMoreListDiffable: NSObject, ListDiffable {
  public override init() {
    super.init()
  }
  
  public func diffIdentifier() -> NSObjectProtocol {
    return self
  }

  public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    return object is LoadMoreListDiffable
  }
}
