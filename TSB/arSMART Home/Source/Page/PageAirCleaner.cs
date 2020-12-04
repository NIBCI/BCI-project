using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PageAirCleaner : PageBase
{
    public ImageList this_imageList;

    public UIButton onBtn;
    public UIButton offBtn;
    public UIButton autoBtn;
    public UIButton sleepBtn;
    public UIButton lowBtn;
    public UIButton mediumBtn;
    public UIButton highBtn;

    public GameObject objStatus;
    public Text dust;
    public Text findDust;
    public Text veryFineDust;

    // db
    public GameObject objDB;
    public Text[] dbTime;
    public Text[] dbSwitch;
    public Text[] dbMode;
    public Text[] dbDust;

    public int dbLine;

    // Use this for initialization
    void Start()
    {
        this_imageList = transform.GetComponent<ImageList>();

        onBtn = this_imageList.GetButton("Power#Off_btn");
        offBtn = this_imageList.GetButton("Power#On_btn");
        autoBtn = this_imageList.GetButton("Mode#Auto_btn");
        sleepBtn = this_imageList.GetButton("Mode#Sleep_btn");
        lowBtn = this_imageList.GetButton("Mode#Low_btn");
        mediumBtn = this_imageList.GetButton("Mode#Medium_btn");
        highBtn = this_imageList.GetButton("Mode#High_btn");

        objStatus = transform.Find("StatusBG_img").gameObject;
        dust = objStatus.transform.Find("Dust_txt").GetComponent<Text>();
        findDust = objStatus.transform.Find("FineDust_txt").GetComponent<Text>();
        veryFineDust = objStatus.transform.Find("VeryFineDust_txt").GetComponent<Text>();

        // db   
        dbLine = Main.Instance.dbLine;
        dbTime = new Text[dbLine];
        dbSwitch = new Text[dbLine];
        dbMode = new Text[dbLine];
        dbDust = new Text[dbLine];

        objDB = transform.Find("DataList_img").gameObject;

        for (int i = 0; i < dbLine; i++)
        {
            dbTime[i] = objDB.transform.GetChild(0 + i * 4).GetComponent<Text>();
            dbSwitch[i] = objDB.transform.GetChild(1 + i * 4).GetComponent<Text>();
            dbMode[i] = objDB.transform.GetChild(2 + i * 4).GetComponent<Text>();
            dbDust[i] = objDB.transform.GetChild(3 + i * 4).GetComponent<Text>();
        }
    }

    // Update is called once per frame
    void Update()
    {
        OnRay();
        AirCleanerVisible();
        DatabaseVisible();

        if (rayStayBtn
            && Main.Instance.isAbleBtn.Equals(true))
        {
            Main.Instance.isAbleBtn = false;
            AirCleanerIcon(rayStayBtn.gameObject.name);
        }
    }

    void AirCleanerVisible()
    {
        dust.text = Main.Instance.Status_AirCleaner.strDustA;
        findDust.text = Main.Instance.Status_AirCleaner.strDustB;
        veryFineDust.text = Main.Instance.Status_AirCleaner.strDustC;

        if (Main.Instance.Status_AirCleaner.strPower.Equals("on"))
        {
            onBtn.gameObject.SetActive(true);
            offBtn.gameObject.SetActive(false);
        }
        else
        {
            onBtn.gameObject.SetActive(false);
            offBtn.gameObject.SetActive(true);
        }

        switch (Main.Instance.Status_AirCleaner.strMode)
        {
            case "auto":
                autoBtn.GetComponent<Image>().sprite = autoBtn.FindOVImage("Mode#Auto_btn");
                sleepBtn.GetComponent<Image>().sprite = sleepBtn.FindImage("Mode#Sleep_btn");
                lowBtn.GetComponent<Image>().sprite = lowBtn.FindImage("Mode#Low_btn");
                mediumBtn.GetComponent<Image>().sprite = mediumBtn.FindImage("Mode#Medium_btn");
                highBtn.GetComponent<Image>().sprite = highBtn.FindImage("Mode#High_btn");
                break;

            case "sleep":
                sleepBtn.GetComponent<Image>().sprite = sleepBtn.FindOVImage("Mode#Sleep_btn");
                autoBtn.GetComponent<Image>().sprite = autoBtn.FindImage("Mode#Auto_btn");                
                lowBtn.GetComponent<Image>().sprite = lowBtn.FindImage("Mode#Low_btn");
                mediumBtn.GetComponent<Image>().sprite = mediumBtn.FindImage("Mode#Medium_btn");
                highBtn.GetComponent<Image>().sprite = highBtn.FindImage("Mode#High_btn");
                break;

            case "low":
                lowBtn.GetComponent<Image>().sprite = lowBtn.FindOVImage("Mode#Low_btn");
                autoBtn.GetComponent<Image>().sprite = autoBtn.FindImage("Mode#Auto_btn");
                sleepBtn.GetComponent<Image>().sprite = sleepBtn.FindImage("Mode#Sleep_btn");
                mediumBtn.GetComponent<Image>().sprite = mediumBtn.FindImage("Mode#Medium_btn");
                highBtn.GetComponent<Image>().sprite = highBtn.FindImage("Mode#High_btn");
                break;

            case "medium":
                mediumBtn.GetComponent<Image>().sprite = mediumBtn.FindOVImage("Mode#Medium_btn");
                autoBtn.GetComponent<Image>().sprite = autoBtn.FindImage("Mode#Auto_btn");
                sleepBtn.GetComponent<Image>().sprite = sleepBtn.FindImage("Mode#Sleep_btn");
                lowBtn.GetComponent<Image>().sprite = lowBtn.FindImage("Mode#Low_btn");
                highBtn.GetComponent<Image>().sprite = highBtn.FindImage("Mode#High_btn");
                break;

            case "high":
                highBtn.GetComponent<Image>().sprite = highBtn.FindOVImage("Mode#High_btn");
                autoBtn.GetComponent<Image>().sprite = autoBtn.FindImage("Mode#Auto_btn");
                sleepBtn.GetComponent<Image>().sprite = sleepBtn.FindImage("Mode#Sleep_btn");
                lowBtn.GetComponent<Image>().sprite = lowBtn.FindImage("Mode#Low_btn");
                mediumBtn.GetComponent<Image>().sprite = mediumBtn.FindImage("Mode#Medium_btn");
                break;

            default:

                break;
        }
    }

    public void DatabaseVisible()
    {
        string[] strDust = new string[dbLine];
        for (int i = 0; i < dbLine; i++)
        {
            switch (Main.Instance.Status_AirCleaner.dbDustA[i])
            {
                case "0":
                case "1":
                    strDust[i] = "좋음";
                    break;

                case "2":
                    strDust[i] = "보통";
                    break;

                case "3":
                    strDust[i] = "나쁨";
                    break;

                case "4":
                    strDust[i] = "매우 나쁨";
                    break;

                default:

                    break;
            }
        }

        for (int i = 0; i < dbLine; i++)
        {
            if (Main.Instance.Status_AirCleaner.dbWriteTime[i] != "")
            {
                dbTime[i].text = Main.Instance.Status_AirCleaner.dbWriteTime[i];
                dbSwitch[i].text = Main.Instance.Status_AirCleaner.dbPower[i];
                dbMode[i].text = Main.Instance.Status_AirCleaner.dbMode[i];
                dbDust[i].text = strDust[i];
            }
        }
    }
}
