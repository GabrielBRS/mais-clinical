use std::{
    env,
    io::{Read, Write},
    net::{IpAddr, SocketAddr, TcpStream},
    time::Duration,
};

use ai_native_runtime::{
    VERSION,
    bootstrap::{AppState, RuntimeState},
    config::Settings,
    error::RuntimeError,
    infrastructure::agent::MojoAgentClient,
    observability,
    transport::http,
};
use tokio::{net::TcpListener, signal};
use tracing::info;

#[tokio::main]
async fn main() -> Result<(), RuntimeError> {
    let settings = Settings::load()?;

    if env::args().any(|argument| argument == "--healthcheck") {
        return healthcheck(settings.http_addr);
    }

    observability::init(&settings.log_level);
    let runtime = RuntimeState::new(VERSION);
    let agents = MojoAgentClient::new(&settings.mojo_runtime_url)
        .map_err(|error| RuntimeError::Internal(error.to_string()))?;
    let state = AppState::new(runtime, agents);
    let app = http::router(state.clone());
    let listener = TcpListener::bind(settings.http_addr).await?;
    let local_addr = listener.local_addr()?;
    state.runtime.mark_ready();

    info!(
        app = %settings.app_name,
        environment = %settings.app_env,
        listen = %local_addr,
        mojo_runtime_url = %settings.mojo_runtime_url,
        version = VERSION,
        "public Rust runtime ready"
    );

    let result = axum::serve(listener, app)
        .with_graceful_shutdown(shutdown_signal(state.clone()))
        .await;
    result.map_err(RuntimeError::from)
}

async fn shutdown_signal(state: AppState) {
    let ctrl_c = async {
        signal::ctrl_c()
            .await
            .expect("failed to install Ctrl+C handler");
    };

    #[cfg(unix)]
    let terminate = async {
        signal::unix::signal(signal::unix::SignalKind::terminate())
            .expect("failed to install SIGTERM handler")
            .recv()
            .await;
    };

    #[cfg(not(unix))]
    let terminate = std::future::pending::<()>();

    tokio::select! {
        () = ctrl_c => {},
        () = terminate => {},
    }
    state.runtime.mark_not_ready();
}

fn healthcheck(listen_addr: SocketAddr) -> Result<(), RuntimeError> {
    let address = SocketAddr::new(healthcheck_ip(listen_addr.ip()), listen_addr.port());
    let mut stream = TcpStream::connect_timeout(&address, Duration::from_secs(2))?;
    stream.set_read_timeout(Some(Duration::from_secs(2)))?;
    stream.set_write_timeout(Some(Duration::from_secs(2)))?;
    stream
        .write_all(b"GET /health/ready HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n")?;

    let mut response = String::new();
    stream.read_to_string(&mut response)?;
    if response.starts_with("HTTP/1.1 200") {
        Ok(())
    } else {
        Err(RuntimeError::HealthCheck(
            response
                .lines()
                .next()
                .unwrap_or("empty response")
                .to_owned(),
        ))
    }
}

fn healthcheck_ip(ip: IpAddr) -> IpAddr {
    if ip.is_unspecified() {
        match ip {
            IpAddr::V4(_) => IpAddr::V4(std::net::Ipv4Addr::LOCALHOST),
            IpAddr::V6(_) => IpAddr::V6(std::net::Ipv6Addr::LOCALHOST),
        }
    } else {
        ip
    }
}
