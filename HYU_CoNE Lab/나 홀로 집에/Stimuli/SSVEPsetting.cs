using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SSVEPsetting : MonoBehaviour {

    //public int TrialCount;
    public float TrialDuration;
    public float TimeBetweenTrial;

    public Vector3[] Scales;
    public Color[] Colors;
    public Color[] CommandIconColors;

    private void Awake()
    {
        Star_1.Scales = Scales;
        Star_1.Colors = Colors;
        Star_1.IconColors = CommandIconColors;

        Star_1.TrialDuration = TrialDuration; 
        Star_1.TimeBetweenTrial = TimeBetweenTrial;
    }

}
