//
//  LocationManager.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 22/10/21.
//

import UIKit
import CoreLocation
/*
override func viewDidLoad() {
    super.viewDidLoad()
    //use below code snippet for your single tone location manager class in entire app where ever you want
    LocationManager.shared.start { (info) in
        debugPrint(info.longitude ?? 0.0)
        debugPrint(info.latitude ?? 0.0)
        debugPrint(info.address ?? "")
        debugPrint(info.city ?? "")
        debugPrint(info.zip ?? "")
    }

 LocationManager.shared.stop()
 
}
*/
class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    let locationManager : CLLocationManager
    var locationInfoCallBack: ((_ info:LocationInformation)->())!
    
    override init() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.distanceFilter = kCLLocationAccuracyHundredMeters
        super.init()
        locationManager.delegate = self
    }
    
    func startLocationAlways(locationInfoCallBack:@escaping ((_ info:LocationInformation)->())) {
        self.locationInfoCallBack = locationInfoCallBack
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func startLocationWhileAppInUse(locationInfoCallBack:@escaping ((_ info:LocationInformation)->())) {
        self.locationInfoCallBack = locationInfoCallBack
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    func GetCurrentLocation(locationInfoCallBack:@escaping ((_ info:LocationInformation)->())) {
        self.locationInfoCallBack = locationInfoCallBack
        locationManager.startUpdatingLocation()
    }
    
    func checkUsersLocationServicesAuthorization(SelectedViewController selectedViewController: BaseVC) {
        /// Check if user has authorized Total Plus to use Location Services
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                // Request when-in-use authorization initially
                // This is the first and the ONLY time you will be able to ask the user for permission
                //                self.locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
                break
                
            case .restricted, .denied:
                // Disable location features
                //                switchAutoTaxDetection.isOn = false
                let alert = UIAlertController(title: "Allow Location Access", message: "Location Services Disabled\nTo re-enable, please go to Settings and turn on Location Service for this app.", preferredStyle: UIAlertController.Style.alert)
                
                // Button to Open Settings
                alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            debugPrint("Settings opened: \(success)")
                        })
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
                selectedViewController.present(alert, animated: true, completion: nil)
                
                break
                
            case .authorizedWhenInUse, .authorizedAlways:
                // Enable features that require location services here.
                debugPrint("Full Access")
                //                self.locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
                locationManager.requestAlwaysAuthorization()
                break
            @unknown default:
                break
            }
        } else {
            debugPrint("Location services are not enabled")
            
            GlobalData.shared.displayConfirmationAlert(selectedViewController, title: "Alert", message: "Location Services Disabled\n Please enable user location", btnTitle1: "Cancel", btnTitle2: "Settings", actionBlock: { (isConfirmed) in
                if isConfirmed {
                    UIApplication.shared.open(URL(string: "App-Prefs:root=Privacy&path=LOCATION")! as URL, options: [:], completionHandler: nil)
                }
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //        locationManager.requestWhenInUseAuthorization()
        //        locationManager.requestAlwaysAuthorization()
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            //            locationManager.delegate = self
            //            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            //            locationManager.requestWhenInUseAuthorization()
            //            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        debugPrint(mostRecentLocation)
        
        let info = LocationInformation()
        info.latitude = mostRecentLocation.coordinate.latitude
        info.longitude = mostRecentLocation.coordinate.longitude
        
        //now fill address as well for complete information through lat long ..
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(mostRecentLocation) { (placemarks, error) in
            guard let placemarks = placemarks, let placemark = placemarks.first else { return }
            
            var addressString : String = ""
            if placemark.subLocality != nil {
                addressString = addressString + placemark.subLocality! + ", "
            }
            if placemark.thoroughfare != nil {
                addressString = addressString + placemark.thoroughfare! + ", "
            }
            if placemark.locality != nil {
                addressString = addressString + placemark.locality! + "-"
            }
            if placemark.postalCode != nil {
                addressString = addressString + placemark.postalCode! + ", "
            }
            if placemark.administrativeArea != nil {
                addressString = addressString + placemark.administrativeArea! + ", "
            }
            if placemark.country != nil {
                addressString = addressString + placemark.country! //+ ", "
            }
            info.formattedAddress = addressString
            
            if let city = placemark.locality,
                let state = placemark.administrativeArea,
                let zip = placemark.postalCode,
                let locationName = placemark.name,
                let thoroughfare = placemark.thoroughfare,
                let country = placemark.country {
                info.city     = city
                info.state    = state
                info.zip = zip
                info.address =  locationName + ", " + (thoroughfare as String)
                info.country  = country
            }
            self.locationInfoCallBack(info)
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint(error)
        locationManager.stopUpdatingLocation()
    }
}

class LocationInformation {
    var city:String?
    var address:String?
    var formattedAddress:String?
    var latitude:CLLocationDegrees?
    var longitude:CLLocationDegrees?
    var zip:String?
    var state :String?
    var country:String?
    init(city:String? = "",address:String? = "",formattedAddress:String? = "",latitude:CLLocationDegrees? = Double(0.0),longitude:CLLocationDegrees? = Double(0.0),zip:String? = "",state:String? = "",country:String? = "") {
        self.city    = city
        self.address = address
        self.formattedAddress = formattedAddress
        self.latitude = latitude
        self.longitude = longitude
        self.zip        = zip
        self.state = state
        self.country = country
    }
}
