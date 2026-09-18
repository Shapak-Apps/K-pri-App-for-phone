/// Feature flags for the camera module.
///
/// [kCameraEnabled] gates the real camera implementation behind the
/// "coming soon" experience. Flip it to `true` once the OCR + translation
/// pipeline is production-ready.
const bool kCameraEnabled = false;

/// The release in which camera translation is scheduled to ship.
/// Used across all "coming soon" copy to keep the version consistent.
const String kCameraComingSoonVersion = '2.0.0';
