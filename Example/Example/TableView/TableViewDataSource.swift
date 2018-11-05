//
//  TableViewDataSource.swift
//  Example
//
//  Created by Luong Van Lam on 11/5/18.
//  Copyright © 2018 lamlv. All rights reserved.
//

import Foundation
import ListView
import UIKit

class TableViewDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
  private let viewModel: RepoViewModel
  private weak var viewController: UIViewController?
  
  init(viewModel: RepoViewModel, viewController: UIViewController?) {
    self.viewModel = viewModel
    self.viewController = viewController
    super.init()
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    switch viewModel.viewState.value.displayType {
    case .complete, .loadmore:
      return 1
    default:
      // Depend on your loaing, empty, error type
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let extra = viewModel.viewState.value.shouldLoadNextPage ? 1 : 0
    
    return viewModel.viewState.value.items.count + extra
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.item == viewModel.viewState.value.items.count {
      return loadMoreCell(tableView: tableView, indexPath: indexPath)
    } else {
      return repositoryCell(tableView: tableView, indexPath: indexPath)
    }
  }
  
  func repositoryCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: "RepoViewCell",
      for: indexPath
    ) as? RepoViewCell else { fatalError() }
    
    let data = viewModel.viewState.value.items[indexPath.item]
    cell.lblInfo.text = "\(data.name)\n\(data.full_name)"
    
    return cell
  }
  
  func loadMoreCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Spin", for: indexPath)
    
    let indicator: UIActivityIndicatorView
    
    if let tmp = cell.viewWithTag(11) as? UIActivityIndicatorView {
      indicator = tmp
    } else {
      indicator = UIActivityIndicatorView(style: .gray)
      indicator.tag = 11
      
      cell.addSubview(indicator)
      indicator.translatesAutoresizingMaskIntoConstraints = false
      indicator.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
      indicator.topAnchor.constraint(equalTo: cell.topAnchor, constant: 16).isActive = true
      indicator.bottomAnchor.constraint(greaterThanOrEqualTo: cell.bottomAnchor, constant: -16).isActive = true
    }
    
    // Move to another to control indicator animation in the production code
    indicator.startAnimating()
    
    return cell
  }
}
