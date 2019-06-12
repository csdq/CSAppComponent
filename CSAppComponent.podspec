#
# Be sure to run `pod lib lint CSAppComponent.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
# note: private pod <pod repo add REPO_NAME SOURCE_URL>

Pod::Spec.new do |s|
    s.name             = 'CSAppComponent'
    s.version          = '1.0.20'
    s.summary          = '大杂汇 一股脑儿集装'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    v1.0.0 自定义导航栏、视图、视图模型、数据模型等类和网络请求等基本工具
    v1.0.1 CSWebViewController loadURL(NSString) => loadURL(NSURL)
    v1.0.2 细节调整 & fix bug
    v1.0.3 自定义导航栏优化
    v1.0.4 增加通讯录索引字母栏 & CS_ADD_VIEW_AND_FULLFILL宏定义修改
    v1.0.5 修复内存泄漏和其他bug
    v1.0.6 增加文件下载和删除功能
    v1.0.7 修复CSDataModel 依赖版本写法错误
    v1.0.8 CSWebViewController增加webLoadFinishSubject 作为web加载完毕后的回调； 修改webSubject为webActionSubject
    v1.0.9 修改网络请求& View的Activity Indicator position bug 等
    v1.0.10 修改数据工具类 增加des加密/解密 ecb模式； 去除不需要的第三方库：
    v1.0.11 网络请求方法增加响应格式： json、xml等
    v1.0.12 密码强度检测方法修改
    v1.0.13 修改UIView+CSNotice 添加新的调用方法等
    v1.0.14 添加CSFlowlayoutView 无重用 多控件就内存爆炸的 自动流式布局
    v1.0.15 CSFlowlayoutView project ==> public
    v1.0.16 CSFlowlayoutView 添加subview protocol
    v1.0.17 修改CSNavViewController默认返回效果
    v1.0.18 修复CSDataTool  NSCalendar 错误地使用了台湾时间
    v1.0.19 CSDataTool  NSCalendar 使用西历NSCalendarIdentifierGregorian
    v1.0.20 去除部分警告
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
        ss.dependency 'CSDataModel', '> 1.1.1'
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
        ss.dependency 'CSDataModel', '> 1.1.1'
    end
    
    s.subspec 'Setting' do |ss|
        ss.source_files = 'Setting/Classes/**/*'
        ss.public_header_files = 'Setting/Classes/**/*.h'
        ss.dependency 'CSAppComponent/CSClass'
        ss.dependency 'CSDataModel', '> 1.1.1'
    end
    
    s.subspec 'Tool' do |ss|
        ss.source_files = 'Tool/Classes/**/*'
        ss.public_header_files = 'Tool/Classes/**/*.h'
        ss.dependency 'CSAppComponent/CSClass'
        ss.dependency 'CSAppComponent/Helper'
        ss.dependency 'CSAppComponent/Model'
        ss.dependency 'CSAppComponent/Setting'
        ss.dependency 'CSDataModel', '> 1.1.1'
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
    # File
    s.subspec 'File' do |ss|
        ss.source_files = 'File/Classes/**/*'
        ss.public_header_files = 'File/Classes/**/*.h'
        ss.dependency 'CSDataModel', '> 1.1.1'
        ss.dependency 'CSAppComponent/Tool'
    end
    
    s.resource_bundles = {
        'CSAppComponent' => ['CSAppComponent/Assets/**/*']
    }
    
    # s.public_header_files = 'Pod/Classes/**/*.h'
    # s.frameworks = 'UIKit', 'MapKit'
    #s.dependency 'MJRefresh', '~> 3.1.15.3'
    #s.dependency 'ProgressHUD', '~> 2.51'
    #s.dependency 'CocoaAsyncSocket', '~> 7.6.2'
    #s.dependency 'SDWebImage', '~> 4.3.3'
    #s.dependency 'QBImagePickerController'
end
