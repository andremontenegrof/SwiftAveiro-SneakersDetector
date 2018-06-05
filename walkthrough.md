# Walk-through of the creation and training of our sneakers detector
Please find the steps that describe the path for the creation and training of our sneakers detection model.

## 1. Get the training images
One easy way is to inject javascript in Chrome so that we can fetch the urls while we scroll down a list of Google images. You can find an example in [this article by Adrian Rosebrock](https://www.pyimagesearch.com/2017/12/04/how-to-create-a-deep-learning-dataset-using-google-images/). 

After having a urls.txt we can use any program to download these images to our disk (you can use [the example in this repo](Scripts/download_image_urls.py)).
## 2. Annotate the bounding boxes of the images using Labelbox
Labelbox (<https://www.labelbox.com/>) is a free and easy tool you can use for annotations.

![Labelbox](assets/LabelboxExample.jpg)
## 3. Transform bounding boxes from Labelbox to be used with Turicreate
Labelbox has the functionality to export the annotated data to a CSV or JSON file. It is then necessary to transform these data to a data structure that can be loaded by Turicreate. This data structure is called the [SFrame](https://apple.github.io/turicreate/docs/api/generated/turicreate.SFrame.html).

The script [annotations_labelboxjson_to_sframe.py](Scripts/annotations_labelboxjson_to_sframe.py) parses the Labelbox annotations json file and creates an sframe in our disk.
## 4. Train and generate the object detection using Turicreate
## 5. Evaluate the model and analyze results
## 6. Export the model to a Core ML format
## 7. Use the Core ML model (.mlmodel) in the implemented app