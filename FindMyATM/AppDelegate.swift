//
//  AppDelegate.swift
//  FindMyATM
//
//  Created by Jasmin Abou Aldan on 11/01/15.
//  Copyright (c) 2015 Jasmin Abou Aldan. All rights reserved.
//

import UIKit
import Parse
import CoreSpotlight
import MobileCoreServices


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var adView: MPAdView?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        //MARK: Connection to Parse.com
        Parse.setApplicationId("9PRc2dDa2Ld94x68yuCulqWQIaMO1768dbS8SFXU", clientKey: "nAz94MTAVp9FRNmjUVYsfQAvdWqRhQTVw8H0SHoZ")
        
        //MARK: Parse.com analytics
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
        
        PFAnonymousUtils.logInWithBlock{
            (user: PFUser?, error: NSError?) -> Void in
            
            if error != nil {
                NSLog("Anonymous login failed.")
            }
            else {
                NSLog("Anonymous user logged in.")
            }
            
        }
        
        adView = MPAdView(adUnitId: "024031c116fd4bb78630a444f48fb096", size: MOPUB_BANNER_SIZE)
        
        //MARK: Status and navigation bar colors
        UINavigationBar.appearance().barTintColor = UIColor(red: 33/255.0, green: 150/255.0, blue: 243/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        let titleColor: NSDictionary = [NSForegroundColorAttributeName: UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)]
        UINavigationBar.appearance().titleTextAttributes = titleColor as? [String: AnyObject]
        
        //MARK: App indexing for Core Spotlight
        if #available(iOS 9.0, *){

            let url = NSBundle.mainBundle().URLForResource("BankList", withExtension: "plist")
            let data = NSDictionary(contentsOfURL: url!)
        
            for (var i = 0 ; i<data?.count ; i++){
            
                let oneData = data?.valueForKey("\(i)") as! Array<String>
            
            
                let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeData as String)
                attributeSet.title = oneData[0]
                attributeSet.contentDescription = oneData[1]
                attributeSet.thumbnailData = NSData(data: UIImagePNGRepresentation(UIImage(named: oneData[2])!)!)
                
                let item = CSSearchableItem(uniqueIdentifier: "\(i)", domainIdentifier: nil, attributeSet: attributeSet)
                
                CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([item]) { error in
                    
                    if error != nil {
                        print(error?.localizedDescription)
                    }
                    else {
                        print("Item indexed.")
                    }
                }
            }
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    @available(iOS 8.0, *)
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        
        if #available(iOS 9.0, *){
            
            if userActivity.activityType == CSSearchableItemActionType {
                
                if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                    
                    //Set coreSpotlight true, so that function inside viewDidLoad can be called
                    coreSpotlight = true
                    indexNumber = Int(uniqueIdentifier)
                    
                    //Instantiation of ViewController
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialViewController = storyboard.instantiateViewControllerWithIdentifier("MainVC") as UIViewController
                    self.window?.rootViewController = initialViewController
                    self.window?.makeKeyAndVisible()
                    
                }
                
            }
        }

        return true
    }
}

