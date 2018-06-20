#  Swift Aveiro 2018 - Detecting objects with Core ML and Vision 

<img src="assets/WhiteSneakersDetected.png" height="350" align="right">

🎉 Welcome to *Detecting objects with Core ML and Vision* 👁 

Or, more concretely... *Detecting **sneakers** 👟 with Core ML and Vision* 

The goal of this workshop is to give you a practical intuition of how to leverage machine learning in a mobile app. 
After today you should be unafraid of adventuring yourself with Core ML, Vision and Turi Create.

#### We will divide this in 2 parts:

1. Exercise - Programming steps that will complete an app that detects sneakers 👟. You should be able to complete these steps after **1 hour**.
2. Model training walk-through - Presentation and discussion of the path chosen to create and train the sneakers detection model used in our app.

##  🏁 Please start with:
1. Download the ```SneakersDetector.mlmodel``` in <https://github.com/andremontenegrof/SwiftAveiro-SneakersDetector-Models/blob/master/SneakersDetector.mlmodel>
2. Download this repo as a zip file and open `/SneakersDetector/SneakersDetector.xcodeproj/`

3. Try to build SneakersDetector.xcodeproj 😏. It should fail with: `Cannot call value of non-function type 'module<SneakersDetector>'`


## 💻 Exercise

In ```ObjectDetector.swift``` you should find [9 steps to complete](exercise.md). You just need to search for "Mark:- Step" in the code. After completing all the steps, your app should be able to  recognise sneakers like in the following image:

<p align="center">
<img src="assets/AdidasSneakersDetected.png" height="350">
</p>

After completing the exercise, you can try the app in the ```liveCamera``` mode by tweaking the ```application(_, didFinishLaunchingWithOptions:)```

##  👟📚📈 Model training walk-through
Please open [Walk-through of the creation and training of our sneakers detector](walkthrough.md)