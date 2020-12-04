using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UNIST_Sequence : MonoBehaviour
{
	public BCI_UDP UDP;
	public Main main;

	public static bool isOn;
	public float frequnecyTime = 0.015f;
	

	// for Training
	private float waitTime = 1f;
	//private bool startPoint = false;

	

	// Use this for initialization
	void Start()
	{
		UDP = GameObject.Find("UDP").GetComponent<BCI_UDP>();
		main = GameObject.Find("MainControl").GetComponent<Main>();
	}

	// Update is called once per frame
	void Update()
	{

	}
}
