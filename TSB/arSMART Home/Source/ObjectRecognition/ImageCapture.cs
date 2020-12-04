using System;
using System.Collections;
using System.IO;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.WSA.Input;

public class ImageCapture : MonoBehaviour
{
    /// <summary>
    /// Allows this class to behave like a singleton
    /// </summary>
    public static ImageCapture Instance;
    public PageBase PageBase;

    public GestureRecognizer recognizer;

    /// <summary>
    /// Flagging if the capture loop is running
    /// </summary>
    public bool captureIsActive;

    public bool bGetVideoFrame = false;

    Text GuideText;

    //0 : default
    //1 : success
    //-1 : low probablility
    //-2 : nothing
    //-3 : no video frame
    public int iState = 0;

    /// <summary>
    /// Called on initialization
    /// </summary>
    private void Awake()
    {
        Instance = this;
        PageBase = transform.Find("Page_Common").GetComponent<PageBase>();
    }

    /// <summary>
    /// Runs at initialization right after Awake method
    /// </summary>
    void Start()
    {
        // Subscribing to the Microsoft HoloLens API gesture recognizer to track user gestures
        recognizer = new GestureRecognizer();
        recognizer.SetRecognizableGestures(GestureSettings.Tap);
        recognizer.Tapped += TapHandler;

        try
        {
            GuideText = Positioning.Instance.transform.Find("Canvas").Find("Guide").GetComponent<Text>();
        }
        catch (Exception err)
        {
            Debug.Log(err);
        }
        
    }

    private void TapHandler(TappedEventArgs obj)
    {
        recognizer.CancelGestures();

        SceneOrganiser.Instance.bCaptureStart = true;
        StartCoroutine(StartAnalyzing());
    }

    public IEnumerator StartAnalyzing()
    {
        if (!captureIsActive)
        {
            captureIsActive = true;

            GuideText.text = "분석중 ...";

            //Get Video Frame					
            StartCoroutine(Capture());
        }
        yield return null;
    }

    public IEnumerator Capture()
    {
        if (iState != 0)
            iState = 0;

        yield return StartCoroutine(Wait());

        if (iState == 1)
        {
            //SetText(SceneOrganiser.Instance.prediction.TagName);
            StartCoroutine(Positioning.Instance.FinaliseLabel(SceneOrganiser.Instance.prediction));
            PageBase.DeviceSelectIcon(SceneOrganiser.Instance.prediction.TagName);
        }

        else
        {
            string strReason = "";

            //switch(iState)
            //{
            //    case -1:
            //        {
            //            strReason = "\n 사유 : low probability";
            //            break;
            //        }

            //    case -2:
            //        {
            //            strReason = "\n 사유 : nothing";
            //            break;
            //        }

            //    case -3:
            //        {
            //            strReason = "\n 사유 : no video frame";
            //            break;
            //        }

            //    default:
            //        break;
            //}

            StartCoroutine(ShowText("기기를 찾지 못했습니다." + strReason));
            SetFront();

            recognizer.StartCapturingGestures();
        }

        // Stop the analysis process
        ResetImageCapture();
    }

    private IEnumerator Wait()
    {
        while (!SceneOrganiser.Instance.bFinalizeStart)
        {
            yield return new WaitForSeconds(0.05f);
        }
        SceneOrganiser.Instance.bFinalizeStart = false;
    }

    /// <summary>
    /// Stops all capture pending actions
    /// </summary>
    internal void ResetImageCapture()
    {
        captureIsActive = false;
        GuideText.text = "";
    }

    private void SetText(string strText)
    {
        switch (strText)
        {
            case "Airconditioner":
            case "Airconditioner_Card":
                {
                    strText = "에어컨을 ";
                    break;
                }

            case "Bulb":
            case "Bulb_Card":
                {
                    strText = "전구를 ";
                    break;
                }

            case "CCTV":
            case "CCTV_Card":
                {
                    strText = "CCTV를 ";
                    break;
                }

            case "DoorLock":
            case "DoorLock_Card":
                {
                    strText = "도어락을 ";
                    break;
                }

            case "Fit":
                {
                    strText = "기어핏을 ";
                    break;
                }

            case "GasValve":
            case "GasValve_Card":
                {
                    strText = "가스밸브를 ";
                    break;
                }

            case "Inbody":
                {
                    strText = "인바디를 ";
                    break;
                }

            case "Interphone":
            case "Interphone_Card":
                {
                    strText = "인터폰을 ";
                    break;
                }

            case "RVC":
            case "RVC_Card":
                {
                    strText = "로봇청소기를 ";
                    break;
                }

            case "Refrigerator":
            case "Refrigerator_Card":
                {
                    strText = "냉장고를 ";
                    break;
                }

            case "Scale":
                {
                    strText = "체중계를 ";
                    break;
                }

            case "TV":
            case "TV_Card":
                {
                    strText = "냉장고를 ";
                    break;
                }
        }

        strText = strText + "를 찾았습니다.";
        StartCoroutine(ShowText(strText));
    }

    public IEnumerator ShowText(string strText)
    {
        GuideText.text = strText;

        yield return new WaitForSeconds(3f);

        GuideText.text = "";
    }

    void SetFront()
    {
        GameObject objParent = transform.parent.parent.gameObject;
        GameObject objMyself = transform.parent.gameObject;
        GameObject objCamera = Positioning.Instance.transform.gameObject;

        objMyself.transform.parent = objCamera.transform;
        objMyself.transform.localPosition = new Vector3(0, 0, 2.7f);
        objMyself.transform.eulerAngles = objCamera.transform.eulerAngles;
        //new Vector3(0, objCamera.transform.eulerAngles.y, 0);

        objMyself.transform.parent = objParent.transform;

        PageManager.Instance.GoHome();
    }

    public void ByteToTexture(byte[] bytes, int width, int height)
    {
        Texture2D tex = new Texture2D(width, height, TextureFormat.ARGB32, false);
        tex.LoadImage(bytes);
        tex.Apply();

        transform.parent.Find("RawImage").GetComponent<RawImage>().texture = tex;
    }
}
