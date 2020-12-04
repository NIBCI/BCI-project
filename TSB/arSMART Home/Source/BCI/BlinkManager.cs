using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlinkManager : MonoBehaviour
{
    private static BlinkManager _instance;
    public static BlinkManager Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = FindObjectOfType<BlinkManager>();
                if (!_instance)
                {
                    //Debug.Log("Fail");
                }
            }
            return _instance;
        }
    }

    public GameObject objP300;
    public GameObject objSSVEP;

    public GameObject[] arr_objBlink;
    public GameObject[] arr_objIndex;
    public GameObject[] arr_backupIndex;
    public GameObject objDevice;


    private void Awake()
    {

        arr_objIndex = new GameObject[4];
        arr_backupIndex = new GameObject[4];
    }

    // Use this for initialization
    void Start()
    {
        objP300 = transform.Find("P300").gameObject;
        objSSVEP = transform.Find("SSVEP").gameObject;

        arr_objBlink = new GameObject[objP300.transform.childCount];

        for (int i = 0; i < objP300.transform.childCount; i++)
        {
            arr_objBlink[i] = objP300.transform.GetChild(i).gameObject;
        }

        InitBCI();
    }

    void InitBCI()
    {
        objP300.SetActive(false);
        objSSVEP.SetActive(false);
    }

    // Update is called once per frame
    void Update()
    {
        SetBCI();

        if (Main.Instance.isStartRay)
            return;

        if (P300_Manager.Instance.isTraining == true)
        {
            arr_objIndex[0] = Get_BlinkObject("Training01");
            arr_objIndex[1] = Get_BlinkObject("Training02");
            arr_objIndex[2] = Get_BlinkObject("Training03");
            arr_objIndex[3] = Get_BlinkObject("Training04");

            for (int i = 0; i < arr_objIndex.Length; i++)
            {
                arr_objIndex[i].transform.GetChild(0).gameObject.SetActive(true);
            }
        }

        else
        {
            Set_BlinkObject();
            Set_StartObject();
        }

    }

    void SetBCI()
    {
        if (Main.Instance.isBCI.Equals(false))
        {
            objP300.SetActive(false);
            objSSVEP.SetActive(false);
        }
        else
        {
            if (Main.Instance.isSSVEP.Equals(true))
            {
                objP300.SetActive(false);
                objSSVEP.SetActive(true);

                if (!arr_objBlink[0].activeInHierarchy)
                {
                    for (int i = 0; i < objSSVEP.transform.childCount; i++)
                    {
                        arr_objBlink[i] = objSSVEP.transform.GetChild(i).gameObject;
                    }
                }
            }
            else
            {
                objP300.SetActive(true);
                objSSVEP.SetActive(false);

                if (!arr_objBlink[0].activeInHierarchy)
                {
                    for (int i = 0; i < objP300.transform.childCount; i++)
                    {
                        arr_objBlink[i] = objP300.transform.GetChild(i).gameObject;
                    }
                }
            }
        }

    }


    GameObject Get_BlinkObject(string name)
    {
        GameObject find = null;

        if (P300_Manager.Instance.isTraining == true)
        {
            objDevice = Get_DeviceObject("Training");
        }

        else
            objDevice = Get_DeviceObject(Main.Instance.DeviceMode.ToString());

        if (objDevice)
        {
            for (int i = 0; i < objDevice.transform.childCount; i++)
            {
                if (objDevice.transform.GetChild(i).gameObject.name.Equals(name))
                {
                    find = objDevice.transform.GetChild(i).gameObject;
                }
            }
        }
        return find;
    }

    GameObject Get_DeviceObject(string name)
    {
        GameObject find = null;
        string strName = "Blink_" + name;

        for (int i = 0; i < arr_objBlink.Length; i++)
        {
            if (arr_objBlink[i])
            {
                if (arr_objBlink[i].name.Equals(strName))
                    find = arr_objBlink[i];
            }
        }

        return find;
    }

    // device 추가 될때마다 여기서 blink object 추가해 줘야함
    void Set_BlinkObject()
    {
        switch (Main.Instance.DeviceMode)
        {
            case Main.Device.None:
                if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page0))
                    ;
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page1))
                {
                    arr_objIndex[0] = Get_BlinkObject("Integration01");
                    arr_objIndex[1] = Get_BlinkObject("Integration02");
                    arr_objIndex[2] = Get_BlinkObject("Integration03");
                    arr_objIndex[3] = Get_BlinkObject("Next01");
                }
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page2))
                {
                    arr_objIndex[0] = Get_BlinkObject("Integration04");
                    arr_objIndex[1] = Get_BlinkObject("Integration05");
                    arr_objIndex[2] = Get_BlinkObject("Integration06");
                    arr_objIndex[3] = Get_BlinkObject("Back01");
                }
                break;

            case Main.Device.Refrigerator:

                if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page0))
                    ;
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page1))
                {
                    arr_objIndex[0] = Get_BlinkObject("RapidFridge");
                    arr_objIndex[1] = Get_BlinkObject("RapidFreezing");
                    arr_objIndex[2] = Get_BlinkObject("Status");
                    arr_objIndex[3] = Get_BlinkObject("Back01");
                }
                break;

            case Main.Device.RVC:

                if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page0))
                    ;
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page1))
                {
                    arr_objIndex[0] = Get_BlinkObject("Auto");
                    arr_objIndex[1] = Get_BlinkObject("Recharge");
                    arr_objIndex[2] = Get_BlinkObject("SelectMode");
                    arr_objIndex[3] = Get_BlinkObject("Back01");
                }
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page2))
                {
                    arr_objIndex[0] = Get_BlinkObject("TurboMode");
                    arr_objIndex[1] = Get_BlinkObject("NormalMode");
                    arr_objIndex[2] = Get_BlinkObject("SilenceMode");
                    arr_objIndex[3] = Get_BlinkObject("Back02");
                }
                break;

            case Main.Device.Bulb:

                if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page0))
                    ;
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page1))
                {
                    arr_objIndex[0] = Get_BlinkObject("Power#on");
                    arr_objIndex[1] = Get_BlinkObject("Select#Move01");
                    arr_objIndex[2] = Get_BlinkObject("Select#Move02");
                    arr_objIndex[3] = Get_BlinkObject("Back01");
                }
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page2))
                {
                    arr_objIndex[0] = Get_BlinkObject("Color#255#0#0");
                    arr_objIndex[1] = Get_BlinkObject("Color#0#255#0");
                    arr_objIndex[2] = Get_BlinkObject("Color#0#0#255");
                    arr_objIndex[3] = Get_BlinkObject("Back02");
                }
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page3))
                {
                    arr_objIndex[0] = Get_BlinkObject("Dimming#20");
                    arr_objIndex[1] = Get_BlinkObject("Dimming#60");
                    arr_objIndex[2] = Get_BlinkObject("Dimming#100");
                    arr_objIndex[3] = Get_BlinkObject("Back03");
                }
                break;

            case Main.Device.AirCleaner:

                if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page0))
                    ;
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page1))
                {
                    arr_objIndex[0] = Get_BlinkObject("Power#On");
                    arr_objIndex[1] = Get_BlinkObject("Select#Move01");
                    arr_objIndex[2] = Get_BlinkObject("Select#Move02");
                    arr_objIndex[3] = Get_BlinkObject("Back01");
                }
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page2))
                {
                    arr_objIndex[0] = Get_BlinkObject("Mode#Auto");
                    arr_objIndex[1] = Get_BlinkObject("Mode#Sleep");
                    arr_objIndex[2] = Get_BlinkObject("Status#Air");
                    arr_objIndex[3] = Get_BlinkObject("Back02");
                }
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page3))
                {
                    arr_objIndex[0] = Get_BlinkObject("Mode#Low");
                    arr_objIndex[1] = Get_BlinkObject("Mode#Medium");
                    arr_objIndex[2] = Get_BlinkObject("Mode#High");
                    arr_objIndex[3] = Get_BlinkObject("Back03");
                }
                break;

            case Main.Device.GasValve:

                if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page0))
                    ;
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page1))
                {
                    arr_objIndex[0] = Get_BlinkObject("Valve#Open");
                    arr_objIndex[1] = Get_BlinkObject("Valve#Close");
                    arr_objIndex[2] = Get_BlinkObject("Valve#None");
                    arr_objIndex[3] = Get_BlinkObject("Back01");
                }
                break;

            case Main.Device.DoorLock:

                if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page0))
                    ;
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page1))
                {
                    arr_objIndex[0] = Get_BlinkObject("DoorLock#Open");
                    arr_objIndex[1] = Get_BlinkObject("DoorLock#Close");
                    arr_objIndex[2] = Get_BlinkObject("DoorLock#None");
                    arr_objIndex[3] = Get_BlinkObject("Back01");
                }
                break;

            case Main.Device.Blind:

                if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page0))
                    ;
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page1))
                {
                    arr_objIndex[0] = Get_BlinkObject("Blind#Open");
                    arr_objIndex[1] = Get_BlinkObject("Blind#Close");
                    arr_objIndex[2] = Get_BlinkObject("Blind#Half");
                    arr_objIndex[3] = Get_BlinkObject("Back01");
                }
                break;

            case Main.Device.AirConditioner:

                if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page0))
                    ;
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page1))
                {
                    arr_objIndex[0] = Get_BlinkObject("Power#On");
                    arr_objIndex[1] = Get_BlinkObject("Select#Move01");
                    arr_objIndex[2] = Get_BlinkObject("Select#Move02");
                    arr_objIndex[3] = Get_BlinkObject("Back01");
                }
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page2))
                {
                    arr_objIndex[0] = Get_BlinkObject("Temp#18");
                    arr_objIndex[1] = Get_BlinkObject("Temp#23");
                    arr_objIndex[2] = Get_BlinkObject("Temp#27");
                    arr_objIndex[3] = Get_BlinkObject("Back02");
                }
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page3))
                {
                    arr_objIndex[0] = Get_BlinkObject("Wind#2");
                    arr_objIndex[1] = Get_BlinkObject("Wind#3");
                    arr_objIndex[2] = Get_BlinkObject("Wind#4");
                    arr_objIndex[3] = Get_BlinkObject("Back03");
                }
                break;

            case Main.Device.CCTV:

                if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page0))
                    ;
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page1))
                {
                    arr_objIndex[0] = Get_BlinkObject("Rotate#Up");
                    arr_objIndex[1] = Get_BlinkObject("Rotate#Down");
                    arr_objIndex[2] = Get_BlinkObject("Mode#Rotate");
                    arr_objIndex[3] = Get_BlinkObject("Back01");
                }
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page2))
                {
                    arr_objIndex[0] = Get_BlinkObject("Rotate#Left");
                    arr_objIndex[1] = Get_BlinkObject("Rotate#Right");
                    arr_objIndex[2] = Get_BlinkObject("Streaming");
                    arr_objIndex[3] = Get_BlinkObject("Back02");
                }
                break;

            case Main.Device.TV:

                if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page0))
                    ;
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page1))
                {
                    arr_objIndex[0] = Get_BlinkObject("Power#On");
                    arr_objIndex[1] = Get_BlinkObject("Select#Move01");
                    arr_objIndex[2] = Get_BlinkObject("Select#Move02");
                    arr_objIndex[3] = Get_BlinkObject("Back01");
                }
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page2))
                {
                    arr_objIndex[0] = Get_BlinkObject("Channel#Up");
                    arr_objIndex[1] = Get_BlinkObject("Channel#Down");
                    arr_objIndex[2] = Get_BlinkObject("Channel#None");
                    arr_objIndex[3] = Get_BlinkObject("Back02");
                }
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page3))
                {
                    arr_objIndex[0] = Get_BlinkObject("Volume#Up");
                    arr_objIndex[1] = Get_BlinkObject("Volume#Down");
                    arr_objIndex[2] = Get_BlinkObject("Volume#Mute");
                    arr_objIndex[3] = Get_BlinkObject("Back03");
                }
                break;

            case Main.Device.AirDresser:

                if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page0))
                    ;
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page1))
                {
                    arr_objIndex[0] = Get_BlinkObject("Operation#Run");
                    arr_objIndex[1] = Get_BlinkObject("Operation#Pause");
                    arr_objIndex[2] = Get_BlinkObject("Operation#Stop");
                    arr_objIndex[3] = Get_BlinkObject("Back01");
                }
                break;

            case Main.Device.Inbody:

                if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page0))
                    ;
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page1))
                {
                    arr_objIndex[0] = Get_BlinkObject("Inbody#Fat");
                    arr_objIndex[1] = Get_BlinkObject("Inbody#Mineral");
                    arr_objIndex[2] = Get_BlinkObject("Inbody#Protein");
                    arr_objIndex[3] = Get_BlinkObject("Back01");
                }
                break;

            case Main.Device.Fit:

                if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page0))
                    ;
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page1))
                {
                    arr_objIndex[0] = Get_BlinkObject("Fit#Step");
                    arr_objIndex[1] = Get_BlinkObject("Fit#BPM");
                    arr_objIndex[2] = Get_BlinkObject("Fit#Calories");
                    arr_objIndex[3] = Get_BlinkObject("Back01");
                }
                break;

            case Main.Device.Scale:

                if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page0))
                    ;
                else if (Main.Instance.BCI_Page.Equals(Main.DeviceDepth.Page1))
                {
                    arr_objIndex[0] = Get_BlinkObject("Scale#Recent");
                    arr_objIndex[1] = Get_BlinkObject("Scale#1Week");
                    arr_objIndex[2] = Get_BlinkObject("Scale#2Week");
                    arr_objIndex[3] = Get_BlinkObject("Back01");
                }
                break;

            default:

                break;
        }



        if (arr_backupIndex[0])
        {
            if (arr_backupIndex[0] != arr_objIndex[0])
            {
                for (int i = 0; i < arr_backupIndex.Length; i++)
                {
                    arr_backupIndex[i].transform.GetChild(0).gameObject.SetActive(false);
                }
            }
        }

        for (int i = 0; i < arr_objIndex.Length; i++)
        {
            arr_backupIndex[i] = arr_objIndex[i];
        }

        //if (!Main.Instance.DeviceMode.Equals(Main.Device.None))
        //{

        //}
    }

    void Set_StartObject()
    {
        GameObject startObjs = Get_DeviceObject(Main.Instance.DeviceMode.ToString());

        for (int i = 0; i < startObjs.transform.childCount; i++)
        {
            startObjs.transform.GetChild(i).transform.GetChild(0).gameObject.SetActive(false);
        }

        for (int i = 0; i < arr_objIndex.Length; i++)
        {
            arr_objIndex[i].transform.GetChild(0).gameObject.SetActive(true);
        }


        //if (startObjs)
        //{
        //    for (int i = 0; i < startObjs.transform.childCount; i++)
        //    {
        //        startObjs.transform.GetChild(i).transform.GetChild(0).gameObject.SetActive(false);
        //    }

        //    for (int i = 0; i < arr_objIndex.Length; i++)
        //    {
        //        arr_objIndex[i].transform.GetChild(0).gameObject.SetActive(true);
        //    }
        //}

        //else
        //{
        //    if (arr_backupIndex[0])
        //    {
        //        for (int i = 0; i < arr_backupIndex.Length; i++)
        //        {
        //            arr_backupIndex[i].transform.GetChild(0).gameObject.SetActive(false);
        //        }
        //    }
        //}
    }
}
