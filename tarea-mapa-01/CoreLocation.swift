//
//  CoreLocation.swift
//  tarea-mapa-01
//
//  Created by dam2 on 25/1/24.
//

import UIKit
import CoreLocation

class CoreLocation: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
    }
    
    func requestLocation() {
        locationManager?.requestLocation()
    }
    
    func requestLocationUpdate() {
        locationManager?.startUpdatingLocation()
    }
    
    func stopLocationUpdate() {
        locationManager?.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            print("El usuario aun no se ha decidido")
            locationManager?.requestAlwaysAuthorization()
        case .restricted:
            print("Restringido por control parental")
        case .denied:
            print("El usuario ha rechazado el permiso")
            locationManager?.requestAlwaysAuthorization()
        case .authorizedWhenInUse:
            print("EL usuario ha permitido usar la ubicacion mientras se usa la app")
            self.requestLocationUpdate()
        case .authorizedAlways:
            print("El usuario ha permitido usar la ubicacion siempre")
            self.requestLocationUpdate()
        default:
            print("El usuario ha restringido la ubicacion")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locations = locations.last else { return }
        print("Latitud: \(locations.coordinate.latitude), Longitud: \(locations.coordinate.longitude) (\(locations.horizontalAccuracy)")
        
        if(locations.horizontalAccuracy < 10) {
            self.stopLocationUpdate()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Se ha producido un error: \(error.localizedDescription)")
    }
    



}
