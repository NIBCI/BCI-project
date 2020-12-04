using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PageBase : MonoBehaviour
{
    public UIButton rayStayBtn;
    public ImageList imageList;

    public UIButton homeBtn;
    public UIButton refreshBtn;
    public UIButton BCIOnBtn;
    public UIButton BCIOffBtn;
    public UIButton SSVEPbtn;
    public UIButton P300btn;
    public UIButton RecognitionOnBtn;
    public UIButton RecognitionOffBtn;

    public UIButton trainOnbtn;
    public UIButton trainOffbtn;

    // Use this for initialization
    void Start()
    {
        imageList = transform.GetComponent<ImageList>();

        homeBtn = imageList.GetButton("Home_btn");
        refreshBtn = imageList.GetButton("Refresh_btn");
        BCIOnBtn = imageList.GetButton("BCIOn_btn");
        BCIOffBtn = imageList.GetButton("BCIOff_btn");
        SSVEPbtn = imageList.GetButton("SSVEP_btn");
        P300btn = imageList.GetButton("P300_btn");
        RecognitionOnBtn = imageList.GetButton("RecognitionOn_btn");
        RecognitionOffBtn = imageList.GetButton("RecognitionOff_btn");

        trainOnbtn = imageList.GetButton("TrainingOn_btn");
        trainOffbtn = imageList.GetButton("TrainingOff_btn");
    }

    // Update is called once per frame
    void Update()
    {
        OnRay();
        CommonVisible();

        if (rayStayBtn
            && Main.Instance.isAbleBtn.Equals(true))
        {
            Main.Instance.isAbleBtn = false;
            HomeIcon(rayStayBtn.gameObject.name);
            RefreshIcon(rayStayBtn.gameObject.name);
            BCIicon(rayStayBtn.gameObject.name);
            RecognitionIcon(rayStayBtn.gameObject.name);
        }
    }

    protected void OnRay()
    {
        rayStayBtn = GetRayStayBtn();
    }

    protected UIButton GetRayStayBtn()
    {
        UIButton find = null;

        foreach (UIButton btn in GetComponent<ImageList>().arr_UIButton)
        {
            if (btn)
            {
                if (btn.bRayStay)
                {
                    find = btn;
                    break;
                }
            }
        }

        return find;
    }

    public void CommonVisible()
    {
        if (PageManager.Instance.GetActivePage().name.Equals("Page_Home"))
        {
            homeBtn.gameObject.SetActive(false);
            refreshBtn.gameObject.SetActive(false);
        }
        else
        {
            homeBtn.gameObject.SetActive(true);
            refreshBtn.gameObject.SetActive(true);
        }


        if (Main.Instance.isBCI.Equals(true))
        {
            BCIOnBtn.gameObject.SetActive(true);
            BCIOffBtn.gameObject.SetActive(false);
            SSVEPbtn.gameObject.SetActive(true);
            P300btn.gameObject.SetActive(true);
            trainOnbtn.gameObject.SetActive(false);
            trainOffbtn.gameObject.SetActive(true);

            if (Main.Instance.isSSVEP.Equals(true))
            {
                Main.Instance.org = "HanYang";
                SSVEPbtn.GetComponent<Image>().sprite = SSVEPbtn.FindClickImage("SSVEP_btn");
                P300btn.GetComponent<Image>().sprite = P300btn.FindImage("P300_btn");
            }

            else
            {
                Main.Instance.org = "UNIST";
                SSVEPbtn.GetComponent<Image>().sprite = SSVEPbtn.FindImage("SSVEP_btn");
                P300btn.GetComponent<Image>().sprite = P300btn.FindClickImage("P300_btn");
            }

            if (P300_Manager.Instance.isTraining.Equals(true))
            {
                trainOnbtn.gameObject.SetActive(true);
                trainOffbtn.gameObject.SetActive(false);
            }
            else
            {
                trainOnbtn.gameObject.SetActive(false);
                trainOffbtn.gameObject.SetActive(true);
            }
        }
        else
        {
            Main.Instance.org = "TSB";
            BCIOnBtn.gameObject.SetActive(false);
            BCIOffBtn.gameObject.SetActive(true);
            SSVEPbtn.gameObject.SetActive(false);
            P300btn.gameObject.SetActive(false);
            trainOnbtn.gameObject.SetActive(false);
            trainOffbtn.gameObject.SetActive(false);
        }


        if (Main.Instance.isRecognition.Equals(true))
        {
            ImageCapture.Instance.recognizer.StartCapturingGestures();
            RecognitionOnBtn.gameObject.SetActive(true);
            RecognitionOffBtn.gameObject.SetActive(false);
        }
        else
        {
            ImageCapture.Instance.recognizer.CancelGestures();
            RecognitionOnBtn.gameObject.SetActive(false);
            RecognitionOffBtn.gameObject.SetActive(true);
        }
    }

    public void SelectIcon(string strName)
    {
        if (!strName.Contains("Integration"))
            DeviceSelectIcon(strName);
        else
            IntegrationIcon(strName);
    }

    public void DeviceSelectIcon(string strName)
    {
        if (strName.Contains("_btn"))
            strName = strName.Replace("_btn", "");

        if (strName.Contains("_Card"))
            strName = strName.Replace("_Card", "");

        //장비 선택 전송
        Main.Instance.UDP.UDP_Send("Device#Choice#" + strName + "#" + Main.Instance.deviceNumber.ToString());

        switch (strName)
        {
            case "Refrigerator":
                Main.Instance.DeviceMode = Main.Device.Refrigerator;
                break;

            case "RVC":
                Main.Instance.DeviceMode = Main.Device.RVC;
                break;

            case "Bulb":
                Main.Instance.DeviceMode = Main.Device.Bulb;
                break;

            case "AirCleaner":
                Main.Instance.DeviceMode = Main.Device.AirCleaner;
                break;

            case "GasValve":
                Main.Instance.DeviceMode = Main.Device.GasValve;
                break;

            case "DoorLock":
                Main.Instance.DeviceMode = Main.Device.DoorLock;
                break;

            case "Blind":
                Main.Instance.DeviceMode = Main.Device.Blind;
                break;

            case "AirConditioner":
                Main.Instance.DeviceMode = Main.Device.AirConditioner;
                break;

            case "CCTV":
                Main.Instance.DeviceMode = Main.Device.CCTV;
                break;

            case "AirDresser":
                Main.Instance.DeviceMode = Main.Device.AirDresser;
                break;

            case "TV":
                Main.Instance.DeviceMode = Main.Device.TV;
                break;

            case "Inbody":
                Main.Instance.DeviceMode = Main.Device.Inbody;
                break;

            case "Fit":
                Main.Instance.DeviceMode = Main.Device.Fit;
                break;

            case "Scale":
                Main.Instance.DeviceMode = Main.Device.Scale;
                break;


            default:
                Main.Instance.DeviceMode = Main.Device.None;
                break;
        }

        PageManager.Instance.ChangePage("Page_" + strName);
        Main.Instance.BCI_Page = Main.DeviceDepth.Page1;

        //GetComponent<BoxCollider>().enabled = false;
    }

    public void IntegrationIcon(string strName)
    {
        if (strName.Contains("_btn"))
            strName = strName.Replace("_btn", "");

        Main.Instance.UDP.UDP_Send("Integration#Choice#" + strName);
    }

    public void HomeIcon(string strName)
    {
        if (strName.Equals("Home_btn"))
            PageManager.Instance.GoHome();
    }

    public void RefreshIcon(string strName)
    {
        if (strName.Equals("Refresh_btn"))
            Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#Show");
    }

    public void BCIicon(string strName)
    {
        switch (strName)
        {
            case "BCIOff_btn":
                Main.Instance.isBCI = true;
                break;

            case "BCIOn_btn":
                Main.Instance.isBCI = false;
                break;

            case "SSVEP_btn":
                Main.Instance.isSSVEP = true;
                break;

            case "P300_btn":
                Main.Instance.isSSVEP = false;
                break;

                //case "TrainingOn_btn":
                //    P300_Manager.Instance.isTraining = false;
                //    break;

                //case "TrainingOff_btn":
                //    P300_Manager.Instance.isTraining = true;
                //    break;
        }
    }

    public void RecognitionIcon(string strName)
    {
        switch (strName)
        {
            case "RecognitionOff_btn":
                Main.Instance.isRecognition = true;
                break;

            case "RecognitionOn_btn":
                Main.Instance.isRecognition = false;
                break;
        }
    }

    public void RefrigeratorIcon(string strName)
    {
        if (strName.Contains("_btn"))
            strName = strName.Replace("_btn", "");

        if (strName.Contains("Rapid"))
            Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#Control#" + strName);

        else if (name.Contains("Back01")
            && !Main.Instance.rememberObj.name.Contains("Back02"))
        {
            //Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#" + Main.Instance.depth + "#Control#4");

        }

        else if (name.Contains("Back02"))
        {
            //Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#" + Main.Instance.depth + "#Control#4");
            Main.Instance.depth = "01";
        }

        else if (strName.Contains("EnergyMonitor"))
            PageManager.Instance.ChangePage("Page_Energy");
    }

    public void RVCIcon(string strName)
    {
        if (strName.Contains("_btn"))
            strName = strName.Replace("_btn", "");

        if (strName.Equals("Auto")
           || strName.Equals("Stop")
           || strName.Equals("Recharge")
           || strName.Equals("TurboMode")
           || strName.Equals("NormalMode")
           || strName.Equals("SilenceMode"))
        {
            Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#Control#" + strName);
        }

        else if (strName.Contains("SelectMode"))
        {
            Main.Instance.depth = "02";
        }

        else if (strName.Contains("RVCBack01")
            && !Main.Instance.rememberObj.name.Contains("RVCBack02"))
        {

        }

        else if (strName.Contains("RVCBack02")
            && !Main.Instance.rememberObj.name.Contains("RVCBack01"))
        {
            Main.Instance.depth = "01";
        }
    }

    public void AirCleanerIcon(string strName)
    {
        if (strName.Contains("_btn"))
            strName = strName.Replace("_btn", "");

        if (strName.Contains("Power")
            || strName.Contains("Mode"))
        {
            Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#Control#" + strName);
        }

        if (strName.Contains("Air"))
        {
            // 새로고침 기능으로 변경
        }

        else if (strName.Contains("Move01"))
        {
            Main.Instance.depth = "02";
        }

        else if (strName.Contains("Move02"))
        {
            Main.Instance.depth = "03";
        }


        // back button
        else if (strName.Contains("Back01")
            && !Main.Instance.rememberObj.name.Contains("Back02")
            && !Main.Instance.rememberObj.name.Contains("Back03"))
        {

        }

        else if (strName.Contains("Back02")
            && !Main.Instance.rememberObj.name.Contains("Back04"))
        {
            Main.Instance.depth = "01";
        }

        else if (strName.Contains("Back03"))
        {
            Main.Instance.depth = "01";
        }

        else if (strName.Contains("Back04"))
        {
            Main.Instance.depth = "02";
        }
    }

    public void BulbIcon(string strName)
    {
        if (strName.Contains("_btn"))
            strName = strName.Replace("_btn", "");

        if (strName.Contains("Select"))
        {
            if (strName.Contains("0"))
                Main.Instance.deviceNumber = 0;
            else if (strName.Contains("1"))
                Main.Instance.deviceNumber = 1;
            else if (strName.Contains("2"))
                Main.Instance.deviceNumber = 2;

            Main.Instance.UDP.UDP_Send("Device#Choice#" + "Bulb" + "#" + Main.Instance.deviceNumber.ToString());

            return;
        }

        if (strName.Contains("Power")
            || strName.Contains("Color")
            || strName.Contains("Dimming"))
        {
            Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#Control#" + strName);
        }

        else if (strName.Contains("Move01"))
        {
            Main.Instance.depth = "02";
        }

        else if (strName.Contains("Move02"))
        {
            Main.Instance.depth = "03";
        }

        else if (strName.Contains("Back01")
            && !Main.Instance.rememberObj.name.Contains("Back02")
            && !Main.Instance.rememberObj.name.Contains("Back03"))
        {
        }

        else if (strName.Contains("Back02"))
        {
            Main.Instance.depth = "01";
        }

        else if (strName.Contains("Back03"))
        {
            Main.Instance.depth = "01";
        }
    }

    public void GasValveIcon(string strName)
    {
        if (strName.Contains("_btn"))
            strName = strName.Replace("_btn", "");

        if (strName.Contains("Valve"))
            Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#Control#" + strName);

        else if (name.Contains("Back"))
        {
            //Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#" + Main.Instance.depth + "#Control#" + "4");

        }
    }

    public void DoorLockIcon(string strName)
    {
        if (strName.Contains("_btn"))
            strName = strName.Replace("_btn", "");

        if (strName.Contains("DoorLock"))
            Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#Control#" + strName);

        else if (name.Contains("Back"))
        {
            //Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#" + Main.Instance.depth + "#Control#" + "4");

        }
    }

    public void AirDresserIcon(string strName)
    {
        if (strName.Contains("_btn"))
            strName = strName.Replace("_btn", "");

        if (strName.Contains("Operation"))
            Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#Control#" + strName);

        else if (strName.Equals("Back01"))
        {

        }
    }

    public void CCTVIcon(string strName)
    {
        if (strName.Contains("_btn"))
            strName = strName.Replace("_btn", "");

        if (strName.Contains("Select"))
        {
            if (strName.Contains("1"))
                Main.Instance.deviceNumber = 1;
            else if (strName.Contains("2"))
                Main.Instance.deviceNumber = 2;

            PageManager.Instance.CCTV_Init();
            Main.Instance.UDP.UDP_Send("Device#Choice#" + "CCTV" + "#" + Main.Instance.deviceNumber.ToString());

            return;
        }

        if (strName.Contains("Up")
            || strName.Contains("Down")
            || strName.Contains("Left")
            || strName.Contains("Right")
            || strName.Contains("Wide")
            || strName.Contains("Tele"))
        {
            Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#Control#" + strName);
        }

        if (strName.Contains("Streaming"))
        {
            Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#Control#" + strName);

            if (strName.Contains("On"))
            {
                Main.Instance.Status_CCTV[Main.Instance.deviceNumber - 1].SetData(true);
                OggVideoStreamingTexture.Instance.SetScreen(true);

            }
            else if (strName.Contains("Off"))
            {
                Main.Instance.Status_CCTV[Main.Instance.deviceNumber - 1].SetData(false);
                OggVideoStreamingTexture.Instance.SetScreen(false);
            }
        }

        else if (strName.Equals("Mode#Rotate"))
        {
            Main.Instance.depth = "02";
        }

        else if (strName.Equals("Mode#Zoom"))
        {
            Main.Instance.depth = "03";
        }

        else if (strName.Equals("Back01"))
        {
            //Main.Instance.oggTexture.SetScreen(false);
            //Main.Instance.oggTexture.objPlay01.SetActive(false);
            //Main.Instance.oggTexture.objPlay02.SetActive(false);

            //Main.Instance.Set_BlinkObjectList();
        }

        else if (strName.Equals("Back02"))
        {
            Main.Instance.depth = "01";
        }

        else if (strName.Equals("Back03"))
        {
            Main.Instance.depth = "02";
        }
    }

    public void AirConditionerIcon(string strName)
    {
        if (strName.Contains("_btn"))
            strName = strName.Replace("_btn", "");

        if (strName.Contains("Power")
            || strName.Contains("Wind")
            || strName.Contains("Mode"))
        {
            Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#Control#" + strName);
        }

        if (strName.Contains("Temp"))
        {
            int temp = Convert.ToInt32(Main.Instance.Status_AirConditioner.strSetTemp);

            if (strName.Contains("Up"))
            {
                strName = strName.Replace("Up", "");
                Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#Control#" + strName + (temp + 1).ToString());
            }
            if (strName.Contains("Down"))
            {
                strName = strName.Replace("Down", "");
                Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#Control#" + strName + (temp - 1).ToString());
            }
        }
    }

    public void BlindIcon(string strName)
    {
        if (strName.Contains("_btn"))
            strName = strName.Replace("_btn", "");

        if (strName.Contains("Blind"))
            Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#Control#" + strName);
    }

    public void TvIcon(string strName)
    {
        if (strName.Contains("_btn"))
            strName = strName.Replace("_btn", "");

        if (strName.Contains("Power")
            || strName.Contains("Channel")
            || strName.Contains("Volume"))
        {
            Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#Control#" + strName);
        }
    }

    public void InbodyIcon(string strName)
    {
        if (strName.Contains("_btn"))
            strName = strName.Replace("_btn", "");

        // User Change btn
        if (strName.Contains("User"))
        {
            if (strName.Contains("Default"))
            {
                PageInbody.Instance.userMode = PageInbody.User.Default;                
            }
            else if (strName.Contains("Male"))
            {
                PageInbody.Instance.userMode = PageInbody.User.Male;
            }
            else if (strName.Contains("Fe"))
            {
                PageInbody.Instance.userMode = PageInbody.User.Female;
            }
            else if (strName.Contains("Child"))
            {
                PageInbody.Instance.userMode = PageInbody.User.Child;
            }
            Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#Control#" + strName);
        }
        // Chart Change btn
        else
        {
            PageInbody.Instance.ClearChart();

            if (strName.Contains("BFM"))
            {
                PageInbody.nState = 1;
                //PageInbody.Instance.barChart.GetComponent<BarAnimation>().enabled = false;
            }
            else if (strName.Contains("Mineral"))
            {
                PageInbody.nState = 2;
                //PageInbody.Instance.barChart.GetComponent<BarAnimation>().enabled = false;
            }
            else if (strName.Contains("Protein"))
            {
                PageInbody.nState = 3;
                //PageInbody.Instance.barChart.GetComponent<BarAnimation>().enabled = false;
            }
        }
    }

    public void FitIcon(string strName)
    {
        if (strName.Contains("_btn"))
            strName = strName.Replace("_btn", "");

        PageFit.Instance.ClearChart();

        if (strName.Contains("Step"))
        {

            PageFit.nState = 1;
        }
        else if (strName.Contains("BPM"))
        {

            PageFit.nState = 2;
        }
        else if (strName.Contains("Cal"))
        {

            PageFit.nState = 3;
        }
    }

    public void ScaleIcon(string strName)
    {
        if (strName.Contains("_btn"))
            strName = strName.Replace("_btn", "");

        if (strName.Contains("Latest"))
            PageScale.nState = 1;
        else if (strName.Contains("1Week"))
        {
            PageScale.Instance.ClearChart();
            PageScale.nState = 2;
        }
        else if (strName.Contains("2Week"))
        {
            PageScale.Instance.ClearChart();
            PageScale.nState = 3;
        }
    }

}                                                                                                                                    
