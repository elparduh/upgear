import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {

  static let shared = LocationManager()
  private var previousSpeed: Double = 0.0

  private let locationManager = CLLocationManager()
  var onPermissionDenied: (() -> Void)?
  var onPermissionGranted: (() -> Void)?
  var onLocationUpdate: ((CLLocation, Double) -> Void)?
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
    onLocationUpdate?(newLocation, newSpeed)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    onError?(error)
  }
}
