using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using CustomVision;
using HoloToolkit.Unity;
using System.Text;
using System;
using System.IO;

public class Positioning : MonoBehaviour
{
    public static Positioning Instance;

    GameObject objIcon;
    Transform trsIcon;

    /// <summary>
    /// The cursor object attached to the Main Camera
    /// </summary>
    internal GameObject cursor;

    /// <summary>
    /// Current threshold accepted for displaying the label
    /// Reduce this value to display the recognition more often
    /// </summary>
    internal float probabilityThreshold = 0.5f;

    /// <summary>
    /// The quad object hosting the imposed image captured
    /// </summary>
    private GameObject quad;

    /// <summary>
    /// Renderer of the quad object
    /// </summary>
    internal Renderer quadRenderer;

    public string strTagName = "";
    public string strDeviceName = "";

    private void Awake()
    {
        Instance = this;
    }

    void Start()
    {
        trsIcon = cursor.transform;
    }

    /// <summary>
    /// Instantiate a Label in the appropriate location relative to the Main Camera.
    /// </summary>
    public void PlaceAnalysisLabel()
    {
        trsIcon.position = cursor.transform.position;
        trsIcon.rotation = transform.rotation;

        // Create a GameObject to which the texture can be applied
        quad = GameObject.CreatePrimitive(PrimitiveType.Quad);
        quadRenderer = quad.GetComponent<Renderer>() as Renderer;
        Material m = new Material(Shader.Find("Legacy Shaders/Transparent/Diffuse"));
        quadRenderer.material = m;

        // Here you can set the transparency of the quad. Useful for debugging
        float transparency = 0f;
        quadRenderer.material.color = new Color(1, 1, 1, transparency);

        // Set the position and scale of the quad depending on user position
        quad.transform.parent = transform;
        quad.transform.rotation = transform.rotation;

        // The quad is positioned slightly forward in front of the user
        quad.transform.localPosition = new Vector3(0.0f, 0.0f, 3.0f);

        // The quad scale as been set with the following value following experimentation,  
        // to allow the image on the quad to be as precisely imposed to the real world as possible
        quad.transform.localScale = new Vector3(3f, 1.65f, 1f);
        quad.transform.parent = null;
    }

    public IEnumerator FinaliseLabel(PredictionModel prediction)
    {
        string strName = prediction.TagName;
        if (strName.Contains("_Card"))
        {
            strName = strName.Replace("_Card", "");
        }

        objIcon = null;

        PlaceAnalysisLabel();

        quadRenderer = quad.GetComponent<Renderer>() as Renderer;
        Bounds quadBounds = quadRenderer.bounds;

        // Position the label as close as possible to the Bounding Box of the prediction 
        // At this point it will not consider depth
        //trsIcon.parent = quad.transform;
        //trsIcon.localPosition = CalculateBoundingBoxPosition(quadBounds, prediction.BoundingBox);
        //trsIcon.parent = null;
        //objIcon = MatchIcon(strName);
        objIcon = ImageCapture.Instance.transform.parent.gameObject;

        ////// Cast a ray from the user's head to the currently placed label, it should hit the object detected by the Service.
        //// At that point it will reposition the label where the ray HL sensor collides with the object,
        //// (using the HL spatial tracking)	
        Vector3 headPosition = Camera.main.transform.position;
        RaycastHit objHitInfo;
        Vector3 objDirection = trsIcon.position;
        if (Physics.Raycast(headPosition, objDirection, out objHitInfo, 30.0f, SpatialMappingg.PhysicsRaycastMask))
        {
            //trsIcon.position = objHitInfo.point;
        }
        //else Debug.Log("No Cursor");

        objIcon.transform.position = trsIcon.position;
        objIcon.transform.rotation = transform.rotation;

        yield return null;
    }

    /// <summary>
    /// This method hosts a series of calculations to determine the position 
    /// of the Bounding Box on the quad created in the real world
    /// by using the Bounding Box received back alongside the Best Prediction
    /// </summary>
    public Vector3 CalculateBoundingBoxPosition(Bounds b, BoundingBox boundingBox)
    {
        //Debug.Log($"BB: left {boundingBox.left}, top {boundingBox.top}, width {boundingBox.width}, height {boundingBox.height}");	

        double centerFromLeft = boundingBox.Left + (boundingBox.Width / 2);
        double centerFromTop = boundingBox.Top + (boundingBox.Height / 2);
        //Debug.Log($"BB CenterFromLeft {centerFromLeft}, CenterFromTop {centerFromTop}");

        double quadWidth = b.size.normalized.x;
        double quadHeight = b.size.normalized.y;
        //Debug.Log($"Quad Width {b.size.normalized.x}, Quad Height {b.size.normalized.y}");

        double normalisedPos_X = (quadWidth * centerFromLeft) - (quadWidth / 2);
        double normalisedPos_Y = (quadHeight * centerFromTop) - (quadHeight / 2);

        return new Vector3((float)normalisedPos_X, (float)normalisedPos_Y, 0);
    }

    private GameObject MatchIcon(string strPageName)
    {
        GameObject result = null;

        foreach (GameObject page in PageManager.Instance.pages)
        {
            if (page.name.Equals("Page_" + strPageName))
            {
                result = page;
                return result;
            }
        }

        return null;
    }
}
