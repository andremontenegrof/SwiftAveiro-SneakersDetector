## Tips
1. You will surely need to read some documentation of the Vision classes you come across to
2. Steps should not be skipped (except the last bonus step) 
3. Follow Mark:- Step x
4. Make sure it compiles every time you finish a step

## Steps
### 1. Understanding the Core ML model 
Drag and drop the SneakersDetector.mlmodel to the Xcode project.
### 2. 

Create the detection request by passing the visionModel and self.handleDetection as arguments. self.handleDetection is already implemented below, so you just need to pass it as an argument.

Note: The detection request should be a VNCoreMLRequest. Vision has other types of requests used for built-in features such as detections of faces, barcodes, etc. However, VNCoreMLRequest is the one to be used when we want to perform predictions in CoreML models. The results are passed to the completionHandler passed in the initialization.

### 3. 

Implement predict(requestHandler:). For each image we need to perform the detection request against the passed instance of VNImageRequestHandler. The naming in Vision are a bit confusing so please be aware that the completionHandler used to create the detectionRequest is a whole different thing from the 'requestHandler: VNImageRequestHandler'

Note: Each image used for predictions needs to have its associated VNImageRequestHandler. This pattern exists to be possible to perform several Vision executions in the same image and complete once they all return. For example, we could want to detect faces and objects in the same image all at once. However, in your implementation you only need to perform the detectionRequest.

### 4. 
Get the results from the request object. They should be casted to VNCoreMLFeatureValueObservation.
Create the predictions using self.predictions(from:confidenceThreshold:maxCount:) and send them to the ObjectDetectorDelegate.

### 5. 
Use shape property to get the number of boxes. After implementing boxesCount you can uncomment the definition of the boxesPointer

### 6. 
Use stride property to properly infer the number of elements that compose the box.

### 8. 
After Step 5 you can uncomment the code related to bounding box creation
    
### 9. 
Define boundingBox with the correct value

### 10. 

Define confidence with the correct value

### 11. 
We should sort the unorderedPredictions by confidence before returning

### 12. 
Return the ordered predictions capped to the maxCount given as argument.

### Bonus 
You can try to apply Non-maximum suppression to return just the boxes with the highest confidence for each object. Implement predictionsAfterNMS(threshold:) in NonMaximumSuppresion.swift
