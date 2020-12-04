using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SSVEP_Frequency : MonoBehaviour
{    
    public enum FrequencyIndex
    {
        Index0,
        Index1,
        Index2,
        Index3,
        Index4
    }
    public FrequencyIndex Freq_Index = FrequencyIndex.Index0;

    private float TotalTime;
    private float waitTime;

    public float TotalTickTime;
    private float TickTime;
    private float delayTick = 0f;        

    public bool isOn = true;
    private bool startPoint = false;
    private int endPoint = 0;

    public float frequencyTime;

    // star bg 용
    private float sizeFactor;
    private Vector3 big_position;
    private Vector3 big_scale = new Vector3(0.65f, 0.65f, 0.65f);
    private Vector3 small_position;
    private Vector3 small_scale = new Vector3(0.45f, 0.45f, 0.45f);

    public GameObject objBG;
    public GameObject objTexture;

    // Use this for initialization
    void Start()
    {
        objBG = transform.GetChild(0).gameObject;
        objTexture = objBG.transform.GetChild(0).gameObject;

        Set_Frequency();
        FrequencyInit();

        sizeFactor = 1.6f;
        big_scale = big_scale * sizeFactor;
        small_scale = small_scale * sizeFactor;
    }

    void Set_Frequency()
    {
        TotalTime = SSVEP_Manager.Instance.TotalTime;
        waitTime = SSVEP_Manager.Instance.waitTime;

        switch (Freq_Index)
        {
            case FrequencyIndex.Index0:
                frequencyTime = 0;
                break;

            case FrequencyIndex.Index1:
                frequencyTime = 0.133334f;
                break;

            case FrequencyIndex.Index2:
                frequencyTime = 0.116667f;
                break;

            case FrequencyIndex.Index3:
                frequencyTime = 0.1f;
                break;

            case FrequencyIndex.Index4:
                frequencyTime = 0.083334f;
                break;
        }
    }

    public void FrequencyInit()
    {
        TotalTickTime = 0f;
        TickTime = 0;

        if (objBG)
        {
            objBG.GetComponent<MeshRenderer>().materials[0].color = new Color32(128, 128, 128, 255);
            objTexture.GetComponent<MeshRenderer>().materials[0].color = new Color32(0, 0, 0, 255);
            objBG.transform.localScale = big_scale;
        }
        endPoint = 0;
    }

    private void FixedUpdate()
    {
        if (Freq_Index == FrequencyIndex.Index0)
            return;

        if (!Main.Instance.isStartRay)
        {
            return;
        }

        Set_Frequency();

        TotalTickTime += Time.fixedDeltaTime;
        TickTime += Time.fixedDeltaTime;

        if (TotalTickTime <= waitTime)
        {
            return;
        }

        else if (TotalTickTime > waitTime
            && TotalTickTime <= TotalTime + waitTime)
        {
            if (Freq_Index == FrequencyIndex.Index1
                && startPoint == false)
            {
                startPoint = true;
                Main.Instance.UDP.UDP_Send("HanYang#" + Main.Instance.DeviceMode.ToString() + "#Sequence#Start");
                //Main.Instance.isStartRay = true;
            }
            Reversal_Mode();
        }

        else
        {
            if (Freq_Index == FrequencyIndex.Index1
                && endPoint == 0)
            {
                Main.Instance.UDP.UDP_Send("HanYang#" + Main.Instance.DeviceMode.ToString() + "#Sequence#End");
                endPoint++;
                startPoint = false;
                Main.Instance.isStartRay = false;
                SSVEP_Manager.Instance.isLineInit = true;
            }
        }
    }

    void Reversal_Mode()
    {
        // 6sec 동안 라인별 frquency 대로 blink
        if (TickTime >= frequencyTime)
        {
            // 직전이 on 일 때 alpha 값 0
            if (isOn == true)
            {
                isOn = false;
                objBG.GetComponent<MeshRenderer>().materials[0].color = new Color32(255, 255, 255, 255);
                objTexture.GetComponent<MeshRenderer>().materials[0].color = new Color32(0, 0, 0, 255);
                objBG.transform.localScale = small_scale;

                TickTime = 0f;
            }

            // 직전이 off 일 때 alpha 값 255
            else if (isOn == false)
            {
                isOn = true;
                objBG.GetComponent<MeshRenderer>().materials[0].color = new Color32(128, 128, 128, 255);
                objTexture.GetComponent<MeshRenderer>().materials[0].color = new Color32(0, 0, 0, 255);
                objBG.transform.localScale = big_scale;

                TickTime = 0f;
            }

            else
                return;
        }
    }
}
