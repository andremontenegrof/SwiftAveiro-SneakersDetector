import turicreate as tc
import argparse
import json
import os
import urlparse
from turicreate import SFrame
from collections import namedtuple

ImageSize = namedtuple("ImageSize", "width height")

ap = argparse.ArgumentParser()
ap.add_argument("-j", "--json_input_file", required=True,
                help="path to labelbox json file")
ap.add_argument("-o", "--output", required=True, help="path to output sframe")
ap.add_argument("-i", "--images_dir", required=True,
                help="path to images directory")
args = vars(ap.parse_args())

json_input_path = args["json_input_file"]
sframe_path = args["output"]
images_dir_path = args["images_dir"]

total_annotated_images = json.load(open(json_input_path))


def coordinates_from_bounding_box(labelbox_bounding_box, image_size):

    print(labelbox_bounding_box)

    x = (labelbox_bounding_box[0]['x'] + labelbox_bounding_box[2]['x']) / 2
    y = (labelbox_bounding_box[0]['y'] + labelbox_bounding_box[1]['y']) / 2
    width = abs(labelbox_bounding_box[2]['x'] - labelbox_bounding_box[0]['x'])
    height = abs(labelbox_bounding_box[0]['y'] - labelbox_bounding_box[1]['y'])

    # invert y
    y = image_size.height - y

    print('result')
    print({'x': x, 'y': y, 'width': width, 'height': height})

    return {'x': x, 'y': y, 'width': width, 'height': height}


def img_filename_from_annotated_image(annotated_image):

    img_filename = annotated_image["External ID"]

    if not img_filename:
        url = annotated_image["Labeled Data"]
        img_filename = image_name = os.path.basename(urlparse.urlparse(url).path)

    print(img_filename)

    return img_filename

def row_from_annotated_image(annotated_image):

    # create Image object
    img_filename = img_filename_from_annotated_image(annotated_image)

    img = tc.Image(images_dir_path + img_filename)
    image_size = ImageSize(width=img.width, height=img.height)

    if annotated_image["Label"] == "Skip":
        return (img, None)
    
    labelbox_annotations = annotated_image["Label"].iteritems()

    # parse and process annotations info
    def sframe_annotations_from_labelbox_annotations(class_annotations):
        class_name = class_annotations[0]
        bounding_boxes = class_annotations[1]
        sframe_entry = []
        for bounding_box in bounding_boxes:
            coordinate = {'coordinates': coordinates_from_bounding_box(
                bounding_box, image_size), 'label': class_name, 'type': 'rectangle'}
            sframe_entry.append(coordinate)
        return sframe_entry

    sframe_annotations = map(
        lambda kv: sframe_annotations_from_labelbox_annotations(kv), labelbox_annotations)

    # we need to flatten it to a list of dictionaries ... turicreate supports
    flat_sframe_annotations = [
        item for sublist in sframe_annotations for item in sublist]

    return (img, flat_sframe_annotations)


rows = map(lambda annotated_image: row_from_annotated_image(
    annotated_image), total_annotated_images)
images, annotations = zip(*rows)

sframe = SFrame({"image": images, "annotations": annotations})
sframe.save(sframe_path)
print(repr(sframe))
