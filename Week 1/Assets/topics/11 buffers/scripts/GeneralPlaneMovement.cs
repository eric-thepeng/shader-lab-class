using UnityEngine;

public class OscillatePositionEase : MonoBehaviour
{
    [SerializeField] private float amplitude = 3f; // The distance to oscillate (max x position)
    [SerializeField] private float frequency = 1f; // The speed of oscillation (cycles per second)

    private Vector3 initialPosition;

    void Start()
    {
        // Store the initial local position of the GameObject
        initialPosition = transform.localPosition;
    }

    void Update()
    {
        // Calculate the oscillation value using an eased curve
        float t = Mathf.Repeat(Time.time * frequency, 1f); // Normalized time in range [0, 1]
        float easedT = Mathf.PingPong(t * 2f, 1f);        // Make it go back and forth between 0 and 1
        float curveValue = Mathf.Cos(easedT * Mathf.PI);  // Create the cosine easing effect

        // Map the curve value to the amplitude (-3 to 3)
        float oscillation = curveValue * amplitude;

        // Update the local position while keeping y and z the same
        transform.localPosition = new Vector3(initialPosition.x + oscillation, initialPosition.y, initialPosition.z);
    }
}