/// Jenis tantangan active liveness
enum FaceChallengeType {
  turnLeft('TURN_LEFT', 'Palingkan wajah ke kiri'),
  turnRight('TURN_RIGHT', 'Palingkan wajah ke kanan'),
  liftHead('LIFT_HEAD', 'Dongakkan kepala ke atas'),
  smile('SMILE', 'Senyum ke kamera'),
  blink('BLINK', 'Kedipkan kedua mata');

  final String code;
  final String label;

  const FaceChallengeType(this.code, this.label);
}

/// Threshold & konstanta deteksi liveness (sesuai spesifikasi PLN GAMA)
class LivenessConfig {
  LivenessConfig._();

  // Sudut Euler & Probabilitas
  static const double yawThreshold =
      20.0; // Palingkan kiri/kanan (|Euler Y| > 20)
  static const double tiltThreshold = 15.0; // Dongak kepala (Euler X > 15)
  static const double smileThreshold =
      0.65; // Senyum (smilingProbability >= 0.65)
  static const double eyeClosedThreshold = 0.35; // Mata tertutup
  static const double eyeOpenThreshold = 0.60; // Mata terbuka
  static const int maxBlinkTimeMs = 1500; // Jeda kedip maksimal

  // Posisi Wajah Lurus (Straight Face Point)
  static const double straightYaw = 5.0; // |Euler Y| < 5
  static const double straightRoll = 5.0; // |Euler Z| < 5
  static const int straightHoldDurationMs =
      500; // Tahan wajah lurus selama 500ms

  // Limit & Waktu
  static const int timeoutSeconds = 60; // Hitung mundur 60 detik
  static const int maxRetry = 20; // Batas percobaan gagal
  static const int processIntervalMs = 400; // Interval inferensi frame ML Kit
}

/// Data hasil challenge yang akan dikirim ke backend
class FaceChallengeResult {
  final FaceChallengeType type;
  final Map<String, dynamic> properties;

  FaceChallengeResult({required this.type, required this.properties});

  Map<String, dynamic> toJson() {
    return {'challenge': type.code, 'properties': properties};
  }
}
