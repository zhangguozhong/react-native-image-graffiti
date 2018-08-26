
# react-native-image-graffiti

## Getting started

`$ npm install react-native-image-graffiti --save`

### Mostly automatic installation

`$ react-native link react-native-image-graffiti`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-image-graffiti` and add `RNImageGraffiti.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNImageGraffiti.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.imagegraffiti.RNImageGraffitiPackage;` to the imports at the top of the file
  - Add `new RNImageGraffitiPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-image-graffiti'
  	project(':react-native-image-graffiti').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-image-graffiti/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-image-graffiti')
  	```


## Usage
```javascript
import RNImageGraffiti from 'react-native-image-graffiti';

// TODO: What to do with the module?
RNImageGraffiti;
```
  