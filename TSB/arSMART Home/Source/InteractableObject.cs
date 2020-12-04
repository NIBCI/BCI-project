using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InteractableObject : MonoBehaviour
{

	
	
	/// <summary>
	/// Called when iether the head or a controller is pointed at an object
	/// </summary>
	/// <param name="controller">Leave null if ray is coming from head</param>
	public virtual void RayEnter(RaycastHit hit)
	{
		//Empty, Overriden method only.
	}

	/// <summary>
	/// Called every frame the head or a controller is pointed at an object
	/// </summary>
	/// <param name="controller">Leave null if ray is coming from head</param>
	public virtual void RayStay(RaycastHit hit)
	{
		//Empty, Overriden method only.
	}

	/// <summary>
	/// Called when either the head or a controller leaves the object
	/// </summary>
	/// <param name="controller">Leave null if ray is coming from head</param>
	public virtual void RayExit()
	{
		//Empty, Overriden method only.
	}


	// Use this for initialization
	void Start()
	{

	}

	// Update is called once per frame
	void Update()
	{

	}
}
