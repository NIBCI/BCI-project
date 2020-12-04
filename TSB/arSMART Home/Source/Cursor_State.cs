using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Cursor_State : MonoBehaviour
{

	public Light lights;
	public Main main;


	// Use this for initialization
	void Start()
	{

		main = GameObject.Find("MainControl").GetComponent<Main>();

		lights = GetComponent<Light>();

	}

	// Update is called once per frame
	void Update()
	{

		if (main.isStartRay == true)
		{
			lights.range = 0;
		}

		else
			lights.range = 0.05f;

	}
}
