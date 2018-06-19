## Steps
* After each step the project should build 👷 without errors ❌  
* Warnings ⚠️ are expected to appear until you complete all steps

### 1. Understanding the Core ML model 
Drag and drop the SneakersDetector.mlmodel to the Xcode project.
### 2. Vision API - Detection request

Create the detection request by passing the `visionModel` and `self.handleDetection` as arguments. `self.handleDetection` is already implemented below, so you just need to pass it as an argument.

Note: The detection request should be a VNCoreMLRequest. Vision has other types of requests used for built-in features such as detections of faces, barcodes, etc. However, VNCoreMLRequest is the one to be used when we want to perform predictions in CoreML models. The results are passed to the completionHandler passed in the initialization.

### 3. Send results to delegate
Get the results from the request object. They should be cast to VNCoreMLFeatureValueObservation.
Create the predictions using `self.predictions(from:confidenceThreshold:maxCount:)` and send them to the ObjectDetectorDelegate.

### 4. Understanding MLMultiArray - shape
Use shape property to get the number of boxes outputted by or model. After implementing `boxesCount` you can uncomment the definition of the `boxesPointer`

### 5. Understanding MLMultiArray - stride
Use stride property to properly infer the number of elements that compose the box.

### 6. Understanding bounding box
After Step 6 you can uncomment the code related to bounding box creation.
Take a time to understand how the bounding box properties are being accessed with the pointer. Also uncomment the `boundingBox `definition.

### 7. Create and append prediction to be returned
Create the prediction and add it to `unorderedPredictions`

### 8. Sort results
We should sort the `unorderedPredictions` by confidence before returning

### 9. Return results capped to maximum number
Return the ordered predictions capped to the `maxCount` given as argument.

___
#### Bonus - Implement NMS algorithm
You can try to apply Non-maximum suppression to return just the boxes with the highest confidence for each object. Implement `predictionsAfterNMS(threshold:)` in NonMaximumSuppresion.swift
