using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Assertions;
using UnityEngine.Events;
using HoloToolkit.Unity;
using System;
using System.IO;
using System.Text;
using System.Linq;
using System.Collections.Generic;

#if !UNITY_EDITOR
using Windows.Networking.Sockets;
using Windows.Networking.Connectivity;
using Windows.Networking;
#endif

[System.Serializable]
public class UDPMessageEvent : UnityEvent<string, string, byte[]>
{

}

public class BCI_UDP : Singleton<BCI_UDP>
{
    //private BCI_Contents m_BCI;
    public UDPMessageEvent udpEvent = null;
    private readonly Queue<Action> ExecuteOnMainThread = new Queue<Action>();
    public string internalPort = "8052";
    public int externalPort = 8053;
    public int unistPort = 8059;
    public static string m_String = "";

    public string[] strRecvArray;
    public Main main;

    public bool initSignal = false;
    public string strObjName = "";
    public string strNum = "";

#if !UNITY_EDITOR
    DatagramSocket socket = new DatagramSocket();  
    
    
    
    HostName hostName;
    object lockObject_ = new object();
    const int MAX_BUFFER_SIZE = 1024;
    
#endif
#if !UNITY_EDITOR
    void UDPMessageReceived(string host, string port, byte[] data)
    {
 
    }

    async void Start()
    { 
        if (udpEvent == null)
        {
            udpEvent = new UDPMessageEvent();
            udpEvent.AddListener(UDPMessageReceived);
        }

        socket.MessageReceived += OnMessage;
        await socket.BindServiceNameAsync(internalPort);     
    }
    
    
    private async System.Threading.Tasks.Task SendMessage(string message, string ip, int port)
        {
            using (var stream = await socket.GetOutputStreamAsync(new Windows.Networking.HostName(ip), port.ToString()))
            {
                using (var writer = new Windows.Storage.Streams.DataWriter(stream))
                {
                    var data = Encoding.UTF8.GetBytes(message);
                    writer.WriteBytes(data);
                    await writer.StoreAsync();
                }
            }
        }

    async void OnMessage(DatagramSocket sender, DatagramSocketMessageReceivedEventArgs args)
    {                
        using (var streamIn = args.GetDataStream().AsStreamForRead())
        {
         
            MemoryStream ms = ToMemoryStream(streamIn);
            byte[] msgData = ms.ToArray();

			//m_String이 최종 recv 파일(string임)
            m_String = Encoding.ASCII.GetString(msgData);
         
                ExecuteOnMainThread.Enqueue(() =>
                {
                    if (udpEvent != null)
                        udpEvent.Invoke(args.RemoteAddress.DisplayName, internalPort, msgData);
                });
                                    
         }        
    }

    
    

 
#else

    // Use this for initialization    
    void Start()
    {
        strRecvArray = new string[20];
        Array.Clear(strRecvArray, 0, strRecvArray.Length);
    }
    // Update is called once per frame	

#endif

    void InitSetting()
    {
        initSignal = true;

        strRecvArray = new string[20];
        Array.Clear(strRecvArray, 0, strRecvArray.Length);

        main = GameObject.Find("MainControl").GetComponent<Main>();

        UDP_Send(main.org + "#Init");
    }

    void Update()
    {
        if (initSignal == false)
            InitSetting();

        while (ExecuteOnMainThread.Count > 0)
        {
            //main.recvData = m_String;

            ExecuteOnMainThread.Dequeue().Invoke();

            RecvProcess(m_String);
        }
    }

    // recv 처리
    void RecvProcess(string recvdata)
    {
        // 중복 return
        if (recvdata == main.strOverlap)
            return;
        main.strOverlap = recvdata;

        strRecvArray = recvdata.Split('#');
        string strMode = strRecvArray[0];

        switch (strMode)
        {
            case "MiddleWare":
                // MiddleWare#[number]
                if (strRecvArray[1].Length == 1)
                    RecvBCInumber();

                // MiddleWare#Stop#Signal   // UNIST
                else if (strRecvArray[1].Equals("Stop"))
                    main.isStopSignal = true;
                break;

            case "GateWay":
                // 2019. GateWay#[device]#~~~       // device status receive
                SetDeviceStatus();
                break;

            case "DB":
                SetDatabase(m_String);
                break;

            case "DBh":
                SetHealthDatabase(m_String);
                break;

            case "UNISTSet":
                SetUnistOption();
                break;

            case "HYSet":
                SetHYOption();
                break;

            default:

                break;
        }
    }

    public void SetObjectName(string strNumber)
    {
        if (main.n1Obj == null)
            return;

        switch (strNumber)
        {
            case "1":
                strObjName = main.n1Obj.name;
                break;

            case "2":
                strObjName = main.n2Obj.name;
                break;

            case "3":
                strObjName = main.n3Obj.name;
                break;

            case "4":
                strObjName = main.n4Obj.name;
                break;

            default:
                break;
        }
    }

    public void RecvBCInumber()
    {
        strNum = strRecvArray[1].ToString();
        SetObjectName(strNum);

        switch (Main.Instance.DeviceMode)
        {
            case Main.Device.Refrigerator:
            case Main.Device.AirDresser:
            case Main.Device.Blind:
            case Main.Device.DoorLock:
            case Main.Device.GasValve:
                break;

            case Main.Device.None:
                if (Main.Instance.BCI_Page == Main.DeviceDepth.Page1
                    && strNum.Equals("4"))
                    Main.Instance.BCI_Page = Main.DeviceDepth.Page2;

                else if (Main.Instance.BCI_Page == Main.DeviceDepth.Page2
                    && strNum.Equals("4"))
                    Main.Instance.BCI_Page = Main.DeviceDepth.Page1;
                break;

            case Main.Device.RVC:

                if (Main.Instance.BCI_Page == Main.DeviceDepth.Page1
                    && strNum.Equals("3"))
                    Main.Instance.BCI_Page = Main.DeviceDepth.Page2;

                else if (Main.Instance.BCI_Page == Main.DeviceDepth.Page2
                    && strNum.Equals("4"))
                    Main.Instance.BCI_Page = Main.DeviceDepth.Page1;
                break;

            case Main.Device.AirConditioner:
            case Main.Device.AirCleaner:
            case Main.Device.Bulb:
            case Main.Device.TV:

                if (Main.Instance.BCI_Page == Main.DeviceDepth.Page1
                   && strNum.Equals("2"))
                    Main.Instance.BCI_Page = Main.DeviceDepth.Page2;

                else if (Main.Instance.BCI_Page == Main.DeviceDepth.Page1
                   && strNum.Equals("3"))
                    Main.Instance.BCI_Page = Main.DeviceDepth.Page3;

                else if (Main.Instance.BCI_Page == Main.DeviceDepth.Page2
                    && strNum.Equals("4"))
                    Main.Instance.BCI_Page = Main.DeviceDepth.Page1;

                else if (Main.Instance.BCI_Page == Main.DeviceDepth.Page3
                    && strNum.Equals("4"))
                    Main.Instance.BCI_Page = Main.DeviceDepth.Page1;

                break;

            case Main.Device.CCTV:

                if (Main.Instance.BCI_Page == Main.DeviceDepth.Page1
                    && strNum.Equals("3"))
                    Main.Instance.BCI_Page = Main.DeviceDepth.Page2;

                else if (Main.Instance.BCI_Page == Main.DeviceDepth.Page2
                    && strNum.Equals("4"))
                    Main.Instance.BCI_Page = Main.DeviceDepth.Page1;

                else if (Main.Instance.BCI_Page == Main.DeviceDepth.Page2
                    && strNum.Equals("3"))
                {
                    Main.Instance.Status_CCTV[Main.Instance.deviceNumber - 1].SetData(true);
                    OggVideoStreamingTexture.Instance.SetScreen(true);
                }
                break;

            case Main.Device.Inbody:
                if (strNum.Equals("1"))
                {
                    PageInbody.Instance.ClearChart();
                    PageInbody.nState = 1;
                }
                else if (strNum.Equals("2"))
                {
                    PageInbody.Instance.ClearChart();
                    PageInbody.nState = 2;
                }
                else if (strNum.Equals("3"))
                {
                    PageInbody.Instance.ClearChart();
                    PageInbody.nState = 3;
                }
                break;

            case Main.Device.Fit:
                if (strNum.Equals("1"))
                {
                    PageFit.nState = 1;
                }
                else if (strNum.Equals("2"))
                {
                    PageFit.nState = 2;
                }
                else if (strNum.Equals("3"))
                {
                    PageFit.nState = 3;
                }
                break;

            case Main.Device.Scale:
                if (strNum.Equals("1"))
                {
                    PageScale.nState = 1;
                }
                else if (strNum.Equals("2"))
                {
                    PageScale.nState = 2;
                }
                else if (strNum.Equals("3"))
                {
                    PageScale.nState = 3;
                }
                break;
        }
    }

    public void SetUnistOption()
    {
        if (strRecvArray.Length >= 4)
        {
            main.unist_frequency = (float)Convert.ToDouble(strRecvArray[1]);
            main.breakTime = (int)Convert.ToInt32(strRecvArray[2]);
            main.sendCnt = (int)Convert.ToInt32(strRecvArray[3]);
        }

        return;
    }

    public void SetHYOption()
    {
        if (strRecvArray.Length >= 3)
        {
            SSVEP_Manager.Instance.TotalTime = (float)Convert.ToDouble(strRecvArray[1]);
            SSVEP_Manager.Instance.waitTime = (int)Convert.ToInt32(strRecvArray[2]);
        }

        return;
    }

    public void SetDeviceStatus()
    {
        string deviceName = strRecvArray[1];

        switch (deviceName)
        {
            case "Refrigerator":
                // GateWay#[device]#[a]#[b]#[c]#[d]#[e]#[f]#[g]#[h]
                main.Status_Refrigerator.SetData(strRecvArray[2], strRecvArray[3], strRecvArray[4], strRecvArray[5], strRecvArray[6], strRecvArray[7], strRecvArray[8], strRecvArray[9]);
                break;

            case "RVC":
                // GateWay#[device]#[a]#[b]
                main.Status_RVC.SetData(strRecvArray[2], strRecvArray[3]);
                break;

            case "Bulb":
                // GateWay#[device]#[a]#[b]#[c]#[d]#[e]
                // GateWay#[device]#[index]#[a]#[b]#[c]#[d]#[e]
                if (strRecvArray[2].Length == 1)
                    main.Status_Bulb[Convert.ToInt32(strRecvArray[2]) - 1].SetData(strRecvArray[3], strRecvArray[4], strRecvArray[5], strRecvArray[6], strRecvArray[7]);
                else
                    main.Status_Bulb[main.deviceNumber - 1].SetData(strRecvArray[2], strRecvArray[3], strRecvArray[4], strRecvArray[5], strRecvArray[6]);
                break;

            case "AirCleaner":
                // GateWay#[device]#[a]#[b]#[c]#[d]#[e]
                main.Status_AirCleaner.SetData(strRecvArray[2], strRecvArray[3], strRecvArray[4], strRecvArray[5], strRecvArray[6]);
                break;

            case "GasValve":
                // GateWay#[device]#[a]
                main.Status_GasValve.SetData(strRecvArray[2]);
                break;

            case "DoorLock":

                main.Status_DoorLock.SetData(strRecvArray[2], strRecvArray[3]);

                //if (strRecvArray[2].Equals("Ring"))                //{
                //    main.depth = "91";
                //    main.Set_BlinkObjectList();
                //    main.isRing = true;
                //}
                break;

            case "Blind":

                break;

            case "AirConditioner":
                // GateWay#[device]#[a]#[b]#[c]#[d]#[e]#[f]
                main.Status_AirConditioner.SetData(strRecvArray[2], strRecvArray[3], strRecvArray[4], strRecvArray[5], strRecvArray[6], strRecvArray[7]);
                break;

            case "CCTV":

                break;

            case "TV":

                break;

            case "AirDresser":
                // GateWay#[device]#[a]#[b]#[c]#[d]#[e]#[f]
                main.Status_AirDresser.SetData(strRecvArray[2], strRecvArray[3], strRecvArray[4], strRecvArray[5], strRecvArray[6], strRecvArray[7]);
                break;

            case "Inbody":
                // Gateway#[device]#
                main.Status_Inbody.SetData(strRecvArray[2], strRecvArray[3], strRecvArray[4], strRecvArray[5], strRecvArray[6], strRecvArray[7], strRecvArray[8], strRecvArray[9],
                    strRecvArray[10], strRecvArray[11], strRecvArray[12], strRecvArray[13], strRecvArray[14], strRecvArray[15], strRecvArray[16], strRecvArray[17], strRecvArray[18], strRecvArray[19], strRecvArray[20], strRecvArray[21]);
                break;

            case "Fit":
                main.Status_Fit.SetData(strRecvArray[2], strRecvArray[3], strRecvArray[4]);
                break;

            case "Scale":
                main.Status_Scale.SetData(strRecvArray[2], strRecvArray[3], strRecvArray[4], strRecvArray[5]);
                break;


            default:

                break;
        }
    }

    public void SetDatabase(string strOrigin)
    {
        try
        {
            string deviceName = strRecvArray[1];
            int index;
            strOrigin = strOrigin.Replace("DB#", "");
            strOrigin = strOrigin.Replace(strRecvArray[1] + "#", "");
            index = Convert.ToInt32(strOrigin.Substring(0, 1));
            strOrigin = strOrigin.Remove(0, 2);

            string[] strArrDB = new string[5];
            strArrDB = strOrigin.Split('@');

            string[] arrDataLow1 = strArrDB[0].Split('#');
            string[] arrDataLow2 = strArrDB[1].Split('#');
            string[] arrDataLow3 = strArrDB[2].Split('#');

            switch (deviceName)
            {
                case "Refrigerator":
                    // [FridgeTemp]#[FreezingTemp]#[SetFridgeTemp]#[SetFreezingTemp]#[Mode]#[WriteTime]
                    main.Status_Refrigerator.SetDatabase(0, arrDataLow1[0], arrDataLow1[1], arrDataLow1[2], arrDataLow1[3], arrDataLow1[4], arrDataLow1[5]);
                    main.Status_Refrigerator.SetDatabase(1, arrDataLow2[0], arrDataLow2[1], arrDataLow2[2], arrDataLow2[3], arrDataLow2[4], arrDataLow2[5]);
                    main.Status_Refrigerator.SetDatabase(2, arrDataLow3[0], arrDataLow3[1], arrDataLow3[2], arrDataLow3[3], arrDataLow3[4], arrDataLow3[5]);

                    break;

                case "RVC":
                    // [Status]#[Mode]#[WriteTime]
                    main.Status_RVC.SetDatabase(0, arrDataLow1[0], arrDataLow1[1], arrDataLow1[2]);
                    main.Status_RVC.SetDatabase(1, arrDataLow2[0], arrDataLow2[1], arrDataLow2[2]);
                    main.Status_RVC.SetDatabase(2, arrDataLow3[0], arrDataLow3[1], arrDataLow3[2]);
                    break;

                case "Bulb":
                    // [Switch]#[R]#[G]#[B]#[dimming]#[WriteTime]
                    main.Status_Bulb[index - 1].SetDatabase(0, arrDataLow1[0], arrDataLow1[1], arrDataLow1[2], arrDataLow1[3], arrDataLow1[4], arrDataLow1[5]);
                    main.Status_Bulb[index - 1].SetDatabase(1, arrDataLow2[0], arrDataLow2[1], arrDataLow2[2], arrDataLow2[3], arrDataLow2[4], arrDataLow2[5]);
                    main.Status_Bulb[index - 1].SetDatabase(2, arrDataLow3[0], arrDataLow3[1], arrDataLow3[2], arrDataLow3[3], arrDataLow3[4], arrDataLow3[5]);
                    break;

                case "AirCleaner":
                    // [Power]#[Mode]#[DustA]#[DustB]#[DustC]#[WriteTime]
                    main.Status_AirCleaner.SetDatabase(0, arrDataLow1[0], arrDataLow1[1], arrDataLow1[2], arrDataLow1[3], arrDataLow1[4], arrDataLow1[5]);
                    main.Status_AirCleaner.SetDatabase(1, arrDataLow2[0], arrDataLow2[1], arrDataLow2[2], arrDataLow2[3], arrDataLow2[4], arrDataLow2[5]);
                    main.Status_AirCleaner.SetDatabase(2, arrDataLow3[0], arrDataLow3[1], arrDataLow3[2], arrDataLow3[3], arrDataLow3[4], arrDataLow3[5]);
                    break;

                case "GasValve":
                    // [Status]#[WriteTime]
                    main.Status_GasValve.SetDatabase(0, arrDataLow1[0], arrDataLow1[1]);
                    main.Status_GasValve.SetDatabase(1, arrDataLow2[0], arrDataLow2[1]);
                    main.Status_GasValve.SetDatabase(2, arrDataLow3[0], arrDataLow3[1]);
                    break;

                case "DoorLock":
                    // [Status]#[WriteTime]
                    main.Status_DoorLock.SetDatabase(0, arrDataLow1[0], arrDataLow1[1]);
                    main.Status_DoorLock.SetDatabase(1, arrDataLow2[0], arrDataLow2[1]);
                    main.Status_DoorLock.SetDatabase(2, arrDataLow3[0], arrDataLow3[1]);
                    break;

                case "Blind":
                    // [RailLength]#[WriteTime]
                    main.Status_Blind.SetDatabase(0, arrDataLow1[0], arrDataLow1[1]);
                    main.Status_Blind.SetDatabase(1, arrDataLow2[0], arrDataLow2[1]);
                    main.Status_Blind.SetDatabase(2, arrDataLow3[0], arrDataLow3[1]);
                    break;

                case "AirConditioner":
                    // [Temp]#[setTemp]#[Mode]#[Wind]#[StartTime]#[EndTime]
                    main.Status_AirConditioner.SetDatabase(0, arrDataLow1[0], arrDataLow1[1], arrDataLow1[2], arrDataLow1[3], arrDataLow1[4], arrDataLow1[5]);
                    main.Status_AirConditioner.SetDatabase(1, arrDataLow2[0], arrDataLow2[1], arrDataLow2[2], arrDataLow2[3], arrDataLow2[4], arrDataLow2[5]);
                    main.Status_AirConditioner.SetDatabase(2, arrDataLow3[0], arrDataLow3[1], arrDataLow3[2], arrDataLow3[3], arrDataLow3[4], arrDataLow3[5]);
                    break;

                case "CCTV":
                    //
                    break;

                case "TV":
                    //
                    break;

                case "AirDresser":
                    // [Course]#[SilenceMode]#[WrinkleFree]#[StartTime]#[UsingTime]
                    main.Status_AirDresser.SetDatabase(0, arrDataLow1[0], arrDataLow1[1], arrDataLow1[2], arrDataLow1[3], arrDataLow1[4]);
                    main.Status_AirDresser.SetDatabase(1, arrDataLow2[0], arrDataLow2[1], arrDataLow2[2], arrDataLow2[3], arrDataLow2[4]);
                    main.Status_AirDresser.SetDatabase(2, arrDataLow3[0], arrDataLow3[1], arrDataLow3[2], arrDataLow3[3], arrDataLow3[4]);
                    break;

                default:

                    break;
            }
        }

        catch (Exception e)
        {
            //Debug.Log(e.ToString());
        }
    }

    public void SetHealthDatabase(string strOrigin)
    {
        try
        {
            string deviceName = strRecvArray[1];
            int dbLength;
            strOrigin = strOrigin.Replace("DBh#", "");
            strOrigin = strOrigin.Replace(strRecvArray[1] + "#", "");
            dbLength = strOrigin.Split('#').Length;

            string[] strArrDB = new string[dbLength];
            strArrDB = strOrigin.Split('#');

            for (int i = 0; i < dbLength; i++)
            {
                string[] dataLaw = strArrDB[i].Split('@');

                switch (deviceName)
                {
                    case "Inbody":
                        main.Status_Inbody.SetDatabase(i, dataLaw[0], dataLaw[1], dataLaw[2], dataLaw[3], dataLaw[4]);
                        break;

                    case "Fit":
                        main.Status_Fit.SetDatabase(i, dataLaw[0], dataLaw[1], dataLaw[2], dataLaw[3]);
                        break;

                    case "Scale":
                        main.Status_Scale.SetDatabase(i, dataLaw[0], dataLaw[1]);
                        break;
                }
            }
        }

        catch (Exception err)
        {

        }
    }

    static MemoryStream ToMemoryStream(Stream input)
    {
        try
        {                                         // Read and write in
            byte[] block = new byte[0x1000];       // blocks of 4K.
            MemoryStream ms = new MemoryStream();
            while (true)
            {
                int bytesRead = input.Read(block, 0, block.Length);
                if (bytesRead == 0) return ms;
                ms.Write(block, 0, bytesRead);
            }
        }
        finally { }
    }

    public
#if WINDOWS_UWP
    async
#endif
    void UDP_Send(string m_MSG)
    {
        //if (main.notice)
        //    main.notice.text = m_MSG;

#if WINDOWS_UWP
        await SendMessage(m_MSG, "255.255.255.255", externalPort);

        await SendMessage(m_MSG, "255.255.255.255", unistPort);
        
#endif

    }

}
