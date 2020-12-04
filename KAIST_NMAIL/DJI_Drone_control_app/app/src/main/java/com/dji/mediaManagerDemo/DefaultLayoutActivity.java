package com.dji.mediaManagerDemo;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.atomic.AtomicReference;

import dji.common.error.DJIError;
import dji.common.flightcontroller.ObstacleDetectionSector;
import dji.common.flightcontroller.VisionDetectionState;
import dji.common.flightcontroller.virtualstick.FlightControlData;
import dji.common.flightcontroller.virtualstick.FlightCoordinateSystem;
import dji.common.flightcontroller.virtualstick.RollPitchControlMode;
import dji.common.flightcontroller.virtualstick.VerticalControlMode;
import dji.common.flightcontroller.virtualstick.YawControlMode;
import dji.common.util.CommonCallbacks;
import dji.keysdk.DJIKey;
import dji.keysdk.FlightControllerKey;
import dji.keysdk.KeyManager;
import dji.keysdk.callback.KeyListener;
import dji.logic.vision.DJIVisionHelper;
import dji.sdk.flightcontroller.FlightAssistant;
import dji.sdk.flightcontroller.FlightController;

public class DefaultLayoutActivity extends AppCompatActivity implements View.OnClickListener{

    private Button mMediaManagerBtn;

    private Timer sendVirtualStickDataTimer;
    private SendVirtualStickDataTask sendVirtualStickDataTask;

    private float pitch;
    private float roll;
    private float yaw;
    private float throttle;

    private long delay = null;
    private long period = null;

    private float up_speed = null;
    private float front_speed = null;
    private float right_speed = null;

    private boolean yawControlModeFlag = true;
    private boolean rollPitchControlModeFlag = true;
    private boolean verticalControlModeFlag = true;
    private boolean horizontalCoordinateFlag = true;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_default_layout);

        mMediaManagerBtn = (Button)findViewById(R.id.btn_mediaManager);
        mMediaManagerBtn.setOnClickListener(this);

        new Thread(new Runnable(){
            public void run(){
                send("Start");
            }
        }).start();


    }

    @Override
    public void onClick(View v) {

        switch (v.getId()) {
            case R.id.btn_mediaManager: {
                Intent intent = new Intent(this, MainActivity.class);
                startActivity(intent);
                break;
            }
            default:
                break;
        }
    }
    public void recordValues(){

    }
    public void send(String data){

        try {
            FlightController flightController = ModuleVerificationUtil.getFlightController();
            AtomicReference<Boolean> blockInput = new AtomicReference<>(false);
            sendVirtualStickDataTimer = new Timer();
            String dserverName = null;
            int dport = null;
            Socket dclient = new Socket(dserverName, dport);
            PrintWriter dout = new PrintWriter(dclient.getOutputStream(), true);
            FlightAssistant flightAssistant = flightController.getFlightAssistant();

            final String[] obstacles = {""};
            DJIKey djiKey = FlightControllerKey.createFlightAssistantKey(FlightControllerKey.VISION_DETECTION_STATE);
            KeyManager.getInstance().addListener(djiKey, new KeyListener() {
                @Override
                public void onValueChange(@Nullable Object oldValue, @Nullable Object newValue) {
                    if (newValue instanceof VisionDetectionState) {
                        VisionDetectionState state = (VisionDetectionState) newValue;

                        ObstacleDetectionSector[] sectors = state.getDetectionSectors();
                        if (sectors != null) {
                            //THERE IS NO SECTOR[4] ONLY TILL [3]
                            obstacles[0]="";
                            obstacles[0] = obstacles[0] + String.valueOf(sectors[0].getWarningLevel())+" || ";
                            obstacles[0] = obstacles[0] + String.valueOf(sectors[1].getWarningLevel())+" || ";
                            obstacles[0] = obstacles[0] + String.valueOf(sectors[2].getWarningLevel())+" || ";
                            obstacles[0] = obstacles[0] + String.valueOf(sectors[3].getWarningLevel())+"\n\n\n";
                        }
                    }
                }
            });


            Timer data_sender = new Timer();
            data_sender.scheduleAtFixedRate(new TimerTask() {
                @Override
                public void run() {
                    dout.println(obstacles[0]);
                    dout.println("--------------------------------------------------");
                }
            }, 0, 2000);


            String serverName = null;
            int port = null;
            Socket client = new Socket(serverName, port);
            BufferedReader stdIn = new BufferedReader(new InputStreamReader(client.getInputStream()));

            DJIKey disableKey = FlightControllerKey.createFlightAssistantKey(FlightControllerKey.COLLISION_AVOIDANCE_ENABLED);
            KeyManager.getInstance().setValue(disableKey,false,null);
            AtomicReference<Boolean> threadAlive = new AtomicReference<>(false);

            while(true) {

                float pX;
                float pY;
                float verticalJoyControlMaxSpeed;
                float yawJoyControlMaxSpeed;
                float pitchJoyControlMaxSpeed;
                float rollJoyControlMaxSpeed;
                String in = stdIn.readLine();
                if(blockInput.get()){
                    continue;
                }
                switch (in) {
                    case "1":
                        flightController.setVerticalControlMode(VerticalControlMode.VELOCITY);
                        verticalControlModeFlag = true;
                        flightController.setYawControlMode(YawControlMode.ANGULAR_VELOCITY);
                        yawControlModeFlag = true;
                        flightController.setRollPitchControlMode(RollPitchControlMode.VELOCITY);
                        rollPitchControlModeFlag = true;
                        flightController.setRollPitchCoordinateSystem(FlightCoordinateSystem.BODY);
                        horizontalCoordinateFlag = true;

                        flightController.setVirtualStickModeEnabled(true, new CommonCallbacks.CompletionCallback() {
                            @Override
                            public void onResult(DJIError djiError) {
                            }
                        });

                        break;
                    case "2":
                        flightController.setVirtualStickModeEnabled(false, new CommonCallbacks.CompletionCallback() {
                            @Override
                            public void onResult(DJIError djiError) {
                            }
                        });
                        break;
                    case "t":
                        flightController.startTakeoff(new CommonCallbacks.CompletionCallback() {
                            @Override
                            public void onResult(DJIError djiError) {
                            }
                        });
                        break;
                    case "f":
                        flightController.confirmLanding(new CommonCallbacks.CompletionCallback() {
                            @Override
                            public void onResult(DJIError djiError) {
                            }
                        });
                        break;
                    case "c":

                        flightController.startLanding(new CommonCallbacks.CompletionCallback() {
                            @Override
                            public void onResult(DJIError djiError) {
                            }
                        });
                        break;
                    case "e":
                        pitch = 0;
                        roll = 0;
                        yaw = 0;
                        throttle = up_speed;

                        sendVirtualStickDataTask = new SendVirtualStickDataTask();
                        sendVirtualStickDataTimer.schedule(sendVirtualStickDataTask, delay, period);
                        break;
                    case "q":
                        pitch = 0;
                        roll = 0;
                        yaw = 0;
                        throttle = -up_speed;

                        sendVirtualStickDataTask = new SendVirtualStickDataTask();
                        sendVirtualStickDataTimer.schedule(sendVirtualStickDataTask, delay, period);
                        break;
                    case "d":
                        pitch = 0;
                        roll = 0;
                        yaw = right_speed;
                        throttle = 0;

                        sendVirtualStickDataTask = new SendVirtualStickDataTask();
                        sendVirtualStickDataTimer.schedule(sendVirtualStickDataTask, delay, period);
                        break;
                    case "a":
                        pitch = 0;
                        roll = 0;
                        yaw = -right_speed;
                        throttle = 0;

                        sendVirtualStickDataTask = new SendVirtualStickDataTask();
                        sendVirtualStickDataTimer.schedule(sendVirtualStickDataTask, delay, period);
                        break;
                    case "w":
                        pitch = 0;
                        roll = front_speed;
                        yaw = 0;
                        throttle = 0;

                        sendVirtualStickDataTask = new SendVirtualStickDataTask();
                        sendVirtualStickDataTimer.schedule(sendVirtualStickDataTask, delay, period);
                        break;
                    case "i":
                        yaw = 0;
                        throttle =0;
                        roll=0;
                        pitch = 0;

                        sendVirtualStickDataTask = new SendVirtualStickDataTask();
                        sendVirtualStickDataTimer.schedule(sendVirtualStickDataTask, delay, period);
                        break;

                    case "s":
                        pitch = 0;
                        roll = -front_speed
                        yaw = 0;
                        throttle = 0;

                        sendVirtualStickDataTask = new SendVirtualStickDataTask();
                        sendVirtualStickDataTimer.schedule(sendVirtualStickDataTask, delay, period);
                        break;
                }
            }
        }
        catch (IOException e) {
            e.printStackTrace();

        }
    }

    private class SendVirtualStickDataTask extends TimerTask {

        @Override
        public void run() {
            if (ModuleVerificationUtil.isFlightControllerAvailable()) {
                DemoApplication.getAircraftInstance()
                        .getFlightController()
                        .sendVirtualStickFlightControlData(new FlightControlData(pitch,
                                        roll,
                                        yaw,
                                        throttle),
                                new CommonCallbacks.CompletionCallback() {
                                    @Override
                                    public void onResult(DJIError djiError) {

                                    }
                                });
            }
        }
    }
}