## Workshop setup:
1. Download this repo as a zip file and open /SneakersDetector/SneakersDetector.xcworkspace/
2. Download the SneakersDetector.mlmodel from <https://github.com/andremontenegrof/SwiftAveiro-SneakersDetector-Models>
## Tips
1. You will benefit from reading some documentation of the Vision classes you come across to
2. Search for "Mark:- Step". You should find 10 steps to complete. None of these steps should be skipped
3. Make sure it compiles every time you finish a step

## Steps
### 1. Understanding the Core ML model 
Drag and drop the SneakersDetector.mlmodel to the Xcode project.
### 2. Vision API - Detection request

Create the detection request by passing the visionModel and self.handleDetection as arguments. self.handleDetection is already implemented below, so you just need to pass it as an argument.

Note: The detection request should be a VNCoreMLRequest. Vision has other types of requests used for built-in features such as detections of faces, barcodes, etc. However, VNCoreMLRequest is the one to be used when we want to perform predictions in CoreML models. The results are passed to the completionHandler passed in the initialization.

### 3. Vision API - VNImageRequestHandler
Implement predict(requestHandler:). For each image we need to perform the detection request against the passed instance of VNImageRequestHandler. The naming in Vision are a bit confusing so please be aware that the completionHandler used to create the detectionRequest is a whole different thing from the 'requestHandler: VNImageRequestHandler'

Note: Each image used for predictions needs to have its associated VNImageRequestHandler. This pattern exists to be possible to perform several Vision executions in the same image and complete once they all return. For example, we could want to detect faces and objects in the same image all at once. However, in your implementation you only need to perform the detectionRequest.

### 4. Send results to delegate
Get the results from the request object. They should be casted to VNCoreMLFeatureValueObservation.
Create the predictions using self.predictions(from:confidenceThreshold:maxCount:) and send them to the ObjectDetectorDelegate.

### 5. Understanding MLMultiArray - shape
Use shape property to get the number of boxes. After implementing boxesCount you can uncomment the definition of the boxesPointer

### 6. Understanding MLMultiArray - stride
Use stride property to properly infer the number of elements that compose the box.

### 7. Understanding bounding box
After Step 6 you can uncomment the code related to bounding box creation.
Take a time to understand how the bounding box properties are being accessed with the pointer. Also uncomment the boundingBox definition.

### 8. Create and append prediction to be returned
Create the prediction and add it to unorderedPredictions

### 9. Sort results
We should sort the unorderedPredictions by confidence before returning

### 10. Return results capped to maximum number
Return the ordered predictions capped to the maxCount given as argument.

### Bonus - Implement NMS algorithm
You can try to apply Non-maximum suppression to return just the boxes with the highest confidence for each object. Implement predictionsAfterNMS(threshold:) in NonMaximumSuppresion.swift
