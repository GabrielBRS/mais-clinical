fn main() -> Result<(), Box<dyn std::error::Error>> {
    let protos = [
        "proto/agent.proto",
        "proto/common.proto",
        "proto/inference.proto",
        "proto/retrieval.proto",
    ];

    for proto in protos {
        println!("cargo:rerun-if-changed={proto}");
    }

    tonic_prost_build::configure()
        .build_client(true)
        .build_server(true)
        .compile_protos(&protos, &["proto"])?;

    Ok(())
}
