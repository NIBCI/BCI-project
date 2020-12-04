using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIButton : InteractableObject
{
    private ImageList imageList;
    public Vector3 originScale;

    public bool bRayStay;

    private bool isInit;

    // Use this for initialization
    void Start()
    {
        imageList = transform.parent.GetComponent<ImageList>();

        //if (!this.name.Contains("img"))
        //{
        //    BoxCollider col = GetComponent<BoxCollider>();
        //    if (col.Equals(null))
        //        col = gameObject.AddComponent<BoxCollider>();

        //    RectTransform rectTrans = GetComponent<RectTransform>();
        //    col.size = new Vector3(rectTrans.rect.width, rectTrans.rect.height, 0.001f);
        //}

        BoxCollider col = transform.GetComponent<BoxCollider>();
        if (col)
        {
            RectTransform rectTrans = GetComponent<RectTransform>();
            col.size = new Vector3(rectTrans.rect.width, rectTrans.rect.height, 0.001f);
        }
        
        originScale = transform.localScale;
        bRayStay = false;
    }

    override public void RayStay(RaycastHit hit)
    {
        bRayStay = true;

        if (transform.localScale.x != 0)
        {
            GetComponent<Image>().sprite = FindOVImage(name);
            transform.localScale = originScale * 1.1f;
        }
    }

    override public void RayExit()
    {
        bRayStay = false;

        if (transform.localScale.x != 0)
        {
            GetComponent<Image>().sprite = FindImage(name);
            transform.localScale = originScale;
        }
    }

    public Sprite FindOVImage(string name)
    {
        string compareName = "OV_" + name;
        Sprite find = null;

        for (int i = 0; i < imageList.arr_spriteOVimg.Length; i++)
        {
            try
            {
                if (imageList.arr_spriteOVimg[i] == null)
                {
                    continue;
                }
                if (compareName == imageList.arr_spriteOVimg[i].name)
                {
                    find = imageList.arr_spriteOVimg[i];
                    break;
                }
            }

            catch (Exception e)
            {
                //Debug.Log(e);
            }
        }

        return find;
    }

    public Sprite FindImage(string name)
    {
        string compareName = name;
        Sprite find = null;

        for (int i = 0; i < imageList.arr_spriteImg.Length; i++)
        {
            try
            {
                if (imageList.arr_spriteImg[i] == null)
                {
                    continue;
                }
                if (compareName == imageList.arr_spriteImg[i].name)
                {
                    find = imageList.arr_spriteImg[i];
                    break;
                }
            }

            catch (Exception e)
            {
                Debug.Log(e.ToString());
            }
        }

        return find;
    }

    public Sprite FindClickImage(string name)
    {
        string compareName = "Click_" + name;
        Sprite find = null;

        for (int i = 0; i < imageList.arr_spriteClickImg.Length; i++)
        {
            try
            {
                if (imageList.arr_spriteClickImg[i] == null)
                {
                    continue;
                }
                if (compareName == imageList.arr_spriteClickImg[i].name)
                {
                    find = imageList.arr_spriteClickImg[i];
                    break;
                }
            }

            catch (Exception e)
            {
                //Debug.Log(e);
            }
        }

        return find;
    }
}
