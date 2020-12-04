using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PageGasValve : PageBase
{
    public ImageList this_imageList;

    public UIButton valveImg;
    public UIButton openBtn;
    public UIButton closeBtn;

    // db
    public GameObject objDB;
    public Text[] dbTime;
    public Text[] dbStatus;

    public int dbLine;

    // Use this for initialization
    void Start()
    {
        this_imageList = transform.GetComponent<ImageList>();

        valveImg = this_imageList.GetButton("Valve_btn_img");
        openBtn = this_imageList.GetButton("Valve#Close_btn");
        closeBtn = this_imageList.GetButton("Valve#Open_btn");

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
        GasValveVisible();
        DatabaseVisible();

        if (rayStayBtn
            && Main.Instance.isAbleBtn.Equals(true))
        {
            Main.Instance.isAbleBtn = false;
            GasValveIcon(rayStayBtn.gameObject.name);
        }
    }

    void GasValveVisible()
    {
        if (Main.Instance.Status_GasValve.strStatus.Equals("open"))
        {
            valveImg.GetComponent<Image>().sprite = valveImg.FindImage("ValveOpen_btn_img");
            openBtn.GetComponent<Image>().sprite = openBtn.FindClickImage("Valve#Close_btn");
            closeBtn.GetComponent<Image>().sprite = closeBtn.FindImage("Valve#Open_btn");
        }
        else
        {
            valveImg.GetComponent<Image>().sprite = valveImg.FindImage("ValveClose_btn_img");
            openBtn.GetComponent<Image>().sprite = openBtn.FindImage("Valve#Close_btn");
            closeBtn.GetComponent<Image>().sprite = closeBtn.FindClickImage("Valve#Open_btn");
        }
    }

    public void DatabaseVisible()
    {
        for (int i = 0; i < dbLine; i++)
        {
            if (Main.Instance.Status_GasValve.dbWriteTime[i] != "")
            {
                dbTime[i].text = Main.Instance.Status_GasValve.dbWriteTime[i];
                dbStatus[i].text = Main.Instance.Status_GasValve.dbStatus[i];
            }
        }
    }
}
