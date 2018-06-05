import turicreate as tc
import argparse
import os

# arguments parsing
ap = argparse.ArgumentParser()

ap.add_argument("-s", "--sframe", required=True, help="path to sframe file")
ap.add_argument("-o", "--output", required=True,
                help="path to dir to output created model")
ap.add_argument("-e", "--epochs", type=int, required=False,
                help="number of epochs")
ap.add_argument("-r", "--rand_split", type=float, required=False,
                help="fraction for random split")
ap.add_argument("-m", "--base_model", required=False,
                help="base model for transfer learning")

args = vars(ap.parse_args())

sframe_filepath = args["sframe"]
model_filename = os.path.basename(sframe_filepath)
model_output_path = args["output"]
number_of_epochs = args["epochs"]
rand_split = args["rand_split"]
base_model = args["base_model"]

# fallbacks
number_of_epochs = number_of_epochs if number_of_epochs is not None else 0
rand_split = rand_split if rand_split is not None else 0.8
base_model = base_model if base_model is not None else 'darknet-yolo'

print(number_of_epochs)

# load data, divide into train and test data and start training
data_frame = tc.SFrame(sframe_filepath)

train_data, test_data = data_frame.random_split(rand_split)

print(repr(train_data))
print(repr(test_data))

model = tc.object_detector.create(train_data,
                                  feature='image',
                                  annotations='annotations',
                                  max_iterations=number_of_epochs,
                                  model=base_model)

# save the model
model.save(model_output_path + model_filename + '.model')

# perform evaluation and log its result
scores = model.evaluate(data_frame)
print(scores)
#test_data.explore()

# export model to CoreML format
model.export_coreml(model_filename + '.mlmodel')
