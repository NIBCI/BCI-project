using ChartAndGraph;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PageFit : PageBase
{
    private static PageFit _instance;
    public static PageFit Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = FindObjectOfType<PageFit>();
                if (!_instance)
                {
                    //Debug.Log("Fail");
                }
            }
            return _instance;
        }
    }

    public ImageList this_imageList;

    public GameObject mainBG;
    public GameObject arrow;

    public Text stepTxt;
    public Text bpmTxt;
    public Text calTxt;
    public Text todayTxt;

    public UIButton stepBtn;
    public UIButton bpmBtn;
    public UIButton calBtn;

    public BarChart barChart;
    public GraphChart graphChart;
    public GraphChart graphMaxChart;
    Text[] dayTxt;
    Text[] valueTxt;
    Text[] valueMaxTxt;

    // hover event
    int hoverSize;
    int nonSize;
    Color32 hoverColor;
    Color32 nonColor;

    GameObject legend_bpm;
    DateTime LasMonday;

    Vector3[] posArrow;

    public static int nState;

    // Start is called before the first frame update
    void Start()
    {
        this_imageList = transform.GetComponent<ImageList>();

        mainBG = transform.Find("MainBG_img").gameObject;
        stepTxt = mainBG.transform.GetChild(0).GetComponent<Text>();
        bpmTxt = mainBG.transform.GetChild(1).GetComponent<Text>();
        calTxt = mainBG.transform.GetChild(2).GetComponent<Text>();
        todayTxt = mainBG.transform.GetChild(3).GetComponent<Text>();

        stepBtn = this_imageList.GetButton("Step_btn_img");
        bpmBtn = this_imageList.GetButton("BPM_btn_img");
        calBtn = this_imageList.GetButton("Calories_btn_img");
        arrow = transform.Find("Arrow_img").gameObject;

        posArrow = new Vector3[3];
        for (int i = 0; i < posArrow.Length; i++)
        {
            posArrow[i] = new Vector3(-50, -23 - (i * 91), 0);
        }

        nState = 0;

        barChart = transform.Find("Fit_BarChart").GetComponent<BarChart>();
        graphChart = transform.Find("Fit_Graph").GetComponent<GraphChart>();
        graphMaxChart = transform.Find("Fit_Graph_Max").GetComponent<GraphChart>();
        dayTxt = new Text[7];
        valueTxt = new Text[7];
        valueMaxTxt = new Text[7];
        for (int i = 0; i < dayTxt.Length; i++)
        {
            dayTxt[i] = graphChart.transform.Find("DateList").transform.GetChild(i).GetComponent<Text>();
            valueTxt[i] = graphChart.transform.Find("ValueList").transform.GetChild(i).GetComponent<Text>();
            valueMaxTxt[i] = graphMaxChart.transform.Find("ValueList").transform.GetChild(i).GetComponent<Text>();
        }

        // hover event set
        hoverSize = 63;
        nonSize = 51;
        hoverColor = new Color32(255, 0, 0, 255);
        nonColor = new Color32(255, 255, 255, 255);

        legend_bpm = graphChart.transform.Find("Legend").transform.Find("MinMax").gameObject;

        SetDateTimes();

        todayTxt.text = DateTime.Today.ToString("yyyy. MM. dd");

        // debug
        Main.Instance.Status_Fit.SetDatabase(0, "1740", "62", "69", "1403");
        Main.Instance.Status_Fit.SetDatabase(1, "1642", "0", "0", "131");
        Main.Instance.Status_Fit.SetDatabase(2, "1892", "61", "90", "5995");
        Main.Instance.Status_Fit.SetDatabase(3, "1845", "64", "70", "3266");
        Main.Instance.Status_Fit.SetDatabase(4, "3195", "61", "82", "4443");
        Main.Instance.Status_Fit.SetDatabase(5, "3620", "65", "75", "9602");
        Main.Instance.Status_Fit.SetDatabase(6, "2365", "0", "0", "3173");
    }

    // Update is called once per frame
    void Update()
    {
        OnRay();
        FitVisible();
        DatabaseVisible();

        if (rayStayBtn
            && Main.Instance.isAbleBtn.Equals(true))
        {
            Main.Instance.isAbleBtn = false;
            FitIcon(rayStayBtn.gameObject.name);
        }
    }

    void FitVisible()
    {
        // btn overoll img init
        for (int i = 0; i < this_imageList.arr_UIButton.Length; i++)
        {
            UIButton btn = this_imageList.arr_UIButton[i];

            if (btn)
            {
                btn.GetComponent<Image>().sprite = btn.FindImage(btn.name);
            }
        }

        // btn overoll img & arrow position setting
        switch (nState)
        {
            case 0:

                break;

            case 1:
                stepBtn.GetComponent<Image>().sprite = stepBtn.FindOVImage("Step_btn_img");
                arrow.transform.localPosition = posArrow[nState - 1];
                break;

            case 2:
                bpmBtn.GetComponent<Image>().sprite = stepBtn.FindOVImage("BPM_btn_img");
                arrow.transform.localPosition = posArrow[nState - 1];
                break;

            case 3:
                calBtn.GetComponent<Image>().sprite = stepBtn.FindOVImage("Calories_btn_img");
                arrow.transform.localPosition = posArrow[nState - 1];
                break;
        }

        // now data show
        stepTxt.text = Main.Instance.Status_Fit.strSteps + " 걸음";
        bpmTxt.text = Main.Instance.Status_Fit.strBPM + " bpm";
        calTxt.text = Main.Instance.Status_Fit.strCalories + " Kcal";
    }

    void DatabaseVisible()
    {
        if (Main.Instance.Status_Fit.dbSteps[0] != "")
        {

            // btn push event
            switch (nState)
            {
                case 0:
                    barChart.enabled = false;
                    graphChart.enabled = false;
                    graphMaxChart.enabled = false;
                    legend_bpm.SetActive(false);
                    break;

                case 1:
                    barChart.enabled = true;
                    graphChart.enabled = true;
                    graphMaxChart.enabled = false;
                    legend_bpm.SetActive(false);

                    // draw once
                    if (barChart.DataSource.GetValue("Day1", "All") != 0)
                        return;

                    graphChart.DataSource.StartBatch();
                    graphChart.DataSource.ClearCategory("Data1");

                    for (int i = 0; i < 7; i++)
                    {
                        string strCategory = string.Format("Day{0}", i + 1);
                        barChart.DataSource.SetValue(strCategory, "All", Convert.ToSingle(Main.Instance.Status_Fit.dbSteps[i]) / 1000);
                        graphChart.DataSource.AddPointToCategory("Data1", (i * 2 + 1), (Convert.ToSingle(Main.Instance.Status_Fit.dbSteps[i]) / 1000) / 10);

                        dayTxt[i].text = LasMonday.AddDays(i).ToString("yy.MM.dd");
                        valueTxt[i].text = Main.Instance.Status_Fit.dbSteps[i];
                        valueMaxTxt[i].text = "";
                    }

                    graphChart.DataSource.AutomaticVerticallView = true;
                    graphChart.DataSource.EndBatch();

                    break;

                case 2:
                    barChart.enabled = false;
                    graphChart.enabled = true;
                    graphMaxChart.enabled = true;
                    legend_bpm.SetActive(true);

                    //// draw once
                    if (graphChart.DataSource.GetPoint("Data1", 3).y != 0)
                        return;

                    graphChart.DataSource.StartBatch();
                    graphChart.DataSource.ClearCategory("Data1");

                    graphMaxChart.DataSource.StartBatch();
                    graphMaxChart.DataSource.ClearCategory("Data2");

                    for (int i = 0; i < 7; i++)
                    {
                        graphChart.DataSource.AddPointToCategory("Data1", (i * 2 + 1), Convert.ToSingle(Main.Instance.Status_Fit.dbMinBPM[i]) / 30 + 5);
                        graphMaxChart.DataSource.AddPointToCategory("Data2", (i * 2 + 1), Convert.ToSingle(Main.Instance.Status_Fit.dbMaxBPM[i]) / 30 + 5);

                        dayTxt[i].text = LasMonday.AddDays(i).ToString("yy.MM.dd");
                        valueTxt[i].text = Main.Instance.Status_Fit.dbMinBPM[i];
                        valueMaxTxt[i].text = Main.Instance.Status_Fit.dbMaxBPM[i];
                    }


                    graphMaxChart.DataSource.AutomaticVerticallView = false;
                    graphMaxChart.DataSource.VerticalViewOrigin = 4.5;
                    graphMaxChart.DataSource.VerticalViewSize = 4;
                    graphChart.DataSource.AutomaticVerticallView = false;
                    graphChart.DataSource.VerticalViewOrigin = 4.5;
                    graphChart.DataSource.VerticalViewSize = 4;


                    graphChart.DataSource.EndBatch();
                    graphMaxChart.DataSource.EndBatch();
                    break;

                case 3:
                    barChart.enabled = true;
                    graphChart.enabled = true;
                    graphMaxChart.enabled = false;
                    legend_bpm.SetActive(false);

                    // draw once
                    if (barChart.DataSource.GetValue("Day1", "All") != 0)
                        return;

                    graphChart.DataSource.StartBatch();
                    graphChart.DataSource.ClearCategory("Data1");

                    for (int i = 0; i < 7; i++)
                    {
                        string strCategory = string.Format("Day{0}", i + 1);
                        barChart.DataSource.SetValue(strCategory, "All", Convert.ToSingle(Main.Instance.Status_Fit.dbCalories[i]) / 1000);
                        graphChart.DataSource.AddPointToCategory("Data1", (i * 2 + 1), (Convert.ToSingle(Main.Instance.Status_Fit.dbCalories[i]) / 1000) / 10);

                        dayTxt[i].text = LasMonday.AddDays(i).ToString("yy.MM.dd");
                        valueTxt[i].text = Main.Instance.Status_Fit.dbCalories[i];
                        valueMaxTxt[i].text = "";
                    }

                    graphChart.DataSource.AutomaticVerticallView = true;
                    graphChart.DataSource.EndBatch();
                    break;
            }
        }
    }

    public void ClearChart()
    {
        barChart.DataSource.ClearValues();
        graphChart.DataSource.ClearCategory("Data1");
        graphMaxChart.DataSource.ClearCategory("Data2");

        for (int i = 0; i < 7; i++)
        {
            dayTxt[i].text = "";
            valueTxt[i].text = "";
            valueMaxTxt[i].text = "";
        }
    }

    void SetDateTimes()
    {
        string strToday = DateTime.Now.DayOfWeek.ToString();

        switch (strToday)
        {
            case "Monday":
                LasMonday = DateTime.Now.AddDays(-7);
                break;

            case "Tuesday":
                LasMonday = DateTime.Now.AddDays(-8);
                break;

            case "Wednesday":
                LasMonday = DateTime.Now.AddDays(-9);
                break;

            case "Thursday":
                LasMonday = DateTime.Now.AddDays(-10);
                break;

            case "Friday":
                LasMonday = DateTime.Now.AddDays(-11);
                break;

            case "Saturday":
                LasMonday = DateTime.Now.AddDays(-12);
                break;

            case "Sunday":
                LasMonday = DateTime.Now.AddDays(-13);
                break;

            default:
                break;
        }
    }

    public void BarHovered(BarChart.BarEventArgs args)
    {
        int num = Convert.ToInt32(args.Category.Replace("Day", ""));
        dayTxt[num - 1].color = hoverColor;
        dayTxt[num - 1].fontSize = hoverSize;
        valueTxt[num - 1].color = hoverColor;
        valueTxt[num - 1].fontSize = hoverSize;
    }

    public void NonHovered()
    {
        for (int i = 0; i < 7; i++)
        {
            dayTxt[i].color = nonColor;
            dayTxt[i].fontSize = nonSize;
            valueTxt[i].color = nonColor;
            valueTxt[i].fontSize = nonSize;
        }
    }
}
