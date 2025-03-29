import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {

  static let shared = LocationManager()
  private var previousSpeed: Double = 0.0
  private var currentGear: Int = 1

  private let locationManager = CLLocationManager()
  var onPermissionDenied: (() -> Void)?
  var onPermissionGranted: (() -> Void)?
  var onLocationUpdate: ((CLLocation, Double, Int) -> Void)?
  var onError: ((Error) -> Void)?

  private override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    locationManager.distanceFilter = 1
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.pausesLocationUpdatesAutomatically = false
  }

  func requestLocationPermission() {
    let status = CLLocationManager().authorizationStatus

    switch status {
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
    case .authorizedWhenInUse, .authorizedAlways:
      onPermissionGranted?()
    case .denied, .restricted:
      onPermissionDenied?()
    default:
      break
    }
  }

  func startUpdatingLocation() {
    locationManager.startUpdatingLocation()
  }

  func stopUpdatingLocation() {
    locationManager.stopUpdatingLocation()
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    requestLocationPermission()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let newLocation = locations.last else { return }
    let newSpeed = max(0, newLocation.speed)
    if abs(newSpeed - previousSpeed) > 10 { return }
    previousSpeed = newSpeed
    let speedKmH = newSpeed * 3.6
    updateGear(speed: speedKmH)
    onLocationUpdate?(newLocation, speedKmH, currentGear)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    onError?(error)
  }

  private func updateGear(speed: Double) {
    switch currentGear {
    case 1:
      if speed >= 14 { currentGear = 2 } // Sube a segunda en 14 km/h
    case 2:
      if speed >= 28 { currentGear = 3 } // Sube a tercera en 28 km/h
      else if speed < 10 { currentGear = 1 } // Baja a primera en 10 km/h
    case 3:
      if speed < 27 { currentGear = 2 } // Baja a segunda en 26 km/h
    default:
      break
    }
  }
}
