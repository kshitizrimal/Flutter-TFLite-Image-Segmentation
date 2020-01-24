# Flutter TF Segmentation

Flutter TF Segmentation is an example app that uses Flutter for the ios/android app and uses TensorFlow Lite for Image segmentation.
Here a static approach to image segmentation is used. User can select image from live camera or gallery to pick image for segmentation.
The model used here for Image Segmentation is DeepLab V3 with TensorFlow Lite.

## App Structure

- '<app_root>/pubspec.yaml': Used to add packages to the app from pub.dev
- '<app_root>/lib/main.dart': Used for all the logic of the app
- '<app_root>/assets/': used for storing and using TFLite model and label for the app
- '<app_root>/android/app/src/main/AndroidManifest.xml': used for modifying app name and details
- '<app_root>/android/app/build.gradle': used for specifying TFLite model not to be compressed

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
