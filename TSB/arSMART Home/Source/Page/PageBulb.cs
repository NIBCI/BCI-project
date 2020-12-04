using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PageBulb : PageBase
{
    public ImageList this_imageList;

    public UIButton pointImg;

    public UIButton onBtn;
    public UIButton offBtn;

    public UIButton redBtn;
    public UIButton greenBtn;
    public UIButton blueBtn;
    public UIButton whiteBtn;
    public UIButton[] customBtn;

    public UIButton lowBtn;
    public UIButton mediumBtn;
    public UIButton highBtn;

    public UIButton[] modeBtn;

    public UIButton[] bulbBtn;

    // db
    public GameObject objDB;
    public Text[] dbTime;
    public Text[] dbSwitch;
    public Text[] dbIndex;
    public Text[] dbColor;
    public Text[] dbDimming;

    public int dbLine;

    // Use this for initialization
    void Start()
    {
        this_imageList = transform.GetComponent<ImageList>();

        pointImg = this_imageList.GetButton("Point_btn_img");

        onBtn = this_imageList.GetButton("Power#off_btn");
        offBtn = this_imageList.GetButton("Power#on_btn");
        redBtn = this_imageList.GetButton("Color#255#0#0_btn");
        greenBtn = this_imageList.GetButton("Color#0#255#0_btn");
        blueBtn = this_imageList.GetButton("Color#0#0#255_btn");
        whiteBtn = this_imageList.GetButton("Color#0#0#0_btn");

        lowBtn = this_imageList.GetButton("Dimming#29_btn");
        mediumBtn = this_imageList.GetButton("Dimming#63_btn");
        highBtn = this_imageList.GetButton("Dimming#100_btn");

        customBtn = new UIButton[10];
        modeBtn = new UIButton[10];
        bulbBtn = new UIButton[10];

        customBtn[0] = this_imageList.GetButton("Color#255#251#245_btn");
        customBtn[1] = this_imageList.GetButton("Color#226#212#191_btn");
        customBtn[2] = this_imageList.GetButton("Color#239#229#216_btn");

        modeBtn[0] = this_imageList.GetButton("Mode#Sleep_btn");
        modeBtn[1] = this_imageList.GetButton("Mode#Movie_btn");
        modeBtn[2] = this_imageList.GetButton("Mode#Study_btn");

        bulbBtn[0] = this_imageList.GetButton("Select#Bulb#0_btn");
        bulbBtn[1] = this_imageList.GetButton("Select#Bulb#1_btn");
        bulbBtn[2] = this_imageList.GetButton("Select#Bulb#2_btn");

        // db set
        dbLine = Main.Instance.dbLine;
        dbTime = new Text[dbLine];
        dbSwitch = new Text[dbLine];
        dbIndex = new Text[dbLine];
        dbColor = new Text[dbLine];
        dbDimming = new Text[dbLine];

        objDB = transform.Find("DataList_img").gameObject;

        for (int i = 0; i < dbLine; i++)
        {
            dbTime[i] = objDB.transform.GetChild(0 + i * 5).GetComponent<Text>();
            dbSwitch[i] = objDB.transform.GetChild(1 + i * 5).GetComponent<Text>();
            dbIndex[i] = objDB.transform.GetChild(2 + i * 5).GetComponent<Text>();
            dbColor[i] = objDB.transform.GetChild(3 + i * 5).GetComponent<Text>();
            dbDimming[i] = objDB.transform.GetChild(4 + i * 5).GetComponent<Text>();
        }
    }

    // Update is called once per frame
    void Update()
    {
        OnRay();
        BulbVisible();
        DatabaseVisible();

        if (rayStayBtn
            && Main.Instance.isAbleBtn.Equals(true))
        {
            Main.Instance.isAbleBtn = false;
            BulbIcon(rayStayBtn.gameObject.name);
        }
    }

    void BulbVisible()
    {
        for (int i = 0; i < this_imageList.arr_UIButton.Length; i++)
        {
            UIButton btn = this_imageList.arr_UIButton[i];

            if (btn)
            {
                btn.GetComponent<Image>().sprite = btn.FindImage(btn.name);
            }
        }

        int dNum = Main.Instance.deviceNumber;

        bulbBtn[dNum].GetComponent<Image>().sprite = bulbBtn[dNum].FindOVImage("Select#Bulb#" + dNum + "_btn");

        if (dNum == 0)
            dNum = 1;

        string r = Main.Instance.Status_Bulb[dNum - 1].strR;
        string g = Main.Instance.Status_Bulb[dNum - 1].strG;
        string b = Main.Instance.Status_Bulb[dNum - 1].strB;
        int dim = Convert.ToInt32(Main.Instance.Status_Bulb[dNum - 1].strDimming);

        if (Main.Instance.Status_Bulb[dNum - 1].strSwitch.Equals("on"))
        {
            onBtn.gameObject.SetActive(true);
            offBtn.gameObject.SetActive(false);
        }
        else
        {
            onBtn.gameObject.SetActive(false);
            offBtn.gameObject.SetActive(true);
        }

        switch (r + "#" + g + "#" + b)
        {
            case "0#0#0":
                whiteBtn.GetComponent<Image>().sprite = whiteBtn.FindOVImage("Color#0#0#0_btn");
                break;

            case "255#0#0":
                redBtn.GetComponent<Image>().sprite = redBtn.FindOVImage("Color#255#0#0_btn");
                break;

            case "0#255#0":
                greenBtn.GetComponent<Image>().sprite = greenBtn.FindOVImage("Color#0#255#0_btn");
                break;

            case "0#0#255":
                blueBtn.GetComponent<Image>().sprite = blueBtn.FindOVImage("Color#0#0#255_btn");
                break;

            case "255#251#245":
                customBtn[0].GetComponent<Image>().sprite = customBtn[0].FindOVImage("Color#255#251#245_btn");
                break;

            case "226#212#191":
                customBtn[1].GetComponent<Image>().sprite = customBtn[1].FindOVImage("Color#226#212#191_btn");
                break;

            case "239#251#245":
                customBtn[2].GetComponent<Image>().sprite = customBtn[2].FindOVImage("Color#239#229#216_btn");
                break;

            default:
                break;
        }

        if (dim > 0 && dim <= 30)
        {
            lowBtn.GetComponent<Image>().sprite = lowBtn.FindOVImage("Dimming#29_btn");
            pointImg.transform.localPosition = new Vector3(lowBtn.transform.localPosition.x, pointImg.transform.localPosition.y, 0);
        }
        else if (dim > 30 && dim <= 70)
        {
            mediumBtn.GetComponent<Image>().sprite = mediumBtn.FindOVImage("Dimming#63_btn");
            pointImg.transform.localPosition = new Vector3(mediumBtn.transform.localPosition.x, pointImg.transform.localPosition.y, 0);
        }
        else
        {
            highBtn.GetComponent<Image>().sprite = highBtn.FindOVImage("Dimming#100_btn");
            pointImg.transform.localPosition = new Vector3(highBtn.transform.localPosition.x, pointImg.transform.localPosition.y, 0);
        }
    }

    public void DatabaseVisible()
    {
        int index = Main.Instance.deviceNumber - 1;
        if (index == -1)
            index = 0;

        string[] strDbColor = new string[dbLine];
        string[] strIndex = new string[dbLine];

        for (int i = 0; i < dbLine; i++)
        {
            strDbColor[i] = string.Format("{0}, {1}, {2}", Main.Instance.Status_Bulb[index].dbR[i].ToString(), Main.Instance.Status_Bulb[index].dbG[i].ToString(), Main.Instance.Status_Bulb[index].dbB[i].ToString());
            strIndex[i] = string.Format("전구{0}", (index + 1).ToString());
        }

        for (int i = 0; i < dbLine; i++)
        {
            if (Main.Instance.Status_Bulb[index].dbWriteTime[i] != "")
            {
                dbTime[i].text = Main.Instance.Status_Bulb[index].dbWriteTime[i];
                dbSwitch[i].text = Main.Instance.Status_Bulb[index].dbSwitch[i];
                dbIndex[i].text = strIndex[i];
                dbColor[i].text = strDbColor[i];
                dbDimming[i].text = Main.Instance.Status_Bulb[index].dbDimming[i];
            }
        }
    }
}
