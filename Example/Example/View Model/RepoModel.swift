//
//  RepoModel.swift
//  Example
//
//  Created by Luong Van Lam on 11/5/18.
//  Copyright © 2018 lamlv. All rights reserved.
//

import Foundation
import IGListKit

class RepoModel: NSObject, Codable, ListDiffable {
  let id: Int
  let name: String
  let full_name: String
  
  func diffIdentifier() -> NSObjectProtocol {
    return self
  }
  
  func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard let value = object as? RepoModel else { return false }
    return value.id == id
      && value.name == name
      && value.full_name == full_name
  }
}

struct RepoResult: Codable {
  let total_count: Int
  let items: [RepoModel]
}
