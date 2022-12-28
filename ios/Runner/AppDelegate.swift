import UIKit
import Flutter
import GoogleMaps
import Firebase
import FirebaseCore
import flutter_local_notifications
import FirebaseMessaging    


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
   
     
    GMSServices.provideAPIKey("AIzaSyC9s5juB7LHmteq7EKunhCodywTVwd0mPo")
    // GeneratedPluginRegistrant.register(with: self)
  // FirebaseApp.configure()
if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
//     if #available(iOS 10.0, *) {
//   // For iOS 10 display notification (sent via APNS)
//   UNUserNotificationCenter.current().delegate = self
//   let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//   UNUserNotificationCenter.current().requestAuthorization(
//     options: authOptions,
//     completionHandler: { _, _ in }
//   )
// } else {
//   let settings: UIUserNotificationSettings =
//     UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//   application.registerUserNotificationSettings(settings)
// }
// application.registerForRemoteNotifications()


    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application:UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken:Data){
    Messaging.messaging().apnsToken=deviceToken 
    super.application(application,didRegisterForRemoteNotificationsWithDeviceToken:deviceToken)
  }
  

  
}

