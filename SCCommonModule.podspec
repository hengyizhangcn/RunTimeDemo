#
# Be sure to run `pod lib lint SCCommonModule.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SCCommonModule'
  s.version          = '1.0.2.23'
  '1.0.2.14'
  s.summary          = 'A short description of SCCommonModule.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/jianyingwan/SCCommonModule'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jianying.wan' => 'jianying.wan@uama.com.cn' }
  s.source           = { :git => 'http://git.uama.com.cn:8888/base/SCCommonModule.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.user_target_xcconfig = { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }



  s.subspec 'Marco' do |ss|
      ss.source_files = 'SCCommonModule/Classes/*'
  end

  s.subspec 'Base' do |ba|
      ba.source_files = 'SCCommonModule/Classes/Base/*'
  end

  s.subspec 'Category' do |ca|
      ca.subspec 'AESEncrypt' do |aes|
          aes.source_files = 'SCCommonModule/Classes/Category/AESEncrypt/*'
      end

      ca.subspec 'NSNumer' do |num|
          num.dependency 'SCCommonModule/Marco'
          num.source_files = 'SCCommonModule/Classes/Category/NSNumber/*'
      end

      ca.subspec 'NSString' do |str|
          str.source_files = 'SCCommonModule/Classes/Category/NSString/*'
      end

      ca.subspec 'SVProgressHUD' do |hud|
          hud.dependency 'SCCommonModule/Marco'
          hud.source_files = 'SCCommonModule/Classes/Category/SVProgressHUD/*'
      end

      ca.subspec 'UIImage' do |img|
          img.source_files = 'SCCommonModule/Classes/Category/UIImage/*'
      end

      ca.subspec 'UIView' do |v|
          v.source_files = 'SCCommonModule/Classes/Category/UIView/*'
      end

      ca.source_files = 'SCCommonModule/Classes/Category/*'
  end

  s.subspec 'Helper' do |ss|
      ss.dependency 'SCCommonModule/Marco'
      ss.dependency 'SCCommonModule/Category/SVProgressHUD'
      ss.dependency 'SCCommonModule/Utils/MGTemplateEngine'
      ss.dependency 'SCCommonModule/Category/NSString'
      ss.dependency 'SCCommonModule/Category/AESEncrypt'
      ss.source_files = 'SCCommonModule/Classes/Helper/*'
  end

  s.subspec 'Utils' do |u|
      u.subspec 'GTMBase64' do |g|
          g.source_files = 'SCCommonModule/Classes/Utils/GTMBase64/*'
      end

      u.subspec 'ChineseSort' do |cs|
          cs.source_files = 'SCCommonModule/Classes/Utils/ChineseSort/*'
      end

      u.subspec 'MGTemplateEngine' do |mg|
          mg.source_files = 'SCCommonModule/Classes/Utils/MGTemplateEngine/**/*'
      end

      u.subspec 'SCRouter' do |router|
          router.source_files = 'SCCommonModule/Classes/Utils/SCRouter/*'
      end
  end

  s.subspec 'General' do |g|
      g.subspec 'EmptyDataSet' do |em|
          em.dependency 'SCCommonModule/Base'
          em.source_files = 'SCCommonModule/Classes/General/EmptyDataSet/*'
      end

      g.source_files = 'SCCommonModule/Classes/General/*'
  end

  s.subspec 'CommonUI' do |ss|
      ss.subspec 'SCBottomPickView' do |bpv|

          bpv.dependency 'SCCommonModule/Marco'
          bpv.source_files = 'SCCommonModule/Classes/CommonUI/SCBottomPickView/*.{h,m}'
          bpv.resources = ['SCCommonModule/Classes/CommonUI/SCBottomPickView/**/*.png']
      end

      ss.subspec 'CustomTextField' do |ctf|
          ctf.source_files = 'SCCommonModule/Classes/CommonUI/CustomTextField/*'
      end
      ss.subspec 'UnderlineButton' do |sss|
         sss.source_files = 'SCCommonModule/Classes/CommonUI/UnderlineButton/*'
      end
      ss.subspec 'JSMessageText' do |jsm|
          jsm.source_files = 'SCCommonModule/Classes/CommonUI/JSMessageText/*'
      end
      ss.subspec 'LCCustomRefresh' do |refresh|
          refresh.source_files = 'SCCommonModule/Classes/CommonUI/LCCustomRefresh/*'
      end
      ss.subspec 'SCCustomScanner' do |scanner|
          scanner.source_files = 'SCCommonModule/Classes/CommonUI/SCCustomScanner/*.{h,m}'
          scanner.resources = ['SCCommonModule/Classes/CommonUI/SCCustomScanner/**/*.png']
      end
      ss.subspec 'TSMessage' do |tsm|
          tsm.subspec 'Classes' do |cs|
            cs.dependency 'SCCommonModule/Marco'
            cs.source_files = 'SCCommonModule/Classes/CommonUI/TSMessage/Classes/*'
          end

          tsm.subspec 'Assets' do |ass|
            ass.resources = ['SCCommonModule/Classes/CommonUI/TSMessage/Assets/*.png', 'SCCommonModule/Classes/CommonUI/TSMessage/Assets/*.json']
          end
      end
      ss.subspec 'VerticalScrollview' do |vsc|
          vsc.dependency 'SCCommonModule/Category'
          vsc.source_files = 'SCCommonModule/Classes/CommonUI/VerticalScrollview/*'
      end
  end

  # s.resource_bundles = {
  #   'SCCommonModule' => ['SCCommonModule/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'

    s.frameworks = 'UIKit'
    s.dependency 'ReactiveCocoa', '~> 2.5'
    s.dependency 'Masonry', '~> 1.1.0'
    s.dependency 'MJRefresh', '~> 3.1.0'
    s.dependency 'MJExtension', '~> 3.0.9'
    s.dependency 'Colours', '~> 5.12.0'
    s.dependency 'UITextView+Placeholder', '~> 1.1.0'
    s.dependency 'SVProgressHUD', '~> 2.0.3'
    s.dependency 'DZNEmptyDataSet', '~> 1.7.3'
    s.dependency 'BlocksKit', '2.2.3'
    s.dependency 'MGJRouter', '~> 0.9.3'
end
