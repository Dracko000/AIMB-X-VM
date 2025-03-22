pub const RELAYER: &str = "J5vXNkH5x4VQzCG7rE1sFqYzrkjL4uVX6Py5TnLSnX";

pub struct crosschain {
    pub relayer: &'static str,
}

impl crosschain {
    pub fn new() -> Self {
        Self { relayer: RELAYER }
    }
}
