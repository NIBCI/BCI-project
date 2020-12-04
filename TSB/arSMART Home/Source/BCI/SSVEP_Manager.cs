using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SSVEP_Manager : MonoBehaviour
{
    private static SSVEP_Manager _instance;
    public static SSVEP_Manager Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = FindObjectOfType<SSVEP_Manager>();
                if (!_instance)
                {
                    //Debug.Log("Fail");
                }
            }
            return _instance;
        }
    }

    public GameObject[] arr_objFrequency;
    public bool isLineInit = false;

    //private float TotalTime = 2.5f;
    public float TotalTime = 5f;
    public float waitTime = 3f;

    // Use this for initialization
    void Start()
    {
        arr_objFrequency = new GameObject[4];
    }

    private void FixedUpdate()
    {
        if (BlinkManager.Instance.arr_objIndex[0] != null)
        {
            for (int i = 0; i < arr_objFrequency.Length; i++)
            {
                arr_objFrequency[i] = BlinkManager.Instance.arr_objIndex[i];
                arr_objFrequency[i].transform.GetChild(0).GetComponent<SSVEP_Frequency>().Freq_Index = (SSVEP_Frequency.FrequencyIndex)(i + 1);
            }
        }

        if (isLineInit)
        {
            for (int i = 0; i < arr_objFrequency.Length; i++)
            {
                arr_objFrequency[i].transform.GetChild(0).GetComponent<SSVEP_Frequency>().FrequencyInit();
            }
            isLineInit = false;
        }
    }
}
