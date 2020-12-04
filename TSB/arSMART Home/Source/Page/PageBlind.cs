using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PageBlind : PageBase
{
    public ImageList this_imageList;
    public UIButton pointImg;
    public UIButton openBtn;
    public UIButton halfBtn;
    public UIButton closeBtn;

    // db
    public GameObject objDB;
    public Text[] dbTime;
    public Text[] dbLength;

    public int dbLine;
    public int maxLength;

    // Use this for initialization
    void Start()
    {
        this_imageList = transform.GetComponent<ImageList>();

        pointImg = this_imageList.GetButton("Point_btn_img");
        openBtn = this_imageList.GetButton("Blind#Open_btn");
        halfBtn = this_imageList.GetButton("Blind#Half_btn");
        closeBtn = this_imageList.GetButton("Blind#Close_btn");

        // db   
        dbLine = Main.Instance.dbLine;
        dbTime = new Text[dbLine];
        dbLength = new Text[dbLine];

        objDB = transform.Find("DataList_img").gameObject;

        for (int i = 0; i < dbLine; i++)
        {
            dbTime[i] = objDB.transform.GetChild(0 + i * 2).GetComponent<Text>();
            dbLength[i] = objDB.transform.GetChild(1 + i * 2).GetComponent<Text>();
        }
    }

    // Update is called once per frame
    void Update()
    {
        OnRay();
        BlindVisible();
        DatabaseVisible();

        if (rayStayBtn
            && Main.Instance.isAbleBtn.Equals(true))
        {
            Main.Instance.isAbleBtn = false;
            BlindIcon(rayStayBtn.gameObject.name);
        }
    }

    void BlindVisible()
    {
        maxLength = Convert.ToInt32(Main.Instance.Status_Blind.maxLength);

        if (Main.Instance.Status_Blind.strStatus.Equals("open"))
        {
            pointImg.transform.localPosition = new Vector3(openBtn.transform.localPosition.x, pointImg.transform.localPosition.y, 0);
            openBtn.GetComponent<Image>().sprite = openBtn.FindClickImage("Blind#Open_btn");
            halfBtn.GetComponent<Image>().sprite = halfBtn.FindImage("Blind#Half_btn");
            closeBtn.GetComponent<Image>().sprite = closeBtn.FindImage("Blind#Close_btn");
        }
        else if (Main.Instance.Status_Blind.strStatus.Equals("close"))
        {
            pointImg.transform.localPosition = new Vector3(closeBtn.transform.localPosition.x, pointImg.transform.localPosition.y, 0);
            openBtn.GetComponent<Image>().sprite = openBtn.FindImage("Blind#Open_btn");
            halfBtn.GetComponent<Image>().sprite = halfBtn.FindImage("Blind#Half_btn");
            closeBtn.GetComponent<Image>().sprite = closeBtn.FindClickImage("Blind#Close_btn");
        }
        else
        {
            pointImg.transform.localPosition = new Vector3(halfBtn.transform.localPosition.x, pointImg.transform.localPosition.y, 0);
            openBtn.GetComponent<Image>().sprite = openBtn.FindImage("Blind#Open_btn");
            halfBtn.GetComponent<Image>().sprite = halfBtn.FindClickImage("Blind#Half_btn");
            closeBtn.GetComponent<Image>().sprite = closeBtn.FindImage("Blind#Close_btn");
        }
    }

    public void DatabaseVisible()
    {
        string[] strLength = new string[dbLine];
        for (int i = 0; i < dbLine; i++)
        {
            int rLength = Convert.ToInt32(Main.Instance.Status_Blind.dbLength[i]);

            if (rLength < (maxLength / 2 - 3))
                strLength[i] = "Close";
            else if (rLength >= (maxLength / 2 - 3)
                && rLength <= (maxLength / 2 + 3))
                strLength[i] = "Half";
            else
                strLength[i] = "Open";
        }

        for (int i = 0; i < dbLine; i++)
        {
            if (Main.Instance.Status_DoorLock.dbWriteTime[i] != "")
            {
                dbTime[i].text = Main.Instance.Status_Blind.dbWriteTime[i];
                dbLength[i].text = strLength[i];
            }
        }
    }
}
