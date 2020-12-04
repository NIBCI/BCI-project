using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ImageList : MonoBehaviour
{
    public Sprite[] arr_spriteImg;
    public Sprite[] arr_spriteOVimg;
    public Sprite[] arr_spriteClickImg;

    public UIButton[] arr_UIButton;


    private void Awake()
    {
        arr_spriteImg = new Sprite[transform.childCount];
        arr_spriteOVimg = new Sprite[transform.childCount];
        arr_spriteClickImg = new Sprite[transform.childCount];
        arr_UIButton = new UIButton[transform.childCount];

        for (int i = 0; i < transform.childCount; i++)
        {
            if (!transform.GetChild(i).name.Contains("_btn"))
            {
                continue;
            }
            arr_UIButton[i] = transform.GetChild(i).GetComponent<UIButton>();
            if (arr_UIButton[i] == null)
            {
                arr_UIButton[i] = transform.GetChild(i).gameObject.AddComponent<UIButton>();
            }

            arr_spriteImg[i] = transform.GetChild(i).GetComponent<Image>().sprite;
            if (arr_spriteImg[i] != null)
            {
                arr_spriteImg[i].name = transform.GetChild(i).name;
            }
            if (transform.GetChild(i).childCount > 0)
            {
                arr_spriteOVimg[i] = transform.GetChild(i).GetChild(0).GetComponent<Image>().sprite;
                if (arr_spriteOVimg[i] != null)
                {
                    arr_spriteOVimg[i].name = "OV_" + arr_spriteImg[i].name;
                }
            }
            if (transform.GetChild(i).childCount > 1)
            {
                arr_spriteClickImg[i] = transform.GetChild(i).GetChild(1).GetComponent<Image>().sprite;
                if (arr_spriteClickImg[i] != null)
                {
                    arr_spriteClickImg[i].name = "Click_" + arr_spriteImg[i].name;
                }
            }
        }
    }

    public UIButton GetButton(string btnName)
    {
        UIButton find = null;

        foreach (UIButton btn in arr_UIButton)
        {
            if (btn == null)
            {
                continue;
            }

            if (btn.name.Equals(btnName))
            {
                find = btn;
                break;
            }
        }

        return find;
    }
}
