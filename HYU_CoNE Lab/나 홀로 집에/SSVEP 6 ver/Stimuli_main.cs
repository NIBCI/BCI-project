using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Stimuli_main : MonoBehaviour {


    public Color indicatorColor;

    public SpriteRenderer[] StimuliSpriteRenderers;  // 0: Star_1      1: Star_2       2: Star_3

    public static Vector3[] Scales = { new Vector3(0.05f,0.05f,0.05f), new Vector3(0.06f, 0.06f, 0.06f) };
    public static Color[] Colors = { Color.white*0.4f, Color.white*0.9f };
    public static Color[] IconColors = { Color.white * 0.8f, Color.black };


    public static int checker_1, checker_2;
    public static float secCount;
    public static float tempTime;
    public static string currentStimuliNum;
    public static float TrialDuration = 7f;
    public static float TimeBetweenTrial = 7f;

    int currentScale;

    Transform GOtransform;
    SpriteRenderer GOspriterenderer;
    string GOname;
    SpriteRenderer Icon;
    GameObject childText;

    public TextMesh CenterOfStimuli;
    public GameObject Arrow;
    public int FrameCount;


    //실험용 배열 - 한 트라이얼마다 랜덤으로 하나 선택. 1~6의 자극이 총 5번씩 랜덤으로 나오게끔. 
    //string[] numbers = { "1", "2", "3", "4", "5", "6", "1", "2", "3", "4", "5", "6", "1", "2", "3", "4", "5", "6", "1", "2", "3", "4", "5", "6", "1", "2", "3", "4", "5", "6", " " };
    string[] numbers = { "1", "2", "3", "4", "5", "1", "2", "3", "4", "5", "1", "2", "3", "4", "5",  "1", "2", "3", "4", "5",  "1", "2", "3", "4", "5", " " };

    //실험용 트리거

    public static string StartTrigger;
    public static string EndTrigger;

    string StartTrigger_Stimuli1 = "a";
    string EndtartTrigger_Stimuli1 = "b";

    string StartTrigger_Stimuli2 = "c";
    string EndTrigger_Stimuli2 = "d";

    string StartTrigger_Stimuli3 = "e";
    string EndTrigger_Stimuli3 = "f";

    string StartTrigger_Stimuli4 = "g";
    string EndTrigger_Stimuli4 = "h";

    string StartTrigger_Stimuli5 = "i";
    string EndTrigger_Stimuli5 = "j";

    string StartTrigger_Stimuli6 = "k";
    string EndTrigger_Stimuli6 = "l";

    //실험용 변수들
    public static int trial = 0;


    void Start () {
        
        //numbers에 있는 요소 랜덤화
        shuffle(numbers);
       
        currentScale = 0;
        secCount = 0;
        GOtransform = gameObject.GetComponent<Transform>();
        GOspriterenderer = gameObject.GetComponent<SpriteRenderer>();
        GOname = gameObject.name;

        //실험용 생략
        //Icon = transform.GetChild(0).transform.GetComponent<SpriteRenderer>();
        //Icon.color = new Color(0f, 0f, 0f, 1f);

        //numText추가
        childText = transform.GetChild(1).gameObject;

        //실험용일때는 Switching_ForExperiment() 호출
        //StartCoroutine(revisedSwitching());
       StartCoroutine(Switching_ForExperiment());

        //1.0.5.0 ver #1 화살표  Arrow  카운트다운끝날때까지는 비활성화
        Arrow.SetActive(false);
   
    }

    //테스트할때는 OnEnable 호출 될 일 없음
    private void OnEnable()
    {

        secCount = 0;
        currentScale = 1;
        GOtransform.localScale = Scales[currentScale];
        GOspriterenderer.color = Colors[currentScale];
        // Icon.color = IconColors[currentScale];


        trial = 0;
        Arrow.SetActive(false);
        CenterOfStimuli.transform.localPosition = Vector3.zero;
        childText.SetActive(true);

        StartCoroutine(Switching_ForExperiment());

    }

    //실험용 SSVEP자극 깜빡임 
    IEnumerator Switching_ForExperiment()
    {

        //깜빡임 시작전 안내 및 카운트다운
        CenterOfStimuli.fontSize = 70;
        CenterOfStimuli.text = "3초 후\n 시작됩니다";
        yield return new WaitForSeconds(3f);

        CenterOfStimuli.color = Color.white * 0.7f;
        CenterOfStimuli.fontSize = 120;
        CenterOfStimuli.text = "3";
        yield return new WaitForSeconds(1f);
        CenterOfStimuli.text = "2";
        yield return new WaitForSeconds(1f);
        CenterOfStimuli.text = "1";
        yield return new WaitForSeconds(1f);
        CenterOfStimuli.text = "";


        //1.0.5.0 ver #1 숫자제시 대신 화살표   - CenterOfStimuli 아주 없애지 않고 그냥 시야에 안들어오게끔 이동시켜버림. 고개 들면 보이는 정도
        CenterOfStimuli.transform.localPosition += new Vector3(0,0.65f,0);
        //1.0.5.0 ver #1 화살표  Arrow  카운트다운 이후 활성화
        Arrow.SetActive(true);

        //랜덤숫자제시후 trial 카운트 +1
        CenterOfStimuli.color = Color.white;
        CenterOfStimuli.fontSize = 170;
        currentStimuliNum = numbers[trial];
        CenterOfStimuli.text = currentStimuliNum;
        trial++;

        //1.0.5.0 ver #1 숫자대신 화살표
        setArrowAngle();

        //-------------------------------------TimeBetweenTrial 시작

        if (currentStimuliNum == "1")  //Star_1
            StimuliSpriteRenderers[0].color = indicatorColor;
        else if (currentStimuliNum == "2") //Star_2
            StimuliSpriteRenderers[1].color = indicatorColor;
        else if (currentStimuliNum == "3") //Star_3
            StimuliSpriteRenderers[2].color = indicatorColor;
        else if (currentStimuliNum == "4") //Star_4
            StimuliSpriteRenderers[3].color = indicatorColor;
        else if (currentStimuliNum == "5") //Star_5
            StimuliSpriteRenderers[4].color = indicatorColor;

        yield return new WaitForSecondsRealtime(TimeBetweenTrial);

        //-------------------------------------TimeBetweenTrial 끝


       secCount = Time.time;

       assignTrigger();

        //STARTING POINT    트라이얼 시작
        checker_1 = 0;
        checker_2 = 1;

        //numText 트라이얼 시작시 비활성화
        childText.SetActive(false);

        yield return new WaitForSeconds(0.01f); //0.01초 delay해주어야만 Update()의 한 프레임에서 캐치함


        checker_1 = 1;
        checker_2 = 1;


        while (trial < 26) //트라이얼 30회일때는 while(trial < 31) 
        {

            yield return StartCoroutine(WaitFor.Frames(FrameCount));

            GOtransform.localScale = Scales[currentScale];
            GOspriterenderer.color = Colors[currentScale];

            //실험용 생략
            //Icon.color = Stimuli_main.IconColors[currentScale];

            currentScale += 1;
            currentScale %= 2;

            tempTime = Time.time;

            if (currentScale == 0 && tempTime - secCount > TrialDuration)
            {
                

                //ENDING POINT
                checker_1 = 1;
                checker_2 = 0;

                yield return new WaitForSeconds(0.01f);

                
                //랜덤숫자제시후 trial 카운트 +1
                CenterOfStimuli.fontSize = 170;
                //CenterOfStimuli.text =  numbers[trial];
                 currentStimuliNum = numbers[trial];//#1
                CenterOfStimuli.text = currentStimuliNum;
                trial++;

                //1.0.5.0 ver #1 숫자대신 화살표
                setArrowAngle();

                //트라이얼 간 번호 구분하기 위해 다음 트라이얼로 넘어가기 전에 숫자 잠깐 깜빡
                //CenterOfStimuli.transform.RotateAroundLocal(Vector3.up,360*Time.deltaTime);
                CenterOfStimuli.GetComponent<Animator>().ResetTrigger("startRotate");
                CenterOfStimuli.GetComponent<Animator>().SetTrigger("startRotate");

                assignTrigger();
                //currentStimuliNum = numbers[trial];// 다음 트라이얼의 자극 숫자 할당을 최대한 빨리#1

                // trial 사이의 pause
                checker_1 = 0;
                checker_2 = 0;

                //numText 추가
                childText.SetActive(true);
                 

                //----------------------------TimeBetweenTrial 시작

                if (currentStimuliNum == "1")  //Star_1
                    StimuliSpriteRenderers[0].color = indicatorColor;
                else if(currentStimuliNum == "2")
                    StimuliSpriteRenderers[1].color = indicatorColor;
                else if (currentStimuliNum == "3")
                    StimuliSpriteRenderers[2].color = indicatorColor;
                else if (currentStimuliNum == "4")
                    StimuliSpriteRenderers[3].color = indicatorColor;
                else if (currentStimuliNum == "5")
                    StimuliSpriteRenderers[4].color = indicatorColor;

                yield return new WaitForSecondsRealtime(TimeBetweenTrial);

                //-----------------------------TimeBetweenTrial 끝


                //pause 후 시작시점에 secCount 새값 할당
                secCount = Time.time;

                //STARTING POINT    
                checker_1 = 0;
                checker_2 = 1;

                //numText 추가
                childText.SetActive(false);

                yield return new WaitForSeconds(0.01f); //0.01초 delay해주어야만 Update()의 한 프레임에서 캐치함\


                checker_1 = 1;
                checker_2 = 1;
            }

        }

        StartTrigger = null;
        EndTrigger = null;

    }

    IEnumerator CountDown()
    {
        //첫 트라이얼만 3초 쉬고 시작. secCount = 0 일때 스킵
        //secCount 0 넘고나서 부터는 앞에도 3초쉬고 뒤에서도 3초 쉬기
        //CommandStimuli만 해당되는 명령어
        if (gameObject.transform.root.name == "CommandStimuli")
        {
            if (secCount != 0)
            {
                yield return new WaitForSeconds(3f);
            }
        }

        CenterOfStimuli.fontSize = 170;
        CenterOfStimuli.text = "3";
        yield return new WaitForSeconds(1f);

        CenterOfStimuli.text = "2";
        yield return new WaitForSeconds(1f);

        CenterOfStimuli.text = "1";
        yield return new WaitForSeconds(1f);

        CenterOfStimuli.text = "";

    }

    IEnumerator revisedSwitching()
    {
        CenterOfStimuli.fontSize = 48;
        CenterOfStimuli.text = "잠시후\n시작됩니다";

        StartCoroutine(CountDown());

        //첫 트라이얼만 3초 더 쉬고 시작
        if (secCount == 0)
        {
                yield return new WaitForSeconds(3f);
        }
        else
        {
            yield return new WaitForSeconds(TimeBetweenTrial);
        }

        secCount = Time.time;

        //STARTING POINT    
        checker_1 = 0;
        checker_2 = 1;

        yield return new WaitForSeconds(0.01f); //0.01초 delay해주어야만 Update()의 한 프레임에서 캐치함


        checker_1 = 1;
        checker_2 = 1;

        while (true)
        {

            yield return StartCoroutine(WaitFor.Frames(FrameCount));

            GOtransform.localScale = Scales[currentScale];
            GOspriterenderer.color = Colors[currentScale];

 //실험용 생략
            //Icon.color = IconColors[currentScale];

            currentScale += 1;
            currentScale %= 2;

            tempTime = Time.time;

            if (currentScale == 1 && tempTime - secCount > TrialDuration )
            {
                //ENDING POINT
                checker_1 = 1;
                checker_2 = 0;

                yield return new WaitForSeconds(0.01f);


                // trial 사이의 pause
                checker_1 = 0;
                checker_2 = 0;

                StartCoroutine(CountDown());
                yield return new WaitForSecondsRealtime(TimeBetweenTrial);

                //pause 후 시작시점에 secCount 새값 할당
                secCount = Time.time;

                //STARTING POINT    
                checker_1 = 0;
                checker_2 = 1;

                yield return new WaitForSeconds(0.01f); //0.01초 delay해주어야만 Update()의 한 프레임에서 캐치함\


                checker_1 = 1;
                checker_2 = 1;
            }
        }
    }

    /*FRAME COUNT*/
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


    //선택된 자극 번호에 따라 화살표 자극이 가리키는 각도 할당
    void setArrowAngle()
    {
        if (currentStimuliNum == "1")
        {
            Arrow.transform.localRotation = Quaternion.Euler(0,0,43);
        }
        else if (currentStimuliNum == "2")
        {
            Arrow.transform.localRotation = Quaternion.Euler(0, 0, -43);
        }
        else if (currentStimuliNum == "3")
        {
            Arrow.transform.localRotation = Quaternion.Euler(0, 0, 100);
        }
        else if (currentStimuliNum == "4")
        {
            Arrow.transform.localRotation = Quaternion.Euler(0, 0, -100);
        }
        else if (currentStimuliNum == "5")
        {
            Arrow.transform.localRotation = Quaternion.Euler(0, 0, 180);
        }


    }

    ////선택된 자극 번호에 따라 start, end 트리거값 할당
    void assignTrigger()
    {
        
        if (currentStimuliNum == "1")
        {
            StartTrigger = StartTrigger_Stimuli1;
            EndTrigger = EndtartTrigger_Stimuli1;
        }
        else if (currentStimuliNum == "2")
        {
            StartTrigger = StartTrigger_Stimuli2;
            EndTrigger = EndTrigger_Stimuli2;
        }
        else if (currentStimuliNum == "3")
        {
            StartTrigger = StartTrigger_Stimuli3;
            EndTrigger = EndTrigger_Stimuli3;
        }
        else if (currentStimuliNum == "4")
        {
            StartTrigger = StartTrigger_Stimuli4;
            EndTrigger = EndTrigger_Stimuli4;
        }
        else if (currentStimuliNum == "5")
        {
            StartTrigger = StartTrigger_Stimuli5;
            EndTrigger = EndTrigger_Stimuli5;
        }
        else if (currentStimuliNum == "6")
        {
            StartTrigger = StartTrigger_Stimuli6;
            EndTrigger = EndTrigger_Stimuli6;
        }

    }

    /*트라이얼마다 랜덤한 숫자*/
    void shuffle(string[] numbers)
    {
        for (int t = 0; t < numbers.Length - 1; t++)
        {
            string tmp = numbers[t];
            int r = Random.Range(t, numbers.Length - 1);

            numbers[t] = numbers[r];
            numbers[r] = tmp;
        }
    }
}
