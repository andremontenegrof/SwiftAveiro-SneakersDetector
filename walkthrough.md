# Walk-through
These are the steps that describe the path to create an object detection model trained with our own images, that can be used in an iOS app.
## 1. Get the training images
## 2. Annotate the bounding boxes of the images using Labelbox
## 3. Transform bounding boxes from Labelbox to be used with turicreate
## 4. Train and generate the object detection using turicreate
## 5. Evaluate the model and analyze results
## 5. Export the model to a Core ML format
## 6. Use the Core ML model (.mlmodel) in the implemented app

## Notes:
* Half precision
* Download core ml model