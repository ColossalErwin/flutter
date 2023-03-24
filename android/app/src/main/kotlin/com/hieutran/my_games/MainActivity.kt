package com.hieutran.my_games

import com.google.firebase.appcheck.FirebaseAppCheck
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.firebase.appcheck.debug.DebugAppCheckProviderFactory
import androidx.annotation.NonNull
/*
class MainActivity: FlutterActivity() {
    
    FirebaseApp.initializeApp(context: this)
    val firebaseAppCheck = FirebaseAppCheck.getInstance()
    firebaseAppCheck.installAppCheckProviderFactory(
    DebugAppCheckProviderFactory.getInstance()
    )
    
}
*/
class MainActivity: FlutterActivity() {
    /* //this segment is for AppCheck
    private val CHANNEL = "samples.flutter.dev/appcheck"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {

        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler {
                call, result ->
                    if (call.method == "installDebug") {
                        val firebaseAppCheck = FirebaseAppCheck.getInstance()
                        firebaseAppCheck.installAppCheckProviderFactory(
                            DebugAppCheckProviderFactory.getInstance()
                        )
                        result.success(1)
                    } else {
                        result.notImplemented()
                    }
            }
       }
       */
}
