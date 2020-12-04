using HoloToolkit.Unity;
using UnityEngine;
using UnityEngine.XR.WSA;

public class SpatialMappingg : MonoBehaviour
{
    /// <summary>
    /// Allows this class to behave like a singleton
    /// </summary>
    public static SpatialMappingg Instance;

    /// <summary>
    /// Used by the GazeCursor as a property with the Raycast call
    /// </summary>
    internal static int PhysicsRaycastMask;

    /// <summary>
    /// The layer to use for spatial mapping collisions
    /// </summary>
    internal int physicsLayer = 31;

    /// <summary>
    /// Creates environment colliders to work with physics
    /// </summary>
    private SpatialMappingCollider spatialMappingCollider;
    //private Collider[] colliders;

    private void Awake()
    {
        // Allows this instance to behave like a singleton
        Instance = this;
    }

    // Use this for initialization
    void Start()
    {
        // Initialize and configure the collider
        spatialMappingCollider = gameObject.GetComponent<SpatialMappingCollider>();
        spatialMappingCollider.surfaceParent = this.gameObject;
        spatialMappingCollider.freezeUpdates = false;
        spatialMappingCollider.layer = physicsLayer;

        // define the mask
        PhysicsRaycastMask = 1 << physicsLayer;

        // set the object as active one
        gameObject.SetActive(true);
    }
}
