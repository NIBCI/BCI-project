using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Ray_Start : InteractableObject
{
    private static Ray_Start _instance;
    public static Ray_Start Instance
    {
        get
        {
            return _instance;
        }
    }

    public Main main;
    public GameObject start_obj;

    // ray delay 용
    public GameObject lastHitObj = null;
    private float waitTime = 1;
    private float tickTime = 0f;

    private void Start()
    {
        _instance = this;

        //main = GameObject.Find("MainControl").GetComponent<Main>();
        start_obj = this.GetComponent<Transform>().GetChild(0).gameObject;
    }

    private void Update()
    {
        //Set_Collider();

        //if (main.org == "UNIST")
        //{
        //    if (name.Equals("Sequence_Start")
        //    && main.isStartRay == false)
        //    {
        //        start_obj.SetActive(true);
        //    }

        //    else if (name.Equals("Sequence_Start")
        //        && main.isStartRay == true)
        //    {
        //        start_obj.SetActive(false);
        //    }
        //}

        //else
        //{
        //    if (name.Equals("Sequence_Start"))
        //        start_obj.SetActive(false);
        //}
    }

    public override void RayStay(RaycastHit hit)
    {
        Debug.Log("11");

        if (lastHitObj != null)
            return;

        lastHitObj = this.gameObject;

        
        if (name.Contains("Trial"))
        {
            Debug.Log("123");

            P300_Manager.Instance.isTraining = true;
            P300_Manager.Instance.trial = Convert.ToInt32(name.Substring(5));

            GetComponent<BoxCollider>().enabled = false;

            return;
        }
        
        //else if (name.Equals("CCTV1#Play"))
        //{
        //    main.oggTexture.strMode = 1;
        //    if (main.oggTexture.movieTexture01.isPlaying)
        //        main.oggTexture.SetScreen(false);
        //    else
        //        main.oggTexture.SetScreen(true);

        //    return;
        //}

        //else if (name.Equals("CCTV2#Play"))
        //{
        //    main.oggTexture.strMode = 2;
        //    if (main.oggTexture.movieTexture02.isPlaying)
        //        main.oggTexture.SetScreen(false);
        //    else
        //        main.oggTexture.SetScreen(true);

        //    return;
        //}       
    }

    public void DeviceIcon(string strName)
    {
        main.UDP.UDP_Send("Device#Choice#" + strName);

        GetComponent<BoxCollider>().enabled = false;

        //if (strName.Equals("CCTV"))
        //{
        //    main.oggTexture.objPlay01.SetActive(true);
        //    main.oggTexture.objPlay02.SetActive(true);
        //}
    }

    // rapidFridge&Freezing	::	0(Off), 1(On)
    // Fridge&FreezingTemp	::	0 ~ 4 (5 step)
    // Fridge&FreezingDoor	::	0(all Close), 1(all Open). 2(fridge Open), 3(freezing open)
    // rapidFridge	rapidFreezing	FridgeTemp	FreezingTemp	FridgeDoor
    public void RefrigeratorIcon()
    {
        if (name.Contains("RapidFridgeOn"))
        {
            main.UDP.UDP_Send(main.org + "#" + main.DeviceMode + "#" + main.depth + "#Control#" + "1#On");

        }

        else if (name.Contains("RapidFridgeOff"))
        {
            main.UDP.UDP_Send(main.org + "#" + main.DeviceMode + "#" + main.depth + "#Control#" + "1#Off");

        }

        else if (name.Contains("RapidFreezingOn"))
        {
            main.UDP.UDP_Send(main.org + "#" + main.DeviceMode + "#" + main.depth + "#Control#" + "2#On");

        }

        else if (name.Contains("RapidFreezingOff"))
        {
            main.UDP.UDP_Send(main.org + "#" + main.DeviceMode + "#" + main.depth + "#Control#" + "2#Off");

        }

        else if (name.Contains("Status"))
        {
            main.UDP.UDP_Send(main.org + "#" + main.DeviceMode + "#" + main.depth + "#Contro#3");
            main.depth = "02";
        }

        else if (name.Contains("Back01")
            && !main.rememberObj.name.Contains("Back02"))
        {
            main.UDP.UDP_Send(main.org + "#" + main.DeviceMode + "#" + main.depth + "#Control#4");
            
        }

        else if (name.Contains("Back02"))
        {
            main.UDP.UDP_Send(main.org + "#" + main.DeviceMode + "#" + main.depth + "#Control#4");
            main.depth = "01";
        }
    }

    public void RVCIcon(string strName)
    {
        if (strName.Equals("Auto")
           || strName.Equals("Stop")
           || strName.Equals("Recharge")
           || strName.Equals("TurboMode")
           || strName.Equals("NormalMode")
           || strName.Equals("SilenceMode"))
        {
            main.UDP.UDP_Send(main.org + "#" + main.DeviceMode + "#Control#" + strName);
        }

        else if (strName.Contains("SelectMode"))
        {
            main.depth = "02";
        }

        else if (strName.Contains("RVCBack01")
            && !main.rememberObj.name.Contains("RVCBack02"))
        {
        }

        else if (strName.Contains("RVCBack02")
            && !main.rememberObj.name.Contains("RVCBack01"))
        {
            main.depth = "01";
        }
    }

    public void AirCleanerIcon(string strName)
    {
        if (strName.Contains("Power")
            || strName.Contains("Mode"))
        {
            main.UDP.UDP_Send(main.org + "#" + main.DeviceMode + "#Control#" + strName);
        }

        if (strName.Contains("Air"))
        {
            // 새로고침 기능으로 변경
        }

        else if (strName.Contains("Move01"))
        {
            main.depth = "02";
        }

        else if (strName.Contains("Move02"))
        {
            main.depth = "03";
        }


        // back button
        else if (strName.Contains("Back01")
            && !main.rememberObj.name.Contains("Back02")
            && !main.rememberObj.name.Contains("Back03"))
        {
        }

        else if (strName.Contains("Back02")
            && !main.rememberObj.name.Contains("Back04"))
        {
            main.depth = "01";
        }

        else if (strName.Contains("Back03"))
        {
            main.depth = "01";
        }

        else if (strName.Contains("Back04"))
        {
            main.depth = "02";
        }
    }

    public void SmartBulbIcon(string strName)
    {
        if (strName.Contains("Power")
            || strName.Contains("Color")
            || strName.Contains("Dimming"))
        {
            main.UDP.UDP_Send(main.org + "#" + main.DeviceMode + "#Control#" + strName);            
        }

        else if (strName.Contains("Move01"))
        {
            main.depth = "02";
        }

        else if (strName.Contains("Move02"))
        {
            main.depth = "03";
        }

        else if (strName.Contains("Back01")
            && !main.rememberObj.name.Contains("Back02")
            && !main.rememberObj.name.Contains("Back03"))
        {
        }

        else if (strName.Contains("Back02"))
        {
            main.depth = "01";
        }

        else if (strName.Contains("Back03"))
        {            
            main.depth = "01";
        }
    }

    public void GasValveIcon()
    {
        if (name.Contains("Open"))
        {
            main.UDP.UDP_Send(main.org + "#" + main.DeviceMode + "#" + main.depth + "#Control#" + "1");
        }

        else if (name.Contains("Close"))
        {
            main.UDP.UDP_Send(main.org + "#" + main.DeviceMode + "#" + main.depth + "#Control#" + "2");
        }

        else if (name.Contains("Battery"))
        {
            main.UDP.UDP_Send(main.org + "#" + main.DeviceMode + "#" + main.depth + "#Control#" + "3");
        }

        else if (name.Contains("Back"))
        {
            main.UDP.UDP_Send(main.org + "#" + main.DeviceMode + "#" + main.depth + "#Control#" + "4");
            
        }
    }

    public void DoorLockIcon()
    {
        if (name.Contains("Open"))
        {
            main.UDP.UDP_Send(main.org + "#" + main.DeviceMode + "#" + main.depth + "#Control#" + "1");
        }

        else if (name.Contains("Close"))
        {
            main.UDP.UDP_Send(main.org + "#" + main.DeviceMode + "#" + main.depth + "#Control#" + "2");
        }

        else if (name.Contains("View"))
        {
            main.UDP.UDP_Send(main.org + "#" + main.DeviceMode + "#" + main.depth + "#Control#" + "3");
        }

        else if (name.Contains("Back"))
        {
            main.UDP.UDP_Send(main.org + "#" + main.DeviceMode + "#" + main.depth + "#Control#" + "4");
         
        }
    }

    public void AirDresserIcon(string strName)
    {
        if (strName.Contains("Operation"))
            main.UDP.UDP_Send(main.org + "#" + main.DeviceMode + "#Control#" + strName);

        else if (strName.Equals("Back01"))
        {

        }
    }

    public void CCTVIcon(string strName)
    {
        if (strName.Contains("Up")
            || strName.Contains("Down")
            || strName.Contains("Left")
            || strName.Contains("Right")
            || strName.Contains("Wide")
            || strName.Contains("Tele"))
        {
            main.UDP.UDP_Send(main.org + "#" + main.DeviceMode + "#Control#" + strName);
        }

        else if (strName.Equals("Mode#Rotate"))
        {
            main.depth = "02";
        }

        else if (strName.Equals("Mode#Zoom"))
        {
            main.depth = "03";
        }

        else if (strName.Equals("Back01"))
        {
            //main.oggTexture.SetScreen(false);
            //main.oggTexture.objPlay01.SetActive(false);
            //main.oggTexture.objPlay02.SetActive(false);

            //main.Set_BlinkObjectList();
        }

        else if (strName.Equals("Back02"))
        {
            main.depth = "01";
        }

        else if (strName.Equals("Back03"))
        {
            main.depth = "02";
        }
    }

    public override void RayExit()
    {
        lastHitObj = null;
        main.rememberObj = this.gameObject;
    }


    void Set_Collider()
    {
        if (start_obj.activeInHierarchy)
        {
            if (main.org != "UNIST")
                GetComponent<BoxCollider>().enabled = true;

            else if (main.isStartRay == false)
            {
                if (name.Equals("Sequence_Start")
                    || name.Equals("Training04")
                    || (name.Equals("Back01") && main.depth == "91"))
                    GetComponent<BoxCollider>().enabled = true;
            }
            else
                GetComponent<BoxCollider>().enabled = false;
        }
        else
            GetComponent<BoxCollider>().enabled = false;
    }

}
