import Flutter
import UIKit
import GoogleMobileAds

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // AdMob 초기화
    GADMobileAds.sharedInstance().start(completionHandler: { status in
      #if DEBUG
      print("AdMob initialized with status: \(status)")
      #endif
    })
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
