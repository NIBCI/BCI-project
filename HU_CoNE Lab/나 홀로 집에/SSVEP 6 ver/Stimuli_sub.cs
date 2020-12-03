using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Stimuli_sub : MonoBehaviour {

    int currentScale;

    Transform GOtransform;
    SpriteRenderer GOspriterenderer;
    SpriteRenderer Icon;
    GameObject childText;
    

    public int FrameCount;


    void Start() {
        currentScale = 0;

        GOtransform = gameObject.GetComponent<Transform>();
        GOspriterenderer = gameObject.GetComponent<SpriteRenderer>();


        //numText 추가
        childText = transform.GetChild(1).gameObject;

        /*HM 중요  */
        if (gameObject.name == "Star_4" || transform.root.name == "ApplianceStimuli")
            Icon = transform.GetChild(0).transform.GetComponent<SpriteRenderer>();
        
        else if(ForTest_UDPresponder.ApplianceSelect == "MiddleWare#HanYang#SelectDevice#RVC" )//
        {
            Icon = transform.Find("RVC").transform.GetComponent<SpriteRenderer>();
        }
        else if (ForTest_UDPresponder.ApplianceSelect == "MiddleWare#HanYang#SelectDevice#AirCleaner#01")//
        {
            Icon = transform.Find("Air1").transform.GetComponent<SpriteRenderer>();
        }
        else if (ForTest_UDPresponder.ApplianceSelect == "MiddleWare#HanYang#SelectDevice#AirCleaner#02"  )//
        {
            Icon = transform.Find("Air2").transform.GetComponent<SpriteRenderer>();
        }
        else
        {
            Icon = transform.GetChild(0).transform.GetComponent<SpriteRenderer>();
            //Icon = transform.Find("Air2").transform.GetComponent<SpriteRenderer>();
            //Icon = transform.Find("RVC").transform.GetComponent<SpriteRenderer>();
            //Icon = transform.Find("Phone").transform.GetComponent<SpriteRenderer>();
        }

        Icon.color = new Color(0f, 0f, 0f, 1f);

        StartCoroutine(revisedSwitching());
    }
    private void OnEnable()
    {

        currentScale = 1;
        GOtransform.localScale = Stimuli_main.Scales[currentScale];
        GOspriterenderer.color = Stimuli_main.Colors[currentScale];
        //Icon.color = Star_1.IconColors[currentScale];

        childText.SetActive(true);
        StartCoroutine(revisedSwitching());
    }

    IEnumerator revisedSwitching()
    {

        // 어플 시작시 n초간의 여유를 둔 다음  TimeBetweenTrial 동안 숫자 제시
        yield return new WaitForSeconds(6f);

        //---------------------TimeBetweenTrial 시작

        /*if (Stimuli_main.currentStimuliNum == "2" && GOname == "Star_2")
            GOspriterenderer.color = indicatorColor;
        else if (Stimuli_main.currentStimuliNum == "3" && GOname == "Star_3")
            GOspriterenderer.color = indicatorColor;
        else if (Stimuli_main.currentStimuliNum == "4" && GOname == "Star_4")
            GOspriterenderer.color = indicatorColor;
        else if (Stimuli_main.currentStimuliNum == "5" && GOname == "Star_5")
            GOspriterenderer.color = indicatorColor;
            */

        yield return new WaitForSeconds(Stimuli_main.TimeBetweenTrial);

        //---------------------TimeBetweenTrial 끝

        //numText추가
        childText.SetActive(false);

        while (true)
        {
            //yield return StartCoroutine(WaitFor.Frames(7));
            yield return StartCoroutine(WaitFor.Frames(FrameCount));

            //아이콘 크기를 Star_1와 별개로 지정해야한다면 이 스크립트에 새로운 배열 선언해서 사용하기 

            

            //1.0.5.0 ver #2색변환수정
            /*
            GOtransform.localScale = Stimuli_main.Scales[currentScale];
            GOspriterenderer.color = Stimuli_main.Colors[currentScale];
            */
            if (Stimuli_main.checker_1 != 0 && Stimuli_main.checker_2 != 0) //Stimuli main에서 pause일때는 깜빡임 없음
            {
                GOtransform.localScale = Stimuli_main.Scales[currentScale];
                GOspriterenderer.color = Stimuli_main.Colors[currentScale];
            }
            //

            //실험용 생략
            //Icon.color = Stimuli_main.IconColors[currentScale];

            currentScale += 1;
            currentScale %= 2;

            //numText추가
            childText.SetActive(true);

           

            if (currentScale == 0 && Stimuli_main.tempTime - Stimuli_main.secCount > Stimuli_main.TrialDuration)
            {
                //---------------------TimeBetweenTrial 시작

                /*
                 if (Stimuli_main.currentStimuliNum == "2" && GOname == "Star_2")
                     GOspriterenderer.color = indicatorColor;
                 else if (Stimuli_main.currentStimuliNum == "3" && GOname == "Star_3")
                     GOspriterenderer.color = indicatorColor;
                else if (Stimuli_main.currentStimuliNum == "4" && GOname == "Star_4")
                     GOspriterenderer.color = indicatorColor;
                 else if (Stimuli_main.currentStimuliNum == "5" && GOname == "Star_5")
                     GOspriterenderer.color = indicatorColor; ;
                     */

                //1.0.5.0 ver #2색변환수정초록색이 아니라면 
                if (GOspriterenderer.color == Stimuli_main.Colors[0] || GOspriterenderer.color == Stimuli_main.Colors[1])
                {                  
                         GOspriterenderer.color = Stimuli_main.Colors[1];
                }

                GOtransform.localScale = Stimuli_main.Scales[1];

                yield return new WaitForSecondsRealtime(Stimuli_main.TimeBetweenTrial);

                //---------------------TimeBetweenTrial 끝
            }

            //numText추가
            childText.SetActive(false);

            if (Stimuli_main.trial > 25) // 트라이얼 횟수 30회일 때 :  Stimuli_main.trial > 30
            {
                break;
            }
        }

        
    }


    public static class WaitFor
    {
        public static IEnumerator Frames(int frameCount)
        {
            /*if (frameCount <= 0)
            {
                throw new ArgumentOutOfRangeException("frameCount", "Cannot wait for less that 1 frame");
            }*/

            while (frameCount > 0)
            {
                frameCount--;
                yield return null;
            }
        }

    }
}
