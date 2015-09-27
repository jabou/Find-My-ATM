//
//  Alerts.swift
//  FindMyATM
//
//  Created by Jasmin Abou Aldan on 21/09/15.
//  Copyright © 2015 JaMaCo. Software. All rights reserved.
//

/*
All classes for handling alert views.
Alert view for:
    - No internet
    - Position Error
    - Location access
*/

import Foundation
import UIKit

/**************************************************************************************************************/
//MARK: - Class with method for opening App Settings
private class Open{
    private func settings(){
        if #available(iOS 8.0, *){
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }
    }
}

/**********************************************************************************************************/
//MARK: - Class with method for internet connection allerts
public class InternetAlert{
    
    public func noInternetConnectionAllert(view: UIViewController){
        
        if #available(iOS 8.0, *){
            let network: UIAlertController = UIAlertController(title: NSLocalizedString("NO_INTERNET", comment: "No internet connection"), message: NSLocalizedString("CHECK_INTERNET", comment: "Please check your internet connection and try again"), preferredStyle: UIAlertControllerStyle.Alert)
            network.addAction(UIAlertAction(title: NSLocalizedString("SETTINGS", comment: "Settings"), style: .Default, handler: {action in
                Open().settings()
            }))
            network.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .Cancel, handler: nil))
            view.presentViewController(network, animated: true, completion: nil)
        }
        else{
            let networkAlert: UIAlertView = UIAlertView()
            networkAlert.title = NSLocalizedString("NO_INTERNET", comment: "No internet connection")
            networkAlert.message = NSLocalizedString("CHECK_INTERNET", comment: "Please check your internet connection and try again")
            networkAlert.addButtonWithTitle(NSLocalizedString("OK", comment: "Ok"))
            networkAlert.tag = 1
            networkAlert.show()
        }
    }
}

/**********************************************************************************************************/
//MARK: - Class with methods for GPS and position allerts
public class GPSAlert{
    
    private func settings(){
        if #available(iOS 8.0, *){
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }
    }
    
    public func locationAccessError(view: UIViewController){
        if #available(iOS 8.0, *){
            let navigation: UIAlertController = UIAlertController(title: NSLocalizedString("GPS_ERROR", comment: "GPS error"), message: NSLocalizedString("ALLOW_ACCES", comment: "You need to allow location access"), preferredStyle: UIAlertControllerStyle.Alert)
            navigation.addAction(UIAlertAction(title: NSLocalizedString("SETTINGS", comment: "Settings"), style: .Default, handler: {action in
                Open().settings()
            }))
            navigation.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .Cancel, handler: nil))
            view.presentViewController(navigation, animated: true, completion: nil)
        }
        else{
            let gpsAlert: UIAlertView = UIAlertView()
            gpsAlert.title = NSLocalizedString("GPS_ERROR", comment: "GPS error")
            gpsAlert.message = NSLocalizedString("ALLOW_ACCES", comment: "You need to allow location access")
            gpsAlert.addButtonWithTitle(NSLocalizedString("OK", comment: "OK"))
            gpsAlert.tag = 2
            gpsAlert.show()
        }
    }
    
    public func positionError(view: UIViewController){
        if #available(iOS 8.0, *){
            let navigation: UIAlertController = UIAlertController(title: NSLocalizedString("POSITION_ERROR", comment: "Position error"), message: NSLocalizedString("LOCATION_UNAVAILABLE", comment: "User location not obtained yet. If this is repeated, check your settings"), preferredStyle: UIAlertControllerStyle.Alert)
            navigation.addAction(UIAlertAction(title: NSLocalizedString("SETTINGS", comment: "Settings"), style: .Default, handler: {action in
                self.settings()
            }))
            navigation.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .Cancel, handler: nil))
            view.presentViewController(navigation, animated: true, completion: nil)
        }
        else{
            let gpsAlert: UIAlertView = UIAlertView()
            gpsAlert.title = NSLocalizedString("POSITION_ERROR", comment: "Position error")
            gpsAlert.message = NSLocalizedString("LOCATION_UNAVAILABLE", comment: "User location not obtained yet. If this is repeated, check your settings")
            gpsAlert.addButtonWithTitle(NSLocalizedString("OK", comment: "OK"))
            gpsAlert.tag = 2
            gpsAlert.show()
        }
    }
}