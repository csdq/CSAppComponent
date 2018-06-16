#
# Be sure to run `pod lib lint CSAppComponent.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
# note: private pod <pod repo add REPO_NAME SOURCE_URL>

Pod::Spec.new do |s|
    s.name             = 'CSAppComponent'
    s.version          = '1.0.0'
    s.summary          = '集成封装了常用库和基类'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    v1.0.0 自定义导航栏、视图、视图模型、数据模型等类和网络请求等基本工具
    DESC
    
    s.homepage         = 'https://github.com/csdq/CSAppComponent'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Mr.s' => 'stqemail@163.com' }
    s.source           = { :git => 'https://github.com/csdq/CSAppComponent.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.ios.deployment_target = '8.0'
    
    s.source_files = 'CSAppComponent/Classes/*'
    #stq自己的为打成lib的常用工具类
    s.subspec 'CSClass' do |ss|
        ss.source_files = 'CSClass/Classes/**/*'
        ss.public_header_files = 'CSClass/Classes/**/*.h'
        ss.dependency 'CSDataModel', '~> 1.0.0'
    end
    #helper 包含常用宏定义 错误定义等
    s.subspec 'Helper' do |ss|
        ss.source_files = 'Helper/Classes/**/*'
        ss.public_header_files = 'Helper/Classes/**/*.h'
        ss.dependency 'CSAppComponent/CSClass'
    end
    
    s.subspec 'Category' do |ss|
        ss.source_files = 'Category/Classes/**/*'
        ss.public_header_files = 'Category/Classes/**/*.h'
        ss.dependency 'CSAppComponent/CSClass'
        ss.dependency 'CSAppComponent/Setting'
    end
    
    s.subspec 'Controller' do |ss|
        ss.source_files = 'Controller/Classes/**/*'
        ss.public_header_files = 'Controller/Classes/**/*.h'
        ss.dependency 'CSAppComponent/CSClass'
        ss.dependency 'CSAppComponent/Category'
        ss.dependency 'CSAppComponent/Helper'
        ss.dependency 'CSAppComponent/Setting'
        ss.dependency 'CSAppComponent/View'
        ss.dependency 'ReactiveCocoa','~> 2.5.0'
        ss.dependency 'Masonry', '~> 1.1.0'
    end
    
    s.subspec 'Model' do |ss|
        ss.source_files = 'Model/Classes/**/*'
        ss.public_header_files = 'Model/Classes/**/*.h'
        ss.dependency 'CSAppComponent/CSClass'
        ss.dependency 'CSAppComponent/Helper'
        ss.dependency 'CSDataModel', '~> 1.0.0'
    end
    
    s.subspec 'Setting' do |ss|
        ss.source_files = 'Setting/Classes/**/*'
        ss.public_header_files = 'Setting/Classes/**/*.h'
        ss.dependency 'CSAppComponent/CSClass'
        ss.dependency 'CSDataModel', '~> 1.0.0'
    end
    
    s.subspec 'Tool' do |ss|
        ss.source_files = 'Tool/Classes/**/*'
        ss.public_header_files = 'Tool/Classes/**/*.h'
        ss.dependency 'CSAppComponent/CSClass'
        ss.dependency 'CSAppComponent/Helper'
        ss.dependency 'CSAppComponent/Model'
        ss.dependency 'CSAppComponent/Setting'
        ss.dependency 'CSDataModel', '~> 1.0.0'
        ss.dependency 'ReactiveCocoa','~> 2.5.0'
        ss.dependency 'AFNetworking', '~> 3.0'
    end
    
    s.subspec 'View' do |ss|
        ss.source_files = 'View/Classes/**/*'
        ss.public_header_files = 'View/Classes/**/*.h'
        ss.dependency 'CSAppComponent/Category'
        ss.dependency 'CSAppComponent/CSClass'
        ss.dependency 'CSAppComponent/Helper'
        ss.dependency 'CSAppComponent/ViewModel'
        ss.dependency 'CSAppComponent/Setting'
        ss.dependency 'ReactiveCocoa','~> 2.5.0'
        ss.dependency 'Masonry', '~> 1.1.0'
    end
    # 视图模型 基类
    s.subspec 'ViewModel' do |ss|
        ss.source_files = 'ViewModel/Classes/**/*'
        ss.public_header_files = 'ViewModel/Classes/**/*.h'
        ss.dependency 'CSAppComponent/CSClass'
    end
    
    s.resource_bundles = {
        'CSAppComponent' => ['CSAppComponent/Assets/**/*']
    }
    
    # s.public_header_files = 'Pod/Classes/**/*.h'
    # s.frameworks = 'UIKit', 'MapKit'
    s.dependency 'MJRefresh', '~> 3.1.15.3'
    s.dependency 'ProgressHUD', '~> 2.51'
    s.dependency 'CocoaAsyncSocket', '~> 7.6.2'
    s.dependency 'SDWebImage', '~> 4.3.3'
    s.dependency 'QBImagePickerController'
end
