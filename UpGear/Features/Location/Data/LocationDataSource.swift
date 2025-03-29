protocol LocationDataSourceDelegate: AnyObject {
  func didUpdateLocation(latitude: Double, longitude: Double, speed: Double)
  func didFailWithError(error: Error)
  func didDenyPermission()
}

class LocationDataSource {
  private let locationManager: LocationManager
  weak var delegate: LocationDataSourceDelegate?

  init(locationManager: LocationManager) {
    self.locationManager = locationManager

    self.locationManager.onLocationUpdate = { [weak self] location, speedValue in
      self?.delegate?.didUpdateLocation(
        latitude: location.coordinate.latitude,
        longitude: location.coordinate.longitude,
        speed: speedValue
      )
    }

    self.locationManager.onError = { [weak self] error in
      self?.delegate?.didFailWithError(error: error)
    }

    self.locationManager.onPermissionDenied = { [weak self] in
      self?.delegate?.didDenyPermission()
    }

    self.locationManager.onPermissionGranted = { [weak self] in
      self?.startUpdatingLocation()
    }
  }

  func requestLocationPermission() {
    locationManager.requestLocationPermission()
  }

  func startUpdatingLocation() {
    locationManager.startUpdatingLocation()
  }

  func stopUpdatingLocation() {
    locationManager.stopUpdatingLocation()
  }
}
