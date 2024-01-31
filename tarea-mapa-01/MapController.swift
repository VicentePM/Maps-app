//
//  MapController.swift
//  tarea-mapa-01
//
//  Created by dam2 on 25/1/24.
//

import UIKit
import MapKit

class MapController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    /* Initial location */
    let initialLocation = CLLocation(latitude: 38.092711, longitude: -3.634971)
    
    /* Main region radius */
    let initialLocationDistance: CLLocationDistance = 35000
    
    /* Main Choords */
    let positoLocation = CLLocationCoordinate2D(latitude: 38.092711, longitude: -3.634971)
    let estechLocation = CLLocationCoordinate2D(latitude: 38.0941944, longitude: -3.6338287)
    let catedralLocation = CLLocationCoordinate2D(latitude: 37.9900947, longitude: -3.4713304)
    
    /* Annotations */
    var globalAnnotations: [ArtWork] = []
    
    /* Location Manager */
    var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeInitialConfig()
    }
    
    @IBAction func switchAction(_ sender: UISwitch) {
    
        if sender.isOn {
            centerMapOnLocation(location: initialLocation, locationDistance: 3000)
            showOnlyLinares()
        } else {
            centerMapOnLocation(location: initialLocation, locationDistance: initialLocationDistance)
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(globalAnnotations)
        }
    }
    
    @IBAction func createCustomAnnotation(_ sender: Any) {
        createAlertForCustomAnnotation()
    }
    
    /* Initial configuration */
    func makeInitialConfig() {
        
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        centerMapOnLocation(location: initialLocation, locationDistance: initialLocationDistance)
        createAnnotation(title: "El posito", discipline: "Centro de información turística", coordinate: positoLocation, isInLinares: true)
        createAnnotation(title: "Escuela Estech", discipline: "Centro de estudios", coordinate: estechLocation, isInLinares: true)
        createAnnotation(title: "Catedral de baeza", discipline: "Catedral", coordinate: catedralLocation, isInLinares: false)
        mapView.addAnnotations(globalAnnotations)
    }
    
    /* Center Map on Location */
    func centerMapOnLocation(location: CLLocation, locationDistance: CLLocationDistance) {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: locationDistance, longitudinalMeters: locationDistance)
        mapView.setRegion(region, animated: true)
    }
    
    /* Create annotation*/
    func createAnnotation(title: String, discipline: String, coordinate: CLLocationCoordinate2D, isInLinares: Bool) {
        let annotation = ArtWork(title: title, discipline: discipline, coordinate: coordinate, isInLinares: isInLinares)
        globalAnnotations.append(annotation)
    }
    
    /* Remove annotations outside Linares */
    func showOnlyLinares() {
        mapView.removeAnnotations(mapView.annotations)
        
        for annotation in globalAnnotations{
            if annotation.isInLinares {
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    /* Add custom annotation */
    func createAlertForCustomAnnotation() {
        let alertController = UIAlertController(title: "Añadir", message: "Añadir anotacion", preferredStyle: .alert)
        
        let aceptarInLinaresAction: UIAlertAction = UIAlertAction(title: "Crear en linares", style: .default, handler: { [self] (action) -> Void in
            
            guard let textFields = alertController.textFields else { return }
            
            if let nombre = textFields[0].text, let latitud = CLLocationDegrees(textFields[1].text ?? ""), let longitud = CLLocationDegrees(textFields[2].text ?? "") {
                let location = CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
                createAnnotation(title: nombre, discipline: "", coordinate: location, isInLinares: true)
                mapView.removeAnnotations(mapView.annotations)
                mapView.addAnnotations(globalAnnotations)
            }
            
        })
        
        let aceptarOutLinares: UIAlertAction = UIAlertAction(title: "Crear fuera de linares", style: .default, handler: { [self] (action) -> Void in
            
            guard let textFields = alertController.textFields else { return }
            
            if let nombre = textFields[0].text, let latitud = CLLocationDegrees(textFields[1].text ?? ""), let longitud = CLLocationDegrees(textFields[2].text ?? "") {
                let location = CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
                createAnnotation(title: nombre, discipline: "", coordinate: location, isInLinares: false)
                mapView.removeAnnotations(mapView.annotations)
                mapView.addAnnotations(globalAnnotations)
            }
            
        })
        
        let cancelarAction: UIAlertAction = UIAlertAction(title: "Cancelar", style: .cancel)
        
        alertController.addAction(aceptarInLinaresAction)
        alertController.addAction(aceptarOutLinares)
        alertController.addAction(cancelarAction)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Nombre"
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Latitud"
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Longitud"
        }
        
        self.present(alertController, animated: true)
    }
    
    /* Create Annotation with Mobile Location */
    @IBAction func createMobileLocationAnnotation(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Añadir", message: "Añadir anotacion", preferredStyle: .alert)
        
        let aceptarAction: UIAlertAction = UIAlertAction(title: "Crear anotacion con tu ubicacion", style: .default, handler: { [self] (action) -> Void in
            
            guard let textFields = alertController.textFields else { return }
            
            if let nombre = textFields[0].text {
                
                let location: CLLocationCoordinate2D = (locationManager?.location!.coordinate)!
                
                createAnnotation(title: nombre, discipline: "", coordinate: location, isInLinares: true)
                mapView.removeAnnotations(mapView.annotations)
                mapView.addAnnotations(globalAnnotations)
            }
            
        })
        
        
        let cancelarAction: UIAlertAction = UIAlertAction(title: "Cancelar", style: .cancel)
        
        alertController.addAction(aceptarAction)
        alertController.addAction(cancelarAction)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Nombre"
        }
        
        self.present(alertController, animated: true)
        
    }
    
}

extension MapController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? ArtWork else { return nil }
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            
            dequeuedView.annotation = annotation
            view = dequeuedView
            view.displayPriority = .required
            
            if !annotation.isInLinares { view.markerTintColor = .yellow }
            
        } else {
            
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.displayPriority = .required
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            if !annotation.isInLinares { view.markerTintColor = .yellow }
            
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let location = view.annotation as! ArtWork
        let lOptWalk = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        let lOptDrive = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        if location.title == "Escuela Estech" {
            if let url = URL(string: "https://www.escuelaestech.es") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        }
        
        if location.isInLinares {
            location.mapItem().openInMaps(launchOptions: lOptDrive)
        } else {
            location.mapItem().openInMaps(launchOptions: lOptWalk)
        }
    }
    
}

extension MapController: CLLocationManagerDelegate {
    
    /* Request Locations Functions */
    func requestLocation() {
        locationManager?.requestLocation()
    }
    
    func requestLocationUpdate() {
        locationManager?.startUpdatingLocation()
    }
    
    func stopLocationUpdate() {
        locationManager?.stopUpdatingLocation()
    }
    
    /* Permission of location */
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
    
    /* Get location Accurazy */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locations = locations.last else { return }
        print("Latitud: \(locations.coordinate.latitude), Longitud: \(locations.coordinate.longitude) (\(locations.horizontalAccuracy))")
        
        if(locations.horizontalAccuracy < 10) {
            self.stopLocationUpdate()
        }
    }
    
    /* Error getting location */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Se ha producido un error: \(error.localizedDescription)")
    }
    
}
