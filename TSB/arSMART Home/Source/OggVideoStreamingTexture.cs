using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OggVideoStreamingTexture : MonoBehaviour
{
    private static OggVideoStreamingTexture _instance;
    public static OggVideoStreamingTexture Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = FindObjectOfType<OggVideoStreamingTexture>();
                if (!_instance)
                {
                    //Debug.Log("Fail");
                }
            }
            return _instance;
        }
    }

    public string oggVeideoURL01;
    public string oggVeideoURL02;
    public GameObject GameobjectForVideoTexture;

    public MovieTexture movieTexture01;
    public MovieTexture movieTexture02;

    public GameObject objScreen;
    public int strMode;

    public GameObject objPlay01;
    public GameObject objPlay02;

    // Use this for initialization
    void Start()
    {
        objScreen = this.gameObject.transform.Find("Plane").gameObject;
        objPlay01 = this.gameObject.transform.Find("CCTV1#Play").transform.GetChild(0).gameObject;
        objPlay02 = this.gameObject.transform.Find("CCTV2#Play").transform.GetChild(0).gameObject;
        oggVeideoURL01 = "http://10.177.71.110:8181/stream";
        oggVeideoURL02 = "http://10.177.71.110:8282/stream";
        ///StreamPlayVideoAsTexture();
        InitSteaming();

        objScreen.SetActive(false);
    }

    public void FixedUpdate()
    {
        strMode = Main.Instance.deviceNumber;

        //InitSteaming();

        switch (strMode)
        {
            case 1:
                PlayStreaming(movieTexture01, strMode);
                break;

            case 2:
                PlayStreaming(movieTexture02, strMode);
                break;

            default:
                break;
        }
    }

    public void InitSteaming()
    {
        WWW videoStreamer01 = new WWW(oggVeideoURL01);
        WWW videoStreamer02 = new WWW(oggVeideoURL02);

        movieTexture01 = videoStreamer01.GetMovieTexture();
        movieTexture02 = videoStreamer02.GetMovieTexture();
    }

    public void SetScreen(bool isOn)
    {
        if (isOn.Equals(false))
        {
            if (movieTexture01)
                movieTexture01.Stop();

            if (movieTexture02)
                movieTexture02.Stop();
        }

        if (objScreen)
        {
            objScreen.SetActive(isOn);
        }

        switch (strMode)
        {
            case 1:
                CheckPlay(movieTexture01, isOn);
                break;

            case 2:
                CheckPlay(movieTexture02, isOn);
                break;

            default:
                break;
        }
    }

    public void PlayStreaming(MovieTexture texture, int deviceIndex)
    {
        if (texture == null)
        {
            
            return;
        }

        if (!texture.isReadyToPlay)
        {

            return;
        }

        if (objScreen.activeInHierarchy.Equals(false))
        {
            return;
        }

        if (Main.Instance.Status_CCTV[deviceIndex - 1].isStream)
        {
            try
            {
                if (texture.isPlaying)
                    return;

                GameobjectForVideoTexture.GetComponent<Renderer>().material.mainTexture = texture;
                texture.Play();
            }
            catch (Exception e)
            {
                Main.Instance.UDP.UDP_Send(e.ToString());
                texture.Stop();
            }
        }

        else
            return;
    }

    public void PlayStreaming(int deviceIndex)
    {
        MovieTexture movieTexture = null;

        switch (deviceIndex)
        {
            case 1:
                movieTexture = movieTexture01;
                break;

            case 2:
                movieTexture = movieTexture02;
                break;

            default:
                break;
        }

        if (movieTexture == null)
            return;

        if (!movieTexture.isReadyToPlay)
            return;

        if (objScreen.activeInHierarchy.Equals(false))
            return;

        try
        {
            if (movieTexture.isPlaying)
                return;

            GameobjectForVideoTexture.GetComponent<Renderer>().material.mainTexture = movieTexture;
            movieTexture.Play();
        }
        catch
        {
            movieTexture.Stop();
        }

    }

    public void CheckPlay(MovieTexture texture, bool isOn)
    {
        if (isOn.Equals(true))
        {
            GameobjectForVideoTexture.GetComponent<Renderer>().material.mainTexture = texture;
            texture.Play();
        }

        else
            texture.Stop();
    }

    //   public void StreamPlayVideoAsTexture()
    //   {
    //       StartCoroutine(StartStream(oggVeideoURL));
    //   }

    //   protected IEnumerator StartStream(string url)
    //{
    //	MovieTexture movieTexture;

    //	WWW videoStreamer = new WWW(url);
    //	movieTexture = videoStreamer.GetMovieTexture();
    //	while (!movieTexture.isReadyToPlay)
    //	{
    //		//yield return 0;
    //		yield return new WaitForSeconds(.5f);
    //	}
    //	GameobjectForVideoTexture.GetComponent<Renderer>().material.mainTexture = movieTexture;
    //	movieTexture.Play();
    //}
}
