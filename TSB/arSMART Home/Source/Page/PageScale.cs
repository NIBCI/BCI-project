using ChartAndGraph;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PageScale : PageBase
{
    private static PageScale _instance;
    public static PageScale Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = FindObjectOfType<PageScale>();
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
    public GameObject recordBG;

    public Text weightTxt;
    public Text dateTxt;
    public Text subTxt;

    public UIButton latestBtn;
    public UIButton week1Btn;
    public UIButton week2Btn;

    public static int nState;

    public BarChart barChart;
    public GraphChart graphChart;
    Text[] dayTxt;
    Text[] valueTxt;

    // hover event
    int hoverSize;
    int nonSize;
    Color32 hoverColor;
    Color32 nonColor;

    // Start is called before the first frame update
    void Start()
    {
        this_imageList = transform.GetComponent<ImageList>();

        mainBG = transform.Find("MainBG_img").gameObject;
        recordBG = transform.Find("RecordBG_img").gameObject;

        weightTxt = mainBG.transform.GetChild(0).GetComponent<Text>();
        dateTxt = recordBG.transform.GetChild(0).GetComponent<Text>();
        subTxt = recordBG.transform.GetChild(1).GetComponent<Text>();

        latestBtn = this_imageList.GetButton("Latest_btn");
        week1Btn = this_imageList.GetButton("1Week_btn");
        week2Btn = this_imageList.GetButton("2Week_btn");

        recordBG.SetActive(false);

        nState = 0;

        barChart = transform.Find("Scale_BarChart").GetComponent<BarChart>();
        graphChart = transform.Find("Scale_Graph").GetComponent<GraphChart>();
        dayTxt = new Text[7];
        valueTxt = new Text[7];
        for (int i = 0; i < dayTxt.Length; i++)
        {
            dayTxt[i] = graphChart.transform.Find("DateList").transform.GetChild(i).GetComponent<Text>();
            valueTxt[i] = graphChart.transform.Find("ValueList").transform.GetChild(i).GetComponent<Text>();
        }

        // hover event set
        hoverSize = 53;
        nonSize = 41;
        hoverColor = new Color32(255, 0, 0, 255);
        nonColor = new Color32(255, 255, 255, 255);

        // debug
        Main.Instance.Status_Scale.SetDatabase(0, "72.6", "07.24 08:32");
        Main.Instance.Status_Scale.SetDatabase(1, "72.6", "07.24 08:32");
        Main.Instance.Status_Scale.SetDatabase(2, "72.6", "07.24 08:32");
        Main.Instance.Status_Scale.SetDatabase(3, "73.5", "07.27 09:24");
        Main.Instance.Status_Scale.SetDatabase(4, "73.8", "07.28 10:39");
        Main.Instance.Status_Scale.SetDatabase(5, "73.8", "07.28 10:39");
        Main.Instance.Status_Scale.SetDatabase(6, "73.8", "07.28 10:39");

        Main.Instance.Status_Scale.SetDatabase(7, "73.4", "07.31 13:40");
        Main.Instance.Status_Scale.SetDatabase(8, "73.4", "07.31 13:40");
        Main.Instance.Status_Scale.SetDatabase(9, "73.4", "07.31 13:40");
        Main.Instance.Status_Scale.SetDatabase(10, "73.4", "07.31 13:40");
        Main.Instance.Status_Scale.SetDatabase(11, "73.4", "07.31 13:40");
        Main.Instance.Status_Scale.SetDatabase(12, "73.4", "07.31 13:40");
        Main.Instance.Status_Scale.SetDatabase(13, "73.4", "07.31 13:40");
    }

    // Update is called once per frame
    void Update()
    {
        OnRay();
        ScaleVisible();
        DatabaseVisible();


        if (rayStayBtn
            && Main.Instance.isAbleBtn.Equals(true))
        {
            Main.Instance.isAbleBtn = false;
            ScaleIcon(rayStayBtn.gameObject.name);
        }
    }

    void ScaleVisible()
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

        // latest weight shohw
        weightTxt.text = Main.Instance.Status_Scale.strLatestWeight + " Kg";

        // btn push event
        switch (nState)
        {
            case 0:
                break;

            case 1:
                recordBG.SetActive(true);
                dateTxt.text = Main.Instance.Status_Scale.strBeforeDate;

                if (Convert.ToDouble(Main.Instance.Status_Scale.strLatestWeight) - Convert.ToDouble(Main.Instance.Status_Scale.strBeforeWeight) < 0)
                {
                    subTxt.color = new Color32(0, 0, 255, 255);
                    subTxt.text = "- " + Math.Round((Convert.ToDouble(Main.Instance.Status_Scale.strLatestWeight) - Convert.ToDouble(Main.Instance.Status_Scale.strBeforeWeight)), 2).ToString() + " Kg";
                }
                else if (Convert.ToDouble(Main.Instance.Status_Scale.strLatestWeight) - Convert.ToDouble(Main.Instance.Status_Scale.strBeforeWeight) == 0)
                {
                    subTxt.color = new Color32(255, 255, 255, 255);
                    subTxt.text = "0 Kg";
                }
                else
                {
                    subTxt.color = new Color32(255, 0, 0, 255);
                    subTxt.text = "+ " + Math.Round((Convert.ToDouble(Main.Instance.Status_Scale.strLatestWeight) - Convert.ToDouble(Main.Instance.Status_Scale.strBeforeWeight)), 2).ToString() + " Kg";
                }
                latestBtn.GetComponent<Image>().sprite = latestBtn.FindOVImage("Latest_btn");
                break;

            case 2:
                recordBG.SetActive(false);
                week1Btn.GetComponent<Image>().sprite = week1Btn.FindOVImage("1Week_btn");
                break;

            case 3:
                recordBG.SetActive(false);
                week2Btn.GetComponent<Image>().sprite = week2Btn.FindOVImage("2Week_btn");
                break;
        }

    }

    void DatabaseVisible()
    {
        if (Main.Instance.Status_Scale.dbLastWeights[0] != "")
        {
            // btn push event
            switch (nState)
            {
                case 0:

                    break;

                case 1:
                    //dbTest.text = "No Graph";
                    ClearChart();

                    break;

                // 1 week ago
                case 2:
                    // draw once
                    if (barChart.DataSource.GetValue("Day1", "All") != 0)
                        return;

                    graphChart.DataSource.StartBatch();
                    graphChart.DataSource.ClearCategory("Data1");

                    for (int i = 0; i < 7; i++)
                    {
                        string strCategory = string.Format("Day{0}", i + 1);

                        if (i > 0
                            && (Main.Instance.Status_Scale.dbLastDates[i + 6] == Main.Instance.Status_Scale.dbLastDates[i + 7]))
                        {
                            barChart.DataSource.SetValue(strCategory, "All", 0);
                            graphChart.DataSource.AddPointToCategory("Data1", (i * 2 + 1), 0);

                            dayTxt[i].text = "";
                            valueTxt[i].text = "";
                        }
                        else
                        {
                            barChart.DataSource.SetValue(strCategory, "All", Convert.ToSingle(Main.Instance.Status_Scale.dbLastWeights[i + 7]));
                            graphChart.DataSource.AddPointToCategory("Data1", (i * 2 + 1), (Convert.ToSingle(Main.Instance.Status_Scale.dbLastWeights[i + 7])) / 500);

                            dayTxt[i].text = Main.Instance.Status_Scale.dbLastDates[i + 7];
                            valueTxt[i].text = Main.Instance.Status_Scale.dbLastWeights[i + 7] + " Kg";
                        }
                    }

                    //barChart.DataSource.MaxValue = Math.Ceiling(Convert.ToSingle(Main.Instance.Status_Scale.dbLastWeights[7]) / 10) * 10;
                    //barChart.DataSource.MinValue = Math.Truncate(Convert.ToSingle(Main.Instance.Status_Scale.dbLastWeights[7]) / 10) * 10 - 10;

                    barChart.DataSource.MaxValue = Convert.ToSingle(Main.Instance.Status_Scale.dbLastWeights[7]) + 7;
                    barChart.DataSource.MinValue = Convert.ToSingle(Main.Instance.Status_Scale.dbLastWeights[7]) - 7;

                    //graphChart.DataSource.AutomaticVerticallView = true;
                    graphChart.DataSource.EndBatch();
                    break;

                // 2 week ago
                case 3:
                    // draw once
                    if (barChart.DataSource.GetValue("Day1", "All") != 0)
                        return;

                    graphChart.DataSource.StartBatch();
                    graphChart.DataSource.ClearCategory("Data1");

                    for (int i = 0; i < 7; i++)
                    {
                        string strCategory = string.Format("Day{0}", i + 1);

                        if (i > 0
                            && (Main.Instance.Status_Scale.dbLastDates[i - 1] == Main.Instance.Status_Scale.dbLastDates[i]))
                        {
                            barChart.DataSource.SetValue(strCategory, "All", 0);
                            graphChart.DataSource.AddPointToCategory("Data1", (i * 2 + 1), 0);

                            dayTxt[i].text = "";
                            valueTxt[i].text = "";
                        }
                        else
                        {
                            barChart.DataSource.SetValue(strCategory, "All", Convert.ToSingle(Main.Instance.Status_Scale.dbLastWeights[i]));
                            graphChart.DataSource.AddPointToCategory("Data1", (i * 2 + 1), (Convert.ToSingle(Main.Instance.Status_Scale.dbLastWeights[i])) / 500);

                            dayTxt[i].text = Main.Instance.Status_Scale.dbLastDates[i];
                            valueTxt[i].text = Main.Instance.Status_Scale.dbLastWeights[i] + " Kg";
                        }
                    }

                    //barChart.DataSource.MaxValue = Math.Ceiling(Convert.ToSingle(Main.Instance.Status_Scale.dbLastWeights[0]) / 10) * 10;
                    //barChart.DataSource.MinValue = Math.Truncate(Convert.ToSingle(Main.Instance.Status_Scale.dbLastWeights[0]) / 10) * 10 - 10;

                    barChart.DataSource.MaxValue = Convert.ToSingle(Main.Instance.Status_Scale.dbLastWeights[0]) + 7;
                    barChart.DataSource.MinValue = Convert.ToSingle(Main.Instance.Status_Scale.dbLastWeights[0]) - 7;

                    //graphChart.DataSource.AutomaticVerticallView = true;
                    graphChart.DataSource.EndBatch();
                    break;
            }
        }
    }

    public void ClearChart()
    {
        barChart.DataSource.ClearValues();
        graphChart.DataSource.ClearCategory("Data1");

        for (int i = 0; i < 7; i++)
        {
            dayTxt[i].text = "";
            valueTxt[i].text = "";
        }
    }

    public void BarHovered(BarChart.BarEventArgs args)
    {
        int num = Convert.ToInt32(args.Category.Replace("Day", ""));
        dayTxt[num - 1].color = hoverColor;
        dayTxt[num - 1].fontSize = hoverSize;
        valueTxt[num - 1].color = hoverColor;
        valueTxt[num - 1].fontSize = hoverSize + 10;
    }

    public void NonHovered()
    {
        for (int i = 0; i < 7; i++)
        {
            dayTxt[i].color = nonColor;
            dayTxt[i].fontSize = nonSize;
            valueTxt[i].color = nonColor;
            valueTxt[i].fontSize = nonSize + 10;
        }
    }
}
