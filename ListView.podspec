#
#  Be sure to run `pod spec lint ListView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "ListView"
  spec.version      = "0.0.1"
  spec.summary      = "Convinence way to create a view controller with UITableView/UICollectionView"
  spec.homepage     = 'https://github.com/zoka2305/ListView'
  spec.description  = <<-DESC
  You won't need to care about load more data, pull to refresh trigger action anymore.
  This project is in the early stage. DO NOT TRY TO USE THIS IN THE PRODUCTION APPLICATION.
                   DESC
  spec.license      = "MIT"
  spec.author       = { "Luong Van Lam" => "lam.luongvan2305@gmail.com" }
  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/zoka2305/ListView.git", :tag => spec.version.to_s  }

  spec.source_files  = "ListView/**/*.{swift}"
  #spec.exclude_files = "Classes/Exclude"

  spec.subspec 'libraries' do |lib|
    lib.dependency 'IGListKit'
    lib.dependency 'RxSwift'
    lib.dependency 'RxCocoa'
  end
end
