class GetLocationUseCase {
  private let repository: LocationRepository
  var onLocationUpdated: ((Double, Double, Double) -> Void)?
  var onError: ((Error) -> Void)?
  var onPermissionDenied: (() -> Void)?

  init(repository: LocationRepository) {
    self.repository = repository
    self.repository.delegate = self
  }

  func execute() {
    repository.requestLocationPermission()
    repository.startTracking()
  }

  func stop() {
    repository.stopTracking()
  }
}


extension GetLocationUseCase : LocationRepositoryDelegate {

  func didUpdateLocation(latitude: Double, longitude: Double, speed: Double) {
    onLocationUpdated?(latitude, longitude, speed)
  }
  
  func didFailWithError(error: any Error) {
    onError?(error)
  }
  
  func didDenyPermission() {
    onPermissionDenied?()
  }
}
