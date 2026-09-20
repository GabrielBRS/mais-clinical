use tonic::service::Routes;
use tonic_health::server::HealthReporter;

use crate::bootstrap::App;

/// Monta as rotas gRPC. Serviços gerados de proto/ entram aqui.
pub fn router(_app: App) -> (HealthReporter, Routes) {
    let (reporter, health_service) = tonic_health::server::health_reporter();
    (reporter, Routes::new(health_service))
}
