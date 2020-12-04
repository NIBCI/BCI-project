using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Sequence_Manager : InteractableObject
{
    public GameObject start_obj;

    // Use this for initialization
    void Start()
    {
        start_obj = transform.Find("Start_btn").gameObject;
    }

    // Update is called once per frame
    void Update()
    {
        if (name.Equals("Sequence_Start")
            && Main.Instance.isStartRay == false)
        {
            start_obj.SetActive(true);
        }

        else if (name.Equals("Sequence_Start")
            && Main.Instance.isStartRay == true)
        {
            start_obj.SetActive(false);
        }
    }

    public override void RayStay(RaycastHit hit)
    {
        if (Main.Instance.isAbleBtn)
        {
            if (name.Equals("Sequence_Start"))
            {

                Main.Instance.isStartRay = true;
                start_obj.SetActive(false);
                return;
            }

            if (name.Contains("Trial"))
            {
                //P300_Manager.Instance.isTraining = true;
                P300_Manager.Instance.trial = Convert.ToInt32(name.Substring(5));

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
