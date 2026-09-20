pub mod orchestrator {
    tonic::include_proto!("ai.orchestrator.v1");
}

#[cfg(test)]
mod tests {
    use prost::Message;

    use super::orchestrator::{HealthResponse, Status, StatusCode};

    #[test]
    fn health_contract_round_trips() {
        let response = HealthResponse {
            status: Some(Status {
                code: StatusCode::StatusOk.into(),
                message: "ready".to_owned(),
            }),
            version: "0.1.0".to_owned(),
            ready: true,
        };
        let bytes = response.encode_to_vec();
        let decoded = HealthResponse::decode(bytes.as_slice()).expect("valid protobuf");

        assert_eq!(decoded, response);
    }
}
