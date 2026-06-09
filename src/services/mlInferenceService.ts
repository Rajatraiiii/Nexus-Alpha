// ============================================================
//  ML INFERENCE SERVICE  ←  OPEN SOCKET #0
//
//  ════════════════════════════════════════════════════════
//  YOUR ML TEAM: Implement IMLInferenceService and plug in here.
//  ════════════════════════════════════════════════════════
//
//  This service is responsible for:
//  1. Accepting a camera frame (image path)
//  2. Running the ML model inference
//  3. Returning predicted reading + confidence
//
//  The UI never makes direct model calls. It always goes through
//  this service, making it trivial to swap implementations.
// ============================================================

import type { IMLInferenceService, MLInferenceResult } from '../types';

/**
 * ════════════════════════════════════════════════════
 *  STUB IMPLEMENTATION
 *  Replace this with your actual ML model inference.
 *  
 *  Example wiring (TensorFlow.js):
 *    const model = await tf.loadLayersModel('path/to/model.json');
 *    const prediction = await model.predict(preprocessedFrame);
 *
 *  Example wiring (ONNX Runtime Web):
 *    const session = await ort.InferenceSession.create(modelPath);
 *    const results = await session.run(feeds);
 * ════════════════════════════════════════════════════
 */
const stubMLImplementation: IMLInferenceService = {
  async predictReading(imagePath: string): Promise<MLInferenceResult> {
    // STUB — Replace with real ML inference
    console.info('[MLInferenceService STUB] Processing frame:', imagePath);

    // Simulate ML latency (in production, this is actual model inference)
    await new Promise((resolve) => setTimeout(resolve, 1200));

    // Return synthetic result
    const reading = (Math.random() * 5000 + 100).toFixed(2);
    const confidence = 0.75 + Math.random() * 0.24; // 0.75–0.99

    return {
      readingValue: reading,
      confidence: Math.round(confidence * 1000) / 1000,
      processedImagePath: imagePath,
      meterSerialHint: 'MTR-2024-00847',
      inferenceTimestamp: new Date().toISOString(),
    };
  },
};

class MLInferenceServiceImpl implements IMLInferenceService {
  private _implementation: IMLInferenceService = stubMLImplementation;

  /**
   * ════════════════════════════════════════════════════
   *  PLUGIN POINT — Your ML team calls this ONCE on startup.
   *  
   *  Example (in your ML bootstrap, e.g. App.tsx):
   *    const myMLModel = await loadMyTensorFlowModel();
   *    MLInferenceService.registerImplementation({
   *      predictReading: async (imagePath) => {
   *        const frame = await readFrameFromPath(imagePath);
   *        const preprocessed = preprocessImage(frame);
   *        const logits = await myMLModel.predict(preprocessed);
   *        return {
   *          readingValue: parseReading(logits),
   *          confidence: logits.confidence,
   *          processedImagePath: imagePath,
   *          meterSerialHint: tryExtractSerial(logits),
   *          inferenceTimestamp: new Date().toISOString(),
   *        };
   *      }
   *    });
   * ════════════════════════════════════════════════════
   */
  registerImplementation(impl: IMLInferenceService): void {
    this._implementation = impl;
    console.info('[MLInferenceService] Custom ML implementation registered.');
  }

  /**
   * ════════════════════════════════════════════════════
   *  UI CONTRACT — The camera component calls this
   *  whenever a new frame is ready for ML inference.
   * ════════════════════════════════════════════════════
   */
  async predictReading(imagePath: string): Promise<MLInferenceResult> {
    return this._implementation.predictReading(imagePath);
  }
}

export const MLInferenceService = new MLInferenceServiceImpl();
