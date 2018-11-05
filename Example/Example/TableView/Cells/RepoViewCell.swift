//
//  RepoViewCell.swift
//  Example
//
//  Created by Luong Van Lam on 11/5/18.
//  Copyright © 2018 lamlv. All rights reserved.
//

import UIKit

class RepoViewCell: UITableViewCell {
  
  @IBOutlet var lblInfo: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }
}
