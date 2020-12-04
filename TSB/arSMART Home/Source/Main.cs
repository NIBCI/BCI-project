using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using System;
using System.IO;
using UnityEngine.UI;
using System.Net;

using UnityEngine.Networking;
using System.Net.Sockets;
using System.Linq;
using UnityEngine.Video;

public class Main : MonoBehaviour
{
    private static Main _instance;
    public static Main Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = FindObjectOfType<Main>();
                if (!_instance)
                {
                    //Debug.Log("Fail");
                }
            }
            return _instance;
        }
    }


    public GameObject udpObj;
    public BCI_UDP UDP;

    public string recvData = "";
    public GameObject text_recv;

    public GameObject[] orgObjs;
    public GameObject[] devObjs;
    public GameObject[] blinkObjs;
    public GameObject[] commonObjs;

    public GameObject blinkObj;
    public GameObject n1Obj;
    public GameObject n2Obj;
    public GameObject n3Obj;
    public GameObject n4Obj;

    public GameObject rememberObj = null;

    //public string appMode = "";
    public string org = "";
    public string shape = "";
    //public string device = "";
    public string depth = "";

    public bool isToggle = false;
    public bool isRing = false;

    // for UNIST sequence
    private int[] unist_Sequence;
    public float unist_frequency;
    public bool isSequence;
    public bool isStartRay;
    public bool isTraining;
    public int trial;
    public float breakTime;
    public GameObject trial_Number;
    public int sendCnt;

    //상태 표시
    public Text Status;
    public bool b_st = false;

    public string strOverlap = "";

    // streaming
    //public OggVideoStreamingTexture oggTexture;

    // Unist Stop Signal
    public bool isStopSignal;
    public Coroutine runningCoroutine;

    // Device Status Struct
    public DeviceStatus.Refrigerator Status_Refrigerator;
    public DeviceStatus.RVC Status_RVC;
    public DeviceStatus.AirConditioner Status_AirConditioner;
    public DeviceStatus.AirCleaner Status_AirCleaner;
    public DeviceStatus.AirDresser Status_AirDresser;
    public DeviceStatus.Bulb[] Status_Bulb = new DeviceStatus.Bulb[2];
    public DeviceStatus.DoorLock Status_DoorLock;
    public DeviceStatus.GasValve Status_GasValve;
    public DeviceStatus.TV Status_TV;
    public DeviceStatus.SmartPlug Status_SmartPlug;
    public DeviceStatus.CCTV[] Status_CCTV = new DeviceStatus.CCTV[2];
    public DeviceStatus.Blind Status_Blind;

    public DeviceStatus.Inbody Status_Inbody;
    public DeviceStatus.Fit Status_Fit;
    public DeviceStatus.Scale Status_Scale;


    //public string[] arrDeviceNumber = new string[] { "1", "2", "3", "4", "5" };
    public int deviceNumber = 1;

    public bool isAppStart;

    public int dbLine;

    public enum AppMode
    {
        None,
        Main,

        Energy_Total,
        Energy_Device01,
        Energy_Device02,
        Energy_Device03,
        Energy_Device04,

        Device_Refrigerator,
        Device_RVC,
        Device_AirCleaner,
        Device_AirDresser,
        Device_Bulb00,
        Device_Bulb01,
        Device_Bulb02,
        Device_DoorLock,
        Device_GasValve,
        Device_TV,
        Device_CCTV00,
        Device_CCTV01,
        Device_CCTV02,
        Device_Blind
    }
    public AppMode ApplicationMode = AppMode.None;

    public enum Device
    {
        None,
        Refrigerator,
        RVC,
        AirCleaner,
        Bulb,
        DoorLock,
        GasValve,
        Blind,
        AirConditioner,
        CCTV,
        TV,
        AirDresser,
        Inbody,
        Fit,
        Scale
    }
    public Device DeviceMode = Device.None;

    public enum DeviceDepth
    {
        Page0,
        Page1,
        Page2,
        Page3,
        Page4
    }
    public DeviceDepth BCI_Page = DeviceDepth.Page1;

    public enum Platform
    {
        None,
        AR,
        P300,
        SSVEP
    }
    public Platform PlatformMode = Platform.None;

    //ray 후 2sec 지났는지 확인
    public bool isAbleBtn = false;

    // bci 기능 사용 여부
    public bool isBCI = false;
    // true 이면 ssvep, false 이면 p300
    public bool isSSVEP = false;

    public bool isRecognition = false;

    public Text notice;
    public string strRayName;

    public GameObject test;
    public VideoPlayer aa;
    public RawImage bb;

    private void Awake()
    {
        dbLine = 3;
    }

    // Use this for initialization
    void Start()
    {
        Init();

        UnistInit();
    }

    void Init()
    {
        isAppStart = true;
        org = "TSB";

        UDP = udpObj.GetComponent<BCI_UDP>();

        //Set_OrganizationObject();
        //Set_DeviceObject();
        //Set_CommonObject();

        ApplicationMode = AppMode.Main;

        sendCnt = 1;

        //oggTexture = GameObject.Find("Screen").transform.gameObject.GetComponent<OggVideoStreamingTexture>();

        isStopSignal = false;
        runningCoroutine = null;

        notice = GameObject.Find("Mian Screen").transform.Find("Main Canvas").transform.Find("PageManager").transform.Find("Page_Common").transform.Find("Notice_txt").GetComponent<Text>();
        //strRayName = "";

        BCI_Page = DeviceDepth.Page1;

        Status_Refrigerator.InitArr(3);
        Status_AirCleaner.InitArr(3);
        Status_AirConditioner.InitArr(3);
        Status_AirDresser.InitArr(3);
        Status_Blind.InitArr(3);
        Status_Bulb[0].InitArr(3);
        Status_Bulb[1].InitArr(3);
        Status_DoorLock.InitArr(3);
        Status_GasValve.InitArr(3);
        Status_RVC.InitArr(3);
        Status_Inbody.InitArr(5);
        Status_Fit.InitArr(7);
        Status_Scale.InitArr(14);



        // debug        
        Status_DoorLock.SetData("close", "55");
        Status_GasValve.SetData("close");
        Status_Blind.SetData("close");
        Status_TV.SetData("off");
        Status_CCTV[0].SetData(false);
        Status_CCTV[1].SetData(false);            
        //Status_Refrigerator.SetData("on", "off", "allOpen", "1", "-19", "0", "-20", "freezer");
        //Status_RVC.SetData("cleaning", "turbo");
        //Status_Bulb[0].SetData("on", "255", "255", "0", "35");
        //Status_Bulb[1].SetData("on", "0", "0", "255", "100");
        //Status_AirCleaner.SetData("on", "auto", "1", "24", "35");
        //Status_AirConditioner.SetData("on", "cool", "turbo", "27", "21", "10");

        //GateWay#Inbody#69#72.4#30.5#18.1#23.6#25.0#0.87#7#1542#2203#67.4#-5.0#-8.0#3.0#30.0#M#175
        Status_Inbody.SetData("0", "0.0", "0.0", "0.0", "0.0", "0.0", "0.0", "0", "0", "0", "0.0", "0.0", "0.0", "0.0", "0.0", "M", "0", "0.0", "0", "0.0");
        Status_Fit.SetData("0", "0", "0");
        Status_Scale.SetData("0.0", "00.00 00:00", "0.0", "00.00 00:00");

        //Status_AirDresser.SetData("standard", "dustFree", "ready", "12", "off", "on");

        isBCI = true;
        isSSVEP = false;

        //test = GameObject.Find("Video").gameObject;
        //aa = test.GetComponent<VideoPlayer>();
        //aa.Prepare();
        //bb = test.GetComponent<RawImage>();
        //bb.texture = aa.texture;
        //aa.Play();
        //Debug.Log("end");
    }

    void UnistInit()
    {
        // unist set
        unist_frequency = 0.1f;
        breakTime = 2f;
        isSequence = false;
        isStartRay = false;
        isTraining = false;
        trial_Number = GameObject.Find("Training Canvas").transform.Find("TrainingNumber").gameObject;
        trial_Number.SetActive(false);
    }

    void Update()
    {
        if (isAppStart.Equals(false))
            return;

        // Unist stop signal 받으면 sequence 강제 중지
        if (isStopSignal.Equals(true))
        {
            StopUNIST_Sequence();
            return;
        }

    }

    void InitData()
    {
        UDP.UDP_Send("TSB" + "#" + DeviceMode + "#Sequence" + "#" + "11");
    }

    //void Set_OrganizationObject()
    //{
    //	int num = GameObject.Find("Organization_Objects").transform.childCount;

    //	orgObjs = new GameObject[num];

    //	for (int i = 0; i < orgObjs.Length; i++)
    //	{
    //		orgObjs[i] = GameObject.Find("Organization_Objects").transform.GetChild(i).transform.GetChild(0).gameObject;
    //	}
    //}

    //void Set_DeviceObject()
    //{
    //	int num = GameObject.Find("Device_Objects").transform.childCount;

    //	devObjs = new GameObject[num];

    //	for (int i = 0; i < devObjs.Length; i++)
    //	{
    //		devObjs[i] = GameObject.Find("Device_Objects").transform.GetChild(i).transform.GetChild(0).gameObject;
    //	}
    //}

    //void Set_CommonObject()
    //{
    //	int num = GameObject.Find("Common_Objects").transform.childCount;

    //	commonObjs = new GameObject[num];

    //	for (int i = 0; i < commonObjs.Length; i++)
    //	{
    //		commonObjs[i] = GameObject.Find("Common_Objects").transform.GetChild(i).transform.GetChild(0).gameObject;
    //	}
    //}


    GameObject Get_BlinkObject(string name)
    {
        GameObject find = null;

        for (int i = 0; i < blinkObj.transform.childCount; i++)
        {
            if (blinkObj.transform.GetChild(i).gameObject.name.Equals(name))
                find = blinkObj.transform.GetChild(i).gameObject;
        }

        return find;
    }

    void Set_BlinkObject()
    {
        switch (DeviceMode)
        {
            case Device.None:
                if (depth.Equals("91"))
                {
                    // depth 바뀔 때, 전의 icon 제거
                    if (n4Obj != Get_BlinkObject("Back01"))
                        Show_BlinkObject(false);

                    n1Obj = Get_BlinkObject("HomeAppliance");
                    n2Obj = Get_BlinkObject("IoTDevice");
                    n3Obj = Get_BlinkObject("SmartFunction");
                    n4Obj = Get_BlinkObject("Back01");
                }

                else if (depth.Equals("92"))
                {
                    // depth 바뀔 때, 전의 icon 제거
                    if (n4Obj != Get_BlinkObject("Back02"))
                        Show_BlinkObject(false);

                    n1Obj = Get_BlinkObject("Refrigerator");
                    n2Obj = Get_BlinkObject("RVC");
                    n3Obj = Get_BlinkObject("AirCleaner");
                    n4Obj = Get_BlinkObject("Back02");
                }

                else if (depth.Equals("93"))
                {
                    // depth 바뀔 때, 전의 icon 제거
                    if (n4Obj != Get_BlinkObject("Back03"))
                        Show_BlinkObject(false);

                    n1Obj = Get_BlinkObject("Bulb");
                    n2Obj = Get_BlinkObject("DoorLock");
                    n3Obj = Get_BlinkObject("GasValve");
                    n4Obj = Get_BlinkObject("Back03");
                }

                else if (depth.Equals("94"))
                {
                    // depth 바뀔 때, 전의 icon 제거
                    if (n4Obj != Get_BlinkObject("Back04"))
                        Show_BlinkObject(false);

                    n1Obj = Get_BlinkObject("AirDresser");
                    n2Obj = Get_BlinkObject("AirConditioner");
                    n3Obj = Get_BlinkObject("CCTV");
                    n4Obj = Get_BlinkObject("Back04");
                }
                break;

            case Device.Refrigerator:

                //if (depth.Equals("01"))
                //{
                //	// depth 바뀔 때, 전의 icon 제거
                //	if (n4Obj == Get_BlinkObject(shape + "_Back02"))
                //		Show_BlinkObject(false);

                //	if (refState[0] == 0)
                //	{
                //		Get_BlinkObject(shape + "_RapidFridgeOff").transform.GetChild(0).gameObject.SetActive(false);
                //		n1Obj = Get_BlinkObject(shape + "_RapidFridgeOn");
                //	}
                //	else
                //	{
                //		Get_BlinkObject(shape + "_RapidFridgeOn").transform.GetChild(0).gameObject.SetActive(false);
                //		n1Obj = Get_BlinkObject(shape + "_RapidFridgeOff");
                //	}

                //	if (refState[1] == 0)
                //	{
                //		Get_BlinkObject(shape + "_RapidFreezingOff").transform.GetChild(0).gameObject.SetActive(false);
                //		n2Obj = Get_BlinkObject(shape + "_RapidFreezingOn");
                //	}
                //	else
                //	{
                //		Get_BlinkObject(shape + "_RapidFreezingOn").transform.GetChild(0).gameObject.SetActive(false);
                //		n2Obj = Get_BlinkObject(shape + "_RapidFreezingOff");
                //	}

                //	n3Obj = Get_BlinkObject(shape + "_Status");
                //	n4Obj = Get_BlinkObject(shape + "_Back01");
                //}

                //else if (depth.Equals("02"))
                //{
                //	// depth 바뀔 때, 전의 icon 제거
                //	if (n4Obj == Get_BlinkObject(shape + "_Back01"))
                //		Show_BlinkObject(false);

                //	RefStateOff();

                //	n1Obj = Get_BlinkObject(shape + "_FridgeTemp0" + (refState[2] + 1).ToString());
                //	n2Obj = Get_BlinkObject(shape + "_FreezingTemp0" + (refState[3] + 1).ToString());
                //	n3Obj = Get_BlinkObject(shape + "_Door0" + (refState[4] + 1).ToString());
                //	n4Obj = Get_BlinkObject(shape + "_Back02");
                //}

                break;

            case Device.RVC:

                if (depth.Equals("01"))
                {
                    // depth 바뀔 때, 전의 icon 제거
                    if (n2Obj == Get_BlinkObject("NormalMode"))
                        Show_BlinkObject(false);

                    if (Status_RVC.strStatus.Equals("cleaning"))
                    {
                        Get_BlinkObject("Auto").transform.GetChild(0).gameObject.SetActive(false);
                        n1Obj = Get_BlinkObject(shape + "Stop");
                    }
                    else
                    {
                        Get_BlinkObject("Stop").transform.GetChild(0).gameObject.SetActive(false);
                        n1Obj = Get_BlinkObject("Auto");
                    }

                    n2Obj = Get_BlinkObject("Recharge");
                    n3Obj = Get_BlinkObject("SelectMode");
                    n4Obj = Get_BlinkObject("Back01");
                }

                else if (depth.Equals("02"))
                {
                    // depth 바뀔 때, 전의 icon 제거
                    if (n2Obj == Get_BlinkObject("Recharge"))
                        Show_BlinkObject(false);

                    n1Obj = Get_BlinkObject("TurboMode");
                    n2Obj = Get_BlinkObject("NormalMode");
                    n3Obj = Get_BlinkObject("SilenceMode");
                    n4Obj = Get_BlinkObject("Back02");
                }

                break;

            case Device.AirCleaner:

                if (depth.Equals("01"))
                {
                    // depth 바뀔 때, 전의 icon 제거
                    if (n4Obj != Get_BlinkObject("Back01"))
                        Show_BlinkObject(false);

                    if (Status_AirCleaner.strPower.Equals("off"))
                    {
                        Get_BlinkObject("Power#Off").transform.GetChild(0).gameObject.SetActive(false);
                        n1Obj = Get_BlinkObject("Power#On");
                    }
                    else
                    {
                        Get_BlinkObject("Power#On").transform.GetChild(0).gameObject.SetActive(false);
                        n1Obj = Get_BlinkObject("Power#Off");
                    }

                    n2Obj = Get_BlinkObject("Select#Move01");
                    n3Obj = Get_BlinkObject("Select#Move02");
                    n4Obj = Get_BlinkObject("Back01");
                }
                else if (depth.Equals("02"))
                {
                    // depth 바뀔 때, 전의 icon 제거
                    if (n4Obj != Get_BlinkObject("Back02"))
                        Show_BlinkObject(false);

                    n1Obj = Get_BlinkObject("Mode#Auto");
                    n2Obj = Get_BlinkObject("Mode#Sleep");
                    n3Obj = Get_BlinkObject("Status#Air");
                    n4Obj = Get_BlinkObject("Back02");
                }
                else if (depth.Equals("03"))
                {
                    // depth 바뀔 때, 전의 icon 제거
                    if (n4Obj != Get_BlinkObject("Back03"))
                        Show_BlinkObject(false);

                    n1Obj = Get_BlinkObject("Mode#Low");
                    n2Obj = Get_BlinkObject("Mode#Medium");
                    n3Obj = Get_BlinkObject("Mode#High");
                    n4Obj = Get_BlinkObject("Back03");
                }
                break;

            case Device.Bulb:

                if (depth.Equals("01"))
                {
                    // depth 바뀔 때, 전의 icon 제거
                    if (n2Obj == Get_BlinkObject("Color#0#255#0")
                        || n2Obj == Get_BlinkObject("Dimming#60"))
                        Show_BlinkObject(false);

                    if (Status_Bulb[deviceNumber - 1].strSwitch.Equals("off"))
                    {
                        Get_BlinkObject("Power#off").transform.GetChild(0).gameObject.SetActive(false);
                        n1Obj = Get_BlinkObject("Power#on");
                    }
                    else
                    {
                        Get_BlinkObject("Power#on").transform.GetChild(0).gameObject.SetActive(false);
                        n1Obj = Get_BlinkObject("Power#off");
                    }

                    n2Obj = Get_BlinkObject("Select#Move01");
                    n3Obj = Get_BlinkObject("Select#Move02");
                    n4Obj = Get_BlinkObject("Bakc01");
                }

                // color change
                else if (depth.Equals("02"))
                {
                    // depth 바뀔 때, 전의 icon 제거
                    if (n2Obj == Get_BlinkObject("Select#Move01"))
                        Show_BlinkObject(false);

                    n1Obj = Get_BlinkObject("Color#255#0#0");
                    n2Obj = Get_BlinkObject("Color#0#255#0");
                    n3Obj = Get_BlinkObject("Color#0#0#255");
                    n4Obj = Get_BlinkObject("Back02");
                }

                // dimming change
                else if (depth.Equals("03"))
                {
                    // depth 바뀔 때, 전의 icon 제거
                    if (n2Obj == Get_BlinkObject("Select#Move01"))
                        Show_BlinkObject(false);

                    n1Obj = Get_BlinkObject("Dimming#20");
                    n2Obj = Get_BlinkObject("Dimming#60");
                    n3Obj = Get_BlinkObject("Dimming#100");
                    n4Obj = Get_BlinkObject("Back03");
                }
                break;

            case Device.DoorLock:

                if (depth.Equals("01"))
                {
                    n1Obj = Get_BlinkObject(shape + "_DoorOpen");
                    n2Obj = Get_BlinkObject(shape + "_DoorClose");
                    n3Obj = Get_BlinkObject(shape + "_View");
                    n4Obj = Get_BlinkObject(shape + "_Back");
                }
                break;

            case Device.GasValve:

                if (depth.Equals("01"))
                {
                    n1Obj = Get_BlinkObject(shape + "_ValveOpen");
                    n2Obj = Get_BlinkObject(shape + "_ValveClose");
                    n3Obj = Get_BlinkObject(shape + "_Battery");
                    n4Obj = Get_BlinkObject(shape + "_Back");
                }
                break;

            //case :

            //	n1Obj = Get_BlinkObject("Training01");
            //	n2Obj = Get_BlinkObject("Training02");
            //	n3Obj = Get_BlinkObject("Training03");
            //	n4Obj = Get_BlinkObject("Training04");
            //	break;

            case Device.CCTV:

                if (depth.Equals("01"))
                {
                    // depth 바뀔 때, 전의 icon 제거
                    if (n1Obj == Get_BlinkObject("Rotate#Left")
                        || n1Obj == Get_BlinkObject("Zoom#Wide"))
                        Show_BlinkObject(false);

                    n1Obj = Get_BlinkObject("Rotate#Up");
                    n2Obj = Get_BlinkObject("Rotate#Down");
                    n3Obj = Get_BlinkObject("Mode#Rotate");
                    n4Obj = Get_BlinkObject("Back01");
                }
                else if (depth.Equals("02"))
                {
                    // depth 바뀔 때, 전의 icon 제거
                    if (n1Obj == Get_BlinkObject("Rotate#Up")
                         || n1Obj == Get_BlinkObject("Zoom#Wide"))
                        Show_BlinkObject(false);

                    n1Obj = Get_BlinkObject("Rotate#Left");
                    n2Obj = Get_BlinkObject("Rotate#Right");
                    n3Obj = Get_BlinkObject("Mode#Zoom");
                    n4Obj = Get_BlinkObject("Back02");
                }
                else if (depth.Equals("03"))
                {
                    // depth 바뀔 때, 전의 icon 제거
                    if (n1Obj == Get_BlinkObject("Rotate#Left")
                        || n1Obj == Get_BlinkObject("Rotate#Up"))
                        Show_BlinkObject(false);

                    n1Obj = Get_BlinkObject("Zoom#Wide");
                    n2Obj = Get_BlinkObject("Zoom#Tele");
                    n3Obj = Get_BlinkObject("None");
                    n4Obj = Get_BlinkObject("Back03");
                }
                break;

            case Device.AirDresser:

                if (depth.Equals("01"))
                {
                    n1Obj = Get_BlinkObject("Operation#Run");
                    n2Obj = Get_BlinkObject("Operation#Pause");
                    n3Obj = Get_BlinkObject("Operation#Stop");
                    n4Obj = Get_BlinkObject("Back01");
                }

                break;

            default:
                n1Obj = null;
                n2Obj = null;
                n3Obj = null;
                n4Obj = null;
                break;
        }
    }


    // 자극 icon show & hide
    void Show_BlinkObject(bool isOn)
    {
        if (n1Obj == null)
            return;

        if (org.Equals("UNIST"))
        {   // start_ray on 됬을 때 자극 1회(40번) 시작
            if (isStartRay == true)
            {
                // start obj show
                if (isSequence == false)
                {
                    n1Obj.transform.GetChild(0).gameObject.SetActive(isOn);
                    n2Obj.transform.GetChild(0).gameObject.SetActive(isOn);
                    n3Obj.transform.GetChild(0).gameObject.SetActive(isOn);
                    n4Obj.transform.GetChild(0).gameObject.SetActive(isOn);

                    if (isTraining == false)
                    {
                        ChangeTexture(true);
                        runningCoroutine = StartCoroutine(P300_Sequence());
                    }
                    else
                    {
                        runningCoroutine = StartCoroutine(P300_Training());
                    }
                }
            }

            // start_ray off, 레이 안볼 때 icon 상황
            else if (isStartRay == false)
            {
                n1Obj.transform.GetChild(0).gameObject.SetActive(isOn);
                n2Obj.transform.GetChild(0).gameObject.SetActive(isOn);
                n3Obj.transform.GetChild(0).gameObject.SetActive(isOn);
                n4Obj.transform.GetChild(0).gameObject.SetActive(isOn);

                if (isTraining == false)
                    ChangeTexture(true);
            }
        }

        else
        {
            n1Obj.transform.GetChild(0).gameObject.SetActive(isOn);
            n2Obj.transform.GetChild(0).gameObject.SetActive(isOn);
            n3Obj.transform.GetChild(0).gameObject.SetActive(isOn);
            n4Obj.transform.GetChild(0).gameObject.SetActive(isOn);
            ChangeTexture(false);

            // start obj unshow
        }
    }

    public int[] GetPattern()
    {
        int[] arr = new int[40];
        System.Random rand = new System.Random((int)DateTime.Now.Ticks);
        int first;
        int last = 999;

        for (int i = 0; i < 10; i++)
        {
            // 1 ~ 4 random create
            int[] sample = Enumerable.Range(1, 4).OrderBy(o => rand.Next()).ToArray();
            first = sample[0];

            // block last와 새 blcok first compare 후 중복 방지
            if (i >= 1)
            {
                while (first == last)
                {
                    sample = Enumerable.Range(1, 4).OrderBy(o => rand.Next()).ToArray();
                    first = sample[0];
                }
            }

            for (int j = 0; j < 4; j++)
            {
                arr[(i * 4) + (j)] = sample[j];
            }

            last = sample[3];
        }

        return arr;
    }

    IEnumerator P300_Sequence()
    {
        GameObject[] unistObj;
        unistObj = new GameObject[4] { n1Obj, n2Obj, n3Obj, n4Obj };

        isSequence = true;

        yield return new WaitForSeconds(breakTime);

        for (int i = 0; i < sendCnt + 1; i++)
        {
            UDP.UDP_Send(org + "#" + DeviceMode + "#Sequence" + "#" + "11");
        }

        yield return new WaitForSeconds(0.1f);

        unist_Sequence = GetPattern();

        for (int i = 0; i < sendCnt + 1; i++)
        {
            // start signal
            UDP.UDP_Send(org + "#" + DeviceMode + "#Sequence" + "#" + "12");
        }

        for (float i = 0; i < unist_Sequence.Length; i = i + 0.5f)
        {
            // 정수 일 때(base color)
            if (i / 1.00 == (int)i)
            {

                for (int j = 0; j < 4; j++)
                {
                    unistObj[j].transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(90, 89, 255, 255);
                }
            }
            // 실수 일 때(change color)
            else
            {
                for (int m = 0; m < sendCnt; m++)
                {
                    UDP.UDP_Send(org + "#" + DeviceMode + "#Sequence" + "#" + (unist_Sequence[(int)i]).ToString());
                }

                unistObj[unist_Sequence[(int)i] - 1].transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(196, 244, 122, 255);

            }

            yield return new WaitForSeconds(unist_frequency);
        }

        // end signal
        for (int i = 0; i < sendCnt + 1; i++)
        {
            UDP.UDP_Send(org + "#" + DeviceMode + "#Sequence" + "#" + "13");
        }

        // base color로 reset
        for (int j = 0; j < 4; j++)
        {
            unistObj[j].transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(90, 89, 255, 255);
        }

        // sequence 끝남 알림
        isSequence = false;
        // ray 다시 시작할 수 있음 알림
        isStartRay = false;
    }

    IEnumerator P300_Training()
    {
        GameObject[] unistObj;
        unistObj = new GameObject[4] { n1Obj, n2Obj, n3Obj, n4Obj };
        trial_Number.SetActive(true);
        trial_Number.GetComponent<Text>().text = "1";

        isSequence = true;

        for (int i = 0; i < sendCnt + 1; i++)
        {
            UDP.UDP_Send(org + "#" + DeviceMode + "#" + "Trial" + "#" + trial.ToString());
        }

        for (int k = 0; k < trial; k++)
        {
            if (k == 0)
                yield return new WaitForSeconds(breakTime);

            for (int i = 0; i < sendCnt + 1; i++)
            {
                UDP.UDP_Send(org + "#" + DeviceMode + "#TrainingSequence" + "#" + "11");
            }

            yield return new WaitForSeconds(0.1f);

            for (int i = 0; i < sendCnt + 1; i++)
            {
                UDP.UDP_Send(org + "#" + DeviceMode + "#TrainingSequence" + "#" + ((k % 4) + 1).ToString());
            }

            yield return new WaitForSeconds(0.1f);

            trial_Number.GetComponent<Text>().text = ((k % 4) + 1).ToString();
            unist_Sequence = GetPattern();

            // start signal
            for (int i = 0; i < sendCnt + 1; i++)
            {
                UDP.UDP_Send(org + "#" + DeviceMode + "#TrainingSequence" + "#" + "12");
            }

            for (float i = 0; i < unist_Sequence.Length; i = i + 0.5f)
            {
                // 정수 일 때(base color)
                if (i / 1.00 == (int)i)
                {
                    for (int j = 0; j < 4; j++)
                    {
                        unistObj[j].transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(90, 89, 255, 255);
                    }
                }
                // 실수 일 때(change color)
                else
                {
                    for (int m = 0; m < sendCnt; m++)
                    {
                        UDP.UDP_Send(org + "#" + DeviceMode + "#TrainingSequence" + "#" + (unist_Sequence[(int)i]).ToString());
                    }

                    unistObj[unist_Sequence[(int)i] - 1].transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(196, 244, 122, 255);

                }
                yield return new WaitForSeconds(unist_frequency);
            }

            // end signal
            for (int i = 0; i < sendCnt + 1; i++)
            {
                UDP.UDP_Send(org + "#" + DeviceMode + "#TrainingSequence" + "#" + "13");
            }

            // base color로 reset
            for (int j = 0; j < 4; j++)
            {
                unistObj[j].transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(90, 89, 255, 255);
            }

            if (k + 1 != trial)
            {
                trial_Number.GetComponent<Text>().text = (((k + 1) % 4) + 1).ToString();
                yield return new WaitForSeconds(breakTime);
            }
        }

        // training end send
        for (int i = 0; i < sendCnt + 1; i++)
        {
            UDP.UDP_Send(org + "#" + DeviceMode + "#TrainingSequence" + "#" + "99");
        }

        // sequence 끝남 알림
        isSequence = false;
        // ray 다시 시작할 수 있음 알림
        isStartRay = false;
        // trial number 삭제
        trial_Number.SetActive(false);
    }

    public void StopUNIST_Sequence()
    {
        if (runningCoroutine != null)
            StopCoroutine(runningCoroutine);

        runningCoroutine = null;
        isStopSignal = false;
        isSequence = false;
        isStartRay = false;
        trial_Number.SetActive(false);
    }

    void ChangeTexture(bool isChange)
    {
        if (isChange == true)
        {
            if (isTraining == false)
            {
                n1Obj.transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(0, 0, 0, 255);
                n2Obj.transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(0, 0, 0, 255);
                n3Obj.transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(0, 0, 0, 255);
                n4Obj.transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(0, 0, 0, 255);
            }
            else
            {
                n1Obj.transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(0, 0, 0, 0);
                n2Obj.transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(0, 0, 0, 0);
                n3Obj.transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(0, 0, 0, 0);
                n4Obj.transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(0, 0, 0, 0);
            }
        }

        else
        {
            n1Obj.transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(255, 255, 255, 255);
            n2Obj.transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(255, 255, 255, 255);
            n3Obj.transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(255, 255, 255, 255);
            n4Obj.transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(255, 255, 255, 255);

            n1Obj.transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(15, 118, 199, 255);
            n2Obj.transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(15, 118, 199, 255);
            n3Obj.transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(15, 118, 199, 255);
            n4Obj.transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(15, 118, 199, 255);

        }
    }

}
