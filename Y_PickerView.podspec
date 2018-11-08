#
#  Be sure to run `pod spec lint Y_PickerView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  #名称
  s.name         = "Y_PickerView"
  #版本
  s.version      = "0.0.4"
  #简介
  s.summary      = "快速创建一个多种样式的 PickerView 选择器"
  #详介
  s.description  = <<-DESC
                   创建一个带有 UIDatePicker 或 UIPickerView 的选择器视图
                   DESC

  #首页
  s.homepage     = "https://github.com/1ilI/Y_PickerView"
  #截图
  s.screenshots  = "https://raw.githubusercontent.com/1ilI/Y_PickerView/master/Y_PickerView.gif"

  #开源协议
  s.license      = { :type => "MIT", :file => "LICENSE" }
  #作者信息
  s.author             = { "1ilI" => "1ilI" }
  #iOS的开发版本
  s.ios.deployment_target = "8.0"
  #源码地址
  s.source       = { :git => "https://github.com/1ilI/Y_PickerView.git", :tag => "#{s.version}" }
  #源文件所在文件夹，会匹配到该文件夹下所有的 .h、.m文件
  s.source_files  = "Y_PickerView", "Y_PickerView/**/*.{h,m}"
  #依赖的framework
  s.framework  = "UIKit"

end
