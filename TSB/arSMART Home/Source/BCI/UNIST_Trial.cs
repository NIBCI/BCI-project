using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UNIST_Trial : InteractableObject
{
    GameObject obj;
    GameObject txt;

    // Use this for initialization
    void Start()
    {
        obj = transform.GetChild(0).gameObject;

        if (name.Contains("30"))
            txt = obj.transform.Find("Now").gameObject;
    }

    // Update is called once per frame
    void Update()
    {
        if (P300_Manager.Instance.isTraining == false)
        {
            obj.SetActive(false);
        }
        else
        {
            obj.SetActive(true);

            if (name.Contains("30"))
                txt.GetComponent<Text>().text = string.Format("Trial :: {0}", P300_Manager.Instance.trial);
        }

    }

    public override void RayStay(RaycastHit hit)
    {
        if (Main.Instance.isAbleBtn)
        {
            if (name.Contains("Trial"))
            {
                P300_Manager.Instance.trial = Convert.ToInt32(name.Substring(5, 2));
                GetComponent<BoxCollider>().enabled = false;

                return;
            }
        }
    }

    public override void RayExit()
    {
        if (name.Contains("Trial"))
        {
            GetComponent<BoxCollider>().enabled = true;
        }
    }
}
