import UIKit
import Flutter
import GoogleMaps
import Firebase
import FirebaseCore
import flutter_local_notifications
import FirebaseMessaging    

// @UIApplicationMain
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     GeneratedPluginRegistrant.register(with: self)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
   
     
    GMSServices.provideAPIKey("AIzaSyC9s5juB7LHmteq7EKunhCodywTVwd0mPo")
//    SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback(registerPlugins)
if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }


    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application:UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken:Data){
    Messaging.messaging().apnsToken=deviceToken 
    super.application(application,didRegisterForRemoteNotificationsWithDeviceToken:deviceToken)
  }
  
}

// here
func registerPlugins(registry: FlutterPluginRegistry) {
  GeneratedPluginRegistrant.register(with: registry)
}
