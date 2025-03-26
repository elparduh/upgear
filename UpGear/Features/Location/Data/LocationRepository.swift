protocol LocationRepositoryDelegate: AnyObject {
  func didUpdateLocation(latitude: Double, longitude: Double, speed: Double)
  func didFailWithError(error: Error)
  func didDenyPermission()
}

class LocationRepository {
  private let dataSource: LocationDataSource
  weak var delegate: LocationRepositoryDelegate?

  init(dataSource: LocationDataSource) {
    self.dataSource = dataSource
    self.dataSource.delegate = self
  }

  func requestLocationPermission() {
      dataSource.requestLocationPermission()
  }

  func startTracking() {
      dataSource.startUpdatingLocation()
  }

  func stopTracking() {
    dataSource.stopUpdatingLocation()
  }
}

extension LocationRepository: LocationDataSourceDelegate {

  func didUpdateLocation(latitude: Double, longitude: Double, speed: Double) {
    delegate?.didUpdateLocation(latitude: latitude, longitude: longitude, speed: speed)
  }

  func didFailWithError(error: any Error) {
    delegate?.didFailWithError(error: error)
  }

  func didDenyPermission() {
    delegate?.didDenyPermission()
  }
}
