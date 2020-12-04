using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PageHome : PageBase
{
    Text time_txt;

    private void Start()
    {
        time_txt = transform.Find("Time_img").gameObject.transform.GetChild(0).gameObject.GetComponent<Text>();
    }

    // Update is called once per frame
    void Update()
    {
        Set_Time();
        OnRay();

        if (rayStayBtn
            && Main.Instance.isAbleBtn.Equals(true))
        {
            Main.Instance.isAbleBtn = false;
            SelectIcon(rayStayBtn.gameObject.name);
        }
    }

    void Set_Time()
    {
        time_txt.text = DateTime.Now.ToString("HH:mm");
    }
}

