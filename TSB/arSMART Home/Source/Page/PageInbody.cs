using ChartAndGraph;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PageInbody : PageBase
{
    private static PageInbody _instance;
    public static PageInbody Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = FindObjectOfType<PageInbody>();
                if (!_instance)
                {
                    //Debug.Log("Fail");
                }
            }
            return _instance;
        }
    }

    public struct BodyData
    {
        public float fAge;
        public string strGender;
        public float fHeight;

        public int score;
        public float fWeight;
        public float fSMM;
        public float fBFM;
        public int BMR;
        public int renergy;

        public float fBMI;
        public float fPBF;
        public float fWHR;
        public float fVFL;

        public float fTW;
        public float fWC;
        public float fFC;
        public float fMC;
    }
    public BodyData bodyData;

    public ImageList this_imageList;

    public GameObject weightBG;
    public GameObject fatBG;
    public GameObject RecomandBG;

    // 체중, 골격근량, 체지방량, 체지방률
    public Text scoreTxt;
    public Text weightTxt;
    public Text smmTxt;
    public Text bfmTxt;
    public Text bmrTxt;
    public Text renergyTxt;

    // bmi, 체지방률, 복부지방률, 내장지방레벨
    public Text bmiTxt;
    public Text pbfTxt;
    public Text whrTxt;
    public Text vflTxt;

    // 적정체중, 체중-지방-근육 조절
    public Text twTxt;
    public Text wcTxt;
    public Text fcTxt;
    public Text mcTxt;

    // boundry setting
    float fWeight_min;
    float fWeight_max;
    float fSMM_min;
    float fSMM_max;
    float fBFM_min;
    float fBFM_max;
    float fBMI_min;
    float fBMI_max;
    float fPBF_min;
    float fPBF_max;
    float fWHR_min;
    float fWHR_max;
    float fVFL_min;
    float fVFL_max;

    public UIButton BFM_btn;
    public UIButton Mineral_btn;
    public UIButton Protein_btn;

    UIButton[] lv_Weight;
    UIButton[] lv_SMM;
    UIButton[] lv_BFM;
    UIButton[] lv_BMI;
    UIButton[] lv_PBF;
    UIButton[] lv_WHR;
    UIButton[] lv_VFl;
    UIButton[] img_Body;
    UIButton lv_Body;

    // user btn
    UIButton default_btn;
    UIButton male_btn;
    UIButton female_btn;
    UIButton child_btn;

    // user mode
    public enum User
    {
        Default,
        Male,
        Female,
        Child
    }
    public User userMode = User.Default;

    public int lv_size;
    public int img_size;
    int[] lv_body;
    public Text lvTxt;

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

    // Use this for initialization
    void Start()
    {
        this_imageList = transform.GetComponent<ImageList>();

        scoreTxt = transform.Find("ScoreBG_img").transform.Find("Score_txt").GetComponent<Text>();

        weightBG = transform.Find("WeightBG_img").gameObject;
        weightTxt = weightBG.transform.GetChild(0).GetComponent<Text>();
        smmTxt = weightBG.transform.GetChild(1).GetComponent<Text>();
        bfmTxt = weightBG.transform.GetChild(2).GetComponent<Text>();

        fatBG = transform.Find("FatBG_img").gameObject;
        bmiTxt = fatBG.transform.GetChild(0).GetComponent<Text>();
        pbfTxt = fatBG.transform.GetChild(1).GetComponent<Text>();
        whrTxt = fatBG.transform.GetChild(2).GetComponent<Text>();
        vflTxt = fatBG.transform.GetChild(3).GetComponent<Text>();

        bmrTxt = transform.Find("BMRBG_img").transform.Find("BMR_txt").GetComponent<Text>();
        renergyTxt = transform.Find("RenergyBG_img").transform.Find("Renergy_txt").GetComponent<Text>();

        RecomandBG = transform.Find("RecommandBG_img").gameObject;
        twTxt = RecomandBG.transform.GetChild(0).GetComponent<Text>();
        wcTxt = RecomandBG.transform.GetChild(1).GetComponent<Text>();
        fcTxt = RecomandBG.transform.GetChild(2).GetComponent<Text>();
        mcTxt = RecomandBG.transform.GetChild(3).GetComponent<Text>();

        BFM_btn = this_imageList.GetButton("BFM_btn");
        Mineral_btn = this_imageList.GetButton("Mineral_btn");
        Protein_btn = this_imageList.GetButton("Protein_btn");

        lv_size = 3;
        img_size = 9;
        lv_Body = this_imageList.GetButton("Body_lv_btn_img");
        lvTxt = transform.Find("GraphBG_img").transform.GetChild(0).GetComponent<Text>();

        // 색상에 따라 1 ~ 3 ;; blue(1), green(2), red(3)
        // arr 순서대로 weight, smm, bfm
        lv_body = new int[3];

        lv_Weight = new UIButton[lv_size];
        lv_SMM = new UIButton[lv_size];
        lv_BFM = new UIButton[lv_size];
        lv_BMI = new UIButton[lv_size];
        lv_PBF = new UIButton[lv_size];
        lv_WHR = new UIButton[lv_size];
        lv_VFl = new UIButton[lv_size];
        img_Body = new UIButton[img_size];

        for (int i = 0; i < lv_size; i++)
        {
            lv_Weight[i] = this_imageList.GetButton(String.Format("Weight_lv{0}_btn_img", i + 1));
            lv_SMM[i] = this_imageList.GetButton(String.Format("SMM_lv{0}_btn_img", i + 1));
            lv_BFM[i] = this_imageList.GetButton(String.Format("BFM_lv{0}_btn_img", i + 1));
            lv_BMI[i] = this_imageList.GetButton(String.Format("BMI_lv{0}_btn_img", i + 1));
            lv_PBF[i] = this_imageList.GetButton(String.Format("PBF_lv{0}_btn_img", i + 1));
            lv_WHR[i] = this_imageList.GetButton(String.Format("WHR_lv{0}_btn_img", i + 1));
            lv_VFl[i] = this_imageList.GetButton(String.Format("VFL_lv{0}_btn_img", i + 1));
        }
        for (int i = 0; i < img_size; i++)
        {
            img_Body[i] = this_imageList.GetButton(String.Format("Body_type{0}_btn_img", i + 1));
        }

        nState = 0;

        barChart = transform.Find("Inbody_BarChart").GetComponent<BarChart>();
        graphChart = transform.Find("Inbody_Graph").GetComponent<GraphChart>();
        dayTxt = new Text[5];
        valueTxt = new Text[5];
        for (int i = 0; i < dayTxt.Length; i++)
        {
            dayTxt[i] = graphChart.transform.Find("DateList").transform.GetChild(i).GetComponent<Text>();
            valueTxt[i] = graphChart.transform.Find("ValueList").transform.GetChild(i).GetComponent<Text>();
        }

        // user Change btn
        default_btn = this_imageList.GetButton("User#Default_btn");        
        male_btn = this_imageList.GetButton("User#Male_btn");
        female_btn = this_imageList.GetButton("User#Female_btn");
        child_btn = this_imageList.GetButton("User#Child_btn");

        // hover event set
        hoverSize = 63;
        nonSize = 51;
        hoverColor = new Color32(255, 0, 0, 255);
        nonColor = new Color32(255, 255, 255, 255);

        // debug
        Main.Instance.Status_Inbody.SetDatabase(0, "31.4", "11.2", "3.78", "17.3", "2020.07.27");
        Main.Instance.Status_Inbody.SetDatabase(1, "28.1", "10.9", "3.66", "17.5", "2020.07.28");
        Main.Instance.Status_Inbody.SetDatabase(2, "27.9", "10.9", "3.77", "18.3", "2020.07.29");
        Main.Instance.Status_Inbody.SetDatabase(3, "26.5", "10.9", "3.76", "17.8", "2020.07.30");
        Main.Instance.Status_Inbody.SetDatabase(4, "21.4", "10.8", "3.65", "17.8", "2020.07.31");
    }

    // Update is called once per frame
    void Update()
    {
        OnRay();
        Set_Data();
        InbodyVisible();
        Show_Chart();
        DatabaseVisible();

        if (rayStayBtn
            && Main.Instance.isAbleBtn.Equals(true))
        {
            Main.Instance.isAbleBtn = false;
            InbodyIcon(rayStayBtn.gameObject.name);
        }
    }

    void Set_Data()
    {
        bodyData.fAge = Convert.ToSingle(Main.Instance.Status_Inbody.strAge);
        bodyData.strGender = Main.Instance.Status_Inbody.strGender;
        bodyData.fHeight = Convert.ToSingle(Main.Instance.Status_Inbody.strHeight);

        bodyData.score = Convert.ToInt32(Main.Instance.Status_Inbody.strScore);
        bodyData.fWeight = Convert.ToSingle(Main.Instance.Status_Inbody.strWeight);
        bodyData.fSMM = Convert.ToSingle(Main.Instance.Status_Inbody.strSMM);
        bodyData.fBFM = Convert.ToSingle(Main.Instance.Status_Inbody.strBFM);
        bodyData.BMR = Convert.ToInt32(Main.Instance.Status_Inbody.strBMR);
        bodyData.renergy = Convert.ToInt32(Main.Instance.Status_Inbody.strRenergy);

        bodyData.fBMI = Convert.ToSingle(Main.Instance.Status_Inbody.strBMI);
        bodyData.fPBF = Convert.ToSingle(Main.Instance.Status_Inbody.strPBF);
        bodyData.fWHR = Convert.ToSingle(Main.Instance.Status_Inbody.strWHR);
        bodyData.fVFL = Convert.ToSingle(Main.Instance.Status_Inbody.strVFL);

        bodyData.fTW = Convert.ToSingle(Main.Instance.Status_Inbody.strTW);
        bodyData.fWC = Convert.ToSingle(Main.Instance.Status_Inbody.strWC);
        bodyData.fFC = Convert.ToSingle(Main.Instance.Status_Inbody.strFC);
        bodyData.fMC = Convert.ToSingle(Main.Instance.Status_Inbody.strMC);


        float st_SMM = bodyData.fSMM + bodyData.fMC;
        float st_BFM = bodyData.fBFM + bodyData.fFC;

        fWeight_min = bodyData.fTW * 0.85f;
        fWeight_max = bodyData.fTW * 1.15f;

        fSMM_min = st_SMM * 0.9f;
        fSMM_max = st_SMM * 1.1f;

        fBFM_min = st_BFM * 0.8f;
        fBFM_max = st_BFM * 1.6f;

        fBMI_min = 18.5f;
        fBMI_max = 25.0f;

        fVFL_min = 8;
        fVFL_max = 12;

        if (bodyData.strGender.Equals("M"))
        {
            fPBF_min = 10.0f;
            fPBF_max = 20.0f;

            fWHR_min = 0.8f;
            fWHR_max = 0.9f;
        }
        else
        {
            fPBF_min = 18.0f;
            fPBF_max = 28.0f;

            fWHR_min = 0.75f;
            fWHR_max = 0.85f;
        }
    }

    void InbodyVisible()
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

        // btn push event
        switch (nState)
        {
            case 0:
                break;

            case 1:
                BFM_btn.GetComponent<Image>().sprite = BFM_btn.FindOVImage("BFM_btn");
                break;

            case 2:
                Mineral_btn.GetComponent<Image>().sprite = Mineral_btn.FindOVImage("Mineral_btn");
                break;

            case 3:
                Protein_btn.GetComponent<Image>().sprite = Protein_btn.FindOVImage("Protein_btn");
                break;
        }

        switch (userMode)
        {
            case User.Default:
                default_btn.GetComponent<Image>().sprite = default_btn.FindOVImage("User#Default_btn");
                break;

            case User.Male:
                male_btn.GetComponent<Image>().sprite = male_btn.FindOVImage("User#Male_btn");
                break;

            case User.Female:
                female_btn.GetComponent<Image>().sprite = female_btn.FindOVImage("User#Female_btn");
                break;

            case User.Child:
                child_btn.GetComponent<Image>().sprite = child_btn.FindOVImage("User#Child_btn");
                break;
        }

        scoreTxt.text = bodyData.score.ToString();

        weightTxt.text = bodyData.fWeight.ToString();
        smmTxt.text = bodyData.fSMM.ToString();
        bfmTxt.text = bodyData.fBFM.ToString();

        bmiTxt.text = bodyData.fBMI.ToString();
        pbfTxt.text = bodyData.fPBF.ToString();
        whrTxt.text = bodyData.fWHR.ToString();
        vflTxt.text = bodyData.fVFL.ToString();

        bmrTxt.text = bodyData.BMR.ToString();
        renergyTxt.text = bodyData.renergy.ToString();

        twTxt.text = bodyData.fTW.ToString();
        wcTxt.text = bodyData.fWC.ToString();
        fcTxt.text = bodyData.fFC.ToString();
        mcTxt.text = bodyData.fMC.ToString();
    }

    void Show_Chart()
    {
        // init
        for (int i = 0; i < lv_size; i++)
        {
            lv_Weight[i].gameObject.SetActive(false);
            lv_SMM[i].gameObject.SetActive(false);
            lv_BFM[i].gameObject.SetActive(false);
            lv_BMI[i].gameObject.SetActive(false);
            lv_PBF[i].gameObject.SetActive(false);
            lv_WHR[i].gameObject.SetActive(false);
            lv_VFl[i].gameObject.SetActive(false);
        }
        for (int i = 0; i < img_size; i++)
        {
            img_Body[i].gameObject.SetActive(false);
        }

        // condition check 후 show
        if (bodyData.fWeight > fWeight_max)
        {
            lv_Weight[2].gameObject.SetActive(true);
            lv_body[0] = 3;
        }
        else if (bodyData.fWeight < fWeight_min)
        {
            lv_Weight[0].gameObject.SetActive(true);
            lv_body[0] = 1;
        }
        else
        {
            lv_Weight[1].gameObject.SetActive(true);
            lv_body[0] = 2;
        }

        if (bodyData.fSMM > fSMM_max)
        {
            lv_SMM[2].gameObject.SetActive(true);
            lv_body[1] = 3;
        }
        else if (bodyData.fSMM < fSMM_min)
        {
            lv_SMM[0].gameObject.SetActive(true);
            lv_body[1] = 1;
        }
        else
        {
            lv_SMM[1].gameObject.SetActive(true);
            lv_body[1] = 2;
        }

        if (bodyData.fBFM > fBFM_max)
        {
            lv_BFM[2].gameObject.SetActive(true);
            lv_body[2] = 3;
        }
        else if (bodyData.fBFM < fBFM_min)
        {
            lv_BFM[0].gameObject.SetActive(true);
            lv_body[2] = 1;
        }
        else
        {
            lv_BFM[1].gameObject.SetActive(true);
            lv_body[2] = 2;
        }

        Show_BodyLevel();

        if (bodyData.fBMI > fBMI_max)
            lv_BMI[2].gameObject.SetActive(true);
        else if (bodyData.fBMI < fBMI_min)
            lv_BMI[0].gameObject.SetActive(true);
        else
            lv_BMI[1].gameObject.SetActive(true);

        if (bodyData.fPBF > fPBF_max)
            lv_PBF[2].gameObject.SetActive(true);
        else if (bodyData.fPBF < fPBF_min)
            lv_PBF[0].gameObject.SetActive(true);
        else
            lv_PBF[1].gameObject.SetActive(true);

        if (bodyData.fWHR > fWHR_max)
            lv_WHR[2].gameObject.SetActive(true);
        else if (bodyData.fWHR < fWHR_min)
            lv_WHR[0].gameObject.SetActive(true);
        else
            lv_WHR[1].gameObject.SetActive(true);

        if (bodyData.fVFL > fVFL_max)
            lv_VFl[2].gameObject.SetActive(true);
        else if (bodyData.fVFL < fVFL_min)
            lv_VFl[0].gameObject.SetActive(true);
        else
            lv_VFl[1].gameObject.SetActive(true);
    }

    void DatabaseVisible()
    {
        if (barChart == null
            || graphChart == null)
            return;


        if (Main.Instance.Status_Inbody.dbTBW[0] != "")
        {
            // draw once
            if (barChart.DataSource.GetValue("Day1", "All") != 0)
                return;

            // btn push event
            switch (nState)
            {
                case 0:
                    break;

                case 1:
                    graphChart.DataSource.StartBatch();
                    graphChart.DataSource.ClearCategory("Data1");

                    for (int i = 0; i < 5; i++)
                    {
                        string strCategory = string.Format("Day{0}", i + 1);
                        barChart.DataSource.SetValue(strCategory, "All", Convert.ToSingle(Main.Instance.Status_Inbody.dbBFM[i]));
                        graphChart.DataSource.AddPointToCategory("Data1", (i * 2 + 1), Convert.ToSingle(Main.Instance.Status_Inbody.dbBFM[i]) / 10);

                        dayTxt[i].text = Main.Instance.Status_Inbody.dbDate[i];
                        valueTxt[i].text = Main.Instance.Status_Inbody.dbBFM[i];
                    }

                    graphChart.DataSource.EndBatch();
                    break;

                case 2:
                    graphChart.DataSource.StartBatch();
                    graphChart.DataSource.ClearCategory("Data1");

                    for (int i = 0; i < 5; i++)
                    {
                        string strCategory = string.Format("Day{0}", i + 1);
                        barChart.DataSource.SetValue(strCategory, "All", Convert.ToSingle(Main.Instance.Status_Inbody.dbMineral[i]));
                        graphChart.DataSource.AddPointToCategory("Data1", (i * 2 + 1), Convert.ToSingle(Main.Instance.Status_Inbody.dbMineral[i]) / 10);

                        dayTxt[i].text = Main.Instance.Status_Inbody.dbDate[i];
                        valueTxt[i].text = Main.Instance.Status_Inbody.dbMineral[i];
                    }
                    
                    graphChart.DataSource.EndBatch();
                    break;

                case 3:
                    graphChart.DataSource.StartBatch();
                    graphChart.DataSource.ClearCategory("Data1");

                    for (int i = 0; i < 5; i++)
                    {
                        string strCategory = string.Format("Day{0}", i + 1);
                        barChart.DataSource.SetValue(strCategory, "All", Convert.ToSingle(Main.Instance.Status_Inbody.dbProtein[i]));
                        graphChart.DataSource.AddPointToCategory("Data1", (i * 2 + 1), Convert.ToSingle(Main.Instance.Status_Inbody.dbProtein[i]) / 10);

                        dayTxt[i].text = Main.Instance.Status_Inbody.dbDate[i];
                        valueTxt[i].text = Main.Instance.Status_Inbody.dbProtein[i];
                    }

                    graphChart.DataSource.EndBatch();
                    break;
            }
        }
    }

    void Show_BodyLevel()
    {
        switch (lv_body[1])
        {
            case 1:
                if (lv_body[2] == 1)
                {
                    lvTxt.text = "마른 몸매형";
                    img_Body[6].gameObject.SetActive(true);
                    lv_Body.transform.localPosition = new Vector3(265, -95, 0);
                }
                else if (lv_body[2] == 2)
                {
                    lvTxt.text = "운동 결핍형";
                    img_Body[3].gameObject.SetActive(true);
                    lv_Body.transform.localPosition = new Vector3(265, -45, 0);
                }
                else
                {
                    lvTxt.text = "잠재적 비만형";
                    img_Body[0].gameObject.SetActive(true);
                    lv_Body.transform.localPosition = new Vector3(265, 5, 0);
                }

                break;

            case 2:
                if (lv_body[2] == 1)
                {
                    lvTxt.text = "마른 근육형";
                    img_Body[7].gameObject.SetActive(true);
                    lv_Body.transform.localPosition = new Vector3(315, -95, 0);
                }
                else if (lv_body[2] == 2)
                {
                    lvTxt.text = "표준형";
                    img_Body[4].gameObject.SetActive(true);
                    lv_Body.transform.localPosition = new Vector3(315, -45, 0);
                }
                else
                {
                    lvTxt.text = "비만형";
                    img_Body[1].gameObject.SetActive(true);
                    lv_Body.transform.localPosition = new Vector3(315, 5, 0);
                }
                break;

            case 3:
                if (lv_body[2] == 1)
                {
                    lvTxt.text = "운동 몸매형";
                    img_Body[8].gameObject.SetActive(true);
                    lv_Body.transform.localPosition = new Vector3(360, -95, 0);
                }
                else if (lv_body[2] == 2)
                {
                    lvTxt.text = "표준 운동형";
                    img_Body[5].gameObject.SetActive(true);
                    lv_Body.transform.localPosition = new Vector3(360, -45, 0);
                }
                else
                {
                    lvTxt.text = "근육질 비만형";
                    img_Body[2].gameObject.SetActive(true);
                    lv_Body.transform.localPosition = new Vector3(360, 5, 0);
                }
                break;
        }

    }

    public void ClearChart()
    {
        barChart.DataSource.ClearValues();
        graphChart.DataSource.ClearCategory("Data1");

        for (int i = 0; i < 5; i++)
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
        valueTxt[num - 1].fontSize = hoverSize;
    }

    public void NonHovered()
    {
        for (int i = 0; i < 5; i++)
        {
            dayTxt[i].color = nonColor;
            dayTxt[i].fontSize = nonSize;
            valueTxt[i].color = nonColor;
            valueTxt[i].fontSize = nonSize;
        }
    }
}
