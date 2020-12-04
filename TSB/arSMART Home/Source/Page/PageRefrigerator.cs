using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PageRefrigerator : PageBase
{
    public ImageList this_imageList;
    public UIButton doorImg;
    public UIButton modeImg;

    public UIButton rapidFridgeOn_btn;
    public UIButton rapidFridgeOff_btn;
    public UIButton rapidFreezingOn_btn;
    public UIButton rapidFreezingOff_btn;

    public GameObject objTemp;
    public Text fridgeTemp;
    public Text freezingTemp;
    public Text setFridgeTemp;
    public Text setFreezingTemp;

    // db
    public GameObject objDB;
    public Text[] dbTime;
    public Text[] dbFridgeTemp;
    public Text[] dbFreezingTemp;
    public Text[] dbMode;

    public int dbLine;

    // Use this for initialization
    void Start()
    {
        this_imageList = transform.GetComponent<ImageList>();

        doorImg = this_imageList.GetButton("Door_btn_img");
        modeImg = this_imageList.GetButton("Mode_btn_img");

        rapidFridgeOn_btn = this_imageList.GetButton("RapidFridge#Off_btn");
        rapidFridgeOff_btn = this_imageList.GetButton("RapidFridge#On_btn");
        rapidFreezingOn_btn = this_imageList.GetButton("RapidFreezing#Off_btn");
        rapidFreezingOff_btn = this_imageList.GetButton("RapidFreezing#On_btn");

        objTemp = transform.Find("TempBG_img").gameObject;
        fridgeTemp = objTemp.transform.Find("NowFridgeTemp_txt").GetComponent<Text>();
        freezingTemp = objTemp.transform.Find("NowFreezingTemp_txt").GetComponent<Text>();
        setFridgeTemp = objTemp.transform.Find("SetFridgeTemp_txt").GetComponent<Text>();
        setFreezingTemp = objTemp.transform.Find("SetFreezingTemp_txt").GetComponent<Text>();

        // db   
        dbLine = Main.Instance.dbLine;
        dbTime = new Text[dbLine];
        dbFridgeTemp = new Text[dbLine];
        dbFreezingTemp = new Text[dbLine];
        dbMode = new Text[dbLine];

        objDB = transform.Find("DataList_img").gameObject;

        for (int i = 0; i < dbLine; i++)
        {
            dbTime[i] = objDB.transform.GetChild(0 + i * 4).GetComponent<Text>();
            dbFridgeTemp[i] = objDB.transform.GetChild(1 + i * 4).GetComponent<Text>();
            dbFreezingTemp[i] = objDB.transform.GetChild(2 + i * 4).GetComponent<Text>();
            dbMode[i] = objDB.transform.GetChild(3 + i * 4).GetComponent<Text>();
        }
    }

    // Update is called once per frame
    void Update()
    {
        OnRay();
        RefrigeratorVisible();
        DatabaseVisible();

        if (rayStayBtn
            && Main.Instance.isAbleBtn.Equals(true))
        {
            Main.Instance.isAbleBtn = false;
            RefrigeratorIcon(rayStayBtn.gameObject.name);
        }
    }

    public void RefrigeratorVisible()
    {
        // allOpen, fridgeOpen, freezingOpen, allClose
        // freezer, softFreezer, meatFish, vegetableCheese, beer
        string doorImgName = Main.Instance.Status_Refrigerator.strRefDoor + "_btn_img";
        string modeImgName = Main.Instance.Status_Refrigerator.strMode + "_btn_img";

        doorImg.GetComponent<Image>().sprite = doorImg.FindImage(doorImgName);
        modeImg.GetComponent<Image>().sprite = modeImg.FindImage(modeImgName);

        //Main.Instance.notice.text = doorImgName + " // " + modeImgName;

        fridgeTemp.text = Main.Instance.Status_Refrigerator.strFridgeTemp + "℃";
        freezingTemp.text = Main.Instance.Status_Refrigerator.strFreezingTemp + "℃";
        setFridgeTemp.text = Main.Instance.Status_Refrigerator.strSetFridgeTemp + "℃";
        setFreezingTemp.text = Main.Instance.Status_Refrigerator.strSetFreezingTemp + "℃";

        if (Main.Instance.Status_Refrigerator.strRapidFridge.Equals("on"))
        {
            rapidFridgeOn_btn.gameObject.SetActive(true);
            rapidFridgeOff_btn.gameObject.SetActive(false);
        }
        else
        {
            rapidFridgeOn_btn.gameObject.SetActive(false);
            rapidFridgeOff_btn.gameObject.SetActive(true);
        }

        if (Main.Instance.Status_Refrigerator.strRapidFreezing.Equals("on"))
        {
            rapidFreezingOn_btn.gameObject.SetActive(true);
            rapidFreezingOff_btn.gameObject.SetActive(false);
        }
        else
        {
            rapidFreezingOn_btn.gameObject.SetActive(false);
            rapidFreezingOff_btn.gameObject.SetActive(true);
        }
    }

    public void DatabaseVisible()
    {
        for (int i = 0; i < dbLine; i++)
        {
            if (Main.Instance.Status_Refrigerator.dbWriteTime[i] != "")
            {
                dbTime[i].text = Main.Instance.Status_Refrigerator.dbWriteTime[i];
                dbFridgeTemp[i].text = Main.Instance.Status_Refrigerator.dbSetFridgeTemp[i];
                dbFreezingTemp[i].text = Main.Instance.Status_Refrigerator.dbSetFreezingTemp[i];
                dbMode[i].text = Main.Instance.Status_Refrigerator.dbMode[i];
            }
        }
    }
}
