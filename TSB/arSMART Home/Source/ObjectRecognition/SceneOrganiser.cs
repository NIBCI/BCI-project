using System;
using System.Linq;
using UnityEngine;
using CustomVision;
using System.IO;
using System.Runtime.InteropServices.WindowsRuntime;

#if UNITY_WSA && !UNITY_EDITOR
using System.Threading.Tasks;
using Windows.Storage;
using Windows.Media;
using Windows.Media.Capture;
using Windows.Media.MediaProperties;
using Windows.Media.Capture.Frames;
using Windows.ApplicationModel.Core;
using Windows.Graphics.Imaging;
using Windows.UI.Xaml.Media.Imaging;
#endif

public class SceneOrganiser : MonoBehaviour
{
	public static SceneOrganiser Instance;

	public bool bFinalizeStart = false;
	public bool bCaptureStart = false;

	public PredictionModel prediction = null;

	float probabilityThreshold = 0.3f;

	TimeSpan predictEvery = TimeSpan.FromMilliseconds(50);  

#if UNITY_WSA && !UNITY_EDITOR
	MediaCapture MediaCapture;
#endif

	private void Awake()
	{
		Instance = this;
	}

	void Start()
	{
#if UNITY_WSA && !UNITY_EDITOR
		CreateMediaCapture();
		InitModel();
#else
		//Debug.Log("Does not work in player.");
#endif
	}

	public void Quitt()
	{
#if UNITY_WSA && !UNITY_EDITOR
		CoreApplication.Exit();
#else
		Application.Quit();
#endif
	}

#if UNITY_WSA && !UNITY_EDITOR
	private ObjectDetection _objectDetection;

	private async void InitModel()
	{
		_objectDetection = new ObjectDetection();
		await _objectDetection.Init();
	}

	private async Task LoadAndEvaluateModelAsync(VideoFrame videoFrame)
	{
		//Reset the components
		if (prediction != null)
			prediction = null;

		var result = await _objectDetection.PredictImageAsync(videoFrame);

		//When recognition is successful 
		if (result.Count != 0)
		{
            //성공
            if (result[0].Probability > probabilityThreshold)
		    {
			    prediction = result[0];

                ImageCapture.Instance.iState = 1;
			    //Debug.Log("result : " + prediction.TagName + prediction.Probability);						
		    }

		    //낮은 확률
		    else
		    {
                ImageCapture.Instance.iState = -1;
                //Debug.Log("low probablility : " + result[0].TagName + result[0].Probability);										
		    }			
		}

		//못찾음 
		else
		{
            ImageCapture.Instance.iState = -2;
            //Debug.Log("nothing");			
		}
			
		bFinalizeStart = true;
	}

	public async void CreateMediaCapture()
	{
		MediaCapture = new MediaCapture();
		MediaCaptureInitializationSettings settings = new MediaCaptureInitializationSettings();
		settings.StreamingCaptureMode = StreamingCaptureMode.Video;
		await MediaCapture.InitializeAsync(settings);

		CreateFrameReader();
	}

	private async void CreateFrameReader()
	{
		var frameSourceGroups = await MediaFrameSourceGroup.FindAllAsync();

		MediaFrameSourceGroup selectedGroup = null;
		MediaFrameSourceInfo colorSourceInfo = null;

		foreach (var sourceGroup in frameSourceGroups)
		{
			foreach (var sourceInfo in sourceGroup.SourceInfos)
			{
				if (sourceInfo.MediaStreamType == MediaStreamType.VideoPreview
					&& sourceInfo.SourceKind == MediaFrameSourceKind.Color)
				{
					colorSourceInfo = sourceInfo;
					break;
				}
			}

			if (colorSourceInfo != null)
			{
				selectedGroup = sourceGroup;
				break;
			}
		}

		var colorFrameSource = MediaCapture.FrameSources[colorSourceInfo.Id];
		var preferredFormat = colorFrameSource.SupportedFormats.Where(format =>
		{
			return format.Subtype == MediaEncodingSubtypes.Argb32;
		}).FirstOrDefault();

		var mediaFrameReader = await MediaCapture.CreateFrameReaderAsync(colorFrameSource);
		await mediaFrameReader.StartAsync();
		StartPullFrames(mediaFrameReader);
	}

	public void StartPullFrames(MediaFrameReader sender)
	{
		Task.Run(async () =>
		{
			for (; ; )
			{
				if (bCaptureStart)
				{
					bCaptureStart = false;

					MediaFrameReference frameReference = sender.TryAcquireLatestFrame();
					VideoFrame videoFrame = frameReference?.VideoMediaFrame?.GetVideoFrame();

                    #region 주 색상 추출
                    //SoftwareBitmap bitmap = videoFrame.SoftwareBitmap;
                    //byte[] bytes;
                    //WriteableBitmap newBitmap = new WriteableBitmap(bitmap.PixelWidth, bitmap.PixelHeight);
                    //bitmap.CopyToBuffer(newBitmap.PixelBuffer);
                    //using (Stream stream = newBitmap.PixelBuffer.AsStream())
                    //using (MemoryStream memoryStream = new MemoryStream())
                    //{
                    //    stream.CopyTo(memoryStream);
                    //    bytes = memoryStream.ToArray();
                    //}
                    //ImageCapture.Instance.ByteToTexture(bytes, bitmap.PixelWidth, bitmap.PixelHeight);
                    #endregion

                    if (videoFrame == null)
					{
                        ImageCapture.Instance.iState = -3;
                        //Debug.Log("No VideoFrame");

						bFinalizeStart = true;
						continue; //ignoring frame
					}

					if (videoFrame.Direct3DSurface == null)
					{
                        ImageCapture.Instance.iState = -3;
                        //Debug.Log("No D3DSurface");

						bFinalizeStart = true;
						continue; //ignoring frame
					}

					try
					{
						await LoadAndEvaluateModelAsync(videoFrame);
					}

					catch (Exception e)
					{
						//Debug.Log(e.Message);						
						bFinalizeStart = true;						
					}

                   
                }
                await Task.Delay(predictEvery);			
			}
		});
	}

#endif
}