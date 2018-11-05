//
//  TableViewExample.swift
//  Example
//
//  Created by Luong Van Lam on 11/4/18.
//  Copyright © 2018 lamlv. All rights reserved.
//

import IGListKit
import ListView
import RxCocoa
import RxSwift
import UIKit

class TableViewExample: ListViewController<RepoModel, RepoViewModel> {
  @IBOutlet var tableView: UITableView!

  private lazy var dataSource: TableViewDataSource = {
    TableViewDataSource(viewModel: viewModel, viewController: self)
  }()

  init(viewModel: RepoViewModel) {
    super.init(viewModel: viewModel, nibName: "TableViewExample")
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Spin")
    tableView.register(UINib(nibName: "RepoViewCell", bundle: nil), forCellReuseIdentifier: "RepoViewCell")
    tableView.delegate = dataSource
    tableView.dataSource = dataSource

    tableView.tableFooterView = UIActivityIndicatorView(style: .gray)
    
    prepareWith(scrollView: tableView)

    reloadData.observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] _ in
        
        // Or you can use list diff to manual insert/delete here
        self?.tableView.reloadData()
      })
      .disposed(by: disposeBag)

    viewModel.command.accept(.initial)
  }
}
