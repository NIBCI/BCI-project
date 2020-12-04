using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PageManager : MonoBehaviour
{
    private static PageManager _instance;
    public static PageManager Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = FindObjectOfType<PageManager>();
                if (!_instance)
                {
                    //Debug.Log("Fail");
                }
            }
            return _instance;
        }
    }

    public GameObject[] pages;

    private void Awake()
    {
        pages = new GameObject[transform.childCount];
        for (int i = 0; i < transform.childCount; i++)
        {
            pages[i] = transform.GetChild(i).gameObject;
        }
    }


    // Use this for initialization
    void Start()
    {
        GoHome();
    }

    void DeviceInit()
    {
        CCTV_Init();
    }

    public void CCTV_Init()
    {
        Main.Instance.Status_CCTV[0].SetData(false);
        Main.Instance.Status_CCTV[1].SetData(false);

        if (OggVideoStreamingTexture.Instance)
            OggVideoStreamingTexture.Instance.SetScreen(false);
    }

    public void GoHome()
    {
        InactiveAllPage();
        ActivePage("Page_Home");

        DeviceInit();

        //장비 선택 전송
        if (Main.Instance.UDP)
        {
            Main.Instance.UDP.UDP_Send("Device#Choice#" + "" + "#" + Main.Instance.deviceNumber.ToString());
        }
        Main.Instance.DeviceMode = Main.Device.None;
        //Main.Instance.BCI_Page = Main.DeviceDepth.Page0;
    }

    public void InactiveAllPage()
    {
        for (int i = 0; i < pages.Length; i++)
        {
            if (!pages[i].name.Equals("Page_Common"))
            {
                pages[i].gameObject.SetActive(false);
            }
        }
    }

    public void ActivePage(string strPageName)
    {
        GameObject page = null;
        for (int i = 0; i < pages.Length; i++)
        {
            if (pages[i].gameObject.name.Equals(strPageName))
            {
                page = pages[i];
                break;
            }
        }

        if (page)
            page.SetActive(true);

        Main.Instance.deviceNumber = 1;
    }

    public void ChangePage(string strPageName)
    {
        InactiveAllPage();
        ActivePage(strPageName);
    }

    public GameObject GetActivePage()
    {
        GameObject find = null;

        foreach (GameObject page in pages)
        {
            if (page.activeInHierarchy
                && !page.name.Equals("Page_Common"))
            {
                find = page;
                break;
            }
        }

        return find;
    }


}
