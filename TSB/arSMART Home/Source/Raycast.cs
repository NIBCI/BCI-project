using HoloToolkit.Unity;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Raycast : MonoBehaviour
{


    public InteractableObject hitObjectObjectInteractable;
    protected RaycastHit hitInfo;
    protected GameObject hitObject;

    public Main main;

    private float TotalTime = 2f;
    private float TotalTickTime;

    int mask = 1 << 8;

    private void Awake()
    {
        
    }

    // Use this for initialization
    void Start()
    {
        Positioning.Instance.cursor = gameObject;
        main = GameObject.Find("MainControl").GetComponent<Main>();
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        // Do a raycast into the world based on the user's head position and orientation.
        Vector3 headPosition = Camera.main.transform.position;
        Vector3 gazeDirection = Camera.main.transform.forward;

        //If Cursor Hit the VR Object
        if (Physics.Raycast(headPosition, gazeDirection, out hitInfo, 100.0f, mask))
        {
            //If the object is the same as the one we hit last frame
            if (hitObject != null && hitObject == hitInfo.transform.gameObject)
            {
                //Debug.Log("in");

                //Trigger "Stay" method on Interactable every frame we hit
                RayStay(hitInfo);
            }

            //We're strill hitting something, but it's a new object
            else
            {
                //Trigger the ray "Exit" method on Interactable
                RayExit();

                //keep track of new object tat we're hitting, and trigger the ray "Enter" method on Interactable
                hitObject = hitInfo.transform.gameObject;
                RayEnter(hitInfo);
            }

        }

        //If Cursor Hit the Real Object
        else if (Physics.Raycast(headPosition, gazeDirection, out hitInfo, 100.0f, SpatialMappingg.PhysicsRaycastMask))
        {
            RayExit();
        }

        else
        {
            //We aren't hitting anything, Trigger ray "Exit" on Interactable
            RayExit();
        }

    }

    protected void RayEnter(RaycastHit hit)
    {

        hitObjectObjectInteractable = hitObject.GetComponent<InteractableObject>();

        if (hitObjectObjectInteractable)
        {

            //If hit object is an Interactable, trigger RayStay Method
            hitObjectObjectInteractable.RayEnter(hit);
        }
    }

    protected void RayStay(RaycastHit hit)
    {

        if (hitObjectObjectInteractable)
        {
            hitObjectObjectInteractable.RayStay(hit);

            TotalTickTime += Time.fixedDeltaTime;

            if (TotalTickTime > TotalTime)
            {
                //If hit object is an Interactable, trigger RayEnter Method
                TotalTickTime = 0;
                main.isAbleBtn = true;
            }
        }
    }

    protected void RayExit()
    {

        if (hitObjectObjectInteractable)
        {
            //If hit object is an Interactable, trigger RayExit Method
            hitObjectObjectInteractable.RayExit();

            //Clear class variables
            hitObjectObjectInteractable = null;
            hitObject = null;

            TotalTickTime = 0f;
            main.isAbleBtn = false;
        }
    }







    //void OnGazeEnter()
    //{
    //	var com = gameObject.GetComponent<Renderer>();
    //	startColor = com.material.color;
    //	com.material.color = Color.black;

    //}

    //void OnGazeExit()
    //{

    //	var com = gameObject.GetComponent<Renderer>();
    //	com.material.color = startColor;

    //}

}
