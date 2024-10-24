using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoRotation : MonoBehaviour
{

    public float rotationSpeed = 30f; // Degrees per second
    public Vector3 rotationAxis = Vector3.right;
    
    void Update()
    {
        // Rotate the object around its local X axis at rotationSpeed degrees per second
        transform.Rotate(rotationAxis * rotationSpeed * Time.deltaTime);
    }
}
