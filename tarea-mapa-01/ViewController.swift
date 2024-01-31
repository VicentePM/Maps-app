//
//  ViewController.swift
//  tarea-mapa-01
//
//  Created by dam2 on 22/1/24.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var switchButton: UIBarButtonItem!
    
    let positoChoords = CLLocationCoordinate2D(latitude: 38.092711, longitude: -3.634971)
    let estechChoords = CLLocationCoordinate2D(latitude: 38.09420601696138, longitude: -3.63124519770404)
    let catedralChoords = CLLocationCoordinate2D(latitude: 37.9900947, longitude: -3.4677252)
    let initialLocation = CLLocation(latitude: 38.045296, longitude: -3.539456)
    let regionRadius: CLLocationDistance = 17000 // 1000 metros
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        centerMapOnLocation(location: initialLocation)
        createAnnotation(title: "El posito", discipline: "Centro de información turística", coordinate: positoChoords, isInLinares: true)
        createAnnotation(title: "Escuela Estech", discipline: "Centro de estudios", coordinate: estechChoords, isInLinares: true)
        createAnnotation(title: "Catedral de baeza", discipline: "Catedral", coordinate: catedralChoords, isInLinares: false)
        
    }
    
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func createAnnotation(title: String, discipline: String, coordinate: CLLocationCoordinate2D, isInLinares: Bool) {
        let marker = Marker(title: title, discipline: discipline, coordinate: coordinate, isInLinares: isInLinares)
        mapView.addAnnotation(marker)
    }
    
    
    @IBAction func switchAction(_ sender: UISwitch) {
        
        if sender.isEnabled == true {
            let location = CLLocation(latitude: 38.09680189691598, longitude: -3.63660645739851)
            let regionRadiusLinares: CLLocationDistance = 2000
            
            let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadiusLinares, longitudinalMeters: regionRadiusLinares)
            
            mapView.setRegion(coordinateRegion, animated: true)
        } else {
            centerMapOnLocation(location: initialLocation)
        }
        
    }
    
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Marker else { return nil }
        
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
            view.displayPriority = .required
            
            if annotation.isInLinares == false {
                view.markerTintColor = .yellow
            }
            
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.displayPriority = .required
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            if annotation.isInLinares == false {
                view.markerTintColor = .yellow
            }
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Marker
        let launchOptionsWalking = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        let launchOptionsDriving = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        if view.annotation?.title == "Escuela Estech" {
            if let url = URL(string: "https://www.escuelaestech.es") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        }
        
        if location.isInLinares == false {
            location.mapItem().openInMaps(launchOptions: launchOptionsDriving)
        } else {
            location.mapItem().openInMaps(launchOptions: launchOptionsWalking)
        }
    }
}
