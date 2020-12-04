using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Cursor_State_off : MonoBehaviour
{
	public Main main;
	MeshRenderer circle;


	// Use this for initialization
	void Start()
	{
		main = GameObject.Find("MainControl").GetComponent<Main>();
		circle = GetComponent<MeshRenderer>();
	}

	// Update is called once per frame
	void Update()
	{
		if (main.isStartRay == true)
		{
			circle.enabled = false;
		}

		else
			circle.enabled = true;
	}

}
