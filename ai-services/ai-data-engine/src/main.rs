//! Binário fino: o wiring vive no composition root (`bootstrap`).

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    ai_data_engine::bootstrap::run().await
}
