#
#  Be sure to run `pod spec lint SwiftDependencyInjector.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "SwiftDependencyInjector"
  spec.version      = "2.1.0"
  spec.summary      = "A native dependency container written in swift that manages dependency injection"

  spec.description  = <<-DESC
This CocoaPods library helps you to used dependency injection and inversion of control in your swift projects.
                   DESC

  spec.homepage     = "https://github.com/andresduke024/swift-dependency-injector.git"
  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "Andres Duque" => "andresduke024@gmail.com" }
  spec.social_media_url   = "https://github.com/andresduke024"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  spec.ios.deployment_target = "13.0"
  spec.osx.deployment_target = "10.15"
  spec.swift_version = "5.8"

  #  When using multiple platforms
  # spec.ios.deployment_target = "5.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  spec.source       = { :git => "https://github.com/andresduke024/swift-dependency-injector.git", :tag => "#{spec.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  spec.source_files  = "Sources/SwiftDependencyInjector/**/*"
  # spec.exclude_files = "Sources/Exclude"

end
