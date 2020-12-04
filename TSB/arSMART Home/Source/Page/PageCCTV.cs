using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PageCCTV : PageBase
{
    public ImageList this_imageList;

    public UIButton[] cctvBtn;
    public UIButton onBtn;
    public UIButton offBtn;

    // Use this for initialization
    void Start()
    {
        this_imageList = transform.GetComponent<ImageList>();

        cctvBtn = new UIButton[2];

        cctvBtn[0] = this_imageList.GetButton("Select#CCTV#1_btn");
        cctvBtn[1] = this_imageList.GetButton("Select#CCTV#2_btn");

        onBtn = this_imageList.GetButton("Streaming#On_btn");
        offBtn = this_imageList.GetButton("Streaming#Off_btn");

        //Main.Instance.oggTexture.InitSteaming();
    }

    // Update is called once per frame
    void Update()
    {
        OnRay();
        cctvVisible();

        if (rayStayBtn
            && Main.Instance.isAbleBtn.Equals(true))
        {
            Main.Instance.isAbleBtn = false;
            CCTVIcon(rayStayBtn.gameObject.name);
        }
    }

    void cctvVisible()
    {
        for (int i = 0; i < this_imageList.arr_UIButton.Length; i++)
        {
            UIButton btn = this_imageList.arr_UIButton[i];

            if (btn
                && btn.name.Contains("Select"))
            {
                btn.GetComponent<Image>().sprite = btn.FindImage(btn.name);
            }
        }

        int dNum = Main.Instance.deviceNumber;
        if (dNum == 0)
            dNum = 1;

        cctvBtn[dNum - 1].GetComponent<Image>().sprite = cctvBtn[dNum - 1].FindOVImage("Select#CCTV#" + dNum + "_btn");

        if (Main.Instance.Status_CCTV[dNum - 1].isStream.Equals(true))
        {
            onBtn.gameObject.SetActive(false);
            offBtn.gameObject.SetActive(true);
        }
        else
        {
            onBtn.gameObject.SetActive(true);
            offBtn.gameObject.SetActive(false);
        }
    }
}
