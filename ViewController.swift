//
//  SceneDelegate.swift
//  FindWay_Manpreet
//
//  Created by  user175413 on 14/06/20.
//  Copyright © 2020  user175413. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController , CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    var directionTransportType =  MKDirectionsTransportType()
    
    var destination: CLLocationCoordinate2D!

    @IBOutlet weak var map: MKMapView!
    
    
    
    @IBOutlet weak var transportSegmentBar: UISegmentedControl!
    
    
    var savedFavoritePlaceArr = [MKPlacemark]()
    
    var addedfavPlaceMark = MKPlacemark()
    
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = AppName
        
        directionTransportType = .walking;
        
        transportSegmentBar.setTitle("Walking", forSegmentAt: 0);
        transportSegmentBar.setTitle("Automobile", forSegmentAt: 1);
        
        transportSegmentBar.isHidden = true;
        
        map.delegate = self
        
    
        // we give the delegate of locationManager to this class
        locationManager.delegate = self
        
        // accuracy of the location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // request the user for the location access
        locationManager.requestWhenInUseAuthorization()
        
        // start updating the location of the user
        locationManager.startUpdatingLocation()
 
  
        // add double tap
        addDoubleTap()
        
    }
    

    
    //MARK: - long press gesture recognizer for the annotation
    @objc func addlongPressAnnotation(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        
        // add annotation
        let annotation = MKPointAnnotation()
        annotation.title = "My destination"
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
    }
    
    
    //MARK: - didupdatelocation method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        displayLocation(latitude: latitude, longitude: longitude, title: "Manpreet kaur Location", subtitle: "I'm Here")
        
        
    }
    
    //MARK: - display user location method
    func displayLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String, subtitle: String) {
        // 2 - define delta latitude and delta longitude for the span
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        // 3 - creating the span and location coordinate and finally the region
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        
        // 4 - set region for the map
        map.setRegion(region, animated: true)
    
    }
    
    //MARK: - double tap func
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        map.addGestureRecognizer(doubleTap)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        
        UIView.transition(with: transportSegmentBar, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.transportSegmentBar.isHidden = true
        })
        
         map.removeOverlays(map.overlays)
        
        removePin()
        
        // add annotation
        
        let touchPoint = sender.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        let annotation = MKPointAnnotation()
        annotation.title = "Destination Points"
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
        
        destination = coordinate
    }
    
    func removePin() {
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
    }
    
    @IBAction func drawDirection(_ sender: UIButton) {
       
        

        if destination == nil {
            
            let alertController = UIAlertController(title: AppName, message: "Please select your destination to double tap on Map.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
            
        }else{
            
            UIView.transition(with: transportSegmentBar, duration: 0.4, options: .transitionCrossDissolve, animations: {
                self.transportSegmentBar.isHidden = false;
            })
           
            GetRoute(directionTransportType: directionTransportType);
            
           
        }
    
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        
        let miles = Double(sender.value)
            let delta = miles / 50.0

            var currentRegion = map.region
            currentRegion.span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
            map.region = currentRegion

    }
    
        
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch transportSegmentBar.selectedSegmentIndex {
        case 0:
            
            directionTransportType = .automobile;
            GetRoute(directionTransportType: directionTransportType);
           
        case 1:
            
            directionTransportType = .walking;
            GetRoute(directionTransportType: directionTransportType);
           
        default:
            break;
        }
    }
     
    func GetRoute(directionTransportType : MKDirectionsTransportType ) {
        
         map.removeOverlays(map.overlays)
        
         let sourcePlaceMark = MKPlacemark(coordinate: locationManager.location!.coordinate)
        
            let destinationPlaceMark = MKPlacemark(coordinate: destination)
        
           
        
            // request a direction
            let directionRequest = MKDirections.Request()
            
            // define source and destination
            directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
            directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
            
            // transportation type
            directionRequest.transportType = directionTransportType;
            
            // calculate directions
            let directions = MKDirections(request: directionRequest)
            directions.calculate { (response, error) in
                guard let directionResponse = response else {return}
                // create route
                let route = directionResponse.routes[0]
                // draw the polyline
                self.map.addOverlay(route.polyline, level: .aboveRoads)
                
                // defining the bounding map rect
                let rect = route.polyline.boundingMapRect
                self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
            }
        }
    
    }
        

extension ViewController: MKMapViewDelegate {
    //MARK: - add viewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
    
        // add custom annotation with image
        let pinAnnotation = map.dequeueReusableAnnotationView(withIdentifier: "droppablePin") ?? MKPinAnnotationView()
        pinAnnotation.image = UIImage(named: "ic_place_2x")
        pinAnnotation.canShowCallout = true
        pinAnnotation.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return pinAnnotation
    }
    
    //MARK: - callout accessory control tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let alertController = UIAlertController(title: "Your Place", message: "Welcome", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Add to Favorite Place", style: .default) {
            UIAlertAction in
            NSLog("OK Pressed")
            
            
            // Add Destination in to fav Array
            self.savedFavoritePlaceArr.append(self.addedfavPlaceMark)
            // save data in Userdefault
            UserDefaults.standard.set(self.savedFavoritePlaceArr, forKey: "FavPlaces")
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - render for overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let rendrer = MKCircleRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.black.withAlphaComponent(0.5)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 2
            return rendrer
        } else if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = UIColor.blue
            rendrer.lineWidth = 3
            return rendrer
        } else if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.6)
            rendrer.strokeColor = UIColor.purple
            rendrer.lineWidth = 2
            return rendrer
        }
        return MKOverlayRenderer()
    }
}

