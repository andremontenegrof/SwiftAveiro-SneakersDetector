## Steps
* After each step the project should build 👷 without errors ❌  
* Warnings ⚠️ are expected to appear until you complete all steps
* The comments in the code and Apple's documentation are a great help to understand the needed concepts

* The app works in 3 different modes that can be selected in the ```AppDelegate.swift```. Use the `staticImages` mode with the Simulator at first and then, once your app starts to present correct bounding boxes, try the `liveCamera` with a real device 😀.
### 1. Vision API - Detection request

Create the detection request by passing the `visionModel` and `self.handleDetection` as arguments. `self.handleDetection` is already implemented below, so you just need to pass it as an argument.

Note: The detection request should be a `VNCoreMLRequest`. Vision has other types of requests used for built-in features such as detections of faces, barcodes, etc. However, `VNCoreMLRequest` is the one to be used when we want to perform predictions in CoreML models. The results are passed to the completionHandler passed in the initialization.

### 2. Send results to delegate
Get the results from the request object. They should be cast to `VNCoreMLFeatureValueObservation`.
Create the predictions using `self.predictions(from:confidenceThreshold:maxCount:)` and send them to the `ObjectDetectorDelegate`.

Note: At this moment we don't have any prediction. We will need to complete the implementation of `self.predictions(from:confidenceThreshold:maxCount:)` in the next steps.

### 3 - Understanding MLMultiArray
The purpose of this function is to transform the output of our model (`boxesArray` and `confidencesArray`) to a list of Predictions that can be used in our UI.
Take 2 or 3 minutes to inspect `boxesArray` and `confidencesArray` and then advance to Step 4. Uncomment the following lines or just use the debugger 😀

```
// print("Boxes Array: " + String(describing: boxesArray))
// print("Confidences Array: " + String(describing: confidencesArray))
```

### 4. Understanding MLMultiArray - shape
Use shape property to get the number of boxes outputted by our model. The definition of `boxesCount` is similar to the definition of confidencesCount.

Note: To help overcome this step you might want to read the documentation of the MLMultiArray's shape.

### 5. Understanding MLMultiArray - stride
Define boxesStride using the property strides of the boxesArray.

Note: This boxesStride is later used at Step 6 to access the boxes in the boxesArray. When accessing values of a MLMultiArray, the property strides is used to calculate an element's location in memory.

### 6. Understanding the bounding box
Uncomment the code related to bounding box creation.
Take a time to understand how the bounding box properties are being accessed with the pointer. Also uncomment the `boundingBox` definition.

### 7. Create and add a Prediction
Create the prediction and add it to `unorderedPredictions`

### 8. Return results capped to maximum number
Return the unorderedPredictions capped to the `maxCount` given as argument of this function.

### 9. Sort results
We should now sort the capped predictions of Step 8 by their confidence.

After returning the new orderedPredictions array you'll have completed the first part of our workshop 🎉! Take the time to explore this codebase, try the app with `liveCamera` mode or take a change at the Bonus Step.

Note: It is expected not to find any difference in the UI between Step 8 and 9 because we are displaying all the bounding boxes (with a confidence greater than our threshold). However, we will need to have our predictions ordered for our Bonus Step, where we will select the best boxes for each detected object.

___
#### Bonus - Implement NMS algorithm
You can try to apply Non-maximum suppression to return just the boxes with the highest confidence for each object. Implement `predictionsAfterNMS(threshold:)` in `NonMaximumSuppresion.swift`

The goal of this function is to return the best bounding boxes for each of the objects detected. How can we know if a certain box is detecting a different object from another box? We use the given IoU (Intersection over Union) threshold to compare it with the IoU between the two boxes.

If the IoU between two boxes is high, we have a high overlap, which means that the 2 boxes are results for the detection of the same object. In this case we need to discard/suppress the box with the lowest confidence.
 

Imperative instructions for the algorithm:

1. Start by selecting the prediction with the highest confidence and calculate its IoU (`CGRect+ObjectDetection.swift`) with the other predictions.
2. Remove (suppress) the predictions that have an IoU under the threshold received as a parameter.
3. Repeat the same process with the reminder predictions until you get an array of the best predictions.

Note: You can try a recursive approach for this algorithm.

See the image for a better intuition about IoU:

<img src="assets/IntersectionOverUnion.png" height="200">
