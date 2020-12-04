using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PageTV : PageBase
{
    public ImageList this_imageList;

    public UIButton onBtn;
    public UIButton offBtn;

    // Use this for initialization
    void Start()
    {
        this_imageList = transform.GetComponent<ImageList>();

        onBtn = this_imageList.GetButton("Power#On_btn");
        offBtn = this_imageList.GetButton("Power#Off_btn");
    }

    // Update is called once per frame
    void Update()
    {
        OnRay();
        TvVisible();

        if (rayStayBtn
            && Main.Instance.isAbleBtn.Equals(true))
        {
            Main.Instance.isAbleBtn = false;
            TvIcon(rayStayBtn.gameObject.name);
        }
    }

    void TvVisible()
    {
        if (Main.Instance.Status_TV.strSwitch.Equals("on"))
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
