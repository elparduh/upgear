import Foundation

@MainActor
class LocationViewModel: ObservableObject {

  private let getLocationUseCase: GetLocationUseCase
  @Published var latitude: Double = 0.0
  @Published var longitude: Double = 0.0
  @Published var speed: Double = 0.0
  @Published var errorMessage: String?
  @Published var showPermissionAlert: Bool = false

  init(getLocationUseCase: GetLocationUseCase) {
    self.getLocationUseCase = getLocationUseCase

    self.getLocationUseCase.onLocationUpdated = { [weak self] lat, lon, speed in
      self?.latitude = lat
      self?.longitude = lon
      self?.speed = speed * 3.6
    }

    self.getLocationUseCase.onError = { [weak self] error in
      self?.errorMessage = error.localizedDescription
    }

    self.getLocationUseCase.onPermissionDenied = { [weak self] in
        self?.showPermissionAlert = true
    }
  }

  func startTracking() {
    getLocationUseCase.execute()
  }

  func stopTracking() {
    getLocationUseCase.stop()
  }
}
