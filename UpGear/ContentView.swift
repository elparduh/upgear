import SwiftUI

struct ContentView: View {
  @StateObject private var viewModel: LocationViewModel

  init() {
    let locationManager = LocationManager.shared
    let dataSource = LocationDataSource(locationManager: locationManager)
    let repository = LocationRepository(dataSource: dataSource)
    let useCase = GetLocationUseCase(repository: repository)
    _viewModel = StateObject(wrappedValue: LocationViewModel(getLocationUseCase: useCase))
  }

  var body: some View {
    VStack(spacing: 20) {
      Text("Latitud: \(viewModel.latitude)")
      Text("Longitud: \(viewModel.longitude)")
      Text("Velocidad: \(viewModel.speed, specifier: "%.0f") km/h")

      Button("Iniciar Seguimiento") {
        viewModel.startTracking()
      }

      Button("Detener Seguimiento") {
        viewModel.stopTracking()
      }
    }
    .padding()
    .alert("Permiso de Ubicación Requerido", isPresented: $viewModel.showPermissionAlert) {
      Button("Abrir Configuración") {
        viewModel.openSettings()
      }
      Button("Cancelar", role: .cancel) { }
    } message: {
      Text("Para usar la ubicación, debes habilitar los permisos en Configuración.")
    }
  }
}
