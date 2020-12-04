using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PageAirConditioner : PageBase
{
    public ImageList this_imageList;

    public UIButton powerOnBtn;
    public UIButton powerOffBtn;

    public UIButton windAutoBtn;
    public UIButton windMediumBtn;
    public UIButton windHighBtn;
    public UIButton windTurboBtn;
    public UIButton modeAutoBtn;
    public UIButton modeCoolBtn;
    public UIButton modeDryBtn;
    public UIButton modeWindBtn;

    public GameObject objTemp;
    public Text nowTemp;
    public Text setTemp;
    public Text humidity;

    // db
    public GameObject objDB;
    public Text[] dbStartTime;
    public Text[] dbEndTime;
    public Text[] dbTemp;

    public int dbLine;

    // Use this for initialization
    void Start()
    {
        this_imageList = transform.GetComponent<ImageList>();

        powerOnBtn = this_imageList.GetButton("Power#On_btn");
        powerOffBtn = this_imageList.GetButton("Power#Off_btn");
        windAutoBtn = this_imageList.GetButton("Wind#0_btn");
        windMediumBtn = this_imageList.GetButton("Wind#2_btn");
        windHighBtn = this_imageList.GetButton("Wind#3_btn");
        windTurboBtn = this_imageList.GetButton("Wind#4_btn");
        modeAutoBtn = this_imageList.GetButton("Mode#Auto_btn");
        modeCoolBtn = this_imageList.GetButton("Mode#Cool_btn");
        modeDryBtn = this_imageList.GetButton("Mode#Dry_btn");
        modeWindBtn = this_imageList.GetButton("Mode#Wind_btn");

        objTemp = transform.Find("TempBG_img").gameObject;
        nowTemp = objTemp.transform.Find("NowTemp_txt").GetComponent<Text>();
        setTemp = objTemp.transform.Find("SetTemp_txt").GetComponent<Text>();
        humidity = objTemp.transform.Find("Humidity_txt").GetComponent<Text>();

        // db   
        dbLine = Main.Instance.dbLine;
        dbStartTime = new Text[dbLine];
        dbEndTime = new Text[dbLine];
        dbTemp = new Text[dbLine];

        objDB = transform.Find("DataList_img").gameObject;

        for (int i = 0; i < dbLine; i++)
        {
            dbStartTime[i] = objDB.transform.GetChild(0 + i * 3).GetComponent<Text>();
            dbEndTime[i] = objDB.transform.GetChild(1 + i * 3).GetComponent<Text>();
            dbTemp[i] = objDB.transform.GetChild(2 + i * 3).GetComponent<Text>();
        }
    }

    // Update is called once per frame
    void Update()
    {
        OnRay();
        AirConditionerVisible();
        DatabaseVisible();

        if (rayStayBtn
            && Main.Instance.isAbleBtn.Equals(true))
        {
            Main.Instance.isAbleBtn = false;
            AirConditionerIcon(rayStayBtn.gameObject.name);            
        }
    }

    void AirConditionerVisible()
    {
        if (Main.Instance.Status_AirConditioner.strSwitch.Equals("on"))
        {
            powerOnBtn.gameObject.SetActive(false);
            powerOffBtn.gameObject.SetActive(true);
        }
        else
        {
            powerOnBtn.gameObject.SetActive(true);
            powerOffBtn.gameObject.SetActive(false);
        }

        switch (Main.Instance.Status_AirConditioner.strWind)
        {
            case "auto":
                windAutoBtn.GetComponent<Image>().sprite = windAutoBtn.FindOVImage("Wind#0_btn");
                windMediumBtn.GetComponent<Image>().sprite = windMediumBtn.FindImage("Wind#2_btn");
                windHighBtn.GetComponent<Image>().sprite = windHighBtn.FindImage("Wind#3_btn");
                windTurboBtn.GetComponent<Image>().sprite = windTurboBtn.FindImage("Wind#4_btn");
                break;

            case "medium":
                windMediumBtn.GetComponent<Image>().sprite = windMediumBtn.FindOVImage("Wind#2_btn");
                windAutoBtn.GetComponent<Image>().sprite = windAutoBtn.FindImage("Wind#0_btn");
                windHighBtn.GetComponent<Image>().sprite = windHighBtn.FindImage("Wind#3_btn");
                windTurboBtn.GetComponent<Image>().sprite = windTurboBtn.FindImage("Wind#4_btn");
                break;

            case "high":
                windHighBtn.GetComponent<Image>().sprite = windHighBtn.FindOVImage("Wind#3_btn");
                windAutoBtn.GetComponent<Image>().sprite = windAutoBtn.FindImage("Wind#0_btn");
                windMediumBtn.GetComponent<Image>().sprite = windMediumBtn.FindImage("Wind#2_btn");
                windTurboBtn.GetComponent<Image>().sprite = windTurboBtn.FindImage("Wind#4_btn");
                break;

            case "turbo":
                windTurboBtn.GetComponent<Image>().sprite = windTurboBtn.FindOVImage("Wind#4_btn");
                windAutoBtn.GetComponent<Image>().sprite = windAutoBtn.FindImage("Wind#0_btn");
                windMediumBtn.GetComponent<Image>().sprite = windMediumBtn.FindImage("Wind#2_btn");
                windHighBtn.GetComponent<Image>().sprite = windHighBtn.FindImage("Wind#3_btn");
                break;
        }

        switch (Main.Instance.Status_AirConditioner.strMode)
        {
            case "auto":
                modeAutoBtn.GetComponent<Image>().sprite = modeAutoBtn.FindOVImage("Mode#Auto_btn");
                modeCoolBtn.GetComponent<Image>().sprite = modeCoolBtn.FindImage("Mode#Cool_btn");
                modeDryBtn.GetComponent<Image>().sprite = modeDryBtn.FindImage("Mode#Dry_btn");
                modeWindBtn.GetComponent<Image>().sprite = modeWindBtn.FindImage("Mode#Wind_btn");
                break;

            case "cool":
                modeCoolBtn.GetComponent<Image>().sprite = modeCoolBtn.FindOVImage("Mode#Cool_btn");
                modeAutoBtn.GetComponent<Image>().sprite = modeAutoBtn.FindImage("Mode#Auto_btn");
                modeDryBtn.GetComponent<Image>().sprite = modeDryBtn.FindImage("Mode#Dry_btn");
                modeWindBtn.GetComponent<Image>().sprite = modeWindBtn.FindImage("Mode#Wind_btn");
                break;

            case "dry":
                modeDryBtn.GetComponent<Image>().sprite = modeDryBtn.FindOVImage("Mode#Dry_btn");
                modeAutoBtn.GetComponent<Image>().sprite = modeAutoBtn.FindImage("Mode#Auto_btn");
                modeCoolBtn.GetComponent<Image>().sprite = modeCoolBtn.FindImage("Mode#Cool_btn");
                modeWindBtn.GetComponent<Image>().sprite = modeWindBtn.FindImage("Mode#Wind_btn");
                break;

            case "wind":
            case "coolClean":
                modeWindBtn.GetComponent<Image>().sprite = modeWindBtn.FindOVImage("Mode#Wind_btn");
                modeAutoBtn.GetComponent<Image>().sprite = modeAutoBtn.FindImage("Mode#Auto_btn");
                modeCoolBtn.GetComponent<Image>().sprite = modeCoolBtn.FindImage("Mode#Cool_btn");
                modeDryBtn.GetComponent<Image>().sprite = modeDryBtn.FindImage("Mode#Dry_btn");
                break;
        }

        nowTemp.text = Main.Instance.Status_AirConditioner.strTemp + "℃";
        setTemp.text = Main.Instance.Status_AirConditioner.strSetTemp + "℃";
        humidity.text = Main.Instance.Status_AirConditioner.strHumidity + "%";
    }

    public void DatabaseVisible()
    {
        for (int i = 0; i < dbLine; i++)
        {
            if (Main.Instance.Status_AirConditioner.dbTemp[i] != "")
            {
                dbStartTime[i].text = Main.Instance.Status_AirConditioner.dbStartTime[i];
                dbEndTime[i].text = Main.Instance.Status_AirConditioner.dbEndTime[i];
                dbTemp[i].text = Main.Instance.Status_AirConditioner.dbTemp[i] + "/" + Main.Instance.Status_AirConditioner.dbSetTemp[i];
            }
        }
    }
}
