## Tips
1. Search for "Mark:- Step". You should find 9 steps to complete. None of these steps should be skipped.
2. Make sure it compiles every time you finish a step.
3. The comments in the code and Apple's documentation are a great help to understand the needed concepts
4. The app works in 3 different modes that can be selected in the ```AppDelegate.swift```. Use the staticImages mode at first and then, once your app starts to present correct bounding boxes, try the liveCamera with a real device ;)

```swift
enum AppMode {
case staticImages
case takePhoto
case liveCamera
}
```

## Steps
### 1. Understanding the Core ML model 
Drag and drop the SneakersDetector.mlmodel to the Xcode project.
### 2. Vision API - Detection request

Create the detection request by passing the `visionModel` and `self.handleDetection` as arguments. `self.handleDetection` is already implemented below, so you just need to pass it as an argument.

Note: The detection request should be a VNCoreMLRequest. Vision has other types of requests used for built-in features such as detections of faces, barcodes, etc. However, VNCoreMLRequest is the one to be used when we want to perform predictions in CoreML models. The results are passed to the completionHandler passed in the initialization.

### 3. Send results to delegate
Get the results from the request object. They should be casted to VNCoreMLFeatureValueObservation.
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

### Bonus - Implement NMS algorithm
You can try to apply Non-maximum suppression to return just the boxes with the highest confidence for each object. Implement `predictionsAfterNMS(threshold:)` in NonMaximumSuppresion.swift
