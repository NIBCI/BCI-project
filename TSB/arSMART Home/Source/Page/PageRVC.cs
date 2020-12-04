using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PageRVC : PageBase
{
    public ImageList this_imageList;

    public UIButton autoBtn;
    public UIButton stopBtn;
    public UIButton rechargeBtn;
    public UIButton turboBtn;
    public UIButton normalBtn;
    public UIButton silenceBtn;

    public GameObject objDB;
    public Text[] dbStatus;
    public Text[] dbMode;
    public Text[] dbTime;
    public int dbLine;

    // Use this for initialization
    void Start()
    {
        this_imageList = transform.GetComponent<ImageList>();

        autoBtn = this_imageList.GetButton("Auto_btn");
        stopBtn = this_imageList.GetButton("Stop_btn");
        rechargeBtn = this_imageList.GetButton("Recharge_btn");
        turboBtn = this_imageList.GetButton("TurboMode_btn");
        normalBtn = this_imageList.GetButton("NormalMode_btn");
        silenceBtn = this_imageList.GetButton("SilenceMode_btn");

        dbLine = Main.Instance.dbLine;
        dbTime = new Text[dbLine];
        dbStatus = new Text[dbLine];
        dbMode = new Text[dbLine];        

        objDB = transform.Find("DataList_img").gameObject;

        for (int i = 0; i < dbLine; i++)
        {
            dbTime[i] = objDB.transform.GetChild(0 + i * 3).GetComponent<Text>();
            dbStatus[i] = objDB.transform.GetChild(1 + i * 3).GetComponent<Text>();            
            dbMode[i] = objDB.transform.GetChild(2 + i * 3).GetComponent<Text>();
        }
    }

    // Update is called once per frame
    void Update()
    {
        OnRay();
        RVCvisible();
        DatabaseVisible();

        if (rayStayBtn
            && Main.Instance.isAbleBtn.Equals(true))
        {
            Main.Instance.isAbleBtn = false;
            RVCIcon(rayStayBtn.gameObject.name);
        }
    }

    void RVCvisible()
    {
        switch (Main.Instance.Status_RVC.strStatus)
        {
            case "pause":
                stopBtn.GetComponent<Image>().sprite = stopBtn.FindOVImage("Stop_btn");
                autoBtn.GetComponent<Image>().sprite = autoBtn.FindImage("Auto_btn");
                rechargeBtn.GetComponent<Image>().sprite = rechargeBtn.FindImage("Recharge_btn");
                break;

            case "cleaning":
                autoBtn.GetComponent<Image>().sprite = autoBtn.FindOVImage("Auto_btn");
                rechargeBtn.GetComponent<Image>().sprite = rechargeBtn.FindImage("Recharge_btn");
                stopBtn.GetComponent<Image>().sprite = stopBtn.FindImage("Stop_btn");
                break;

            case "homing":
            case "charging":
                rechargeBtn.GetComponent<Image>().sprite = rechargeBtn.FindOVImage("Recharge_btn");
                autoBtn.GetComponent<Image>().sprite = autoBtn.FindImage("Auto_btn");
                stopBtn.GetComponent<Image>().sprite = stopBtn.FindImage("Stop_btn");
                break;

            default:
                break;
        }

        switch (Main.Instance.Status_RVC.strMode)
        {
            case "on":
                turboBtn.GetComponent<Image>().sprite = turboBtn.FindOVImage("TurboMode_btn");
                normalBtn.GetComponent<Image>().sprite = normalBtn.FindImage("NormalMode_btn");
                silenceBtn.GetComponent<Image>().sprite = silenceBtn.FindImage("SilenceMode_btn");
                break;

            case "off":
                normalBtn.GetComponent<Image>().sprite = normalBtn.FindOVImage("NormalMode_btn");
                silenceBtn.GetComponent<Image>().sprite = silenceBtn.FindImage("SilenceMode_btn");
                turboBtn.GetComponent<Image>().sprite = turboBtn.FindImage("TurboMode_btn");
                break;

            case "silence":
                silenceBtn.GetComponent<Image>().sprite = silenceBtn.FindOVImage("SilenceMode_btn");
                turboBtn.GetComponent<Image>().sprite = turboBtn.FindImage("TurboMode_btn");
                normalBtn.GetComponent<Image>().sprite = normalBtn.FindImage("NormalMode_btn");
                break;

            default:
                break;
        }
    }

    public void DatabaseVisible()
    {
        for (int i = 0; i < dbLine; i++)
        {
            if (Main.Instance.Status_RVC.dbWriteTime[i] != "")
            {
                dbTime[i].text = Main.Instance.Status_RVC.dbWriteTime[i];
                dbStatus[i].text = Main.Instance.Status_RVC.dbStatus[i];                
                dbMode[i].text = Main.Instance.Status_RVC.dbMode[i];
            }
        }
    }
}
