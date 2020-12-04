using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;

public class P300_Manager : MonoBehaviour
{
    private static P300_Manager _instance;
    public static P300_Manager Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = FindObjectOfType<P300_Manager>();
                if (!_instance)
                {
                    //Debug.Log("Fail");
                }
            }
            return _instance;
        }
    }

    public bool isStopSignal;
    public Coroutine runningCoroutine;

    public float breakTime;
    public int sendCnt;
    public float unist_frequency;
    private int[] unist_Sequence;
    public GameObject trial_Number;
    public int trial;

    public bool isSequence;

    public bool isTraining;

    public GameObject tNum;

    private void Awake()
    {
        runningCoroutine = null;

        breakTime = 2f;
        sendCnt = 1;
        unist_frequency = 0.1f;

        isSequence = false;

        trial = 10;

        trial_Number = transform.Find("Blink_Training").transform.Find("TrainingNumber").gameObject;
        trial_Number.SetActive(false);

        // Training or not **
        isTraining = false;
    } 

    // Update is called once per frame
    void Update()
    {
        Set_Coroutine();
    }

    public int[] GetPattern()
    {
        int[] arr = new int[40];
        System.Random rand = new System.Random((int)DateTime.Now.Ticks);
        int first;
        int last = 999;

        for (int i = 0; i < 10; i++)
        {
            // 1 ~ 4 random create
            int[] sample = Enumerable.Range(1, 4).OrderBy(o => rand.Next()).ToArray();
            first = sample[0];

            // block last와 새 blcok first compare 후 중복 방지
            if (i >= 1)
            {
                while (first == last)
                {
                    sample = Enumerable.Range(1, 4).OrderBy(o => rand.Next()).ToArray();
                    first = sample[0];
                }
            }

            for (int j = 0; j < 4; j++)
            {
                arr[(i * 4) + (j)] = sample[j];
            }

            last = sample[3];
        }

        return arr;
    }

    public void Set_Coroutine()
    {
        if (Main.Instance.isStartRay.Equals(true))
        {
            if (isSequence.Equals(false))
            {
                if (isTraining == false)
                {
                    ChangeTexture(true);
                    runningCoroutine = StartCoroutine(P300_Sequence());
                }
                else
                {
                    ChangeTexture(true);
                    runningCoroutine = StartCoroutine(P300_Training());
                }
            }
        }

        else
            ;
    }

    IEnumerator P300_Sequence()
    {
        GameObject[] unistObj = new GameObject[4];
        for (int i = 0; i < unistObj.Length; i++)
        {
            unistObj[i] = BlinkManager.Instance.arr_objIndex[i];
        }

        isSequence = true;

        yield return new WaitForSeconds(breakTime);

        for (int i = 0; i < sendCnt + 1; i++)
        {
            Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#Sequence" + "#" + "11");
        }

        yield return new WaitForSeconds(0.1f);

        unist_Sequence = GetPattern();

        for (int i = 0; i < sendCnt + 1; i++)
        {
            // start signal
            Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#Sequence" + "#" + "12");
        }

        for (float i = 0; i < unist_Sequence.Length; i = i + 0.5f)
        {
            // 정수 일 때(base color)
            if (i / 1.00 == (int)i)
            {

                for (int j = 0; j < 4; j++)
                {
                    unistObj[j].transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(90, 89, 255, 255);
                }
            }
            // 실수 일 때(change color)
            else
            {
                for (int m = 0; m < sendCnt; m++)
                {
                    Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#Sequence" + "#" + (unist_Sequence[(int)i]).ToString());
                }

                unistObj[unist_Sequence[(int)i] - 1].transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(196, 244, 122, 255);

            }

            yield return new WaitForSeconds(unist_frequency);
        }

        // end signal
        for (int i = 0; i < sendCnt + 1; i++)
        {
            Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#Sequence" + "#" + "13");
        }

        // base color로 reset
        for (int j = 0; j < 4; j++)
        {
            unistObj[j].transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(90, 89, 255, 255);
        }

        // sequence 끝남 알림
        isSequence = false;
        // ray 다시 시작할 수 있음 알림
        Main.Instance.isStartRay = false;
    }

    IEnumerator P300_Training()
    {
        GameObject[] unistObj = new GameObject[4];
        for (int i = 0; i < unistObj.Length; i++)
        {
            unistObj[i] = BlinkManager.Instance.arr_objIndex[i];
        }
        trial_Number.SetActive(true);
        trial_Number.GetComponent<Text>().text = "1";

        isSequence = true;

        for (int i = 0; i < sendCnt + 1; i++)
        {
            Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#" + "Trial" + "#" + trial.ToString());
        }

        for (int k = 0; k < trial; k++)
        {
            if (k == 0)
                yield return new WaitForSeconds(breakTime);

            for (int i = 0; i < sendCnt + 1; i++)
            {
                Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#TrainingSequence" + "#" + "11");
            }

            yield return new WaitForSeconds(0.1f);

            for (int i = 0; i < sendCnt + 1; i++)
            {
                Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#TrainingSequence" + "#" + ((k % 4) + 1).ToString());
            }

            yield return new WaitForSeconds(0.1f);

            trial_Number.GetComponent<Text>().text = ((k % 4) + 1).ToString();
            unist_Sequence = GetPattern();

            // start signal
            for (int i = 0; i < sendCnt + 1; i++)
            {
                Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#TrainingSequence" + "#" + "12");
            }

            for (float i = 0; i < unist_Sequence.Length; i = i + 0.5f)
            {
                // 정수 일 때(base color)
                if (i / 1.00 == (int)i)
                {
                    for (int j = 0; j < 4; j++)
                    {
                        unistObj[j].transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(90, 89, 255, 255);
                    }
                }
                // 실수 일 때(change color)
                else
                {
                    for (int m = 0; m < sendCnt; m++)
                    {
                        Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#TrainingSequence" + "#" + (unist_Sequence[(int)i]).ToString());
                    }

                    unistObj[unist_Sequence[(int)i] - 1].transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(196, 244, 122, 255);

                }
                yield return new WaitForSeconds(unist_frequency);
            }

            //end signal
            for (int i = 0; i < sendCnt + 1; i++)
            {
                Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#TrainingSequence" + "#" + "13");
            }

            //base color로 reset
            for (int j = 0; j < 4; j++)
            {
                unistObj[j].transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(90, 89, 255, 255);
            }

            if (k + 1 != trial)
            {
                trial_Number.GetComponent<Text>().text = (((k + 1) % 4) + 1).ToString();
                yield return new WaitForSeconds(breakTime);
            }
        }

        //training end send
        for (int i = 0; i < sendCnt + 1; i++)
        {
            Main.Instance.UDP.UDP_Send(Main.Instance.org + "#" + Main.Instance.DeviceMode + "#TrainingSequence" + "#" + "99");
        }


        //isTraining = false;

        // sequence 끝남 알림
        isSequence = false;
        // ray 다시 시작할 수 있음 알림
        Main.Instance.isStartRay = false;
        // trial number 삭제
        trial_Number.SetActive(false);
    }

    public void StopUNIST_Sequence()
    {
        if (runningCoroutine != null)
            StopCoroutine(runningCoroutine);

        runningCoroutine = null;
        isStopSignal = false;
        isSequence = false;
        //isStartRay = false;
        trial_Number.SetActive(false);
    }

    void ChangeTexture(bool isChange)
    {
        if (isChange == true)
        {
            if (isTraining == false)
            {
                BlinkManager.Instance.arr_objIndex[0].transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(0, 0, 0, 255);
                BlinkManager.Instance.arr_objIndex[1].transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(0, 0, 0, 255);
                BlinkManager.Instance.arr_objIndex[2].transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(0, 0, 0, 255);
                BlinkManager.Instance.arr_objIndex[3].transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(0, 0, 0, 255);
            }
            else
            {
                BlinkManager.Instance.arr_objIndex[0].transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(0, 0, 0, 0);
                BlinkManager.Instance.arr_objIndex[1].transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(0, 0, 0, 0);
                BlinkManager.Instance.arr_objIndex[2].transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(0, 0, 0, 0);
                BlinkManager.Instance.arr_objIndex[3].transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(0, 0, 0, 0);
            }
        }

        else
        {
            BlinkManager.Instance.arr_objIndex[0].transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(255, 255, 255, 255);
            BlinkManager.Instance.arr_objIndex[1].transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(255, 255, 255, 255);
            BlinkManager.Instance.arr_objIndex[2].transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(255, 255, 255, 255);
            BlinkManager.Instance.arr_objIndex[3].transform.GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(255, 255, 255, 255);

            BlinkManager.Instance.arr_objIndex[0].transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(15, 118, 199, 255);
            BlinkManager.Instance.arr_objIndex[1].transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(15, 118, 199, 255);
            BlinkManager.Instance.arr_objIndex[2].transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(15, 118, 199, 255);
            BlinkManager.Instance.arr_objIndex[3].transform.GetChild(0).GetChild(0).GetChild(0).GetComponent<MeshRenderer>().materials[0].color = new Color32(15, 118, 199, 255);

        }

    }



}
