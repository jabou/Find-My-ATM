//
//  ViewController.swift
//  FindMyATM
//
//  Created by Jasmin Abou Aldan on 11/01/15.
//  Copyright (c) 2015 Jasmin Abou Aldan. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import SystemConfiguration
import Parse
import CoreLocation
import CoreSpotlight

/**************************************************************************************************************/
//MARK: - Custom Point Annotation class
///Subclass from MKPointAnnotation class with support for pin image.

public class CustomPointAnnotation: MKPointAnnotation {
    var imageName: String!
}

/**************************************************************************************************************/
//MARK: - Public variable init

public var coreSpotlight: Bool = false
public var indexNumber: Int!

//MARK: - View Controller
class ViewController: UIViewController, SideMenuDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate, MKMapViewDelegate{
    
    /**********************************************************************************************************/
    //MARK: - Variable declaration
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var leftEdgeGestureView: UIView!
    
    var sideMenu: SideMenu = SideMenu()
    let manager = CLLocationManager()
    internal var dest: String!
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    let query = PFQuery(className: "FindMyATM")
    var myArray: Array<String>!
    
    /**********************************************************************************************************/
    //MARK: - Gesture recognizer
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /**********************************************************************************************************/
    //MARK: - Fitst internet connection check
    //If internet connection is not established, user will be warned
    
    override func viewDidAppear(animated: Bool) {
        if isConectedToNetwork() == false{
            InternetAlert().noInternetConnectionAllert(self)
        }
    }
    
    /**********************************************************************************************************/
    //MARK: - App setup in viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /******************************************************************************************************/
        //MARK: Setup navigation bar title and menu button
        
        self.navigationItem.title = "Find My ATM"
        let image: UIImage = UIImage(named: "menu.png")!
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("openMenuButtonTapped"))
        
        /******************************************************************************************************/
        //MARK: Gesture setup
        
        let showGestureRecognizer: UIScreenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "showSwipe:")
        showGestureRecognizer.edges = UIRectEdge.Left
        leftEdgeGestureView.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "hideSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(hideGestureRecognizer)

        /******************************************************************************************************/
        //MARK: Sidebar setup and fill
        
        let url = NSBundle.mainBundle().URLForResource("BankList", withExtension: "plist")
        let data = NSDictionary(contentsOfURL: url!)
        var items: Array<String> = []
        
        for (var i = 0 ; i<data?.count ; i++){
            
            let oneData = data?.valueForKey("\(i)") as! Array<String>
            items.append(oneData[0])
            
        }
        
        sideMenu = SideMenu(sourceView: self.view, menuItems: items)
        sideMenu.delegate = self
        
        /******************************************************************************************************/
        //MARK: Activity indicator setup
        
        activityIndicator.frame = CGRectMake(100, 100, 100, 100);
        activityIndicator.center = self.view.center
        activityIndicator.bringSubviewToFront(self.view)
        self.view.addSubview(activityIndicator)
        
        /******************************************************************************************************/
        //MARK: Maps setup
        
        mapView.mapType = MKMapType.Standard
        mapView.showsUserLocation = true
        mapView.showsPointsOfInterest = false
        mapView.showsBuildings = false
        
        if #available(iOS 8.0, *){
            mapView.pitchEnabled = true
        }
        else{
            mapView.pitchEnabled = false
        }
        
        mapView.delegate = self
        
        //Zoom on Rijeka
        let zoomLocation = CLLocationCoordinate2DMake(45.329899, 14.438163)
        let span = MKCoordinateSpanMake(0.032, 0.032)
        let region = MKCoordinateRegion(center: zoomLocation, span: span)
        mapView.setRegion(region, animated: true)

        /******************************************************************************************************/
        //MARK: Location manager setup
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest //acc in 5 m
        
        if #available(iOS 8.0, *){
            manager.requestWhenInUseAuthorization()
        }
        
        /******************************************************************************************************/
        //MARK: Fill map with data depending how it was launched
        /*
            If app was launched normaly
                show all ATMs on map
            else (app was launched from Core Spotlight)
                show selected index drom Core Spotlight
        */
        
        if coreSpotlight == false {
            sideMenuDidSelectButtonAtIndex(0, index: 0)
        }
        else {
            coreSpotlight = false
            sideMenuDidSelectButtonAtIndex(1, index: indexNumber)
        }

    }
    
    /**********************************************************************************************************/
    //MARK: - Location Manager Stop Updating Location
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
    }
    
    /**********************************************************************************************************/
    //MARK: - Map View Methods
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        //return nil so map view can draws blue dot for standard user location
        if annotation is MKUserLocation{
            return nil
        }
        
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
        
        if pinView == nil{
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            
            let button = UIButton(type: UIButtonType.InfoDark)
            pinView!.rightCalloutAccessoryView = button
            
        }
        else{
            pinView!.annotation = annotation
        }
        
        let annotationPicture = annotation as! CustomPointAnnotation
        pinView!.image = UIImage(named: annotationPicture.imageName)
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        switch CLLocationManager.authorizationStatus(){
        case .Denied, .NotDetermined, .Restricted:
            GPSAlert().locationAccessError(self)
        default:
            if #available(iOS 8.0, *){
                let navigation: UIAlertController = UIAlertController(title: NSLocalizedString("NAVIGATION", comment: "Navigation"), message: NSLocalizedString("START_NAVIGATION", comment: "Would you like to start navigation?"), preferredStyle: UIAlertControllerStyle.Alert)
                navigation.addAction(UIAlertAction(title: NSLocalizedString("YES", comment: "Yes"), style: .Default, handler: {action in
                    let latitude = annotationView.annotation!.coordinate.latitude
                    let longitude = annotationView.annotation!.coordinate.longitude
                    self.dest = "\(latitude),\(longitude)"
                    self.provideDirections(self.dest)
                }))
                navigation.addAction(UIAlertAction(title: NSLocalizedString("NO", comment: "No"), style: .Cancel, handler: nil))
                self.presentViewController(navigation, animated: true, completion: nil)
            }
            else{
                let latitude = annotationView.annotation!.coordinate.latitude
                let longitude = annotationView.annotation!.coordinate.longitude
                dest = "\(latitude),\(longitude)"
                
                let navigationAlert: UIAlertView = UIAlertView()
                navigationAlert.title = NSLocalizedString("NAVIGATION", comment: "Navigation")
                navigationAlert.message = NSLocalizedString("START_NAVIGATION", comment: "Would you like to start navigation?")
                navigationAlert.addButtonWithTitle(NSLocalizedString("YES", comment: "Yes"))
                navigationAlert.addButtonWithTitle(NSLocalizedString("NO", comment: "No"))
                navigationAlert.delegate = self
                navigationAlert.tag = 3
                navigationAlert.textInputContextIdentifier
                navigationAlert.show()
                
            }
        }
    }
    
    /**********************************************************************************************************/
    //MARK: - Start Navigation Method
    
    //For iOS 7 Navigation start
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
        if(View.tag == 3 && buttonIndex == 0){
            self.provideDirections(dest)
        }
            
        else if(View.tag == 4){
            self.openMenuButtonTapped()
        }
    }
    
    func provideDirections(dest: String){
        
        let destination = dest
        CLGeocoder().geocodeAddressString(destination, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            
            if error != nil {
                //some allert with error?
            }
            else{
                let request = MKDirectionsRequest()
                request.source = MKMapItem.mapItemForCurrentLocation()
                
                //Convert corelocation destination to mapkit placemark
                let placemark = placemarks!.first as CLPlacemark!
                let destinationCoordinates = placemark.location!.coordinate
                
                //get placemark of destination adress
                let destination = MKPlacemark(coordinate: destinationCoordinates, addressDictionary: nil)
                
                request.destination = MKMapItem(placemark: destination)
                
                //set transportation method to walking
                request.transportType = MKDirectionsTransportType.Any
                
                //get direction
                let directions = MKDirections(request: request)
                directions.calculateDirectionsWithCompletionHandler{(response: MKDirectionsResponse?, error: NSError?) -> Void in
                    
                    //display direction on Apple maps
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsMapTypeKey: MKMapType.Standard.rawValue]
                    MKMapItem.openMapsWithItems([response!.destination], launchOptions: launchOptions as? [String : AnyObject])
                    
                }
            }
        })
    }
    
    /**********************************************************************************************************/
    //MARK: - Side Menu Methods
    
    func openMenuButtonTapped() {
        
        if(sideMenu.isSideMenuOpen){
            closeSideMenu()
            mapView.scrollEnabled = true
        }
        else{
            if isConectedToNetwork(){
                sideMenu.showSideMenu(true)
                mapView.scrollEnabled = false
            }
            else{
                InternetAlert().noInternetConnectionAllert(self)
            }
        }
    }
    
    func closeSideMenu(){
        sideMenu.showSideMenu(false)
        mapView.scrollEnabled = true
    }
    
    func showSwipe(recognizer: UIScreenEdgePanGestureRecognizer){
        if(recognizer.state == UIGestureRecognizerState.Began){
            if isConectedToNetwork(){
                sideMenu.showSideMenu(true)
                mapView.scrollEnabled = false
            }
            else{
                InternetAlert().noInternetConnectionAllert(self)
            }
        }
    }
    
    func hideSwipe(recognizer: UISwipeGestureRecognizer){
        sideMenu.showSideMenu(false)
        mapView.scrollEnabled = true

    }
    
    func sideMenuDidSelectButtonAtIndex(section:Int, index: Int) {

        if section == 0{
            if index == 0{
                self.navigationItem.title = NSLocalizedString("ALL_ATMS", comment: "All atms")
                
                closeSideMenu()
                
                if(self.mapView.annotations.isEmpty == false){
                    self.mapView.removeAnnotations(self.mapView.annotations)
                }
                
                let zoomLocation = CLLocationCoordinate2DMake(45.329899, 14.438163)
                let span = MKCoordinateSpanMake(0.032, 0.032)
                let region = MKCoordinateRegion(center: zoomLocation, span: span)
                mapView.setRegion(region, animated: true)
                
                activityIndicator.startAnimating()
                let query = PFQuery(className: "FindMyATM")
                query.findObjectsInBackgroundWithBlock{
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    
                    if (error == nil){
                        
                        if let banks = objects as [PFObject]!{

                            for bank in banks {
                                
                                let bankName = bank.objectForKey("bank_name") as! String
                                let rawBankData = bank.objectForKey("addr_coo")
                                let tmpBankData = JSON(rawBankData!)
                                let bankData = tmpBankData.arrayObject as! Array<String>
                                
                                for data in bankData {
                                    let tmp = data.componentsSeparatedByString(",")
                                    
                                    let name = tmp[0]
                                    let latitude = tmp[1] as NSString
                                    let longitude = tmp[2] as NSString
                                    
                                    let lat = latitude.doubleValue
                                    let long = longitude.doubleValue
                                    
                                    let atm = CustomPointAnnotation()
                                    let atmCoordinates = CLLocationCoordinate2DMake(lat, long)
                                    atm.coordinate = atmCoordinates
                                    atm.title = name
                                    
                                    switch bankName{
                                    case "Banco Popolare":
                                        atm.imageName = "banco.png"
                                    case "BKS banka":
                                        atm.imageName = "bks.png"
                                    case "Croatia banka":
                                        atm.imageName = "croatia.png"
                                    case "Erste banka":
                                        atm.imageName = "erste.png"
                                    case "Hrvatska Poštanska Banka":
                                        atm.imageName = "hpb.png"
                                    case "Hypo Alpe Adria Bank":
                                        atm.imageName = "hypo.png"
                                    case "Istarska Kreditna Banka":
                                        atm.imageName = "ikb.png"
                                    case "Karlovačka banka":
                                        atm.imageName = "kaba.png"
                                    case "Kreditna banka Zagreb":
                                        atm.imageName = "kbz.png"
                                    case "OTP banka":
                                        atm.imageName = "otp.png"
                                    case "Partner banka":
                                        atm.imageName = "paba.png"
                                    case "Podravska banka":
                                        atm.imageName = "poba.png"
                                    case "Privredna Banka Zagreb":
                                        atm.imageName = "pbz.png"
                                    case "Raiffeisen bank":
                                        atm.imageName = "raiffeisen.png"
                                    case "Sberbank":
                                        atm.imageName = "sberbank.png"
                                    case "Slatinska banka":
                                        atm.imageName = "slatinska.png"
                                    case "Splitska banka":
                                        atm.imageName = "splitska.png"
                                    case "Veneto banka":
                                        atm.imageName = "veneto.png"
                                    case "Zagrebačka banka":
                                        atm.imageName = "zaba.png"
                                    default:
                                        print("Error geting pin picture")
                                    }

                                    self.mapView.addAnnotation(atm)
                                    
                                }
                            }
                        }
                        
                    } else {
                        print(error)
                    }
                }
                self.activityIndicator.stopAnimating()
            }
        }
        else {
            switch index{
                case 0:
                    self.navigationItem.title = "Banco Popolare"
                    if(self.mapView.annotations.isEmpty == false){
                        self.mapView.removeAnnotations(self.mapView.annotations)
                    }
                    let zoomLocation = CLLocationCoordinate2DMake(45.329899, 14.438163)
                    let span = MKCoordinateSpanMake(0.032, 0.032)
                    let region = MKCoordinateRegion(center: zoomLocation, span: span)
                    mapView.setRegion(region, animated: true)
                    
                    if #available(iOS 8.0, *){
                        let alert: UIAlertController = UIAlertController(title: NSLocalizedString("DID_YOU_KNOW", comment: "Did you know?"), message: NSLocalizedString("BANCO_POPOLARE", comment: "Members of Banco Populare can withdraw money from all OTP ATMs with no fee."), preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Cancel, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    else{
                        let bankAlert: UIAlertView = UIAlertView()
                        bankAlert.title = NSLocalizedString("DID_YOU_KNOW", comment: "Did you know?")
                        bankAlert.message = NSLocalizedString("BANCO_POPOLARE", comment: "Members of Banco Populare can withdraw money from all OTP ATMs with no fee.")
                        bankAlert.addButtonWithTitle(NSLocalizedString("OK", comment: "OK"))
                        bankAlert.show()
                    }
                    pins("Banco Popolare", ID: "kEqLoZmn8Z", picture: "banco")
                case 1:
                    pins("BKS banka", ID: "xHkyrXjBTB", picture: "bks")
                case 2:
                    pins("Croatia banka", ID: "RBuBuEu2bT", picture: "croatia")
                case 3:
                    pins("Erste bank", ID: "U0IZhZLpwT", picture: "erste")
                case 4:
                    pins("Hrvatska Poštanska Banka", ID: "7L5pwcUylL", picture: "hpb")
                case 5:
                    pins("Hypo Alpe Adria Bank", ID: "sSHwl21Dvr", picture: "hypo")
                case 6:
                    closeSideMenu()
                    self.navigationItem.title = "IMEX banka"
                    if #available(iOS 8.0, *){
                        let navigation: UIAlertController = UIAlertController(title: NSLocalizedString("DID_YOU_KNOW", comment: "Did you know?"), message: NSLocalizedString("IMEX", comment: "Members of IMEX bank can withdraw money with no fee from MBU or NMNet ATMs of: "), preferredStyle: UIAlertControllerStyle.Alert)
                        navigation.addAction(UIAlertAction(title: NSLocalizedString("ABOVE_BUTTON", comment: "Choose a bank included in the list above"), style: .Default, handler: {action in
                            self.openMenuButtonTapped()
                        }))
                        self.presentViewController(navigation, animated: true, completion: nil)
                    }
                    else{
                        let bankAlert: UIAlertView = UIAlertView()
                        bankAlert.title = NSLocalizedString("DID_YOU_KNOW", comment: "Did you know?")
                        bankAlert.message = NSLocalizedString("IMEX", comment: "Members of IMEX bank can withdraw money with no fee from MBU or NMNet ATMs of: ")
                        bankAlert.addButtonWithTitle(NSLocalizedString("ABOVE_BUTTON", comment: "Choose a bank included in the list above"))
                        bankAlert.tag = 4
                        bankAlert.delegate = self
                        bankAlert.show()
                    }
                case 7:
                    pins("Istarska Kreditna Banka", ID: "KFhRxYgGmX", picture: "ikb")
                case 8:
                    pins("Karlovačka banka", ID: "AKLfmoD6qW", picture: "kaba")
                case 9:
                    pins("Kreditna banka Zagreb", ID: "4DCOoZve2U", picture: "kbz")
                case 10:
                    pins("OTP banka", ID: "egT8IgXc5R", picture: "otp")
                case 11:
                    if #available(iOS 8.0, *){
                        let alert: UIAlertController = UIAlertController(title: NSLocalizedString("DID_YOU_KNOW", comment: "Did you know?"), message: NSLocalizedString("PARTNER_BANK", comment: "Members of Partner banka can withdraw money with no fee from all ATMs in MBNet system owned by Croatian banks."), preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Cancel, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    else{
                        let bankAlert: UIAlertView = UIAlertView()
                        bankAlert.title = NSLocalizedString("DID_YOU_KNOW", comment: "Did you know?")
                        bankAlert.message = NSLocalizedString("PARTNER_BANK", comment: "Members of Partner banka can withdraw money with no fee from all ATMs in MBNet system owned by Croatian banks.")
                        bankAlert.addButtonWithTitle(NSLocalizedString("OK", comment: "OK"))
                        bankAlert.show()
                    }
                    pins("Partner banka", ID: "CvMQ4N35E2", picture: "paba")
                case 12:
                    pins("Podravska banka", ID: "MRB5rSImOl", picture: "poba")
                case 13:
                    pins("Privredna Banka Zagreb", ID: "UOEc9OaCIm", picture: "pbz")
                case 14:
                    pins("Raiffeisen bank", ID: "R3p6mKOu2U", picture: "raiffeisen")
                case 15:
                    pins("Sberbank", ID: "GKYsoU95c7", picture: "sberbank")
                case 16:
                    pins("Slatinska banka", ID: "JmGNzNbcAk", picture: "slatinska")
                case 17:
                    pins("Splitska banka", ID: "adSDpX3AIA", picture: "splitska")
                case 18:
                    pins("Veneto banka", ID: "kVUv0tiGch", picture: "veneto")
                case 19:
                    pins("Zagrebačka banka", ID: "L2IssXYgJM", picture: "zaba")
                default:
                    closeSideMenu()
                }
        }
    }

    /**********************************************************************************************************/
    //MARK: - Connection with IBAction (my location button)
    ///When the button is pressed (if we have retrieved the location) zoom will be at the user's location.
    
    @IBAction func myLocation(sender: AnyObject) {
    
        switch CLLocationManager.authorizationStatus(){
        case .Denied, .NotDetermined, .Restricted:
            GPSAlert().locationAccessError(self)
        default:
            if mapView.userLocation.location == nil{
                GPSAlert().positionError(self)
            }
            else{
                let newRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpanMake(0.007, 0.007))
                mapView.setRegion(newRegion, animated: true)
            }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**********************************************************************************************************/
    //MARK: - Custom Functions
    //MARK: Placing pins
    ///Function for placing custom pins on the map.
    /// - Parameter name: Street name where ATM is located
    /// - Parameter ID: Bank ID for downloading data from Parse.com
    /// - Parameter picture: Picture name for pins
    
    func pins(name: String, ID: String, picture: String){
        
        closeSideMenu()
        self.navigationItem.title = name
        
        if(self.mapView.annotations.isEmpty == false){
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        
        let zoomLocation = CLLocationCoordinate2DMake(45.329899, 14.438163)
        let span = MKCoordinateSpanMake(0.032, 0.032)
        let region = MKCoordinateRegion(center: zoomLocation, span: span)
        mapView.setRegion(region, animated: true)
        
        activityIndicator.startAnimating()
        query.getObjectInBackgroundWithId(ID){
            (getData: AnyObject?, error: NSError?) -> Void in
            if (getData != nil && error == nil){
                
                let data = getData as! PFObject
                let take = data["addr_coo"]
                let json = JSON(take)
                self.myArray = json.arrayObject as! Array<String>
                
                for el in self.myArray {
                    
                    var tmp = el.componentsSeparatedByString(",")
                    
                    let ime = tmp[0]
                    let latitude = tmp[1] as NSString
                    let longitude = tmp[2] as NSString
                    
                    let lat = latitude.doubleValue
                    let long = longitude.doubleValue
                    
                    let atm = CustomPointAnnotation()
                    let atm_coordinates = CLLocationCoordinate2DMake(lat,long)
                    atm.coordinate = atm_coordinates
                    atm.title = ime
                    atm.imageName = picture
                    self.mapView.addAnnotation(atm)
                    
                }
            } else {
                print(error)
            }
            self.activityIndicator.stopAnimating()
        }
    }
    
    /**********************************************************************************************************/
    //MARK: Function for checking internet connection
    ///Function checks the internet connection and returns true or false value
    /// - Returns: Bool
    
    func isConectedToNetwork() -> Bool{
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == false {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable && !needsConnection)
    }
    
}
