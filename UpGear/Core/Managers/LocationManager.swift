import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {

  static let shared = LocationManager()

  private let locationManager = CLLocationManager()
  var onPermissionDenied: (() -> Void)?
  var onPermissionGranted: (() -> Void)?
  var onLocationUpdate: ((CLLocation) -> Void)?
  var onError: ((Error) -> Void)?

  private override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    locationManager.distanceFilter = kCLDistanceFilterNone
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
    guard let location = locations.last else { return }
    onLocationUpdate?(location)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    onError?(error)
  }
}
