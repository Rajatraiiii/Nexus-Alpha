export async function saveReadingToBackend(payload: any) {

  console.log("========== API SERVICE CALLED ==========");
  console.log("Original Payload:", payload);

  const backendPayload = {

    meter_id: payload.meterSerial,

    latitude: payload.gps?.latitude ?? 0,

    longitude: payload.gps?.longitude ?? 0,

    image_path:
      payload.imagePaths && payload.imagePaths.length > 0
        ? payload.imagePaths[0]
        : "no-image",

    ocr_reading: String(payload.currentReading),

    flag_reason:
      payload.flagStatus === "NORMAL"
        ? null
        : payload.flagStatus,

    processing_status:
      payload.flagStatus === "NORMAL"
        ? "COMPLETED"
        : "FLAG_REVIEW"
  };

  console.log("Backend Payload:");
  console.log(backendPayload);

  try {

    const response = await fetch(
      "http://127.0.0.1:8000/save-reading",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify(backendPayload)
      }
    );

    console.log("Response Status:", response.status);

    const result = await response.json();

    console.log("Response Data:", result);

    if (!response.ok) {
      throw new Error(
        result?.detail || `Backend Error ${response.status}`
      );
    }

    console.log("SUCCESSFULLY SAVED TO BACKEND");

    return result;

  } catch (error) {

    console.error("API ERROR:", error);

    throw error;
  }
}