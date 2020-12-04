using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PageDoorLock : PageBase
{
    public ImageList this_imageList;
    public UIButton openBtn;
    public UIButton closeBtn;
    public UIButton batteryImg;
    public Text battery;

    // db
    public GameObject objDB;
    public Text[] dbTime;
    public Text[] dbStatus;

    public int dbLine;

    // Use this for initialization
    void Start()
    {
        this_imageList = transform.GetComponent<ImageList>();

        closeBtn = this_imageList.GetButton("DoorLock#Close_btn");
        openBtn = this_imageList.GetButton("DoorLock#Open_btn");
        batteryImg = this_imageList.GetButton("Battery_btn_img");
        battery = transform.Find("SwitchBG_img").transform.Find("Battery_txt").GetComponent<Text>();

        // db   
        dbLine = Main.Instance.dbLine;
        dbTime = new Text[dbLine];
        dbStatus = new Text[dbLine];

        objDB = transform.Find("DataList_img").gameObject;

        for (int i = 0; i < dbLine; i++)
        {
            dbTime[i] = objDB.transform.GetChild(0 + i * 2).GetComponent<Text>();
            dbStatus[i] = objDB.transform.GetChild(1 + i * 2).GetComponent<Text>();
        }
    }

    // Update is called once per frame
    void Update()
    {
        OnRay();
        DoorLockVisible();
        DatabaseVisible();

        if (rayStayBtn
            && Main.Instance.isAbleBtn.Equals(true))
        {
            Main.Instance.isAbleBtn = false;
            DoorLockIcon(rayStayBtn.gameObject.name);
        }
    }

    void DoorLockVisible()
    {
        string strCapacity = Main.Instance.Status_DoorLock.strBattery;
        int capacity = Convert.ToInt32(strCapacity);
        string batName = null;
        battery.text = strCapacity + "%";

        if (capacity == 0)
            batName = "BatteryE_btn_img";
        else if (capacity > 0
            && capacity <= 25)
            batName = "Battery1_btn_img";
        else if (capacity > 25
            && capacity <= 50)
            batName = "Battery2_btn_img";
        else if (capacity > 50
            && capacity <= 75)
            batName = "Battery3_btn_img";
        else if (capacity > 75
            && capacity < 100)
            batName = "Battery4_btn_img";
        else if (capacity == 100)
            batName = "BatteryF_btn_img";

        batteryImg.GetComponent<Image>().sprite = batteryImg.FindImage(batName);

        if (Main.Instance.Status_DoorLock.strStatus.Equals("open"))
        {
            openBtn.gameObject.SetActive(false);
            closeBtn.gameObject.SetActive(true);
        }
        else
        {
            openBtn.gameObject.SetActive(true);
            closeBtn.gameObject.SetActive(false);
        }
    }

    public void DatabaseVisible()
    {
        for (int i = 0; i < dbLine; i++)
        {
            if (Main.Instance.Status_DoorLock.dbWriteTime[i] != "")
            {
                dbTime[i].text = Main.Instance.Status_DoorLock.dbWriteTime[i];
                dbStatus[i].text = Main.Instance.Status_DoorLock.dbStatus[i];
            }
        }
    }
}
