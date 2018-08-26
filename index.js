
import {NativeModules} from 'react-native';
const {ImageGraffitiManager} = NativeModules;

export default class RNImageGraffiti {

    static show(options, callback) {
        ImageGraffitiManager.showGraffitiImage(options, (res)=>{

            if (callback){
                callback(res);
            }
        });
    }
};
