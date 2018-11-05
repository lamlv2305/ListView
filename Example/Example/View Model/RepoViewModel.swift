//
//  RepoViewModel.swift
//  Example
//
//  Created by Luong Van Lam on 11/4/18.
//  Copyright © 2018 lamlv. All rights reserved.
//

import Foundation
import IGListKit
import ListView
import RxCocoa
import RxSwift

class RepoViewModel: ListViewModel<RepoModel> {
  override func getData(page: Int, pageSize: Int) -> Observable<[RepoModel]> {
    let template = "https://api.github.com/search/repositories?q=rx+language:swift&sort=stars&order=desc&page=%d&per_page=%d"
    let ulrString = String(format: template, page, pageSize)
    
    return Observable<[RepoModel]>.create { observer -> Disposable in
      let url = URL(string: ulrString)!
      let task = URLSession.shared.dataTask(with: url) { data, _, error in
        do {
          if let err = error {
            throw err
          }
          
          guard let data = data else {
            throw NSError(domain: #file, code: #line, userInfo: [NSLocalizedDescriptionKey: "Uknown data"])
          }
          
          let result = try JSONDecoder().decode(RepoResult.self, from: data)
          
          observer.onNext(result.items)
          observer.onCompleted()
          
        } catch {
          observer.onError(error)
        }
      }
      
      task.resume()
      
      return Disposables.create { task.cancel() }
    }
  }
}
