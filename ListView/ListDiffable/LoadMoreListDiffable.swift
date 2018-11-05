//
//  LoadMoreListDiffable.swift
//  ListView
//
//  Created by Luong Van Lam on 11/5/18.
//

import Foundation
import IGListKit

public class LoadMoreListDiffable: NSObject, ListDiffable {
  public func diffIdentifier() -> NSObjectProtocol {
    return self
  }

  public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    return object is LoadMoreListDiffable
  }
}
