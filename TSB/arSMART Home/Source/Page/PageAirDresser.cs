using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PageAirDresser : PageBase
{
    public ImageList this_imageList;
    public UIButton modeImg;

    public UIButton runBtn;
    public UIButton pauseBtn;
    public UIButton stopBtn;

    public UIButton silentOnBtn;
    public UIButton silentOffBtn;
    public UIButton wrinklePreventOnBtn;
    public UIButton wrinklePreventOffBtn;

    public Text course;
    public Text rTime;

    // db
    public GameObject objDB;
    public Text[] dbCourse;
    public Text[] dbSilence;
    public Text[] dbWrinkleFree;
    public Text[] dbStartTime;
    public Text[] dbUsingTime;

    public int dbLine;

    // Use this for initialization
    void Start()
    {
        this_imageList = transform.GetComponent<ImageList>();

        modeImg = this_imageList.GetButton("Mode_btn_img");
        course = transform.Find("CourseBG_img").transform.Find("Course_txt").GetComponent<Text>();
        rTime = transform.Find("CourseBG_img").transform.Find("RemainTime_txt").GetComponent<Text>();

        runBtn = this_imageList.GetButton("Operation#Run_btn");
        pauseBtn = this_imageList.GetButton("Operation#Pause_btn");
        stopBtn = this_imageList.GetButton("Operation#Stop_btn");

        silentOnBtn = this_imageList.GetButton("SilentOn_btn_img");
        silentOffBtn = this_imageList.GetButton("SilentOff_btn_img");
        wrinklePreventOnBtn = this_imageList.GetButton("WrinklePreventOn_btn_img");
        wrinklePreventOffBtn = this_imageList.GetButton("WrinklePreventOff_btn_img");

        // db   
        dbLine = Main.Instance.dbLine;
        dbCourse = new Text[dbLine];
        dbSilence = new Text[dbLine];
        dbWrinkleFree = new Text[dbLine];
        dbStartTime = new Text[dbLine];
        dbUsingTime = new Text[dbLine];

        objDB = transform.Find("DataList_img").gameObject;

        for (int i = 0; i < dbLine; i++)
        {
            dbStartTime[i] = objDB.transform.GetChild(0 + i * 5).GetComponent<Text>();
            dbUsingTime[i] = objDB.transform.GetChild(1 + i * 5).GetComponent<Text>();
            dbCourse[i] = objDB.transform.GetChild(2 + i * 5).GetComponent<Text>();
            dbWrinkleFree[i] = objDB.transform.GetChild(3 + i * 5).GetComponent<Text>();
            dbSilence[i] = objDB.transform.GetChild(4 + i * 5).GetComponent<Text>();
        }
    }

    // Update is called once per frame
    void Update()
    {
        OnRay();
        AirDresserVisible();
        DatabaseVisible();

        if (rayStayBtn
            && Main.Instance.isAbleBtn.Equals(true))
        {
            Main.Instance.isAbleBtn = false;
            AirDresserIcon(rayStayBtn.gameObject.name);
        }
    }

    void AirDresserVisible()
    {
        Sprite img = modeImg.FindImage(Main.Instance.Status_AirDresser.strMode + "_btn_img");
        if (img == null)
            modeImg.GetComponent<Image>().sprite = modeImg.FindImage("standard_btn_img");
        else
            modeImg.GetComponent<Image>().sprite = img;

        course.text = Main.Instance.Status_AirDresser.strCourse;
        rTime.text = Main.Instance.Status_AirDresser.strTime;

        switch (Main.Instance.Status_AirDresser.strOperation)
        {
            case "run":
                runBtn.GetComponent<Image>().sprite = runBtn.FindOVImage("Operation#Run_btn");
                pauseBtn.GetComponent<Image>().sprite = pauseBtn.FindImage("Operation#Pause_btn");
                stopBtn.GetComponent<Image>().sprite = stopBtn.FindImage("Operation#Stop_btn");
                break;

            case "pause":
                pauseBtn.GetComponent<Image>().sprite = pauseBtn.FindOVImage("Operation#Pause_btn");
                runBtn.GetComponent<Image>().sprite = runBtn.FindImage("Operation#Run_btn");
                stopBtn.GetComponent<Image>().sprite = stopBtn.FindImage("Operation#Stop_btn");
                break;

            case "stop":
                stopBtn.GetComponent<Image>().sprite = stopBtn.FindOVImage("Operation#Stop_btn");
                runBtn.GetComponent<Image>().sprite = runBtn.FindImage("Operation#Run_btn");
                pauseBtn.GetComponent<Image>().sprite = pauseBtn.FindImage("Operation#Pause_btn");
                break;

            default:
                break;
        }

        if (Main.Instance.Status_AirDresser.strSilenceMdoe.Equals("on"))
        {
            silentOnBtn.gameObject.SetActive(true);
            silentOffBtn.gameObject.SetActive(false);
        }
        else
        {
            silentOnBtn.gameObject.SetActive(false);
            silentOffBtn.gameObject.SetActive(true);
        }

        if (Main.Instance.Status_AirDresser.strWrinkleFree.Equals("on"))
        {
            wrinklePreventOnBtn.gameObject.SetActive(true);
            wrinklePreventOffBtn.gameObject.SetActive(false);
        }
        else
        {
            wrinklePreventOnBtn.gameObject.SetActive(false);
            wrinklePreventOffBtn.gameObject.SetActive(true);
        }
    }

    public void DatabaseVisible()
    {
        for (int i = 0; i < dbLine; i++)
        {
            if (Main.Instance.Status_AirDresser.dbCourse[i] != "")
            {
                dbStartTime[i].text = Main.Instance.Status_AirDresser.dbStartTime[i];
                dbUsingTime[i].text = Main.Instance.Status_AirDresser.dbUsingTime[i];
                dbCourse[i].text = Main.Instance.Status_AirDresser.dbCourse[i];
                dbWrinkleFree[i].text = Main.Instance.Status_AirDresser.dbWrinkleMode[i];
                dbSilence[i].text = Main.Instance.Status_AirDresser.dbSilenceMode[i];
            }
        }
    }
}
